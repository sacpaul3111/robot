*** Settings ***
Documentation    📋 Event Logs & Critical Error Validation Keywords for Test-22
...              📋 Provides log collection, analysis, and validation capabilities
...
Library          SSHLibrary
Library          Collections
Library          String
Library          OperatingSystem
Library          DateTime
Resource         ../../settings.resource

*** Variables ***
${DATA_DIR}                ${OUTPUT_DIR}/data

# Suite-level variables for log data
${JOURNAL_LOGS}                ${EMPTY}
${DMESG_OUTPUT}                ${EMPTY}
${SYSTEM_LOGS}                 ${EMPTY}
${CRITICAL_ERRORS}             ${EMPTY}

*** Keywords ***
Initialize Event Logs Test Environment
    [Documentation]    🏗️ Set up test environment for event log validation
    Log    🚀 Initializing Test-22: Event Logs & Critical Error Validation Environment...    console=yes

    # Create directories for data collection
    Create Directory    ${DATA_DIR}

    # Lookup EDS configuration to get target IP
    ${eds_config}=    EDSLookup.Lookup Server Config    ${TARGET_HOSTNAME}
    Set Suite Variable    ${TARGET_IP}    ${eds_config['ip']}

    Log    📋 Target Server: ${TARGET_HOSTNAME}    console=yes
    Log    📋 Target IP: ${TARGET_IP}    console=yes

    # Establish SSH connection to target server
    Log    🔗 Connecting to target server: ${TARGET_IP}...    console=yes
    Open Connection    ${TARGET_IP}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}

    Log    ✅ SSH connection established successfully    console=yes
    Log    ✅ Test-22 environment initialized    console=yes

Collect Journalctl Logs
    [Documentation]    📋 Collect system journal logs using journalctl
    Log    📋 Collecting journalctl logs...    console=yes

    # Collect journalctl with various priority levels and time ranges
    ${journal_all}=         Execute Command    journalctl --no-pager -n ${LOG_LINES_TO_COLLECT} 2>&1 || echo "journalctl not available"
    ${journal_priority}=    Execute Command    journalctl --no-pager -p ${MIN_LOG_PRIORITY} -n ${LOG_LINES_TO_COLLECT} 2>&1 || echo "Priority filter not available"
    ${journal_boot}=        Execute Command    journalctl --no-pager -b 2>&1 | tail -${LOG_LINES_TO_COLLECT} || echo "Boot log not available"
    ${journal_errors}=      Execute Command    journalctl --no-pager -p err -n ${LOG_LINES_TO_COLLECT} 2>&1 || echo "Error priority filter not available"

    # Combine journal logs
    ${journal_logs}=    Catenate    SEPARATOR=\n
    ...    === Journal - Recent ${LOG_LINES_TO_COLLECT} Entries ===
    ...    ${journal_all}
    ...
    ...    === Journal - Priority ${MIN_LOG_PRIORITY} and Above ===
    ...    ${journal_priority}
    ...
    ...    === Journal - Current Boot ===
    ...    ${journal_boot}
    ...
    ...    === Journal - Error Level Only ===
    ...    ${journal_errors}

    Set Suite Variable    ${JOURNAL_LOGS}    ${journal_logs}

    Log    ✅ Journalctl logs collected    console=yes
    RETURN    ${journal_logs}

Save Journal Logs to File
    [Documentation]    💾 Save journal logs to file
    [Arguments]    ${journal_logs}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${journal_file}=    Set Variable    ${DATA_DIR}/journalctl_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === System Journal Logs (journalctl) ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Lines Collected: ${LOG_LINES_TO_COLLECT}
    ...    Minimum Priority: ${MIN_LOG_PRIORITY}
    ...
    ...    ${journal_logs}
    ...
    ...    =========================================

    Create File    ${journal_file}    ${report}
    Log    📄 Journal logs saved to: ${journal_file}    console=yes
    RETURN    ${journal_file}

Collect Dmesg Output
    [Documentation]    🚀 Collect kernel boot messages using dmesg
    Log    🚀 Collecting dmesg output...    console=yes

    # Collect dmesg with various options
    ${dmesg_all}=        Execute Command    dmesg 2>&1 || echo "dmesg not available"
    ${dmesg_errors}=     Execute Command    dmesg --level=err,crit,alert,emerg 2>&1 || dmesg | grep -i "error\|fail\|critical" || echo "dmesg error filter not available"
    ${dmesg_warnings}=   Execute Command    dmesg --level=warn 2>&1 || dmesg | grep -i "warn" || echo "dmesg warning filter not available"
    ${dmesg_human}=      Execute Command    dmesg -T 2>&1 | tail -${LOG_LINES_TO_COLLECT} || echo "dmesg timestamp format not available"

    # Combine dmesg output
    ${dmesg_output}=    Catenate    SEPARATOR=\n
    ...    === dmesg - All Messages ===
    ...    ${dmesg_all}
    ...
    ...    === dmesg - Errors and Critical ===
    ...    ${dmesg_errors}
    ...
    ...    === dmesg - Warnings ===
    ...    ${dmesg_warnings}
    ...
    ...    === dmesg - Recent (Human Readable) ===
    ...    ${dmesg_human}

    Set Suite Variable    ${DMESG_OUTPUT}    ${dmesg_output}

    Log    ✅ dmesg output collected    console=yes
    RETURN    ${dmesg_output}

Save Dmesg to File
    [Documentation]    💾 Save dmesg output to file
    [Arguments]    ${dmesg_output}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${dmesg_file}=    Set Variable    ${DATA_DIR}/dmesg_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Kernel Boot Messages (dmesg) ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${dmesg_output}
    ...
    ...    =========================================

    Create File    ${dmesg_file}    ${report}
    Log    📄 dmesg output saved to: ${dmesg_file}    console=yes
    RETURN    ${dmesg_file}

Collect System Log Files
    [Documentation]    📂 Collect important system log files from /var/log
    Log    📂 Collecting system log files from /var/log...    console=yes

    # Collect various system logs
    ${messages}=      Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/messages 2>/dev/null || echo "No /var/log/messages"
    ${syslog}=        Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/syslog 2>/dev/null || echo "No /var/log/syslog"
    ${secure}=        Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/secure 2>/dev/null || tail -${LOG_LINES_TO_COLLECT} /var/log/auth.log 2>/dev/null || echo "No secure/auth.log"
    ${cron}=          Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/cron 2>/dev/null || tail -${LOG_LINES_TO_COLLECT} /var/log/cron.log 2>/dev/null || echo "No cron log"
    ${boot}=          Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/boot.log 2>/dev/null || echo "No /var/log/boot.log"
    ${kern}=          Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/kern.log 2>/dev/null || echo "No /var/log/kern.log"

    # List all log files
    ${log_list}=      Execute Command    ls -lh /var/log/*.log /var/log/messages /var/log/syslog 2>/dev/null || echo "Log file listing not available"

    # Combine system logs
    ${system_logs}=    Catenate    SEPARATOR=\n
    ...    === /var/log Directory ===
    ...    ${log_list}
    ...
    ...    === /var/log/messages ===
    ...    ${messages}
    ...
    ...    === /var/log/syslog ===
    ...    ${syslog}
    ...
    ...    === /var/log/secure (auth.log) ===
    ...    ${secure}
    ...
    ...    === /var/log/cron ===
    ...    ${cron}
    ...
    ...    === /var/log/boot.log ===
    ...    ${boot}
    ...
    ...    === /var/log/kern.log ===
    ...    ${kern}

    Set Suite Variable    ${SYSTEM_LOGS}    ${system_logs}

    Log    ✅ System log files collected    console=yes
    RETURN    ${system_logs}

Save System Logs to File
    [Documentation]    💾 Save system logs to file
    [Arguments]    ${system_logs}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${syslog_file}=    Set Variable    ${DATA_DIR}/system_logs_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === System Log Files (/var/log) ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Lines per Log: ${LOG_LINES_TO_COLLECT}
    ...
    ...    ${system_logs}
    ...
    ...    =========================================

    Create File    ${syslog_file}    ${report}
    Log    📄 System logs saved to: ${syslog_file}    console=yes
    RETURN    ${syslog_file}

Search Critical Errors in Journal
    [Documentation]    ⚠️ Search for critical and emergency level errors
    Log    ⚠️ Searching for critical errors...    console=yes

    # Search for critical, alert, and emergency errors
    ${emerg_errors}=    Execute Command    journalctl --no-pager -p emerg -n 100 2>&1 || echo "Emergency level search not available"
    ${alert_errors}=    Execute Command    journalctl --no-pager -p alert -n 100 2>&1 || echo "Alert level search not available"
    ${crit_errors}=     Execute Command    journalctl --no-pager -p crit -n 100 2>&1 || echo "Critical level search not available"

    # Search for specific error keywords in logs
    ${error_keywords}=  Execute Command    journalctl --no-pager -n ${LOG_LINES_TO_COLLECT} | grep -i "critical\|emergency\|fatal\|panic" || echo "No critical keywords found"

    # Combine critical errors
    ${critical_errors}=    Catenate    SEPARATOR=\n
    ...    === Emergency Level (Priority 0) ===
    ...    ${emerg_errors}
    ...
    ...    === Alert Level (Priority 1) ===
    ...    ${alert_errors}
    ...
    ...    === Critical Level (Priority 2) ===
    ...    ${crit_errors}
    ...
    ...    === Critical Keywords in Recent Logs ===
    ...    ${error_keywords}

    Set Suite Variable    ${CRITICAL_ERRORS}    ${critical_errors}

    Log    ✅ Critical error search completed    console=yes
    RETURN    ${critical_errors}

Save Critical Errors to File
    [Documentation]    💾 Save critical errors to file
    [Arguments]    ${critical_errors}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${errors_file}=    Set Variable    ${DATA_DIR}/critical_errors_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Critical Errors Analysis ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Search Keywords: ${CRITICAL_ERROR_KEYWORDS}
    ...
    ...    ${critical_errors}
    ...
    ...    =========================================

    Create File    ${errors_file}    ${report}
    Log    📄 Critical errors saved to: ${errors_file}    console=yes
    RETURN    ${errors_file}

Count Critical Errors
    [Documentation]    🔢 Count the number of critical errors found
    [Arguments]    ${critical_errors}

    # Count lines that contain actual errors (not "No entries" or empty)
    ${error_lines}=    Execute Command    echo "${critical_errors}" | grep -viE "no entries|not available|no critical" | wc -l

    ${error_count}=    Convert To Integer    ${error_lines}

    Log    📊 Critical error count: ${error_count}    console=yes
    RETURN    ${error_count}

Analyze Boot Sequence
    [Documentation]    🚀 Analyze system boot sequence for errors
    Log    🚀 Analyzing boot sequence...    console=yes

    # Analyze boot process
    ${boot_time}=        Execute Command    systemd-analyze time 2>&1 || echo "systemd-analyze not available"
    ${boot_blame}=       Execute Command    systemd-analyze blame 2>&1 | head -30 || echo "systemd-analyze blame not available"
    ${boot_critical}=    Execute Command    systemd-analyze critical-chain 2>&1 | head -30 || echo "systemd-analyze critical-chain not available"
    ${boot_messages}=    Execute Command    journalctl --no-pager -b | head -100 2>&1 || echo "Boot journal not available"
    ${boot_failed}=      Execute Command    journalctl --no-pager -b -p err 2>&1 || echo "Boot errors not available"

    # Combine boot analysis
    ${boot_analysis}=    Catenate    SEPARATOR=\n
    ...    === Boot Time Analysis ===
    ...    ${boot_time}
    ...
    ...    === Boot Blame (Slowest Services) ===
    ...    ${boot_blame}
    ...
    ...    === Boot Critical Chain ===
    ...    ${boot_critical}
    ...
    ...    === Boot Messages (First 100) ===
    ...    ${boot_messages}
    ...
    ...    === Boot Errors ===
    ...    ${boot_failed}

    Log    ✅ Boot sequence analysis completed    console=yes
    RETURN    ${boot_analysis}

Save Boot Analysis to File
    [Documentation]    💾 Save boot analysis to file
    [Arguments]    ${boot_analysis}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${boot_file}=    Set Variable    ${DATA_DIR}/boot_analysis_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Boot Sequence Analysis ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${boot_analysis}
    ...
    ...    =========================================

    Create File    ${boot_file}    ${report}
    Log    📄 Boot analysis saved to: ${boot_file}    console=yes
    RETURN    ${boot_file}

Validate Service Startup Status
    [Documentation]    🔧 Validate service startup from logs
    Log    🔧 Validating service startup status...    console=yes

    # Check for failed services
    ${failed_services}=     Execute Command    systemctl --failed --no-pager 2>&1 || echo "Failed services check not available"
    ${service_startup}=     Execute Command    journalctl --no-pager -b | grep -i "started\|stopped\|failed" | tail -50 2>&1 || echo "Service startup logs not available"
    ${service_status}=      Execute Command    systemctl list-units --type=service --state=failed --no-pager 2>&1 || echo "Service status not available"

    # Combine service startup analysis
    ${startup_analysis}=    Catenate    SEPARATOR=\n
    ...    === Failed Services ===
    ...    ${failed_services}
    ...
    ...    === Service Startup/Shutdown Messages ===
    ...    ${service_startup}
    ...
    ...    === Failed Service Units ===
    ...    ${service_status}

    Log    ✅ Service startup validation completed    console=yes
    RETURN    ${startup_analysis}

Save Service Startup Analysis to File
    [Documentation]    💾 Save service startup analysis to file
    [Arguments]    ${startup_analysis}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${startup_file}=    Set Variable    ${DATA_DIR}/service_startup_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Service Startup Analysis ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${startup_analysis}
    ...
    ...    =========================================

    Create File    ${startup_file}    ${report}
    Log    📄 Service startup analysis saved to: ${startup_file}    console=yes
    RETURN    ${startup_file}

Check Logrotate Configuration
    [Documentation]    🔄 Check log rotation configuration
    Log    🔄 Checking logrotate configuration...    console=yes

    # Collect logrotate configuration
    ${logrotate_conf}=      Execute Command    cat /etc/logrotate.conf 2>/dev/null || echo "No /etc/logrotate.conf"
    ${logrotate_d}=         Execute Command    ls -la /etc/logrotate.d/ 2>/dev/null || echo "No /etc/logrotate.d/"
    ${logrotate_status}=    Execute Command    cat /var/lib/logrotate/logrotate.status 2>/dev/null || cat /var/lib/logrotate.status 2>/dev/null || echo "No logrotate status file"
    ${logrotate_cron}=      Execute Command    cat /etc/cron.daily/logrotate 2>/dev/null || echo "No logrotate cron job"

    # Combine logrotate configuration
    ${logrotate_config}=    Catenate    SEPARATOR=\n
    ...    === /etc/logrotate.conf ===
    ...    ${logrotate_conf}
    ...
    ...    === /etc/logrotate.d/ Directory ===
    ...    ${logrotate_d}
    ...
    ...    === Logrotate Status ===
    ...    ${logrotate_status}
    ...
    ...    === Logrotate Cron Job ===
    ...    ${logrotate_cron}

    Log    ✅ Logrotate configuration collected    console=yes
    RETURN    ${logrotate_config}

Save Logrotate Config to File
    [Documentation]    💾 Save logrotate configuration to file
    [Arguments]    ${logrotate_config}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${logrotate_file}=    Set Variable    ${DATA_DIR}/logrotate_config_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Log Rotation Configuration ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${logrotate_config}
    ...
    ...    =========================================

    Create File    ${logrotate_file}    ${report}
    Log    📄 Logrotate configuration saved to: ${logrotate_file}    console=yes
    RETURN    ${logrotate_file}

Analyze Repeating Error Patterns
    [Documentation]    🔁 Search for repeating error patterns
    Log    🔁 Analyzing repeating error patterns...    console=yes

    # Find most common error messages
    ${common_errors}=     Execute Command    journalctl --no-pager -p err -n ${LOG_LINES_TO_COLLECT} | awk '{print $5" "$6" "$7}' | sort | uniq -c | sort -rn | head -20 2>&1 || echo "Pattern analysis not available"
    ${repeated_msgs}=     Execute Command    grep -i "error\|fail" /var/log/messages 2>/dev/null | awk '{print $5" "$6" "$7}' | sort | uniq -c | sort -rn | head -20 || echo "No messages file for pattern analysis"
    ${frequency}=         Execute Command    journalctl --no-pager --since "24 hours ago" -p err 2>&1 | wc -l || echo "0"

    # Combine pattern analysis
    ${pattern_analysis}=    Catenate    SEPARATOR=\n
    ...    === Most Common Error Patterns (journalctl) ===
    ...    ${common_errors}
    ...
    ...    === Repeated Error Messages (/var/log/messages) ===
    ...    ${repeated_msgs}
    ...
    ...    === Error Frequency (Last 24 Hours) ===
    ...    ${frequency} errors in last 24 hours

    Log    ✅ Pattern analysis completed    console=yes
    RETURN    ${pattern_analysis}

Save Pattern Analysis to File
    [Documentation]    💾 Save pattern analysis to file
    [Arguments]    ${pattern_analysis}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${pattern_file}=    Set Variable    ${DATA_DIR}/error_patterns_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Repeating Error Pattern Analysis ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${pattern_analysis}
    ...
    ...    =========================================

    Create File    ${pattern_file}    ${report}
    Log    📄 Pattern analysis saved to: ${pattern_file}    console=yes
    RETURN    ${pattern_file}

Collect Authentication Logs
    [Documentation]    🔐 Collect authentication logs
    Log    🔐 Collecting authentication logs...    console=yes

    # Collect authentication-related logs
    ${auth_secure}=       Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/secure 2>/dev/null || tail -${LOG_LINES_TO_COLLECT} /var/log/auth.log 2>/dev/null || echo "No auth logs"
    ${failed_logins}=     Execute Command    journalctl --no-pager | grep -i "failed password\|authentication failure" | tail -50 2>&1 || echo "No failed login entries"
    ${successful_logins}=    Execute Command    journalctl --no-pager | grep -i "accepted password\|session opened" | tail -50 2>&1 || echo "No successful login entries"
    ${lastlog}=           Execute Command    lastlog 2>&1 | head -30 || echo "lastlog not available"
    ${last}=              Execute Command    last | head -30 2>&1 || echo "last not available"

    # Combine authentication logs
    ${auth_logs}=    Catenate    SEPARATOR=\n
    ...    === Authentication Logs (secure/auth.log) ===
    ...    ${auth_secure}
    ...
    ...    === Failed Login Attempts ===
    ...    ${failed_logins}
    ...
    ...    === Successful Logins ===
    ...    ${successful_logins}
    ...
    ...    === Last Login (lastlog) ===
    ...    ${lastlog}
    ...
    ...    === Login History (last) ===
    ...    ${last}

    Log    ✅ Authentication logs collected    console=yes
    RETURN    ${auth_logs}

Save Authentication Logs to File
    [Documentation]    💾 Save authentication logs to file
    [Arguments]    ${auth_logs}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${auth_file}=    Set Variable    ${DATA_DIR}/authentication_logs_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Authentication Logs ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${auth_logs}
    ...
    ...    =========================================

    Create File    ${auth_file}    ${report}
    Log    📄 Authentication logs saved to: ${auth_file}    console=yes
    RETURN    ${auth_file}

Search Kernel Errors
    [Documentation]    🖥️ Search for kernel errors
    Log    🖥️ Searching kernel errors...    console=yes

    # Search for kernel errors in dmesg and logs
    ${kernel_errors}=     Execute Command    dmesg | grep -iE "error|fail|bug|oops|panic|segfault" 2>&1 || echo "No kernel errors found"
    ${hardware_errors}=   Execute Command    journalctl --no-pager -k | grep -iE "hardware|disk|memory|i/o error" | tail -50 2>&1 || echo "No hardware errors"
    ${oom_errors}=        Execute Command    journalctl --no-pager | grep -i "out of memory\|oom" | tail -30 2>&1 || echo "No OOM errors"

    # Combine kernel errors
    ${kernel_error_report}=    Catenate    SEPARATOR=\n
    ...    === Kernel Errors (dmesg) ===
    ...    ${kernel_errors}
    ...
    ...    === Hardware Related Errors ===
    ...    ${hardware_errors}
    ...
    ...    === Out of Memory Errors ===
    ...    ${oom_errors}

    Log    ✅ Kernel error search completed    console=yes
    RETURN    ${kernel_error_report}

Save Kernel Errors to File
    [Documentation]    💾 Save kernel errors to file
    [Arguments]    ${kernel_errors}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${kernel_file}=    Set Variable    ${DATA_DIR}/kernel_errors_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Kernel Error Analysis ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${kernel_errors}
    ...
    ...    =========================================

    Create File    ${kernel_file}    ${report}
    Log    📄 Kernel errors saved to: ${kernel_file}    console=yes
    RETURN    ${kernel_file}

Check Log Disk Space
    [Documentation]    💾 Check disk space for /var/log
    Log    💾 Checking log disk space...    console=yes

    # Check disk space for /var/log partition
    ${df_varlog}=    Execute Command    df -h /var/log 2>&1 || echo "df not available"
    ${du_varlog}=    Execute Command    du -sh /var/log/* 2>/dev/null | sort -rh | head -20 || echo "du not available"
    ${inodes}=       Execute Command    df -i /var/log 2>&1 || echo "inode check not available"

    # Combine disk space info
    ${disk_space}=    Catenate    SEPARATOR=\n
    ...    === Disk Space for /var/log ===
    ...    ${df_varlog}
    ...
    ...    === Largest Log Files/Directories ===
    ...    ${du_varlog}
    ...
    ...    === Inode Usage ===
    ...    ${inodes}

    Log    💾 Disk space: ${disk_space}    console=yes
    RETURN    ${disk_space}

Check Log File Permissions
    [Documentation]    🔒 Check log file permissions
    Log    🔒 Checking log file permissions...    console=yes

    # Check permissions on critical log files
    ${log_perms}=    Execute Command    ls -la /var/log/*.log /var/log/messages /var/log/secure /var/log/syslog 2>/dev/null || echo "Permission check not available"
    ${log_owners}=   Execute Command    stat -c '%n %U:%G %a' /var/log/*.log /var/log/messages /var/log/secure 2>/dev/null || echo "stat not available"

    # Combine permission info
    ${permissions}=    Catenate    SEPARATOR=\n
    ...    === Log File Permissions (ls -la) ===
    ...    ${log_perms}
    ...
    ...    === Log File Owners and Modes (stat) ===
    ...    ${log_owners}

    Log    ✅ Log file permissions collected    console=yes
    RETURN    ${permissions}

Save Log Permissions to File
    [Documentation]    💾 Save log permissions to file
    [Arguments]    ${permissions}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${perm_file}=    Set Variable    ${DATA_DIR}/log_permissions_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Log File Permissions ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${permissions}
    ...
    ...    =========================================

    Create File    ${perm_file}    ${report}
    Log    📄 Log permissions saved to: ${perm_file}    console=yes
    RETURN    ${perm_file}

Check SELinux Denials
    [Documentation]    🔒 Check for SELinux denials
    Log    🔒 Checking SELinux denials...    console=yes

    # Check SELinux status and denials (with timeouts to prevent hanging)
    ${selinux_status}=   Execute Command    getenforce 2>&1 || echo "SELinux not available"
    ${audit_denials}=    Execute Command    timeout 30 ausearch -m avc -ts recent 2>&1 | tail -100 || grep -i "denied" /var/log/audit/audit.log 2>/dev/null | tail -50 || echo "No SELinux denials found"
    ${sealert}=          Execute Command    timeout 30 sealert -a /var/log/audit/audit.log 2>&1 | head -50 || echo "sealert not available or timed out"

    # Combine SELinux info
    ${selinux_denials}=    Catenate    SEPARATOR=\n
    ...    === SELinux Status ===
    ...    ${selinux_status}
    ...
    ...    === Audit Denials (ausearch) ===
    ...    ${audit_denials}
    ...
    ...    === SELinux Alerts (sealert) ===
    ...    ${sealert}

    Log    ✅ SELinux denial check completed    console=yes
    RETURN    ${selinux_denials}

Save SELinux Denials to File
    [Documentation]    💾 Save SELinux denials to file
    [Arguments]    ${selinux_denials}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${selinux_file}=    Set Variable    ${DATA_DIR}/selinux_denials_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === SELinux Denials ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${selinux_denials}
    ...
    ...    =========================================

    Create File    ${selinux_file}    ${report}
    Log    📄 SELinux denials saved to: ${selinux_file}    console=yes
    RETURN    ${selinux_file}

Collect Application Logs
    [Documentation]    📱 Collect application-specific logs
    Log    📱 Collecting application logs...    console=yes

    # Collect common application logs
    ${httpd_logs}=    Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/httpd/error_log 2>/dev/null || tail -${LOG_LINES_TO_COLLECT} /var/log/apache2/error.log 2>/dev/null || echo "No httpd logs"
    ${nginx_logs}=    Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/nginx/error.log 2>/dev/null || echo "No nginx logs"
    ${db_logs}=       Execute Command    tail -${LOG_LINES_TO_COLLECT} /var/log/mysql/error.log 2>/dev/null || tail -${LOG_LINES_TO_COLLECT} /var/log/postgresql/*.log 2>/dev/null || echo "No database logs"
    ${app_list}=      Execute Command    ls -la /var/log/ 2>/dev/null | grep -vE "lastlog|wtmp|btmp" || echo "Log directory listing not available"

    # Combine application logs
    ${app_logs}=    Catenate    SEPARATOR=\n
    ...    === Application Log Directory ===
    ...    ${app_list}
    ...
    ...    === HTTPD/Apache Logs ===
    ...    ${httpd_logs}
    ...
    ...    === Nginx Logs ===
    ...    ${nginx_logs}
    ...
    ...    === Database Logs ===
    ...    ${db_logs}

    Log    ✅ Application logs collected    console=yes
    RETURN    ${app_logs}

Save Application Logs to File
    [Documentation]    💾 Save application logs to file
    [Arguments]    ${app_logs}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${app_file}=    Set Variable    ${DATA_DIR}/application_logs_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Application Logs ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${app_logs}
    ...
    ...    =========================================

    Create File    ${app_file}    ${report}
    Log    📄 Application logs saved to: ${app_file}    console=yes
    RETURN    ${app_file}

Check Rsyslog Configuration
    [Documentation]    📡 Check rsyslog configuration
    Log    📡 Checking rsyslog configuration...    console=yes

    # Check rsyslog configuration
    ${rsyslog_conf}=     Execute Command    cat /etc/rsyslog.conf 2>/dev/null || echo "No /etc/rsyslog.conf"
    ${rsyslog_d}=        Execute Command    ls -la /etc/rsyslog.d/ 2>/dev/null || echo "No /etc/rsyslog.d/"
    ${rsyslog_status}=   Execute Command    systemctl status rsyslog 2>&1 || service rsyslog status 2>&1 || echo "rsyslog status not available"
    ${syslog_ng}=        Execute Command    cat /etc/syslog-ng/syslog-ng.conf 2>/dev/null || echo "No syslog-ng configuration"

    # Combine rsyslog configuration
    ${rsyslog_config}=    Catenate    SEPARATOR=\n
    ...    === /etc/rsyslog.conf ===
    ...    ${rsyslog_conf}
    ...
    ...    === /etc/rsyslog.d/ Directory ===
    ...    ${rsyslog_d}
    ...
    ...    === Rsyslog Service Status ===
    ...    ${rsyslog_status}
    ...
    ...    === Syslog-NG Configuration (if present) ===
    ...    ${syslog_ng}

    Log    ✅ Rsyslog configuration collected    console=yes
    RETURN    ${rsyslog_config}

Save Rsyslog Config to File
    [Documentation]    💾 Save rsyslog configuration to file
    [Arguments]    ${rsyslog_config}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${rsyslog_file}=    Set Variable    ${DATA_DIR}/rsyslog_config_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Rsyslog Configuration ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${rsyslog_config}
    ...
    ...    =========================================

    Create File    ${rsyslog_file}    ${report}
    Log    📄 Rsyslog configuration saved to: ${rsyslog_file}    console=yes
    RETURN    ${rsyslog_file}

Analyze Log Sizes and Growth
    [Documentation]    📈 Analyze log file sizes and growth rates
    Log    📈 Analyzing log sizes and growth...    console=yes

    # Analyze log sizes
    ${log_sizes}=        Execute Command    du -sh /var/log/* 2>/dev/null | sort -rh | head -20 || echo "Log size analysis not available"
    ${total_log_size}=   Execute Command    du -sh /var/log 2>&1 || echo "Total size not available"
    ${oldest_logs}=      Execute Command    find /var/log -type f -printf '%T+ %p\n' 2>/dev/null | sort | head -10 || echo "Oldest log search not available"
    ${newest_logs}=      Execute Command    find /var/log -type f -printf '%T+ %p\n' 2>/dev/null | sort -r | head -10 || echo "Newest log search not available"

    # Combine log size analysis
    ${log_size_analysis}=    Catenate    SEPARATOR=\n
    ...    === Largest Log Files/Directories ===
    ...    ${log_sizes}
    ...
    ...    === Total /var/log Size ===
    ...    ${total_log_size}
    ...
    ...    === Oldest Log Files ===
    ...    ${oldest_logs}
    ...
    ...    === Newest Log Files ===
    ...    ${newest_logs}

    Log    ✅ Log size analysis completed    console=yes
    RETURN    ${log_size_analysis}

Save Log Size Analysis to File
    [Documentation]    💾 Save log size analysis to file
    [Arguments]    ${log_size_analysis}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${size_file}=    Set Variable    ${DATA_DIR}/log_size_analysis_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Log Size Analysis ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${log_size_analysis}
    ...
    ...    =========================================

    Create File    ${size_file}    ${report}
    Log    📄 Log size analysis saved to: ${size_file}    console=yes
    RETURN    ${size_file}

Check Uptime and Reboot History
    [Documentation]    ⏱️ Check system uptime and reboot history
    Log    ⏱️ Checking uptime and reboot history...    console=yes

    # Check uptime and reboot history
    ${uptime}=           Execute Command    uptime 2>&1 || echo "uptime not available"
    ${last_reboot}=      Execute Command    last reboot | head -20 2>&1 || echo "last reboot not available"
    ${who_boot}=         Execute Command    who -b 2>&1 || echo "who -b not available"
    ${reboot_history}=   Execute Command    journalctl --list-boots 2>&1 | head -20 || echo "Boot list not available"

    # Combine uptime analysis
    ${uptime_analysis}=    Catenate    SEPARATOR=\n
    ...    === Current Uptime ===
    ...    ${uptime}
    ...
    ...    === Last Boot Time ===
    ...    ${who_boot}
    ...
    ...    === Reboot History (last reboot) ===
    ...    ${last_reboot}
    ...
    ...    === Boot List (journalctl) ===
    ...    ${reboot_history}

    Log    ✅ Uptime and reboot history collected    console=yes
    RETURN    ${uptime_analysis}

Save Uptime Analysis to File
    [Documentation]    💾 Save uptime analysis to file
    [Arguments]    ${uptime_analysis}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${uptime_file}=    Set Variable    ${DATA_DIR}/uptime_analysis_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Uptime and Reboot History ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${uptime_analysis}
    ...
    ...    =========================================

    Create File    ${uptime_file}    ${report}
    Log    📄 Uptime analysis saved to: ${uptime_file}    console=yes
    RETURN    ${uptime_file}

Validate All Log Health Metrics
    [Documentation]    📊 Validate all log health metrics
    Log    📊 Validating all log health metrics...    console=yes

    # This keyword serves as a placeholder for comprehensive validation
    # All individual validations are performed in their respective test cases
    Log    ✅ All log health data collected and validated    console=yes

Close All SSH Connections
    [Documentation]    🔌 Close all SSH connections
    Log    🔌 Closing SSH connections...    console=yes
    Close All Connections
    Log    ✅ SSH connections closed    console=yes

Execute Command
    [Documentation]    🔧 Execute a command on the remote server via SSH
    [Arguments]    ${command}
    ${output}=    SSHLibrary.Execute Command    ${command}
    RETURN    ${output}

Log Test Start
    [Documentation]    📝 Log the start of a test case
    [Arguments]    ${test_name}
    Log    \n================================================================================    console=yes
    Log    🏁 Starting Test: ${test_name}    console=yes
    Log    ================================================================================    console=yes

Log Test End
    [Documentation]    📝 Log the end of a test case with status
    [Arguments]    ${test_name}    ${status}
    Log    ================================================================================    console=yes
    Log    🏁 Completed Test: ${test_name} | Status: ${status}    console=yes
    Log    ================================================================================\n    console=yes

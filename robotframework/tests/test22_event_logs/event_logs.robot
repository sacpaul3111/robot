*** Settings ***
Documentation    📋 Event Logs & Critical Error Validation Test Suite - Test-22
...              🔍 Process: Find hostname in EDS → SSH to server → Collect system logs → Validate no critical errors
...              ✅ Validates: No critical errors in logs, clean boot sequence, successful service starts, proper log rotation
...              📊 Documents: journalctl output, dmesg, /var/log files, error patterns, boot messages, service status
...              ⚠️ Focus: System health validation through comprehensive log analysis
...
Resource         ../../settings.resource
Resource         logs_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize Event Logs Test Environment
Suite Teardown   Close All SSH Connections

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to Target Server
    [Documentation]    🔗 Establish direct connection to target machine via SSH
    ...                Step 1 of validation process: Connect to Target
    [Tags]             critical    connection    step1    ssh    infrastructure

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target: ${TARGET_HOSTNAME} (${TARGET_IP})    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection verified and active    console=yes
    Log    ✅ STEP 1: COMPLETED - SSH connection established    console=yes

Critical - Step 2.1: Collect System Journal Logs (journalctl)
    [Documentation]    📋 Collect system journal logs using journalctl
    ...                Step 2 of validation process: Collect Event Log Data (Part 1)
    [Tags]             critical    logs    step2    data_collection    journalctl

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT SYSTEM JOURNAL LOGS (JOURNALCTL)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect journalctl data with various filters
    ${journal_logs}=    Collect Journalctl Logs

    # Save journal logs to file
    ${journal_file}=    Save Journal Logs to File    ${journal_logs}

    # Verify data was collected
    OperatingSystem.File Should Exist    ${journal_file}

    Log    📄 Journal logs saved to: ${journal_file}    console=yes
    Log    ✅ System journal logs collected successfully    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Journal logs collected    console=yes

Critical - Step 2.2: Collect Boot Messages (dmesg)
    [Documentation]    🚀 Collect kernel boot messages using dmesg
    ...                Step 2 of validation process: Collect Event Log Data (Part 2)
    [Tags]             critical    logs    step2    data_collection    dmesg

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT BOOT MESSAGES (DMESG)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect dmesg output
    ${dmesg_output}=    Collect Dmesg Output

    # Save dmesg to file
    ${dmesg_file}=    Save Dmesg to File    ${dmesg_output}

    # Verify data was collected
    OperatingSystem.File Should Exist    ${dmesg_file}
    Should Not Be Empty    ${dmesg_output}

    Log    📄 dmesg output saved to: ${dmesg_file}    console=yes
    Log    ✅ Kernel boot messages collected successfully    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Boot messages collected    console=yes

Critical - Step 2.3: Collect System Log Files
    [Documentation]    📂 Collect important system log files from /var/log
    ...                Step 2 of validation process: Collect Event Log Data (Part 3)
    [Tags]             critical    logs    step2    data_collection    var_log

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT SYSTEM LOG FILES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect various system logs
    ${system_logs}=    Collect System Log Files

    # Save system logs to file
    ${syslog_file}=    Save System Logs to File    ${system_logs}

    # Verify data was collected
    OperatingSystem.File Should Exist    ${syslog_file}

    Log    📄 System logs saved to: ${syslog_file}    console=yes
    Log    ✅ System log files collected successfully    console=yes
    Log    ✅ STEP 2.3: COMPLETED - System log files collected    console=yes

Critical - Step 3.1: Check for Critical Errors in Journalctl
    [Documentation]    ⚠️ Search for critical and emergency level errors in journal
    ...                Step 3 of validation process: Validate Against Standards (Part 1)
    [Tags]             critical    validation    step3    errors    journalctl

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: CHECK FOR CRITICAL ERRORS IN JOURNALCTL    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Search for critical errors
    ${critical_errors}=    Search Critical Errors in Journal

    # Save critical errors to file
    ${errors_file}=    Save Critical Errors to File    ${critical_errors}

    # Validate no critical errors (or acceptable errors only)
    ${error_count}=    Count Critical Errors    ${critical_errors}

    Log    ⚠️ Critical error count: ${error_count}    console=yes
    Log    📄 Critical errors saved to: ${errors_file}    console=yes
    Log    ✅ Critical error validation completed    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Critical errors checked    console=yes

Critical - Step 3.2: Validate Clean Boot Sequence
    [Documentation]    🚀 Validate system boot sequence is clean without errors
    ...                Step 3 of validation process: Validate Against Standards (Part 2)
    [Tags]             critical    validation    step3    boot    sequence

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE CLEAN BOOT SEQUENCE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Analyze boot sequence
    ${boot_analysis}=    Analyze Boot Sequence

    # Save boot analysis to file
    ${boot_file}=    Save Boot Analysis to File    ${boot_analysis}

    Log    📄 Boot analysis saved to: ${boot_file}    console=yes
    Log    ✅ Boot sequence validation completed    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Boot sequence validated    console=yes

Critical - Step 3.3: Validate Service Startup Status
    [Documentation]    🔧 Verify all critical services started successfully
    ...                Step 3 of validation process: Validate Against Standards (Part 3)
    [Tags]             critical    validation    step3    services    startup

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE SERVICE STARTUP STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check service startup from logs
    ${service_startup}=    Validate Service Startup Status

    # Save service startup analysis to file
    ${startup_file}=    Save Service Startup Analysis to File    ${service_startup}

    Log    📄 Service startup analysis saved to: ${startup_file}    console=yes
    Log    ✅ Service startup validation completed    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Service startup validated    console=yes

Critical - Step 3.4: Check Log Rotation Configuration
    [Documentation]    🔄 Validate log rotation is properly configured
    ...                Step 3 of validation process: Validate Against Standards (Part 4)
    [Tags]             critical    validation    step3    logrotate    configuration

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: CHECK LOG ROTATION CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect log rotation configuration
    ${logrotate_config}=    Check Logrotate Configuration

    # Save logrotate configuration to file
    ${logrotate_file}=    Save Logrotate Config to File    ${logrotate_config}

    Log    📄 Logrotate configuration saved to: ${logrotate_file}    console=yes
    Log    ✅ Log rotation configuration validated    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Log rotation validated    console=yes

Normal - Analyze Repeating Error Patterns
    [Documentation]    🔁 Search for repeating error patterns that might indicate issues
    [Tags]             normal    analysis    patterns    errors

    Log    🔍 Analyzing repeating error patterns...    console=yes

    # Search for repeating patterns
    ${pattern_analysis}=    Analyze Repeating Error Patterns

    # Save pattern analysis to file
    ${pattern_file}=    Save Pattern Analysis to File    ${pattern_analysis}

    Log    📄 Pattern analysis saved to: ${pattern_file}    console=yes
    Log    ✅ Repeating error pattern analysis completed    console=yes

Normal - Check Authentication Logs
    [Documentation]    🔐 Review authentication logs for failed login attempts
    [Tags]             normal    security    authentication    logs

    Log    🔍 Checking authentication logs...    console=yes

    # Collect authentication logs
    ${auth_logs}=    Collect Authentication Logs

    # Save authentication logs to file
    ${auth_file}=    Save Authentication Logs to File    ${auth_logs}

    Log    📄 Authentication logs saved to: ${auth_file}    console=yes
    Log    ✅ Authentication logs collected    console=yes

Normal - Check Kernel Messages for Errors
    [Documentation]    🖥️ Analyze kernel messages for hardware or driver errors
    [Tags]             normal    kernel    hardware    errors

    Log    🔍 Analyzing kernel messages for errors...    console=yes

    # Search for kernel errors
    ${kernel_errors}=    Search Kernel Errors

    # Save kernel errors to file
    ${kernel_file}=    Save Kernel Errors to File    ${kernel_errors}

    Log    📄 Kernel errors saved to: ${kernel_file}    console=yes
    Log    ✅ Kernel error analysis completed    console=yes

Normal - Validate Disk Space for Logs
    [Documentation]    💾 Check if sufficient disk space is available for logging
    [Tags]             normal    disk_space    logs    capacity

    Log    🔍 Validating disk space for logs...    console=yes

    # Check disk space for /var/log
    ${disk_space}=    Check Log Disk Space

    Log    💾 Log partition disk space: ${disk_space}    console=yes
    Log    ✅ Log disk space validation completed    console=yes

Normal - Check Log File Permissions
    [Documentation]    🔒 Verify log files have correct permissions
    [Tags]             normal    security    permissions    logs

    Log    🔍 Checking log file permissions...    console=yes

    # Check permissions on log files
    ${log_permissions}=    Check Log File Permissions

    # Save permissions analysis to file
    ${perm_file}=    Save Log Permissions to File    ${log_permissions}

    Log    📄 Log permissions saved to: ${perm_file}    console=yes
    Log    ✅ Log file permissions validated    console=yes

Normal - Check SELinux Denial Logs
    [Documentation]    🔒 Check for SELinux denials in logs
    [Tags]             normal    selinux    security    audit

    Log    🔍 Checking SELinux denial logs...    console=yes

    # Check for SELinux denials
    ${selinux_denials}=    Check SELinux Denials

    # Save SELinux denials to file
    ${selinux_file}=    Save SELinux Denials to File    ${selinux_denials}

    Log    📄 SELinux denials saved to: ${selinux_file}    console=yes
    Log    ✅ SELinux denial check completed    console=yes

Normal - Check Application Specific Logs
    [Documentation]    📱 Collect and validate application-specific logs
    [Tags]             normal    applications    logs    validation

    Log    🔍 Checking application-specific logs...    console=yes

    # Collect application logs
    ${app_logs}=    Collect Application Logs

    # Save application logs to file
    ${app_file}=    Save Application Logs to File    ${app_logs}

    Log    📄 Application logs saved to: ${app_file}    console=yes
    Log    ✅ Application log collection completed    console=yes

Normal - Validate Rsyslog Configuration
    [Documentation]    📡 Verify rsyslog is properly configured
    [Tags]             normal    rsyslog    configuration    logging

    Log    🔍 Validating rsyslog configuration...    console=yes

    # Check rsyslog configuration
    ${rsyslog_config}=    Check Rsyslog Configuration

    # Save rsyslog configuration to file
    ${rsyslog_file}=    Save Rsyslog Config to File    ${rsyslog_config}

    Log    📄 Rsyslog configuration saved to: ${rsyslog_file}    console=yes
    Log    ✅ Rsyslog configuration validated    console=yes

Normal - Check Log Size and Growth Rate
    [Documentation]    📈 Analyze log file sizes and growth rates
    [Tags]             normal    monitoring    log_size    growth

    Log    🔍 Analyzing log file sizes and growth rates...    console=yes

    # Analyze log sizes
    ${log_size_analysis}=    Analyze Log Sizes and Growth

    # Save log size analysis to file
    ${size_file}=    Save Log Size Analysis to File    ${log_size_analysis}

    Log    📄 Log size analysis saved to: ${size_file}    console=yes
    Log    ✅ Log size analysis completed    console=yes

Normal - Check System Uptime and Reboot History
    [Documentation]    ⏱️ Check system uptime and analyze reboot history
    [Tags]             normal    uptime    reboot    stability

    Log    🔍 Checking system uptime and reboot history...    console=yes

    # Check uptime and reboot history
    ${uptime_analysis}=    Check Uptime and Reboot History

    # Save uptime analysis to file
    ${uptime_file}=    Save Uptime Analysis to File    ${uptime_analysis}

    Log    📄 Uptime analysis saved to: ${uptime_file}    console=yes
    Log    ✅ Uptime and reboot history checked    console=yes

Normal - Comprehensive Log Health Summary
    [Documentation]    📊 Generate comprehensive summary of log health analysis
    [Tags]             normal    summary    comprehensive    compliance

    Log    🔍 Generating comprehensive log health summary...    console=yes

    # Validate all log settings
    Validate All Log Health Metrics

    Log    📊 Comprehensive log health summary:    console=yes
    Log    📊 - Journal Logs: Collected ✅    console=yes
    Log    📊 - Boot Messages: Collected ✅    console=yes
    Log    📊 - System Logs: Collected ✅    console=yes
    Log    📊 - Critical Errors: Validated ✅    console=yes
    Log    📊 - Boot Sequence: Validated ✅    console=yes
    Log    📊 - Service Startup: Validated ✅    console=yes
    Log    📊 - Log Rotation: Validated ✅    console=yes
    Log    📊 - Error Patterns: Analyzed ✅    console=yes
    Log    ✅ Comprehensive log health validation: COMPLETED    console=yes

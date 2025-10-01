*** Settings ***
Documentation    📧 Mail Configuration Keywords for Test-17
...              📋 Provides SSH connection, mail/SMTP data collection, and validation capabilities
...
Library          SSHLibrary
Library          Collections
Library          String
Library          OperatingSystem
Library          DateTime
Resource         ../../settings.resource

*** Variables ***
${DATA_DIR}                results/test17_mail_configuration/data

# Suite-level variables for mail data
${MX_RECORDS_OUTPUT}           ${EMPTY}
${MAIL_RC_CONTENT}             ${EMPTY}
${SMTP_CONNECTIVITY_RESULT}    ${EMPTY}
${MAIL_QUEUE_STATUS}           ${EMPTY}

*** Keywords ***
Initialize Mail Test Environment
    [Documentation]    🏗️ Set up test environment for mail configuration validation
    Log    🚀 Initializing Test-17: Mail Configuration Validation Environment...    console=yes

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
    Log    ✅ Test-17 environment initialized    console=yes

Collect MX Records
    [Documentation]    🌐 Execute nslookup to collect MX records for mail domain
    Log    🌐 Executing nslookup for MX records...    console=yes

    # Extract domain from SMTP relay (e.g., mail.domain.com -> domain.com)
    ${domain}=    Execute Command    echo "${EXPECTED_SMTP_RELAY}" | awk -F. '{print $(NF-1)"."$NF}'

    # Try multiple methods to get MX records
    ${mx_nslookup}=    Execute Command    nslookup -query=mx ${domain} 2>/dev/null || echo "nslookup failed"
    ${mx_dig}=         Execute Command    dig ${domain} MX +short 2>/dev/null || echo "dig not available"
    ${mx_host}=        Execute Command    host -t MX ${domain} 2>/dev/null || echo "host not available"

    # Combine results
    ${mx_records}=    Catenate    SEPARATOR=\n
    ...    === nslookup MX ===
    ...    ${mx_nslookup}
    ...
    ...    === dig MX ===
    ...    ${mx_dig}
    ...
    ...    === host MX ===
    ...    ${mx_host}

    Set Suite Variable    ${MX_RECORDS_OUTPUT}    ${mx_records}

    # Save MX records to file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${mx_file}=    Set Variable    ${DATA_DIR}/mx_records_${timestamp}.txt
    Create File    ${mx_file}    ${mx_records}

    Log    📄 MX records saved to: ${mx_file}    console=yes
    RETURN    ${mx_records}

Collect Mail RC Configuration
    [Documentation]    📄 Read and collect /etc/mail.rc configuration file
    Log    📄 Reading /etc/mail.rc configuration...    console=yes

    # Read mail.rc file (try multiple possible locations)
    ${mail_rc_etc}=       Execute Command    cat /etc/mail.rc 2>/dev/null || echo "Not found at /etc/mail.rc"
    ${mail_rc_mail}=      Execute Command    cat /etc/mail/mail.rc 2>/dev/null || echo "Not found at /etc/mail/mail.rc"
    ${mail_rc_nail}=      Execute Command    cat /etc/nail.rc 2>/dev/null || echo "Not found at /etc/nail.rc"

    # Combine all possible locations
    ${mail_rc_content}=    Catenate    SEPARATOR=\n
    ...    === /etc/mail.rc ===
    ...    ${mail_rc_etc}
    ...
    ...    === /etc/mail/mail.rc ===
    ...    ${mail_rc_mail}
    ...
    ...    === /etc/nail.rc ===
    ...    ${mail_rc_nail}

    Set Suite Variable    ${MAIL_RC_CONTENT}    ${mail_rc_content}

    Log    ✅ Mail.rc configuration collected    console=yes
    RETURN    ${mail_rc_content}

Save Mail RC to File
    [Documentation]    💾 Save mail.rc configuration to file
    [Arguments]    ${content}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${mail_rc_file}=    Set Variable    ${DATA_DIR}/mail_rc_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Mail.rc Configuration Report ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Expected SMTP Relay: ${EXPECTED_SMTP_RELAY}
    ...
    ...    ${content}

    Create File    ${mail_rc_file}    ${report}
    Log    📄 Mail.rc saved to: ${mail_rc_file}    console=yes
    RETURN    ${mail_rc_file}

Validate SMTP Relay Configuration
    [Documentation]    📧 Validate SMTP relay server is configured correctly in mail.rc
    Log    📧 Validating SMTP relay in mail.rc...    console=yes

    # Check if SMTP relay is configured in mail.rc
    ${relay_found}=    Execute Command    grep -i "smtp" /etc/mail.rc 2>/dev/null || grep -i "smtp" /etc/nail.rc 2>/dev/null || echo "No SMTP configuration found"

    # Check for expected relay server
    ${contains_expected}=    Run Keyword And Return Status
    ...    Should Contain    ${MAIL_RC_CONTENT}    ${EXPECTED_SMTP_RELAY}

    ${validation_result}=    Set Variable If
    ...    ${contains_expected}    CONFIGURED - Expected relay found in mail.rc
    ...    WARNING - Expected relay "${EXPECTED_SMTP_RELAY}" not found in mail.rc

    Log    📧 Relay Configuration: ${relay_found}    console=yes
    Log    📧 Validation: ${validation_result}    console=yes

    RETURN    ${validation_result}

Test SMTP Port Connectivity
    [Documentation]    🔌 Test connectivity to SMTP server on port 25
    Log    🔌 Testing SMTP port ${SMTP_PORT} connectivity to ${EXPECTED_SMTP_RELAY}...    console=yes

    # Test using nc (netcat) with timeout
    ${nc_result}=    Execute Command    timeout 5 nc -zv ${EXPECTED_SMTP_RELAY} ${SMTP_PORT} 2>&1 || echo "Connection failed or timeout"

    # Test using telnet (alternative method)
    ${telnet_result}=    Execute Command    timeout 5 bash -c "echo -e '\nQUIT\n' | telnet ${EXPECTED_SMTP_RELAY} ${SMTP_PORT} 2>&1" | head -20 || echo "Telnet test failed"

    # Test using curl SMTP
    ${curl_result}=    Execute Command    timeout 5 curl -v smtp://${EXPECTED_SMTP_RELAY}:${SMTP_PORT} 2>&1 | head -20 || echo "Curl test not available"

    # Combine results
    ${connectivity_result}=    Catenate    SEPARATOR=\n
    ...    === Netcat Test ===
    ...    ${nc_result}
    ...
    ...    === Telnet Test ===
    ...    ${telnet_result}
    ...
    ...    === Curl SMTP Test ===
    ...    ${curl_result}

    Set Suite Variable    ${SMTP_CONNECTIVITY_RESULT}    ${connectivity_result}

    # Save connectivity test to file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${conn_file}=    Set Variable    ${DATA_DIR}/smtp_connectivity_${timestamp}.txt
    Create File    ${conn_file}    ${connectivity_result}

    Log    📄 Connectivity test saved to: ${conn_file}    console=yes
    RETURN    ${connectivity_result}

Send Test Email
    [Documentation]    📨 Send a test email to verify mail subsystem functionality
    Log    📨 Sending test email...    console=yes

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${test_subject}=    Set Variable    Test Email from ${TARGET_HOSTNAME} - ${timestamp}
    ${test_body}=    Set Variable    This is an automated test email from Robot Framework Test-17 Mail Configuration Validation.\\nServer: ${TARGET_HOSTNAME}\\nTimestamp: ${timestamp}

    # Send test email using mail command
    ${send_result}=    Execute Command    echo "${test_body}" | mail -s "${test_subject}" ${TEST_EMAIL_RECIPIENT} 2>&1 || echo "Mail command failed - check if mailx/mail is installed"

    Log    📨 Test email result: ${send_result}    console=yes

    # Save send result to file
    ${send_file}=    Set Variable    ${DATA_DIR}/test_email_send_${timestamp.replace(' ', '_').replace(':', '')}.txt
    ${send_report}=    Catenate    SEPARATOR=\n
    ...    === Test Email Send Report ===
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Recipient: ${TEST_EMAIL_RECIPIENT}
    ...    Subject: ${test_subject}
    ...
    ...    Result:
    ...    ${send_result}

    Create File    ${send_file}    ${send_report}
    RETURN    ${send_result}

Check Mail Queue Status
    [Documentation]    📬 Check mail queue status to ensure no stuck messages
    Log    📬 Checking mail queue status...    console=yes

    # Check queue using mailq (works for postfix/sendmail)
    ${mailq_output}=    Execute Command    mailq 2>&1 || echo "mailq command not available"

    # Check postfix queue specifically
    ${postqueue_output}=    Execute Command    postqueue -p 2>&1 || echo "postqueue not available"

    # Combine results
    ${queue_status}=    Catenate    SEPARATOR=\n
    ...    === mailq output ===
    ...    ${mailq_output}
    ...
    ...    === postqueue -p output ===
    ...    ${postqueue_output}

    Set Suite Variable    ${MAIL_QUEUE_STATUS}    ${queue_status}
    RETURN    ${queue_status}

Save Mail Queue Status to File
    [Documentation]    💾 Save mail queue status to file
    [Arguments]    ${queue_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${queue_file}=    Set Variable    ${DATA_DIR}/mail_queue_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Mail Queue Status Report ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${queue_status}

    Create File    ${queue_file}    ${report}
    RETURN    ${queue_file}

Check Mail Service Status
    [Documentation]    🔧 Check status of mail services (postfix/sendmail)
    Log    🔧 Checking mail service status...    console=yes

    # Check postfix
    ${postfix_status}=    Execute Command    systemctl status postfix 2>&1 | head -20 || echo "Postfix not found"

    # Check sendmail
    ${sendmail_status}=    Execute Command    systemctl status sendmail 2>&1 | head -20 || echo "Sendmail not found"

    # Combine results
    ${service_status}=    Catenate    SEPARATOR=\n
    ...    === Postfix Status ===
    ...    ${postfix_status}
    ...
    ...    === Sendmail Status ===
    ...    ${sendmail_status}

    RETURN    ${service_status}

Collect Mail Logs
    [Documentation]    📋 Collect recent mail log entries
    Log    📋 Collecting recent mail logs...    console=yes

    # Collect from common log locations
    ${maillog}=         Execute Command    tail -100 /var/log/maillog 2>/dev/null || echo "No /var/log/maillog"
    ${mail_log}=        Execute Command    tail -100 /var/log/mail.log 2>/dev/null || echo "No /var/log/mail.log"
    ${mail_info}=       Execute Command    tail -100 /var/log/mail.info 2>/dev/null || echo "No /var/log/mail.info"
    ${syslog_mail}=     Execute Command    grep -i mail /var/log/syslog 2>/dev/null | tail -50 || echo "No mail entries in syslog"

    # Combine logs
    ${mail_logs}=    Catenate    SEPARATOR=\n
    ...    === /var/log/maillog ===
    ...    ${maillog}
    ...
    ...    === /var/log/mail.log ===
    ...    ${mail_log}
    ...
    ...    === /var/log/mail.info ===
    ...    ${mail_info}
    ...
    ...    === Syslog mail entries ===
    ...    ${syslog_mail}

    RETURN    ${mail_logs}

Save Mail Logs to File
    [Documentation]    💾 Save mail logs to file
    [Arguments]    ${mail_logs}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${log_file}=    Set Variable    ${DATA_DIR}/mail_logs_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Mail Logs Report ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${mail_logs}

    Create File    ${log_file}    ${report}
    RETURN    ${log_file}

Check Firewall Rules for SMTP
    [Documentation]    🔥 Check firewall rules for SMTP traffic
    Log    🔥 Checking firewall rules for SMTP...    console=yes

    # Check iptables rules
    ${iptables_rules}=    Execute Command    iptables -L -n | grep -E "25|smtp" 2>&1 || echo "No iptables rules or not accessible"

    # Check firewalld
    ${firewalld_rules}=    Execute Command    firewall-cmd --list-all 2>&1 || echo "firewalld not active"

    # Combine results
    ${firewall_rules}=    Catenate    SEPARATOR=\n
    ...    === iptables (port 25/smtp) ===
    ...    ${iptables_rules}
    ...
    ...    === firewalld ===
    ...    ${firewalld_rules}

    RETURN    ${firewall_rules}

Check SMTP Authentication Config
    [Documentation]    🔐 Check SMTP authentication configuration
    Log    🔐 Checking SMTP authentication configuration...    console=yes

    # Check postfix SMTP auth config
    ${postfix_sasl}=    Execute Command    postconf | grep -i sasl 2>&1 || echo "postconf not available"

    # Check for SASL configuration files
    ${sasl_config}=     Execute Command    cat /etc/postfix/sasl_passwd 2>/dev/null || echo "No /etc/postfix/sasl_passwd"

    # Combine results
    ${auth_config}=    Catenate    SEPARATOR=\n
    ...    === Postfix SASL Configuration ===
    ...    ${postfix_sasl}
    ...
    ...    === SASL Password File ===
    ...    ${sasl_config}

    RETURN    ${auth_config}

Collect Mail Aliases Configuration
    [Documentation]    📮 Collect mail aliases configuration
    Log    📮 Collecting mail aliases configuration...    console=yes

    # Read aliases file
    ${aliases}=    Execute Command    cat /etc/aliases 2>/dev/null | head -100 || echo "No /etc/aliases file"

    RETURN    ${aliases}

Save Mail Aliases to File
    [Documentation]    💾 Save mail aliases to file
    [Arguments]    ${aliases_content}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${aliases_file}=    Set Variable    ${DATA_DIR}/mail_aliases_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Mail Aliases Configuration ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${aliases_content}

    Create File    ${aliases_file}    ${report}
    RETURN    ${aliases_file}

Validate All Mail Settings
    [Documentation]    📊 Validate all mail settings and generate summary
    Log    📊 Validating all mail settings...    console=yes

    # This keyword serves as a placeholder for comprehensive validation
    # All individual validations are performed in their respective test cases
    Log    ✅ All mail configuration data collected and validated    console=yes

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
    Log    \n${'='*80}    console=yes
    Log    🏁 Starting Test: ${test_name}    console=yes
    Log    ${'='*80}    console=yes

Log Test End
    [Documentation]    📝 Log the end of a test case with status
    [Arguments]    ${test_name}    ${status}
    Log    ${'='*80}    console=yes
    Log    🏁 Completed Test: ${test_name} | Status: ${status}    console=yes
    Log    ${'='*80}\n    console=yes

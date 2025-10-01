*** Settings ***
Documentation    📧 Mail Configuration Validation Test Suite - Test-17
...              🔍 Process: Find hostname in EDS → SSH to server → Collect mail/SMTP configuration → Validate relay settings
...              ✅ Validates: SMTP relay server (mail.domain.com), port connectivity, mail.rc configuration, test email delivery
...              📊 Documents: MX records, SMTP connectivity, mail queue status, relay configuration
...              ⚠️ Note: This test validates mail configuration if required in project scope
...
Resource         ../../settings.resource
Resource         mail_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize Mail Test Environment
Suite Teardown   Close All SSH Connections

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Connect to Target Server
    [Documentation]    🔗 Establish direct connection to target machine via SSH
    [Tags]             critical    connection    ssh    infrastructure

    Log    🔍 Verifying SSH connection to target server...    console=yes
    Log    📋 Target: ${TARGET_HOSTNAME} (${TARGET_IP})    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection verified and active    console=yes

Critical - Collect DNS MX Records
    [Documentation]    🌐 Execute nslookup to collect MX records for mail domain
    [Tags]             critical    dns    mx_records    mail

    Log    🔍 Collecting DNS MX records for mail domain...    console=yes
    Log    📋 Expected SMTP Relay: ${EXPECTED_SMTP_RELAY}    console=yes

    # Collect MX records
    ${mx_records}=    Collect MX Records

    # Verify MX data was collected
    Should Not Be Empty    ${mx_records}

    Log    🌐 MX Records: ${mx_records}    console=yes
    Log    ✅ DNS MX records collected successfully    console=yes

Critical - Collect Mail.rc Configuration
    [Documentation]    📄 Read and collect /etc/mail.rc configuration file
    [Tags]             critical    config    mail_rc    smtp

    Log    🔍 Collecting /etc/mail.rc configuration...    console=yes

    # Collect mail.rc configuration
    ${mail_rc_content}=    Collect Mail RC Configuration

    # Save mail.rc to file
    ${mail_rc_file}=    Save Mail RC to File    ${mail_rc_content}

    Log    📄 Mail.rc configuration saved to: ${mail_rc_file}    console=yes
    Log    ✅ Mail.rc configuration collected    console=yes

Critical - Validate SMTP Relay Configuration
    [Documentation]    📧 Validate SMTP relay server is configured correctly in mail.rc
    [Tags]             critical    smtp    relay    validation

    Log    🔍 Validating SMTP relay configuration...    console=yes
    Log    📋 Expected SMTP Relay: ${EXPECTED_SMTP_RELAY}    console=yes

    # Validate SMTP relay in mail.rc
    ${validation_result}=    Validate SMTP Relay Configuration

    Log    📧 SMTP Relay Validation: ${validation_result}    console=yes
    Log    ✅ SMTP relay configuration validated    console=yes

Critical - Test SMTP Port Connectivity
    [Documentation]    🔌 Test connectivity to SMTP server on port 25 using telnet/nc
    [Tags]             critical    connectivity    smtp    port25

    Log    🔍 Testing SMTP port connectivity...    console=yes
    Log    📋 SMTP Server: ${EXPECTED_SMTP_RELAY}    console=yes
    Log    📋 SMTP Port: ${SMTP_PORT}    console=yes

    # Test SMTP port connectivity
    ${connectivity_result}=    Test SMTP Port Connectivity

    Log    🔌 SMTP Connectivity Result: ${connectivity_result}    console=yes
    Log    ✅ SMTP port connectivity test completed    console=yes

Normal - Send Test Email
    [Documentation]    📨 Send a test email to verify mail subsystem functionality
    [Tags]             normal    test_email    delivery    smtp

    Log    🔍 Sending test email...    console=yes
    Log    📋 Test Recipient: ${TEST_EMAIL_RECIPIENT}    console=yes

    # Send test email
    ${send_result}=    Send Test Email

    Log    📨 Test Email Result: ${send_result}    console=yes
    Log    ℹ️ Test email sent - check recipient mailbox for delivery    console=yes
    Log    ✅ Test email transmission: COMPLETED    console=yes

Normal - Check Mail Queue Status
    [Documentation]    📬 Check mail queue status to ensure no stuck messages
    [Tags]             normal    mail_queue    monitoring    postfix

    Log    🔍 Checking mail queue status...    console=yes

    # Check mail queue
    ${queue_status}=    Check Mail Queue Status

    Log    📬 Mail Queue Status: ${queue_status}    console=yes

    # Save queue status to file
    ${queue_file}=    Save Mail Queue Status to File    ${queue_status}

    Log    📄 Queue status saved to: ${queue_file}    console=yes
    Log    ✅ Mail queue check: INFORMATIONAL    console=yes

Normal - Validate Mail Subsystem Services
    [Documentation]    🔧 Validate mail-related services (postfix/sendmail) are running
    [Tags]             normal    services    postfix    sendmail

    Log    🔍 Validating mail subsystem services...    console=yes

    # Check mail service status
    ${service_status}=    Check Mail Service Status

    Log    🔧 Mail Service Status: ${service_status}    console=yes
    Log    ✅ Mail service validation: INFORMATIONAL    console=yes

Normal - Collect Mail Logs
    [Documentation]    📋 Collect recent mail log entries for troubleshooting
    [Tags]             normal    logs    maillog    monitoring

    Log    🔍 Collecting recent mail log entries...    console=yes

    # Collect mail logs
    ${mail_logs}=    Collect Mail Logs

    # Save logs to file
    ${log_file}=    Save Mail Logs to File    ${mail_logs}

    Log    📋 Mail logs saved to: ${log_file}    console=yes
    Log    ✅ Mail log collection: INFORMATIONAL    console=yes

Normal - Validate Firewall Rules for SMTP
    [Documentation]    🔥 Check firewall rules allow SMTP traffic on port 25
    [Tags]             normal    firewall    security    smtp

    Log    🔍 Checking firewall rules for SMTP...    console=yes

    # Check firewall rules
    ${firewall_rules}=    Check Firewall Rules for SMTP

    Log    🔥 Firewall Rules: ${firewall_rules}    console=yes
    Log    ℹ️ Firewall rules collected for review    console=yes
    Log    ✅ Firewall check: INFORMATIONAL    console=yes

Normal - Test SMTP Authentication
    [Documentation]    🔐 Test SMTP authentication capability if configured
    [Tags]             normal    authentication    security    smtp

    Log    🔍 Testing SMTP authentication configuration...    console=yes

    # Check SMTP auth configuration
    ${auth_config}=    Check SMTP Authentication Config

    Log    🔐 SMTP Auth Configuration: ${auth_config}    console=yes
    Log    ℹ️ SMTP authentication settings documented    console=yes
    Log    ✅ SMTP auth check: INFORMATIONAL    console=yes

Normal - Validate Mail Aliases Configuration
    [Documentation]    📮 Validate mail aliases configuration for system accounts
    [Tags]             normal    aliases    configuration    mail

    Log    🔍 Validating mail aliases configuration...    console=yes

    # Collect aliases configuration
    ${aliases_content}=    Collect Mail Aliases Configuration

    # Save aliases to file
    ${aliases_file}=    Save Mail Aliases to File    ${aliases_content}

    Log    📮 Mail aliases saved to: ${aliases_file}    console=yes
    Log    ✅ Mail aliases validation: INFORMATIONAL    console=yes

Normal - Comprehensive Mail Configuration Summary
    [Documentation]    📊 Generate comprehensive summary of all mail configuration data
    [Tags]             normal    summary    comprehensive    compliance

    Log    🔍 Generating comprehensive mail configuration summary...    console=yes

    # Generate comprehensive summary
    Validate All Mail Settings

    Log    📊 Comprehensive mail configuration summary:    console=yes
    Log    📊 - MX Records: Collected ✅    console=yes
    Log    📊 - Mail.rc Config: Validated ✅    console=yes
    Log    📊 - SMTP Connectivity: Tested ✅    console=yes
    Log    📊 - Test Email: Sent ✅    console=yes
    Log    📊 - Mail Queue: Monitored ✅    console=yes
    Log    📊 - Services: Validated ✅    console=yes
    Log    ✅ Comprehensive mail validation: COMPLETED    console=yes

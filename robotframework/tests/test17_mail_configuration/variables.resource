*** Settings ***
Documentation    📧 Test-17 Variables: Mail Configuration Validation
...              📋 Contains all variables specific to mail/SMTP relay configuration testing

*** Variables ***
# 🎯 Test Suite Configuration
${TEST_SUITE_NAME}        Test-17 Mail Configuration Validation
${TEST_SUITE_ID}          test17
${TEST_DESCRIPTION}       Validate SMTP relay configuration (mail.domain.com) if required in project scope

# 📁 Directory Paths
${TEST17_RESULTS_DIR}     results/test17_mail_configuration
${TEST17_DATA_DIR}        results/test17_mail_configuration/data

# 🏷️ Test Tags
@{CRITICAL_TAGS}          critical    mail    smtp    compliance
@{NORMAL_TAGS}           normal      informational    monitoring
@{MAIL_TAGS}             smtp    relay    mx_records    mail_rc    connectivity

# 📧 Expected Mail Configuration
${EXPECTED_SMTP_RELAY}    mail.domain.com
${SMTP_PORT}              25
${SMTP_PORT_TLS}          587
${SMTP_PORT_SSL}          465
${TEST_EMAIL_RECIPIENT}   test@domain.com

# 📄 Mail Configuration Files (Linux)
${MAIL_RC_FILE}           /etc/mail.rc
${MAIL_RC_ALT1}           /etc/mail/mail.rc
${MAIL_RC_ALT2}           /etc/nail.rc
${ALIASES_FILE}           /etc/aliases

# 🔧 Mail Commands (Linux)
${CMD_NSLOOKUP_MX}        nslookup -query=mx
${CMD_DIG_MX}             dig MX +short
${CMD_HOST_MX}            host -t MX
${CMD_MAIL_QUEUE}         mailq
${CMD_POSTQUEUE}          postqueue -p
${CMD_SEND_MAIL}          mail -s
${CMD_NC_TEST}            nc -zv
${CMD_TELNET_TEST}        telnet

# 📊 Mail Service Names
@{MAIL_SERVICES}
...    postfix
...    sendmail
...    exim4

# 📋 Mail Log Files
@{MAIL_LOG_FILES}
...    /var/log/maillog
...    /var/log/mail.log
...    /var/log/mail.info
...    /var/log/mail.warn
...    /var/log/mail.err

# 🔍 Validation Requirements
@{REQUIRED_MAIL_CHECKS}
...    mx_records
...    mail_rc_config
...    smtp_relay
...    smtp_connectivity
...    mail_queue
...    mail_service

# 🌐 DNS Settings
${DNS_QUERY_TIMEOUT}      10
${MX_RECORD_MIN}          1    # Minimum expected MX records

# 🔌 Connectivity Settings
${SMTP_CONNECT_TIMEOUT}   5
${SMTP_RETRY_COUNT}       3

# 📄 Report File Templates
${MX_RECORDS_TEMPLATE}=       mx_records_%s.txt
${MAIL_RC_TEMPLATE}=          mail_rc_%s.txt
${SMTP_CONN_TEMPLATE}=        smtp_connectivity_%s.txt
${MAIL_QUEUE_TEMPLATE}=       mail_queue_%s.txt
${MAIL_LOGS_TEMPLATE}=        mail_logs_%s.txt
${TEST_EMAIL_TEMPLATE}=       test_email_send_%s.txt
${EXEC_SUMMARY_TEMPLATE}=     executive_summary_%s.txt

# 🎨 Console Output Formatting
${LOG_PREFIX_MAIL}        📧 Mail
${LOG_PREFIX_SMTP}        📨 SMTP
${LOG_PREFIX_MX}          🌐 MX
${LOG_PREFIX_QUEUE}       📬 Queue
${LOG_PREFIX_VALIDATION}  🔍 Validating
${LOG_PREFIX_PASSED}      ✅ PASSED
${LOG_PREFIX_FAILED}      ❌ FAILED
${LOG_PREFIX_WARNING}     ⚠️ WARNING
${LOG_PREFIX_INFO}        ℹ️ INFO

# 🔐 SSH Connection Settings (inherited from EDS lookup)
${SSH_USERNAME}           root
${SSH_PASSWORD}           password
${SSH_TIMEOUT}            30

# 🎯 Target Server Configuration (from EDS)
${TARGET_HOSTNAME}        test-server-01
${TARGET_IP}              ${EMPTY}    # Will be populated from EDS lookup

# 📝 Test Email Configuration
${TEST_EMAIL_SUBJECT}     Robot Framework Test-17 Mail Validation
${TEST_EMAIL_BODY}        Automated test email from mail configuration validation suite

# 🔥 Firewall Ports to Check
@{SMTP_PORTS_TO_CHECK}
...    25
...    587
...    465

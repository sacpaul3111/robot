*** Variables ***
# Test Metadata
${TEST_SUITE_NAME}      Security and Compliance Validation Test Suite - Test-8
${TEST_VERSION}         1.0.0
${TEST_ENVIRONMENT}     Production-Ready

# Directory Configuration - Test-specific data, global reports
${REPORTS_DIR}          ${CURDIR}/../../results
${DATA_DIR}             ${CURDIR}/../../results/test8/data
${SCREENSHOTS_DIR}      ${CURDIR}/../../results/test8/screenshots

# Target System Configuration
${TARGET_HOST}          192.168.1.100
${TARGET_USERNAME}      testuser
${TARGET_PASSWORD}      testpass
${TARGET_OS_TYPE}       linux

# Code Server Configuration (Linux jump box)
${CODE_SERVER_HOST}         codeserver.domain.com
${CODE_SERVER_USERNAME}     jumpuser
${CODE_SERVER_PASSWORD}     jumppass
${TARGET_SSH_USER}          testuser

# Security Configuration Requirements
${MINIMUM_COMPLIANCE_SCORE}    85
${MAX_ADMIN_USERS}     5
${MAX_WORLD_WRITABLE_FILES}    5

# Security Test Configuration
${TIMEOUT_SECONDS}      30
${SECURITY_SCAN_DEPTH}  3

# Critical and Blocked Ports Lists
@{CRITICAL_PORTS_LIST}    22    80    443    3389
@{BLOCKED_PORTS_LIST}     21    23    135    139    445    1433    3306

# Prohibited Services List
@{PROHIBITED_SERVICES}    telnet    ftp    rsh    rlogin    finger    tftpd

# Output File Configuration
${USER_ACCOUNTS_FILE}     ${DATA_DIR}/user_accounts.txt
${FIREWALL_STATUS_FILE}   ${DATA_DIR}/firewall_status.txt
${SERVICES_FILE}          ${DATA_DIR}/running_services.txt
${SSH_CONFIG_FILE}        ${DATA_DIR}/ssh_config.txt
${PERMISSIONS_FILE}       ${DATA_DIR}/file_permissions.txt
${SSH_AUTH_LOG_FILE}      ${DATA_DIR}/ssh_auth_test.txt
${AUTHORIZED_KEYS_FILE}   ${DATA_DIR}/authorized_keys_validation.txt

# Test Execution Tracking (initialized values)
${TOTAL_TESTS}          0
${PASSED_TESTS}         0
@{TEST_RESULTS}
@{PERFORMANCE_METRICS}
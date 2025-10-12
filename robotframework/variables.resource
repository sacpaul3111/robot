*** Variables ***
# ===========================================
# Global Variables for All Test Suites
# ===========================================

# ===========================================
# Directory Configuration - Global paths
# ===========================================
${GLOBAL_RESULTS_DIR}     ${CURDIR}/results
${GLOBAL_HTML_REPORTS_DIR}    ${GLOBAL_RESULTS_DIR}
${GLOBAL_DATA_DIR}        ${GLOBAL_RESULTS_DIR}/data
${GLOBAL_SCREENSHOTS_DIR}    ${GLOBAL_RESULTS_DIR}/screenshots

# ===========================================
# Test Environment Settings
# ===========================================
${DEFAULT_ENVIRONMENT}    Production-Ready
${DEFAULT_VERSION}        1.0.0
${DEFAULT_TIMEOUT}        30

# ===========================================
# Common Test Configuration
# ===========================================
${MAX_RETRIES}            3
${DEFAULT_DELAY}          1
${CONNECTION_TIMEOUT}     30
${OPERATION_TIMEOUT}      60

# ===========================================
# Global Test Tracking Variables
# ===========================================
${GLOBAL_TOTAL_TESTS}     ${0}
${GLOBAL_PASSED_TESTS}    ${0}
${GLOBAL_FAILED_TESTS}    ${0}
@{GLOBAL_TEST_RESULTS}
@{GLOBAL_PERFORMANCE_METRICS}

# ===========================================
# Common Network Settings
# ===========================================
${DEFAULT_DNS_SERVER}     8.8.8.8
${BACKUP_DNS_SERVER}      1.1.1.1
${DEFAULT_PING_COUNT}     5
${NETWORK_TIMEOUT}        15

# ===========================================
# File and Logging Configuration
# ===========================================
${LOG_LEVEL}              INFO
${SCREENSHOT_FORMAT}      PNG
${REPORT_FORMAT}          HTML

# ===========================================
# External System Endpoints
# ===========================================
# vCenter Configuration (test4, test9, test15)
${VCENTER_URL}            https://vcenter.example.com
${VCENTER_API_BASE}       https://vcenter.example.com/api

# Splunk Configuration (test14)
${SPLUNK_URL}             https://splunk.example.com:8000
${SPLUNK_API_BASE}        https://splunk.example.com:8089
${SPLUNK_SERVER}          splunk.example.com
${SPLUNK_PORT}            514

# CyberArk Configuration (test16)
${CYBERARK_URL}           https://cyberark.example.com
${CYBERARK_API_BASE}      https://cyberark.example.com/PasswordVault/API

# Tanium Configuration (test21)
${TANIUM_SERVER}          tanium.example.com
${TANIUM_PORT}            17472

# Ansible Tower/AWX Configuration (test24)
${ANSIBLE_TOWER_URL}      https://tower.example.com
${ANSIBLE_API_VERSION}    v2

# ===========================================
# External System Credentials (from Ansible)
# ===========================================
# SSH Credentials (all tests)
${SSH_USERNAME}           ${EMPTY}
${SSH_PASSWORD}           ${EMPTY}

# vCenter Credentials (test4, test9, test15)
${VCENTER_USERNAME}       ${EMPTY}
${VCENTER_PASSWORD}       ${EMPTY}

# Splunk Credentials (test14)
${SPLUNK_USERNAME}        ${EMPTY}
${SPLUNK_PASSWORD}        ${EMPTY}

# CyberArk Credentials (test16)
${CYBERARK_USERNAME}      ${EMPTY}
${CYBERARK_PASSWORD}      ${EMPTY}

# Tanium Credentials (test21)
${TANIUM_USERNAME}        ${EMPTY}
${TANIUM_PASSWORD}        ${EMPTY}

# Ansible Tower Credentials (test24)
${ANSIBLE_TOWER_USERNAME}    ${EMPTY}
${ANSIBLE_TOWER_PASSWORD}    ${EMPTY}
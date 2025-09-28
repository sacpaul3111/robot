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
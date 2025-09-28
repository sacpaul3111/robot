*** Variables ***
# Test Metadata
${TEST_SUITE_NAME}      Time Configuration Validation Test Suite - Test-7
${TEST_VERSION}         1.0.0
${TEST_ENVIRONMENT}     Production-Ready

# Directory Configuration - Test-specific data, global reports
${REPORTS_DIR}          ${CURDIR}/../../results
${DATA_DIR}             ${CURDIR}/../../results/test7/data
${SCREENSHOTS_DIR}      ${CURDIR}/../../results/test7/screenshots

# Target System Configuration
${TARGET_HOST}          192.168.1.100
${TARGET_USERNAME}      testuser
${TARGET_PASSWORD}      testpass
${TARGET_OS_TYPE}       linux

# Time Configuration Requirements
${REQUIRED_TIMEZONE}    America/Los_Angeles
${REQUIRED_NTP_SERVER}  ntpx.domain.com
${MAX_CLOCK_DRIFT_SECONDS}    5
${MAX_PATCH_AGE_DAYS}   30

# Time Test Configuration
${TIMEOUT_SECONDS}      30
${NTP_TEST_COUNT}       3
${TIME_SYNC_TOLERANCE}  2

# Output File Configuration
${TIMEDATECTL_FILE}     ${DATA_DIR}/timedatectl_output.txt
${CHRONY_STATUS_FILE}   ${DATA_DIR}/chrony_status.txt
${CHRONY_SOURCES_FILE}  ${DATA_DIR}/chrony_sources.txt
${HWCLOCK_FILE}         ${DATA_DIR}/hwclock_output.txt

# Test Execution Tracking (initialized values)
${TOTAL_TESTS}          0
${PASSED_TESTS}         0
@{TEST_RESULTS}
@{PERFORMANCE_METRICS}
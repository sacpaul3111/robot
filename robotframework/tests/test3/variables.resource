*** Variables ***
# Test Metadata
${TEST_SUITE_NAME}      Hostname Validation Test Suite - Test-3
${TEST_VERSION}         2.0.0
${TEST_ENVIRONMENT}     Development QA

# Directory Configuration - Test-specific data, global reports
${REPORTS_DIR}          ${CURDIR}/../../results
${DATA_DIR}             ${CURDIR}/../../results/test3/data

# Target Configuration from CBS_Itential_DRAFT_v0.01.xlsx
# These values will be overridden by Itential workflow variables
${TARGET_HOSTNAME}      alhxvdvitap01
${TARGET_IP}            10.26.216.107
${TARGET_SUBNET}        10.26.216.0/24
${TARGET_MASK}          255.255.255.0
${TARGET_GATEWAY}       10.26.216.4
${TARGET_CNAME}         alhxvdvitap01
${TARGET_DOMAIN}        gnscet.com

# Network Test Configuration
${PRIMARY_DNS_SERVER}   8.8.8.8
${SECONDARY_DNS_SERVER}   1.1.1.1
${TEST_DOMAINS}         google.com,github.com,stackoverflow.com
${PING_COUNT}           5
${TIMEOUT_SECONDS}      15

# Test Execution Tracking (initialized values)
${TOTAL_TESTS}          0
${PASSED_TESTS}         0
@{TEST_RESULTS}
@{PERFORMANCE_METRICS}
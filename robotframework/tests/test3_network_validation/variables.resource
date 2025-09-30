*** Variables ***
# Test Metadata - Dynamic test suite identification
${TEST_SUITE_ID}        test3                    # Override with --variable TEST_SUITE_ID:testX
${TEST_SUITE_NAME}      Hostname Validation Test Suite - ${TEST_SUITE_ID}
${TEST_VERSION}         2.0.0
${TEST_ENVIRONMENT}     Development QA

# Directory Configuration - Dynamic based on test suite ID  
${ROBOTFRAMEWORK_ROOT}  ${EXECDIR}
${REPORTS_DIR}          ${ROBOTFRAMEWORK_ROOT}/results
${TEST_REPORTS_DIR}     ${REPORTS_DIR}/${TEST_SUITE_ID}
${DATA_DIR}             ${TEST_REPORTS_DIR}/data

# Target Configuration - These will be dynamically set by EDS lookup
${TARGET_HOSTNAME}      # Set via command line --variable TARGET_HOSTNAME:value
${TARGET_IP}            # Set dynamically from EDS lookup
${TARGET_SUBNET}        # Set dynamically from EDS lookup  
${TARGET_MASK}          # Set dynamically from EDS lookup
${TARGET_GATEWAY}       # Set dynamically from EDS lookup
${TARGET_CNAME}         # Set dynamically from EDS lookup
${TARGET_DOMAIN}        # Set dynamically from EDS lookup

# Network Test Configuration 
${PING_COUNT}           3
${TIMEOUT_SECONDS}      15

# Test Execution Tracking
${TOTAL_TESTS}          0
${PASSED_TESTS}         0
@{TEST_RESULTS}
@{PERFORMANCE_METRICS}
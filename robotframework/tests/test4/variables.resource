*** Settings ***
Documentation    🔧 Variables and configuration for VxRail VM Validation Test Suite

*** Variables ***
# ===========================================
# vCenter Configuration Settings
# ===========================================
${VCENTER_HOST}         vcenter.example.com
${VCENTER_USERNAME}     admin@vsphere.local
${VCENTER_PASSWORD}     password123
${VCENTER_API_VERSION}  7.0

# ===========================================
# Target VM Specifications
# ===========================================
${CLUSTER_NAME}         VxRail-Cluster-01
${VM_NAME}              TestVM-001
${EXPECTED_CPU}         4
${EXPECTED_MEMORY}      8
${EXPECTED_HW_VERSION}  vmx-19

# ===========================================
# Directory Configuration - Test-specific data, global reports
# ===========================================
${RESULTS_DIR}          ../../results
${HTML_REPORTS_DIR}     ${RESULTS_DIR}
${SCREENSHOTS_DIR}      ${RESULTS_DIR}/test4/screenshots
${DATA_DIR}             ${RESULTS_DIR}/test4/data

# ===========================================
# Test Suite Variables
# ===========================================
${SUITE_NAME}           VxRail VM Validation Test-4
${TEST_VERSION}         1.0.0
${ENVIRONMENT}          Production

# ===========================================
# Performance and Validation Thresholds
# ===========================================
${MAX_CONNECTION_TIME}  30
${VM_DISCOVERY_TIMEOUT}    60
${CONFIG_COLLECTION_TIMEOUT}    30

# ===========================================
# Initialize counters and data structures
# ===========================================
${TOTAL_TESTS}          ${0}
${PASSED_TESTS}         ${0}
${FAILED_TESTS}         ${0}
@{TEST_RESULTS}
@{PERFORMANCE_METRICS}

# ===========================================
# Suite-level variables (set during execution)
# ===========================================
${VCENTER_SESSION}      ${EMPTY}
${VM_DETAILS}           ${EMPTY}
${VM_CONFIG_DATA}       ${EMPTY}
${CONFIG_SCREENSHOT}    ${EMPTY}
${STATUS_SCREENSHOT}    ${EMPTY}
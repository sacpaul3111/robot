*** Settings ***
Documentation    🖥️ VxRail VM Validation Test Suite - Test-4
...              Comprehensive VM validation with vCenter API integration
...              ✨ Features: VM discovery, configuration validation, EDS compliance
...              📊 Results: Unified HTML reports with enhanced dashboard
...              🎯 Run with: robot vxrail_vm_validation.robot
...
Metadata         Test Suite    VxRail VM Validation Test-4
Metadata         Environment   Production-Ready
Metadata         Version       1.0.0
Metadata         Features      vCenter API, VM Discovery, EDS Validation, Screenshots
Metadata         Reporting     Unified HTML Reports + Enhanced Dashboard

Resource         ../../settings.resource

# Configure Robot Framework to output to html_reports directory
Default Tags     vm-validation
Force Tags       automated

Suite Setup      Initialize Test Environment
Suite Teardown   Generate Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - vCenter API Connection Validation
    [Documentation]    🔗 Establishes API connection to VMware vCenter
    ...                Validates authentication and API accessibility for VM operations
    [Tags]             critical    vcenter    api    connection

    Log    🔍 Establishing vCenter API connection...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Establish vCenter connection
    ${session_result}=    Connect To VCenter    ${VCENTER_HOST}    ${VCENTER_USERNAME}    ${VCENTER_PASSWORD}
    Should Not Be Empty    ${session_result}    vCenter API connection failed
    Set Suite Variable    ${VCENTER_SESSION}    ${session_result}

    # Validate connection status
    ${connection_status}=    Validate VCenter Connection    ${session_result}
    Should Be Equal    ${connection_status}    connected

    Log    ✅ vCenter API connection: ESTABLISHED    console=yes
    Log    🔑 Session ID: ${session_result}    console=yes
    Append To List    ${TEST_RESULTS}    vCenter Connection: PASS - Session: ${session_result}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Target VM Discovery and Validation
    [Documentation]    🔍 Searches for target VM in specified VxRail cluster
    ...                Validates VM existence and proper cluster placement
    [Tags]             critical    vm    discovery    cluster

    Log    🔍 Searching for VM: ${VM_NAME} in cluster: ${CLUSTER_NAME}    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Search for VM in cluster
    ${vm_details}=    Search VM In Cluster    ${VCENTER_SESSION}    ${VM_NAME}    ${CLUSTER_NAME}
    Should Not Be Empty    ${vm_details}    VM not found in specified cluster
    Set Suite Variable    ${VM_DETAILS}    ${vm_details}

    # Validate cluster placement
    ${vm_cluster}=    Get VM Cluster    ${vm_details}
    Should Be Equal    ${vm_cluster}    ${CLUSTER_NAME}    VM not in expected cluster

    # Get VM status
    ${vm_status}=    Get VM Power State    ${vm_details}

    Log    ✅ VM found in cluster: ${CLUSTER_NAME}    console=yes
    Log    📊 VM Power State: ${vm_status}    console=yes
    Append To List    ${TEST_RESULTS}    VM Discovery: PASS - Found in ${CLUSTER_NAME}, Status: ${vm_status}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - VM Configuration Data Collection
    [Documentation]    📊 Collects comprehensive VM configuration via vCenter API
    ...                Gathers CPU, memory, hardware version, and network specifications
    [Tags]             critical    vm    configuration    api

    Log    🔍 Collecting comprehensive VM configuration data...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Collect VM configuration
    ${vm_config}=    Get VM Configuration    ${VCENTER_SESSION}    ${VM_DETAILS}
    Should Not Be Empty    ${vm_config}    Failed to collect VM configuration
    Set Suite Variable    ${VM_CONFIG_DATA}    ${vm_config}

    # Extract key configuration details
    ${cpu_count}=    Get VM CPU Count    ${vm_config}
    ${memory_gb}=    Get VM Memory GB    ${vm_config}
    ${hw_version}=   Get VM Hardware Version    ${vm_config}
    ${disk_count}=   Get VM Disk Count    ${vm_config}
    ${network_count}=    Get VM Network Adapter Count    ${vm_config}

    # Store configuration data
    Append To List    ${PERFORMANCE_METRICS}    CPU Count: ${cpu_count}
    Append To List    ${PERFORMANCE_METRICS}    Memory: ${memory_gb} GB
    Append To List    ${PERFORMANCE_METRICS}    Hardware Version: ${hw_version}
    Append To List    ${PERFORMANCE_METRICS}    Disk Count: ${disk_count}
    Append To List    ${PERFORMANCE_METRICS}    Network Adapters: ${network_count}

    Log    ✅ VM configuration collected: SUCCESS    console=yes
    Log    💻 CPU Count: ${cpu_count}    console=yes
    Log    🧠 Memory: ${memory_gb} GB    console=yes
    Log    🔧 Hardware Version: ${hw_version}    console=yes
    Append To List    ${TEST_RESULTS}    VM Configuration: PASS - CPU: ${cpu_count}, Memory: ${memory_gb}GB, HW: ${hw_version}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - EDS Compliance Validation
    [Documentation]    ✅ Validates VM specifications against Engineering Design Specification
    ...                Ensures complete compliance with build requirements
    [Tags]             critical    eds    validation    compliance

    Log    🔍 Validating against Engineering Design Specification...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Validate CPU configuration
    ${cpu_validation}=    Validate CPU Against EDS    ${VM_CONFIG_DATA}    ${EXPECTED_CPU}
    Should Be True    ${cpu_validation}    CPU configuration non-compliant

    # Validate memory configuration
    ${memory_validation}=    Validate Memory Against EDS    ${VM_CONFIG_DATA}    ${EXPECTED_MEMORY}
    Should Be True    ${memory_validation}    Memory configuration non-compliant

    # Validate hardware version
    ${hw_validation}=    Validate Hardware Version Against EDS    ${VM_CONFIG_DATA}    ${EXPECTED_HW_VERSION}
    Should Be True    ${hw_validation}    Hardware version non-compliant

    # Validate cluster placement
    ${cluster_validation}=    Validate Cluster Against EDS    ${VM_DETAILS}    ${CLUSTER_NAME}
    Should Be True    ${cluster_validation}    Cluster placement non-compliant

    Log    ✅ EDS validation: COMPLIANT    console=yes
    Log    💻 CPU validation: PASSED    console=yes
    Log    🧠 Memory validation: PASSED    console=yes
    Log    🔧 Hardware validation: PASSED    console=yes
    Log    🎯 Cluster validation: PASSED    console=yes
    Append To List    ${TEST_RESULTS}    EDS Compliance: PASS - All specifications validated

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Normal - vCenter Screenshot Capture
    [Documentation]    📸 Captures screenshots of VM configuration and status
    ...                Documents VM state for verification and audit trail
    [Tags]             normal    screenshot    documentation

    Log    📸 Capturing VM configuration screenshots...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Capture VM configuration screenshot
    ${config_screenshot}=    Capture VM Configuration Screenshot    ${VCENTER_SESSION}    ${VM_DETAILS}    ${SCREENSHOTS_DIR}
    Should Not Be Empty    ${config_screenshot}    VM configuration screenshot not captured

    # Capture VM status screenshot
    ${status_screenshot}=    Capture VM Status Screenshot    ${VCENTER_SESSION}    ${VM_DETAILS}    ${SCREENSHOTS_DIR}
    Should Not Be Empty    ${status_screenshot}    VM status screenshot not captured

    # Store screenshot paths
    Set Suite Variable    ${CONFIG_SCREENSHOT}    ${config_screenshot}
    Set Suite Variable    ${STATUS_SCREENSHOT}     ${status_screenshot}

    # Store screenshot metrics
    Append To List    ${PERFORMANCE_METRICS}    Config Screenshot: ${config_screenshot}
    Append To List    ${PERFORMANCE_METRICS}    Status Screenshot: ${status_screenshot}

    Log    ✅ Screenshot capture: COMPLETED    console=yes
    Log    📸 Config screenshot: ${CONFIG_SCREENSHOT}    console=yes
    Log    📸 Status screenshot: ${STATUS_SCREENSHOT}    console=yes
    Append To List    ${TEST_RESULTS}    Screenshot Capture: PASS - 2 screenshots captured

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}
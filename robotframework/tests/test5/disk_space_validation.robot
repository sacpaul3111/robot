*** Settings ***
Documentation    💿 Disk Space Allocation Information Test Suite - Test-5
...              Comprehensive storage, compute, and disk space validation
...              ✨ Features: SSH connectivity, disk space analysis, CPU validation, storage allocation
...              📊 Results: Detailed reports with build sheet compliance verification
...              🎯 Run with: robot disk_space_validation.robot
...
Metadata         Test Suite    Disk Space Allocation Test-5
Metadata         Environment   Production-Ready
Metadata         Version       1.0.0
Metadata         Features      Storage, CPU, Disk Allocation, Build Compliance
Metadata         Reporting     Comprehensive Storage Reports + Executive Dashboard

Resource         ../../settings.resource
Resource         storage_keywords.resource
Resource         variables.resource

# Configure Robot Framework to output to html_reports directory
Default Tags     storage-validation
Force Tags       automated

Suite Setup      Initialize Test Environment
Suite Teardown   Generate Storage Summary Report

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - SSH Connection to Target Machine
    [Documentation]    🌐 Establish SSH connection to target machine for system analysis
    ...                Tests connectivity through codeserver to target machine
    [Tags]             critical    connectivity    ssh    infrastructure

    Log    🔍 Establishing SSH connection to target machine...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Connect to target machine
    ${connection_success}=    Connect To Target Machine    ${TARGET_MACHINE}
    Should Be True    ${connection_success}    Failed to establish SSH connection to target machine

    Log    ✅ SSH connection established successfully    console=yes
    Append To List    ${TEST_RESULTS}    SSH Connection: PASS - Connected to ${TARGET_MACHINE}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - Disk Space Information Collection
    [Documentation]    💿 Execute df -h command and collect comprehensive disk space information
    ...                Gathers disk usage, filesystem types, and partition information
    [Tags]             critical    storage    disk-space    data-collection

    Log    🔍 Collecting disk space information using df -h...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Collect disk space information
    ${disk_info}=    Collect Disk Space Information
    Should Not Be Empty    ${disk_info}    Disk space information collection failed

    # Validate basic disk space requirements
    ${total_space}=    Validate Disk Space Requirements    ${disk_info}

    Log    ✅ Disk space information collected successfully    console=yes
    Log    📊 Total disk space: ${total_space}GB    console=yes
    Append To List    ${TEST_RESULTS}    Disk Space Collection: PASS - Total: ${total_space}GB

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - CPU Information and Validation
    [Documentation]    🖥️ Collect CPU information and validate against build requirements
    ...                Gathers CPU model, core count, and performance specifications
    [Tags]             critical    compute    cpu    specifications

    Log    🔍 Collecting and validating CPU information...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Collect CPU information
    ${cpu_info}=    Collect CPU Information
    Should Not Be Empty    ${cpu_info}    CPU information collection failed

    # Validate CPU requirements
    ${cpu_cores}=    Validate CPU Requirements    ${cpu_info}

    Log    ✅ CPU information validated successfully    console=yes
    Log    💻 CPU cores: ${cpu_cores}    console=yes
    Append To List    ${TEST_RESULTS}    CPU Validation: PASS - Cores: ${cpu_cores}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - Storage Capacity and Allocation Analysis
    [Documentation]    📦 Analyze storage capacity and validate disk allocation for different purposes
    ...                Validates root, application, and cyber tools disk separation and sizing
    [Tags]             critical    storage    allocation    capacity    build-compliance

    Log    🔍 Analyzing storage capacity and allocation...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Collect storage capacity information
    ${storage_info}=    Collect Storage Capacity Information
    Should Not Be Empty    ${storage_info}    Storage capacity information collection failed

    # Validate storage allocation
    ${allocation_valid}=    Validate Storage Allocation    ${storage_info}

    Log    ✅ Storage allocation analysis completed    console=yes
    Append To List    ${TEST_RESULTS}    Storage Allocation: PASS - Build compliant

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Normal - Build Sheet Compliance Verification
    [Documentation]    📋 Verify all collected information against EDS/Build sheet requirements
    ...                Comprehensive validation of compute and storage specifications
    [Tags]             normal    compliance    build-sheet    verification

    Log    🔍 Verifying build sheet compliance...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Verify minimum requirements are met
    Should Be True    len($TEST_RESULTS) >= 3    Insufficient test data for compliance verification

    # Check for any validation errors
    ${error_count}=    Get Length    ${VALIDATION_ERRORS}
    Should Be Equal As Integers    ${error_count}    0    Build sheet compliance failed: ${error_count} errors found

    # Validate success rate
    ${success_rate}=    Evaluate    ${PASSED_TESTS} / ${TOTAL_TESTS} * 100
    Should Be True    ${success_rate} >= 80    Build compliance success rate too low: ${success_rate}%

    Log    ✅ Build sheet compliance verified    console=yes
    Log    📊 Compliance success rate: ${success_rate}%    console=yes
    Append To List    ${TEST_RESULTS}    Build Compliance: PASS - Success Rate: ${success_rate}%

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Normal - System Resource Documentation
    [Documentation]    📄 Generate comprehensive documentation of system resources
    ...                Creates detailed reports for audit and compliance purposes
    [Tags]             normal    documentation    reporting    audit

    Log    🔍 Generating system resource documentation...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Verify all output files were created
    OperatingSystem.File Should Exist    ${OUTPUT_DIR}/${DISK_INFO_FILE}
    OperatingSystem.File Should Exist    ${OUTPUT_DIR}/${CPU_INFO_FILE}
    OperatingSystem.File Should Exist    ${OUTPUT_DIR}/${STORAGE_INFO_FILE}

    # Count generated files
    @{output_files}=    List Files In Directory    ${OUTPUT_DIR}
    ${file_count}=    Get Length    ${output_files}
    Should Be True    ${file_count} >= 3    Insufficient documentation files generated

    Log    ✅ System resource documentation completed    console=yes
    Log    📁 Generated ${file_count} documentation files    console=yes
    Append To List    ${TEST_RESULTS}    Documentation: PASS - ${file_count} files generated

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

    [Teardown]    Close Target Connection
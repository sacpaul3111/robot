*** Settings ***
Documentation    📦 OS and Package Validation Test Suite - Test-6
...              🔍 Process: Find hostname in EDS → Connect to server (SSH/WinRM) → Collect OS and package data → Validate against standards and CIP-007 R2
...              ✅ Validates: OS version, installed packages, patch history, kernel version, Ansible build template
...              📋 Compliance: CIP-007 R2 - Security Patch Management
...
Resource         ../../settings.resource
Resource         os_package_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize OS Package Test Environment
Suite Teardown   Close All SSH Connections

Test Setup       Log    🚀 Starting: ${TEST_NAME}    console=yes
Test Teardown    Log    ✅ Completed: ${TEST_NAME}    console=yes

*** Test Cases ***
Critical - Step 1: Connect to Target System
    [Documentation]    🔌 Establish direct connection to target machine via WinRM for Windows or SSH for Linux
    ...                Step 1 of validation process: Connect to Target
    [Tags]             critical    connection    step1    infrastructure

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO TARGET SYSTEM    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target: ${TARGET_HOSTNAME} (${TARGET_IP})    console=yes
    Log    📋 OS Type: ${TARGET_OS_TYPE}    console=yes
    Log    📋 Connection Type: ${CONNECTION_TYPE}    console=yes

    # Establish connection (SSH for Linux, WinRM for Windows)
    Connect To Target System

    # Verify connection is active
    Should Be True    ${CONNECTION_ESTABLISHED}
    ...    ❌ Failed to establish connection to target system

    Log    ✅ Connection verified and active    console=yes
    Log    ✅ STEP 1: COMPLETED - Connection established    console=yes

Critical - Step 2.1: Collect OS Version Information
    [Documentation]    📋 Execute system commands to gather OS version information
    ...                Step 2 of validation process: Collect OS and Package Information (Part 1)
    [Tags]             critical    os_version    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT OS VERSION INFORMATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect OS version and kernel information
    Collect OS Version Information

    # Verify data was collected
    Should Not Be Empty    ${OS_VERSION_OUTPUT}
    ...    ❌ OS version information was not collected
    Should Not Be Empty    ${KERNEL_OUTPUT}
    ...    ❌ Kernel information was not collected

    # Verify files were created
    File Should Exist    ${OS_INFO_FILE}
    File Should Exist    ${KERNEL_INFO_FILE}

    Log    📊 OS Version Output (first 200 chars): ${OS_VERSION_OUTPUT[:200]}...    console=yes
    Log    📊 Kernel Output: ${KERNEL_OUTPUT}    console=yes
    Log    ✅ STEP 2.1: COMPLETED - OS version information collected    console=yes

Critical - Step 2.2: Collect Installed Packages
    [Documentation]    📦 Execute system commands to gather installed packages list
    ...                Step 2 of validation process: Collect OS and Package Information (Part 2)
    [Tags]             critical    packages    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT INSTALLED PACKAGES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect installed packages
    Collect Installed Packages

    # Verify data was collected
    Should Not Be Empty    ${PACKAGES_OUTPUT}
    ...    ❌ Packages information was not collected
    Should Not Be Empty    ${BASE_PACKAGES_OUTPUT}
    ...    ❌ Base packages information was not collected

    # Verify file was created
    File Should Exist    ${PACKAGES_FILE}

    # Count packages
    ${package_count}=    Get Line Count    ${PACKAGES_OUTPUT}
    Log    📊 Total packages found: ${package_count}    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Installed packages collected    console=yes

Critical - Step 2.3: Collect Patch History
    [Documentation]    🔄 Execute system commands to gather patch history and security updates
    ...                Step 2 of validation process: Collect OS and Package Information (Part 3)
    [Tags]             critical    patches    step2    data_collection    security

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT PATCH HISTORY    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect patch history and security updates
    Collect Patch History

    # Verify data was collected
    Should Not Be Empty    ${PATCH_HISTORY_OUTPUT}
    ...    ❌ Patch history was not collected

    # Verify file was created
    File Should Exist    ${PATCH_HISTORY_FILE}

    # Count pending security updates
    ${pending_count}=    Count Lines    ${SECURITY_UPDATES_OUTPUT}
    Log    📊 Pending security updates: ${pending_count}    console=yes

    IF    ${pending_count} > 0
        Log    ⚠️ WARNING: ${pending_count} security updates pending    console=yes
    ELSE
        Log    ✅ No pending security updates    console=yes
    END

    Log    ✅ STEP 2.3: COMPLETED - Patch history collected    console=yes

Critical - Step 2.4: Collect Ansible Build Template
    [Documentation]    🤖 Execute system commands to gather Ansible build template details
    ...                Step 2 of validation process: Collect OS and Package Information (Part 4)
    [Tags]             critical    ansible    step2    data_collection    automation

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: COLLECT ANSIBLE BUILD TEMPLATE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect Ansible build template information
    Collect Ansible Build Template Info

    # Verify file was created
    File Should Exist    ${ANSIBLE_TEMPLATE_FILE_PATH}

    # Check if Ansible build info was found
    ${has_ansible_info}=    Run Keyword And Return Status
    ...    Should Not Contain    ${ANSIBLE_TEMPLATE_OUTPUT}    not found

    IF    ${has_ansible_info}
        Log    📊 Ansible Template Info: ${ANSIBLE_TEMPLATE_OUTPUT}    console=yes
        Log    ✅ Ansible build template information found    console=yes
    ELSE
        Log    ⚠️ WARNING: Ansible build template information not found on server    console=yes
        Log    ℹ️ This is informational - server may not have been built with Ansible    console=yes
    END

    Log    ✅ STEP 2.4: COMPLETED - Ansible template collection attempted    console=yes

Critical - Step 3.1: Validate OS Version Against Standards
    [Documentation]    ✅ Compare OS version against approved standards list
    ...                Step 3 of validation process: Validate Against Standards (Part 1)
    [Tags]             critical    validation    step3    compliance    os_version

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE OS VERSION AGAINST STANDARDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate OS version
    ${validation_result}=    Validate OS Version Against Standards

    # Extract OS version for reporting
    ${os_version}=    Extract OS Version From Output    ${OS_VERSION_OUTPUT}

    Log    📊 Detected OS Version: ${os_version}    console=yes
    Log    📊 Validation Result: ${validation_result}    console=yes

    IF    '${validation_result}' == 'PASSED'
        Log    ✅ OS version is approved: ${os_version}    console=yes
    ELSE
        Log    ❌ OS version is NOT approved: ${os_version}    console=yes
        Fail    ❌ OS version ${os_version} is not in the approved standards list
    END

    Log    ✅ STEP 3.1: COMPLETED - OS version validated    console=yes

Critical - Step 3.2: Validate Required Base Packages
    [Documentation]    ✅ Compare installed packages against required base packages list
    ...                Step 3 of validation process: Validate Against Standards (Part 2)
    [Tags]             critical    validation    step3    compliance    packages

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE REQUIRED BASE PACKAGES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate required packages
    ${validation_results}=    Validate Required Base Packages

    # Check results
    ${missing_count}=    Get Length    ${MISSING_PACKAGES}

    Log    📊 Required packages validation completed    console=yes
    Log    📊 Missing packages: ${missing_count}    console=yes

    IF    ${missing_count} > 0
        Log    ⚠️ WARNING: Missing required packages:    console=yes
        FOR    ${package}    IN    @{MISSING_PACKAGES}
            Log    ⚠️ - ${package}    console=yes
        END
        Fail    ❌ ${missing_count} required base packages are missing
    ELSE
        Log    ✅ All required base packages are installed    console=yes
    END

    Log    ✅ STEP 3.2: COMPLETED - Base packages validated    console=yes

Critical - Step 3.3: Validate Prohibited Packages
    [Documentation]    ✅ Verify prohibited security-risk packages are NOT installed
    ...                Step 3 of validation process: Validate Against Standards (Part 3)
    [Tags]             critical    validation    step3    compliance    security

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE PROHIBITED PACKAGES NOT INSTALLED    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate prohibited packages
    ${validation_results}=    Validate Prohibited Packages Not Installed

    # Check results
    ${prohibited_count}=    Get Length    ${PROHIBITED_PACKAGES_FOUND}

    Log    📊 Prohibited packages validation completed    console=yes
    Log    📊 Prohibited packages found: ${prohibited_count}    console=yes

    IF    ${prohibited_count} > 0
        Log    ❌ SECURITY VIOLATION: Prohibited packages detected:    console=yes
        FOR    ${package}    IN    @{PROHIBITED_PACKAGES_FOUND}
            Log    ❌ - ${package}    console=yes
        END
        Fail    ❌ SECURITY VIOLATION: ${prohibited_count} prohibited packages found
    ELSE
        Log    ✅ No prohibited packages detected    console=yes
    END

    Log    ✅ STEP 3.3: COMPLETED - Prohibited packages validated    console=yes

Critical - Step 3.4: Validate CIP-007 R2 Compliance
    [Documentation]    ✅ Compare patch history and security updates against CIP-007 R2 compliance requirements
    ...                Step 3 of validation process: Validate Against Standards (Part 4)
    [Tags]             critical    validation    step3    compliance    cip007_r2    nerc

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: VALIDATE CIP-007 R2 COMPLIANCE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Compliance Standard: ${CIP007_R2_TITLE}    console=yes
    Log    📋 ${CIP007_R2_DESCRIPTION}    console=yes

    # Generate compliance report
    ${compliance_file}=    Generate CIP-007 R2 Compliance Report

    # Verify report was created
    File Should Exist    ${compliance_file}
    ${file_size}=    Get File Size    ${compliance_file}
    Should Be True    ${file_size} > 0

    # Count pending security updates
    ${pending_count}=    Count Lines    ${SECURITY_UPDATES_OUTPUT}

    Log    📊 CIP-007 R2 Compliance Assessment:    console=yes
    Log    📊 - Pending Security Updates: ${pending_count}    console=yes
    Log    📊 - Compliance Report: ${compliance_file}    console=yes

    IF    ${pending_count} > 0
        Log    ⚠️ WARNING: ${pending_count} security updates require evaluation    console=yes
        Log    ⚠️ CIP-007 R2.2: Must evaluate patches within 35 calendar days    console=yes
        Log    ⚠️ CIP-007 R2.3: Apply patches or document technical/risk justification    console=yes
        Log    ℹ️ Review compliance report for details: ${compliance_file}    console=yes
    ELSE
        Log    ✅ No pending security updates - System is current    console=yes
    END

    Log    ✅ STEP 3.4: COMPLETED - CIP-007 R2 compliance validated    console=yes
    Log    📄 Full compliance report available at: ${compliance_file}    console=yes

Normal - Kernel Version Documentation
    [Documentation]    📋 Document kernel version for reference and troubleshooting
    [Tags]             normal    informational    kernel    documentation

    Log    🔍 Documenting kernel version...    console=yes

    Log    📊 Kernel Version: ${KERNEL_OUTPUT}    console=yes
    Log    📄 Detailed information in: ${KERNEL_INFO_FILE}    console=yes

    Log    ℹ️ Kernel version documented    console=yes
    Log    ✅ Kernel documentation: INFORMATIONAL    console=yes

Normal - Package Statistics Analysis
    [Documentation]    📊 Analyze package statistics for operational insights
    [Tags]             normal    informational    packages    analysis

    Log    🔍 Analyzing package statistics...    console=yes

    # Count total packages
    ${total_packages}=    Get Line Count    ${PACKAGES_OUTPUT}
    ${base_packages}=     Get Line Count    ${BASE_PACKAGES_OUTPUT}

    Log    📊 Package Statistics:    console=yes
    Log    📊 - Total packages installed: ${total_packages}    console=yes
    Log    📊 - Base packages: ${base_packages}    console=yes

    # Analyze package distribution (Linux only)
    IF    ${IS_LINUX}
        ${rpm_count}=    Run Keyword And Return Status    Should Contain    ${PACKAGES_OUTPUT}    .rpm
        ${deb_count}=    Run Keyword And Return Status    Should Contain    ${PACKAGES_OUTPUT}    .deb

        IF    ${rpm_count}
            Log    📊 - Package format: RPM (Red Hat/CentOS)    console=yes
        ELSE IF    ${deb_count}
            Log    📊 - Package format: DEB (Debian/Ubuntu)    console=yes
        END
    END

    Log    ℹ️ Package statistics analysis completed    console=yes
    Log    ✅ Package statistics: DOCUMENTED    console=yes

Normal - Ansible Build Template Analysis
    [Documentation]    🤖 Analyze Ansible build template information if available
    [Tags]             normal    informational    ansible    automation

    Log    🔍 Analyzing Ansible build template...    console=yes

    # Check if Ansible build info exists
    ${has_ansible_info}=    Run Keyword And Return Status
    ...    Should Not Contain    ${ANSIBLE_TEMPLATE_OUTPUT}    not found

    IF    ${has_ansible_info}
        Log    📊 Ansible build template information:    console=yes
        Log    ${ANSIBLE_TEMPLATE_OUTPUT}    console=yes

        # Try to extract key fields
        ${has_template_name}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${ANSIBLE_TEMPLATE_OUTPUT}    template_name

        IF    ${has_template_name}
            Log    ✅ Build template information is complete    console=yes
        ELSE
            Log    ℹ️ Build template information is partial    console=yes
        END
    ELSE
        Log    ℹ️ Ansible build template not found    console=yes
        Log    ℹ️ Server may have been provisioned manually or using other tools    console=yes
    END

    Log    ℹ️ Ansible template analysis completed    console=yes
    Log    ✅ Ansible template analysis: INFORMATIONAL    console=yes

Normal - Security Patches Aging Analysis
    [Documentation]    ⏱️ Analyze age of installed patches and pending updates
    [Tags]             normal    informational    patches    security    compliance

    Log    🔍 Analyzing security patches aging...    console=yes

    # Count pending security updates
    ${pending_count}=    Count Lines    ${SECURITY_UPDATES_OUTPUT}

    Log    📊 Security Patch Status:    console=yes
    Log    📊 - Pending security updates: ${pending_count}    console=yes
    Log    📊 - CIP-007 R2 evaluation period: ${PATCH_EVALUATION_DAYS} days    console=yes
    Log    📊 - Recommended critical patch window: ${CRITICAL_PATCH_DAYS} days    console=yes

    IF    ${pending_count} > 0
        Log    ⚠️ Action Required: Review and evaluate pending security updates    console=yes
        Log    ⚠️ Reference: CIP-007-6 R2 Security Patch Management    console=yes
    END

    Log    ℹ️ Security patches aging analysis completed    console=yes
    Log    ✅ Patch aging analysis: INFORMATIONAL    console=yes

Normal - Generate Executive Summary
    [Documentation]    📊 Generate executive summary of all validation results
    [Tags]             normal    summary    reporting    documentation

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📊 EXECUTIVE SUMMARY - TEST-6 OS AND PACKAGE VALIDATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S

    ${summary_file}=    Set Variable    ${TEST6_RESULTS_DIR}/Test6_OS_Package_Executive_Summary.txt

    # Get validation counts
    ${missing_count}=    Get Length    ${MISSING_PACKAGES}
    ${prohibited_count}=    Get Length    ${PROHIBITED_PACKAGES_FOUND}
    ${pending_patches}=    Count Lines    ${SECURITY_UPDATES_OUTPUT}

    # Determine overall status
    ${validation_failed}=    Evaluate    ${missing_count} > 0 or ${prohibited_count} > 0
    ${overall_status}=    Set Variable If    ${validation_failed}    FAILED - REMEDIATION REQUIRED    PASSED - COMPLIANT

    ${summary}=    Catenate    SEPARATOR=\n
    ...    ================================================================
    ...    OS AND PACKAGE VALIDATION - EXECUTIVE SUMMARY
    ...    ================================================================
    ...    ${EMPTY}
    ...    Test Suite: ${TEST_SUITE_NAME}
    ...    Test Suite ID: ${TEST_SUITE_ID}
    ...    Target: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    OS Type: ${TARGET_OS_TYPE}
    ...    Connection: ${CONNECTION_TYPE}
    ...    Report Generated: ${timestamp}
    ...    ${EMPTY}
    ...    ================================================================
    ...    VALIDATION RESULTS
    ...    ================================================================
    ...    ${EMPTY}
    ...    Overall Status: ${overall_status}
    ...    ${EMPTY}
    ...    STEP 1 - Connection: COMPLETED
    ...    STEP 2 - Data Collection: COMPLETED
    ...    STEP 3 - Validation: COMPLETED
    ...    ${EMPTY}
    ...    ================================================================
    ...    COMPLIANCE ASSESSMENT
    ...    ================================================================
    ...    ${EMPTY}
    ...    OS Version Validation: See ${OS_INFO_FILE}
    ...    Required Packages: ${missing_count} missing
    ...    Prohibited Packages: ${prohibited_count} found
    ...    Pending Security Updates: ${pending_patches}
    ...    CIP-007 R2 Compliance: See ${CIP007_COMPLIANCE_FILE}
    ...    ${EMPTY}
    ...    ================================================================
    ...    DETAILED REPORTS
    ...    ================================================================
    ...    ${EMPTY}
    ...    - OS Information: ${OS_INFO_FILE}
    ...    - Kernel Information: ${KERNEL_INFO_FILE}
    ...    - Installed Packages: ${PACKAGES_FILE}
    ...    - Patch History: ${PATCH_HISTORY_FILE}
    ...    - Ansible Template: ${ANSIBLE_TEMPLATE_FILE_PATH}
    ...    - CIP-007 R2 Report: ${CIP007_COMPLIANCE_FILE}
    ...    ${EMPTY}
    ...    ================================================================
    ...    RECOMMENDATIONS
    ...    ================================================================
    ...    ${EMPTY}
    ...    1. Review all validation failures and take corrective action
    ...    2. Evaluate pending security updates per CIP-007 R2 requirements
    ...    3. Document technical or risk-based justification for any exceptions
    ...    4. Maintain patch management documentation for compliance audits
    ...    ${EMPTY}
    ...    ================================================================

    Create File    ${summary_file}    ${summary}

    Log To Console    \n${summary}

    Log    📄 Executive summary saved to: ${summary_file}    console=yes
    Log    ✅ Executive summary generated    console=yes

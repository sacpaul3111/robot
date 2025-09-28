*** Settings ***
Documentation    🖥️ OS Installation Validation Test Suite - Test-6
...              Base OS installation and patch compliance validation per CIP-007 R2
...              ✨ Features: OS verification, package validation, patch assessment, Ansible template verification
...              📊 Results: Unified HTML reports with enhanced dashboard
...              🎯 Run with: robot os_installation_validation.robot
...
Metadata         Test Suite    OS Installation Validation Test-6
Metadata         Environment   Production-Ready
Metadata         Version       1.0.0
Metadata         Features      OS Validation, Package Management, Patch Compliance, CIP-007 R2
Metadata         Reporting     Unified HTML Reports + Enhanced Dashboard

Resource         settings.resource

# Configure Robot Framework to output to html_reports directory
Default Tags     os-validation
Force Tags       automated

Suite Setup      Initialize Test Environment
Suite Teardown   Generate Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Target System Connection Establishment
    [Documentation]    🔗 Establish connection to target system via WinRM (Windows) or SSH (Linux)
    ...                Validates connectivity and authentication for OS validation tasks
    [Tags]             critical    connection    ssh    winrm    authentication

    Log    🔍 Establishing connection to target system: ${TARGET_HOST}    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Determine OS type and establish appropriate connection
    ${connection_result}=    Establish System Connection    ${TARGET_HOST}    ${TARGET_USERNAME}    ${TARGET_PASSWORD}    ${TARGET_OS_TYPE}
    Should Not Be Empty    ${connection_result}    Failed to establish connection to target system
    Set Suite Variable    ${SYSTEM_CONNECTION}    ${connection_result}

    # Validate connection is active
    ${connection_status}=    Validate System Connection    ${connection_result}
    Should Be Equal    ${connection_status}    connected

    Log    ✅ System connection: ESTABLISHED    console=yes
    Log    🔑 Connection Type: ${TARGET_OS_TYPE}    console=yes
    Log    📍 Target Host: ${TARGET_HOST}    console=yes
    Append To List    ${TEST_RESULTS}    System Connection: PASS - ${TARGET_OS_TYPE} connection to ${TARGET_HOST}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Operating System Information Collection
    [Documentation]    📊 Collect comprehensive OS version, kernel, and system information
    ...                Gathers OS release details, kernel version, architecture, and build information
    [Tags]             critical    os    collection    system-info    version

    Log    🔍 Collecting operating system information...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Collect OS version information
    ${os_info}=    Collect OS Information    ${SYSTEM_CONNECTION}
    Should Not Be Empty    ${os_info}    Failed to collect OS information
    Set Suite Variable    ${OS_INFO_DATA}    ${os_info}

    # Extract key OS details
    ${os_name}=    Get OS Name    ${os_info}
    ${os_version}=    Get OS Version    ${os_info}
    ${kernel_version}=    Get Kernel Version    ${os_info}
    ${architecture}=    Get OS Architecture    ${os_info}
    ${build_date}=    Get OS Build Date    ${os_info}

    # Store OS information
    Set Suite Variable    ${OS_NAME}    ${os_name}
    Set Suite Variable    ${OS_VERSION}    ${os_version}
    Set Suite Variable    ${KERNEL_VERSION}    ${kernel_version}
    Set Suite Variable    ${OS_ARCHITECTURE}    ${architecture}

    # Store metrics
    Append To List    ${PERFORMANCE_METRICS}    OS Name: ${os_name}
    Append To List    ${PERFORMANCE_METRICS}    OS Version: ${os_version}
    Append To List    ${PERFORMANCE_METRICS}    Kernel Version: ${kernel_version}
    Append To List    ${PERFORMANCE_METRICS}    Architecture: ${architecture}

    Log    ✅ OS information collected: SUCCESS    console=yes
    Log    🖥️ OS: ${os_name} ${os_version}    console=yes
    Log    🔧 Kernel: ${kernel_version}    console=yes
    Log    🏗️ Architecture: ${architecture}    console=yes
    Append To List    ${TEST_RESULTS}    OS Information: PASS - ${os_name} ${os_version}, Kernel: ${kernel_version}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Base Package Installation Verification
    [Documentation]    📦 Verify base OS packages and minimal installation compliance
    ...                Validates installed packages match base/minimal installation requirements
    [Tags]             critical    packages    installation    base-os    minimal

    Log    🔍 Verifying base package installation...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Collect installed packages
    ${package_list}=    Collect Installed Packages    ${SYSTEM_CONNECTION}
    Should Not Be Empty    ${package_list}    Failed to collect package information
    Set Suite Variable    ${PACKAGE_DATA}    ${package_list}

    # Validate base packages are installed
    ${base_validation}=    Validate Base Packages    ${package_list}    ${REQUIRED_BASE_PACKAGES}
    Should Be True    ${base_validation}    Base package requirements not met

    # Check for minimal installation compliance
    ${minimal_validation}=    Validate Minimal Installation    ${package_list}    ${EXCLUDED_PACKAGES}
    Should Be True    ${minimal_validation}    Installation contains non-minimal packages

    # Count installed packages
    ${package_count}=    Get Package Count    ${package_list}
    Set Suite Variable    ${PACKAGE_COUNT}    ${package_count}

    # Store package metrics
    Append To List    ${PERFORMANCE_METRICS}    Total Packages: ${package_count}
    Append To List    ${PERFORMANCE_METRICS}    Base Package Validation: PASSED
    Append To List    ${PERFORMANCE_METRICS}    Minimal Installation: VALIDATED

    Log    ✅ Package validation: COMPLIANT    console=yes
    Log    📦 Total Packages: ${package_count}    console=yes
    Log    ✔️ Base packages: VALIDATED    console=yes
    Log    ✔️ Minimal installation: CONFIRMED    console=yes
    Append To List    ${TEST_RESULTS}    Package Validation: PASS - ${package_count} packages, base/minimal compliant

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Security Patch Assessment
    [Documentation]    🔒 Assess current patch level and security update status
    ...                Validates patches are current and compliant with CIP-007 R2 requirements
    [Tags]             critical    patches    security    cip-007    r2    compliance

    Log    🔍 Assessing security patch status...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Collect patch information
    ${patch_info}=    Collect Patch Information    ${SYSTEM_CONNECTION}
    Should Not Be Empty    ${patch_info}    Failed to collect patch information
    Set Suite Variable    ${PATCH_DATA}    ${patch_info}

    # Get last patch date
    ${last_patch_date}=    Get Last Patch Date    ${patch_info}
    Set Suite Variable    ${LAST_PATCH_DATE}    ${last_patch_date}

    # Check for available updates
    ${available_updates}=    Check Available Updates    ${SYSTEM_CONNECTION}
    ${update_count}=    Get Update Count    ${available_updates}
    Set Suite Variable    ${AVAILABLE_UPDATES}    ${update_count}

    # Validate patch currency (within acceptable timeframe)
    ${patch_currency}=    Validate Patch Currency    ${last_patch_date}    ${MAX_PATCH_AGE_DAYS}
    Should Be True    ${patch_currency}    System patches are not current

    # Check critical security patches
    ${critical_patches}=    Check Critical Security Patches    ${available_updates}
    Should Be Equal As Numbers    ${critical_patches}    0    Critical security patches pending

    # Store patch metrics
    Append To List    ${PERFORMANCE_METRICS}    Last Patch Date: ${last_patch_date}
    Append To List    ${PERFORMANCE_METRICS}    Available Updates: ${update_count}
    Append To List    ${PERFORMANCE_METRICS}    Critical Patches: ${critical_patches}

    Log    ✅ Patch assessment: COMPLIANT    console=yes
    Log    📅 Last Patch: ${last_patch_date}    console=yes
    Log    🔄 Available Updates: ${update_count}    console=yes
    Log    🚨 Critical Patches: ${critical_patches}    console=yes
    Append To List    ${TEST_RESULTS}    Patch Assessment: PASS - Current as of ${last_patch_date}, ${update_count} updates available

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Ansible Build Template Verification
    [Documentation]    🤖 Verify Ansible playbook template and build compliance
    ...                Validates system was built using approved Ansible templates
    [Tags]             critical    ansible    template    build    automation

    Log    🔍 Verifying Ansible build template compliance...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Check for Ansible build artifacts
    ${ansible_artifacts}=    Check Ansible Build Artifacts    ${SYSTEM_CONNECTION}
    Should Not Be Empty    ${ansible_artifacts}    No Ansible build artifacts found

    # Verify template information
    ${template_info}=    Get Ansible Template Info    ${ansible_artifacts}
    Should Not Be Empty    ${template_info}    Failed to retrieve template information
    Set Suite Variable    ${TEMPLATE_INFO}    ${template_info}

    # Extract template details
    ${template_name}=    Get Template Name    ${template_info}
    ${template_version}=    Get Template Version    ${template_info}
    ${build_timestamp}=    Get Build Timestamp    ${template_info}

    # Validate against approved templates
    ${template_validation}=    Validate Ansible Template    ${template_name}    ${template_version}    ${APPROVED_TEMPLATES}
    Should Be True    ${template_validation}    Template not in approved list

    # Store template information
    Set Suite Variable    ${TEMPLATE_NAME}    ${template_name}
    Set Suite Variable    ${TEMPLATE_VERSION}    ${template_version}
    Set Suite Variable    ${BUILD_TIMESTAMP}    ${build_timestamp}

    # Store template metrics
    Append To List    ${PERFORMANCE_METRICS}    Template Name: ${template_name}
    Append To List    ${PERFORMANCE_METRICS}    Template Version: ${template_version}
    Append To List    ${PERFORMANCE_METRICS}    Build Timestamp: ${build_timestamp}

    Log    ✅ Ansible template: VALIDATED    console=yes
    Log    📋 Template: ${template_name}    console=yes
    Log    📊 Version: ${template_version}    console=yes
    Log    ⏰ Build Time: ${build_timestamp}    console=yes
    Append To List    ${TEST_RESULTS}    Ansible Template: PASS - ${template_name} v${template_version}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - CIP-007 R2 Compliance Validation
    [Documentation]    ✅ Final validation against CIP-007 R2 compliance requirements
    ...                Ensures all collected data meets regulatory compliance standards
    [Tags]             critical    cip-007    r2    compliance    regulatory    final

    Log    🔍 Performing CIP-007 R2 compliance validation...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Validate OS compliance
    ${os_compliance}=    Validate OS Against CIP007R2    ${OS_INFO_DATA}    ${CIP007_OS_REQUIREMENTS}
    Should Be True    ${os_compliance}    OS configuration non-compliant with CIP-007 R2

    # Validate package compliance
    ${package_compliance}=    Validate Packages Against CIP007R2    ${PACKAGE_DATA}    ${CIP007_PACKAGE_REQUIREMENTS}
    Should Be True    ${package_compliance}    Package configuration non-compliant with CIP-007 R2

    # Validate patch compliance
    ${patch_compliance}=    Validate Patches Against CIP007R2    ${PATCH_DATA}    ${CIP007_PATCH_REQUIREMENTS}
    Should Be True    ${patch_compliance}    Patch management non-compliant with CIP-007 R2

    # Validate template compliance
    ${template_compliance}=    Validate Template Against CIP007R2    ${TEMPLATE_INFO}    ${CIP007_TEMPLATE_REQUIREMENTS}
    Should Be True    ${template_compliance}    Build template non-compliant with CIP-007 R2

    # Generate compliance summary
    ${compliance_score}=    Calculate Compliance Score    ${os_compliance}    ${package_compliance}    ${patch_compliance}    ${template_compliance}
    Should Be Equal As Numbers    ${compliance_score}    100    Overall compliance score below 100%

    # Store compliance metrics
    Append To List    ${PERFORMANCE_METRICS}    OS Compliance: PASSED
    Append To List    ${PERFORMANCE_METRICS}    Package Compliance: PASSED
    Append To List    ${PERFORMANCE_METRICS}    Patch Compliance: PASSED
    Append To List    ${PERFORMANCE_METRICS}    Template Compliance: PASSED
    Append To List    ${PERFORMANCE_METRICS}    Overall Compliance Score: ${compliance_score}%

    Log    ✅ CIP-007 R2 compliance: VALIDATED    console=yes
    Log    🖥️ OS compliance: PASSED    console=yes
    Log    📦 Package compliance: PASSED    console=yes
    Log    🔒 Patch compliance: PASSED    console=yes
    Log    🤖 Template compliance: PASSED    console=yes
    Log    📊 Overall Score: ${compliance_score}%    console=yes
    Append To List    ${TEST_RESULTS}    CIP-007 R2 Compliance: PASS - 100% compliant, all requirements met

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Normal - System Documentation and Evidence Collection
    [Documentation]    📋 Collect comprehensive documentation and evidence for audit trail
    ...                Generates detailed reports with all collected system information
    [Tags]             normal    documentation    evidence    audit    reporting

    Log    📋 Collecting system documentation and evidence...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Generate comprehensive system report
    ${system_report}=    Generate System Report    ${OS_INFO_DATA}    ${PACKAGE_DATA}    ${PATCH_DATA}    ${TEMPLATE_INFO}
    Should Not Be Empty    ${system_report}    Failed to generate system report

    # Create evidence package
    ${evidence_package}=    Create Evidence Package    ${system_report}
    Should Not Be Empty    ${evidence_package}    Failed to create evidence package

    # Generate compliance certificate
    ${compliance_cert}=    Generate Compliance Certificate    ${OS_NAME}    ${OS_VERSION}    ${TEMPLATE_NAME}    ${LAST_PATCH_DATE}    ${KERNEL_VERSION}
    Should Not Be Empty    ${compliance_cert}    Failed to generate compliance certificate

    # Store documentation paths
    Set Suite Variable    ${SYSTEM_REPORT}    ${system_report}
    Set Suite Variable    ${EVIDENCE_PACKAGE}    ${evidence_package}
    Set Suite Variable    ${COMPLIANCE_CERTIFICATE}    ${compliance_cert}

    # Store documentation metrics
    Append To List    ${PERFORMANCE_METRICS}    System Report: ${system_report}
    Append To List    ${PERFORMANCE_METRICS}    Evidence Package: ${evidence_package}
    Append To List    ${PERFORMANCE_METRICS}    Compliance Certificate: ${compliance_cert}

    Log    ✅ Documentation collection: COMPLETED    console=yes
    Log    📄 System Report: ${system_report}    console=yes
    Log    📦 Evidence Package: ${evidence_package}    console=yes
    Log    🏆 Compliance Certificate: ${compliance_cert}    console=yes
    Append To List    ${TEST_RESULTS}    Documentation: PASS - Report, evidence, and certificate generated

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}
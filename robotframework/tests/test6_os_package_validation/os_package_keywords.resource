*** Settings ***
Documentation    📦 OS and Package Validation Keywords for Test-6
...              🔧 Provides keywords for connecting to Windows/Linux systems and collecting OS/package data
Library          SSHLibrary
Library          Process
Library          OperatingSystem
Library          Collections
Library          DateTime
Library          String
Library          ../../library/EDSLookup.py

*** Variables ***
${CONNECTION_ESTABLISHED}    ${FALSE}
${IS_WINDOWS}                ${FALSE}
${IS_LINUX}                  ${FALSE}

*** Keywords ***
Initialize OS Package Test Environment
    [Documentation]    🚀 Initialize test environment and lookup configuration from EDS

    Log    🚀 Initializing OS and Package Validation Test Suite (Test-6)    console=yes
    Log    🎯 Target Server: ${TARGET_HOSTNAME}    console=yes

    # Create directory structure
    Create Directory    ${TEST6_RESULTS_DIR}
    Create Directory    ${TEST6_DATA_DIR}

    # Lookup configuration from EDS sheet
    ${eds_config}=    Lookup Server Config    ${TARGET_HOSTNAME}

    # Set target configuration
    Set Suite Variable    ${TARGET_IP}           ${eds_config['ip']}
    Set Suite Variable    ${TARGET_OS_TYPE}      ${eds_config['os_type']}

    # Get credentials from environment variables with fallback to defaults
    ${ssh_user}=    Get Environment Variable    SSH_USERNAME    sac
    ${ssh_pass}=    Get Environment Variable    SSH_PASSWORD    sac
    ${winrm_user}=  Get Environment Variable    WINRM_USERNAME  administrator
    ${winrm_pass}=  Get Environment Variable    WINRM_PASSWORD  ${EMPTY}

    Set Suite Variable    ${SSH_USERNAME}      ${ssh_user}
    Set Suite Variable    ${SSH_PASSWORD}      ${ssh_pass}
    Set Suite Variable    ${WINRM_USERNAME}    ${winrm_user}
    Set Suite Variable    ${WINRM_PASSWORD}    ${winrm_pass}

    Log    📋 EDS Configuration Retrieved:    console=yes
    Log    📋 - IP Address: ${TARGET_IP}    console=yes
    Log    📋 - OS Type: ${TARGET_OS_TYPE}    console=yes

    # Determine connection type based on OS
    ${is_windows}=    Run Keyword And Return Status
    ...    Should Contain Any    ${TARGET_OS_TYPE}    Windows    windows    WIN

    IF    ${is_windows}
        Set Suite Variable    ${CONNECTION_TYPE}    WinRM
        Set Suite Variable    ${IS_WINDOWS}         ${TRUE}
        Set Suite Variable    ${IS_LINUX}           ${FALSE}
        Log    🪟 Detected Windows OS - Will use WinRM connection    console=yes
    ELSE
        Set Suite Variable    ${CONNECTION_TYPE}    SSH
        Set Suite Variable    ${IS_WINDOWS}         ${FALSE}
        Set Suite Variable    ${IS_LINUX}           ${TRUE}
        Log    🐧 Detected Linux OS - Will use SSH connection    console=yes
    END

    Log    ✅ OS Package Test Environment Initialized    console=yes

Connect To Target System
    [Documentation]    🔌 Establish connection to target system (SSH for Linux, WinRM for Windows)

    Log    🔌 Connecting to ${TARGET_HOSTNAME} (${TARGET_IP}) via ${CONNECTION_TYPE}...    console=yes

    IF    '${CONNECTION_TYPE}' == 'SSH'
        Connect Via SSH
    ELSE IF    '${CONNECTION_TYPE}' == 'WinRM'
        Connect Via WinRM
    ELSE
        Fail    ❌ Unknown connection type: ${CONNECTION_TYPE}
    END

    Set Suite Variable    ${CONNECTION_ESTABLISHED}    ${TRUE}
    Log    ✅ Connection established to ${TARGET_HOSTNAME}    console=yes

Connect Via SSH
    [Documentation]    🐧 Establish SSH connection to Linux system

    Log    🐧 Establishing SSH connection to ${TARGET_IP}...    console=yes

    Close All Connections
    Open Connection    ${TARGET_IP}    port=22    timeout=30
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}

    # Test connection
    ${test_output}=    Execute Command    echo "SSH connection successful"
    Should Contain    ${test_output}    SSH connection successful

    Log    ✅ SSH connection established    console=yes

Connect Via WinRM
    [Documentation]    🪟 Establish WinRM connection to Windows system

    Log    🪟 Establishing WinRM connection to ${TARGET_IP}...    console=yes

    # WinRM connection using PowerShell remoting
    # Note: Requires pywinrm library or alternative WinRM support
    Log    ⚠️ WinRM connection - Using PowerShell remoting    WARN

    # Test WinRM connection using PowerShell
    ${result}=    Run Process    powershell    -Command
    ...    Test-WSMan -ComputerName ${TARGET_IP} -ErrorAction SilentlyContinue

    Should Be Equal As Integers    ${result.rc}    0
    ...    ❌ WinRM connection test failed to ${TARGET_IP}

    Log    ✅ WinRM connection validated    console=yes

Execute Remote Command
    [Documentation]    🔧 Execute command on remote system (handles both SSH and WinRM)
    [Arguments]    ${command}

    IF    '${CONNECTION_TYPE}' == 'SSH'
        ${output}=    Execute Command    ${command}
        RETURN    ${output}
    ELSE IF    '${CONNECTION_TYPE}' == 'WinRM'
        ${output}=    Execute WinRM Command    ${command}
        RETURN    ${output}
    ELSE
        Fail    ❌ No active connection established
    END

Execute WinRM Command
    [Documentation]    🪟 Execute PowerShell command via WinRM
    [Arguments]    ${command}

    # Execute PowerShell command remotely via WinRM
    ${result}=    Run Process    powershell    -Command
    ...    Invoke-Command -ComputerName ${TARGET_IP} -Credential (New-Object PSCredential('${WINRM_USERNAME}', (ConvertTo-SecureString '${WINRM_PASSWORD}' -AsPlainText -Force))) -ScriptBlock {${command}}

    Should Be Equal As Integers    ${result.rc}    0
    ...    ❌ WinRM command execution failed: ${command}

    RETURN    ${result.stdout}

Collect OS Version Information
    [Documentation]    📋 Collect OS version information from target system

    Log    🔍 Collecting OS version information...    console=yes

    IF    ${IS_LINUX}
        ${os_output}=    Execute Remote Command    ${CMD_LINUX_OS_VERSION}
        ${kernel_output}=    Execute Remote Command    ${CMD_LINUX_KERNEL}
    ELSE IF    ${IS_WINDOWS}
        ${os_output}=    Execute Remote Command    ${CMD_WIN_OS_VERSION}
        ${kernel_output}=    Execute Remote Command    ${CMD_WIN_KERNEL}
    END

    # Save to file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${os_file}=    Set Variable    ${TEST6_DATA_DIR}/${OS_INFO_TEMPLATE} % (${timestamp})
    ${kernel_file}=    Set Variable    ${TEST6_DATA_DIR}/${KERNEL_INFO_TEMPLATE} % (${timestamp})

    Create File    ${os_file}
    ...    ====================================\n
    ...    OS VERSION INFORMATION\n
    ...    ====================================\n
    ...    Target: ${TARGET_HOSTNAME} (${TARGET_IP})\n
    ...    OS Type: ${TARGET_OS_TYPE}\n
    ...    Collection Time: ${timestamp}\n
    ...    ====================================\n\n
    ...    ${os_output}\n

    Create File    ${kernel_file}
    ...    ====================================\n
    ...    KERNEL INFORMATION\n
    ...    ====================================\n
    ...    Target: ${TARGET_HOSTNAME} (${TARGET_IP})\n
    ...    Collection Time: ${timestamp}\n
    ...    ====================================\n\n
    ...    ${kernel_output}\n

    Set Suite Variable    ${OS_VERSION_OUTPUT}    ${os_output}
    Set Suite Variable    ${KERNEL_OUTPUT}         ${kernel_output}
    Set Suite Variable    ${OS_INFO_FILE}          ${os_file}
    Set Suite Variable    ${KERNEL_INFO_FILE}      ${kernel_file}

    Log    📄 OS information saved to: ${os_file}    console=yes
    Log    📄 Kernel information saved to: ${kernel_file}    console=yes
    Log    ✅ OS version information collected    console=yes

Collect Installed Packages
    [Documentation]    📦 Collect list of all installed packages

    Log    🔍 Collecting installed packages list...    console=yes

    IF    ${IS_LINUX}
        ${packages_output}=    Execute Remote Command    ${CMD_LINUX_PACKAGES}
        ${base_packages}=      Execute Remote Command    ${CMD_LINUX_BASE_PACKAGES}
    ELSE IF    ${IS_WINDOWS}
        ${packages_output}=    Execute Remote Command    ${CMD_WIN_PACKAGES}
        ${base_packages}=      Execute Remote Command    ${CMD_WIN_BASE_PACKAGES}
    END

    # Save to file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${packages_file}=    Set Variable    ${TEST6_DATA_DIR}/${PACKAGE_LIST_TEMPLATE} % (${timestamp})

    Create File    ${packages_file}
    ...    ====================================\n
    ...    INSTALLED PACKAGES\n
    ...    ====================================\n
    ...    Target: ${TARGET_HOSTNAME} (${TARGET_IP})\n
    ...    OS Type: ${TARGET_OS_TYPE}\n
    ...    Collection Time: ${timestamp}\n
    ...    ====================================\n\n
    ...    FULL PACKAGE LIST:\n
    ...    ${packages_output}\n\n
    ...    ====================================\n
    ...    BASE PACKAGES:\n
    ...    ${base_packages}\n

    Set Suite Variable    ${PACKAGES_OUTPUT}       ${packages_output}
    Set Suite Variable    ${BASE_PACKAGES_OUTPUT}  ${base_packages}
    Set Suite Variable    ${PACKAGES_FILE}         ${packages_file}

    Log    📄 Package list saved to: ${packages_file}    console=yes
    Log    ✅ Installed packages collected    console=yes

Collect Patch History
    [Documentation]    🔄 Collect patch installation history

    Log    🔍 Collecting patch history...    console=yes

    IF    ${IS_LINUX}
        ${patch_output}=    Execute Remote Command    ${CMD_LINUX_PATCH_HISTORY}
        ${security_output}=    Execute Remote Command    ${CMD_LINUX_SECURITY_UPDATES}
    ELSE IF    ${IS_WINDOWS}
        ${patch_output}=    Execute Remote Command    ${CMD_WIN_PATCH_HISTORY}
        ${security_output}=    Execute Remote Command    ${CMD_WIN_SECURITY_UPDATES}
    END

    # Save to file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${patch_file}=    Set Variable    ${TEST6_DATA_DIR}/${PATCH_HISTORY_TEMPLATE} % (${timestamp})

    Create File    ${patch_file}
    ...    ====================================\n
    ...    PATCH HISTORY\n
    ...    ====================================\n
    ...    Target: ${TARGET_HOSTNAME} (${TARGET_IP})\n
    ...    OS Type: ${TARGET_OS_TYPE}\n
    ...    Collection Time: ${timestamp}\n
    ...    ====================================\n\n
    ...    RECENT PATCHES:\n
    ...    ${patch_output}\n\n
    ...    ====================================\n
    ...    PENDING SECURITY UPDATES:\n
    ...    ${security_output}\n

    Set Suite Variable    ${PATCH_HISTORY_OUTPUT}    ${patch_output}
    Set Suite Variable    ${SECURITY_UPDATES_OUTPUT}    ${security_output}
    Set Suite Variable    ${PATCH_HISTORY_FILE}      ${patch_file}

    Log    📄 Patch history saved to: ${patch_file}    console=yes
    Log    ✅ Patch history collected    console=yes

Collect Ansible Build Template Info
    [Documentation]    🤖 Collect Ansible build template information

    Log    🔍 Collecting Ansible build template information...    console=yes

    IF    ${IS_LINUX}
        ${template_info}=    Execute Remote Command    cat ${ANSIBLE_TEMPLATE_FILE} 2>/dev/null || echo "Ansible build info not found"
    ELSE IF    ${IS_WINDOWS}
        ${template_info}=    Execute Remote Command    Get-Content ${ANSIBLE_TEMPLATE_FILE_WIN} -ErrorAction SilentlyContinue
    END

    # Save to file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${template_file}=    Set Variable    ${TEST6_DATA_DIR}/${ANSIBLE_TEMPLATE_TEMPLATE} % (${timestamp})

    Create File    ${template_file}
    ...    ====================================\n
    ...    ANSIBLE BUILD TEMPLATE INFORMATION\n
    ...    ====================================\n
    ...    Target: ${TARGET_HOSTNAME} (${TARGET_IP})\n
    ...    Collection Time: ${timestamp}\n
    ...    ====================================\n\n
    ...    ${template_info}\n

    Set Suite Variable    ${ANSIBLE_TEMPLATE_OUTPUT}    ${template_info}
    Set Suite Variable    ${ANSIBLE_TEMPLATE_FILE_PATH}    ${template_file}

    Log    📄 Ansible template info saved to: ${template_file}    console=yes
    Log    ✅ Ansible build template information collected    console=yes

Validate OS Version Against Standards
    [Documentation]    ✅ Validate OS version against approved standards list

    Log    🔍 Validating OS version against approved standards...    console=yes

    ${os_version}=    Extract OS Version From Output    ${OS_VERSION_OUTPUT}

    # Determine which approved list to check
    ${validation_passed}=    Set Variable    ${FALSE}

    IF    ${IS_LINUX}
        ${validation_passed}=    Run Keyword And Return Status
        ...    Should Contain Any    ${os_version}    @{APPROVED_OS_VERSIONS_RHEL}    @{APPROVED_OS_VERSIONS_CENTOS}    @{APPROVED_OS_VERSIONS_UBUNTU}
    ELSE IF    ${IS_WINDOWS}
        ${validation_passed}=    Run Keyword And Return Status
        ...    Should Contain Any    ${os_version}    @{APPROVED_OS_VERSIONS_WINDOWS}
    END

    IF    ${validation_passed}
        Log    ✅ OS version ${os_version} is approved    console=yes
        RETURN    PASSED
    ELSE
        Log    ❌ OS version ${os_version} is NOT in approved list    console=yes
        RETURN    FAILED
    END

Extract OS Version From Output
    [Documentation]    🔧 Extract version number from OS output
    [Arguments]    ${os_output}

    # Extract version for RHEL/CentOS
    ${rhel_version}=    Get Regexp Matches    ${os_output}    VERSION_ID="?(\\d+\\.\\d+)"?    1
    ${rhel_match}=    Get Length    ${rhel_version}
    IF    ${rhel_match} > 0
        RETURN    ${rhel_version}[0]
    END

    # Extract version for Ubuntu
    ${ubuntu_version}=    Get Regexp Matches    ${os_output}    VERSION="?(\\d+\\.\\d+)"?    1
    ${ubuntu_match}=    Get Length    ${ubuntu_version}
    IF    ${ubuntu_match} > 0
        RETURN    ${ubuntu_version}[0]
    END

    # Extract version for Windows
    ${win_version}=    Get Regexp Matches    ${os_output}    (2019|2022)    1
    ${win_match}=    Get Length    ${win_version}
    IF    ${win_match} > 0
        RETURN    ${win_version}[0]
    END

    # Fallback
    RETURN    Unknown

Validate Required Base Packages
    [Documentation]    ✅ Validate that required base packages are installed

    Log    🔍 Validating required base packages...    console=yes

    ${missing_packages}=    Create List
    ${validation_results}=    Create Dictionary

    IF    ${IS_LINUX}
        FOR    ${package}    IN    @{REQUIRED_BASE_PACKAGES_LINUX}
            ${is_installed}=    Run Keyword And Return Status
            ...    Should Contain    ${BASE_PACKAGES_OUTPUT}    ${package}

            Set To Dictionary    ${validation_results}    ${package}    ${is_installed}

            IF    not ${is_installed}
                Append To List    ${missing_packages}    ${package}
                Log    ❌ Required package missing: ${package}    console=yes
            ELSE
                Log    ✅ Required package found: ${package}    console=yes
            END
        END
    ELSE IF    ${IS_WINDOWS}
        FOR    ${package}    IN    @{REQUIRED_BASE_PACKAGES_WINDOWS}
            ${is_installed}=    Run Keyword And Return Status
            ...    Should Contain    ${PACKAGES_OUTPUT}    ${package}

            Set To Dictionary    ${validation_results}    ${package}    ${is_installed}

            IF    not ${is_installed}
                Append To List    ${missing_packages}    ${package}
                Log    ❌ Required package missing: ${package}    console=yes
            ELSE
                Log    ✅ Required package found: ${package}    console=yes
            END
        END
    END

    Set Suite Variable    ${MISSING_PACKAGES}    ${missing_packages}
    Set Suite Variable    ${PACKAGE_VALIDATION_RESULTS}    ${validation_results}

    ${missing_count}=    Get Length    ${missing_packages}
    IF    ${missing_count} > 0
        Log    ⚠️ Total missing required packages: ${missing_count}    console=yes
    ELSE
        Log    ✅ All required base packages are installed    console=yes
    END

    RETURN    ${validation_results}

Validate Prohibited Packages Not Installed
    [Documentation]    ✅ Validate that prohibited packages are NOT installed

    Log    🔍 Validating prohibited packages are not installed...    console=yes

    ${found_prohibited}=    Create List
    ${validation_results}=    Create Dictionary

    FOR    ${package}    IN    @{PROHIBITED_PACKAGES}
        ${is_installed}=    Run Keyword And Return Status
        ...    Should Contain    ${PACKAGES_OUTPUT}    ${package}

        Set To Dictionary    ${validation_results}    ${package}    ${is_installed}

        IF    ${is_installed}
            Append To List    ${found_prohibited}    ${package}
            Log    ❌ SECURITY RISK: Prohibited package found: ${package}    console=yes
        ELSE
            Log    ✅ Prohibited package not found: ${package}    console=yes
        END
    END

    Set Suite Variable    ${PROHIBITED_PACKAGES_FOUND}    ${found_prohibited}

    ${prohibited_count}=    Get Length    ${found_prohibited}
    IF    ${prohibited_count} > 0
        Log    ❌ Security violation: ${prohibited_count} prohibited packages found    console=yes
    ELSE
        Log    ✅ No prohibited packages detected    console=yes
    END

    RETURN    ${validation_results}

Generate CIP-007 R2 Compliance Report
    [Documentation]    📋 Generate CIP-007 R2 compliance report

    Log    📋 Generating CIP-007 R2 compliance report...    console=yes

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${compliance_file}=    Set Variable    ${TEST6_RESULTS_DIR}/${COMPLIANCE_REPORT_TEMPLATE} % (${timestamp})

    # Analyze security updates for CIP-007 R2 compliance
    ${pending_count}=    Count Lines    ${SECURITY_UPDATES_OUTPUT}
    ${compliance_status}=    Set Variable If    ${pending_count} == 0    COMPLIANT    REVIEW REQUIRED

    ${report_content}=    Catenate    SEPARATOR=\n
    ...    ================================================================
    ...    CIP-007-6 R2 COMPLIANCE REPORT
    ...    SECURITY PATCH MANAGEMENT
    ...    ================================================================
    ...    ${EMPTY}
    ...    Test Suite: ${TEST_SUITE_NAME}
    ...    Target: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    OS Type: ${TARGET_OS_TYPE}
    ...    Report Generated: ${timestamp}
    ...    ${EMPTY}
    ...    ================================================================
    ...    COMPLIANCE REQUIREMENTS
    ...    ================================================================
    ...    ${EMPTY}
    ...    R2.1: Track security patches for applicable Cyber Assets
    ...    R2.2: Evaluate security patches within 35 calendar days
    ...    R2.3: Apply patches or document justification
    ...    R2.4: Document mitigation for patches not installed within 35 days
    ...    ${EMPTY}
    ...    ================================================================
    ...    ASSESSMENT RESULTS
    ...    ================================================================
    ...    ${EMPTY}
    ...    Overall Compliance Status: ${compliance_status}
    ...    Pending Security Updates: ${pending_count}
    ...    ${EMPTY}
    ...    OS VERSION VALIDATION: See ${OS_INFO_FILE}
    ...    INSTALLED PACKAGES: See ${PACKAGES_FILE}
    ...    PATCH HISTORY: See ${PATCH_HISTORY_FILE}
    ...    ANSIBLE TEMPLATE: See ${ANSIBLE_TEMPLATE_FILE_PATH}
    ...    ${EMPTY}
    ...    ================================================================
    ...    PENDING SECURITY UPDATES
    ...    ================================================================
    ...    ${EMPTY}
    ...    ${SECURITY_UPDATES_OUTPUT}
    ...    ${EMPTY}
    ...    ================================================================
    ...    RECOMMENDATIONS
    ...    ================================================================
    ...    ${EMPTY}
    ...    1. Review and evaluate all pending security updates
    ...    2. Apply applicable patches within 35-day requirement
    ...    3. Document technical or risk-based justification for non-applied patches
    ...    4. Implement compensating controls where patches cannot be applied
    ...    ${EMPTY}
    ...    ================================================================

    Create File    ${compliance_file}    ${report_content}

    Set Suite Variable    ${CIP007_COMPLIANCE_FILE}    ${compliance_file}

    Log    📄 CIP-007 R2 compliance report: ${compliance_file}    console=yes
    Log    ✅ Compliance report generated    console=yes

    RETURN    ${compliance_file}

Count Lines
    [Documentation]    🔧 Count non-empty lines in text
    [Arguments]    ${text}

    ${lines}=    Split To Lines    ${text}
    ${non_empty}=    Create List

    FOR    ${line}    IN    @{lines}
        ${stripped}=    Strip String    ${line}
        ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${stripped}
        IF    not ${is_empty}
            Append To List    ${non_empty}    ${line}
        END
    END

    ${count}=    Get Length    ${non_empty}
    RETURN    ${count}

Close All SSH Connections
    [Documentation]    🔌 Close all active SSH connections

    Run Keyword If    ${IS_LINUX}
    ...    Close All Connections

    Log    ✅ All connections closed    console=yes

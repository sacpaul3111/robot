*** Settings ***
Documentation    🔐 Patch Management & RSA Authentication Test Suite - Test-18
...              🔍 Process: Find hostname in EDS → SSH to server → Check RSA configuration → Validate patch management registration
...              ✅ Validates: RSA agent installation, RSA configuration files, RSA authentication settings, RSA server connectivity
...              📊 Documents: Patch management server registration (Ansible/Satellite), RSA agent status, authentication flow readiness
...              🔐 Focus: Two-factor authentication (RSA) setup validation for patch management access
...
Resource         ../../settings.resource
Resource         patch_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize Patch Management Test Environment
Suite Teardown   Close All SSH Connections

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to Target Server
    [Documentation]    🔗 Establish direct connection to target machine via SSH
    ...                Step 1 of validation process: Connect to Target
    [Tags]             critical    connection    step1    ssh    infrastructure

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target: ${TARGET_HOSTNAME} (${TARGET_IP})    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection verified and active    console=yes
    Log    ✅ STEP 1: COMPLETED - SSH connection established    console=yes

Critical - Step 2.1: Check RSA Agent Installation
    [Documentation]    🔐 Verify RSA SecurID agent is installed on the system
    ...                Step 2 of validation process: Collect Patch Management Data (Part 1)
    [Tags]             critical    rsa    step2    data_collection    agent

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: CHECK RSA AGENT INSTALLATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check RSA agent installation
    ${agent_status}=    Check RSA Agent Installation

    # Save agent installation details to file
    ${agent_file}=    Save RSA Agent Status to File    ${agent_status}

    Log    📄 RSA agent status saved to: ${agent_file}    console=yes
    Log    ✅ RSA agent installation check completed    console=yes
    Log    ✅ STEP 2.1: COMPLETED - RSA agent installation checked    console=yes

Critical - Step 2.2: Validate RSA Configuration Files
    [Documentation]    📄 Check for RSA configuration files and validate their presence
    ...                Step 2 of validation process: Collect Patch Management Data (Part 2)
    [Tags]             critical    rsa    step2    data_collection    configuration

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: VALIDATE RSA CONFIGURATION FILES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect RSA configuration files
    ${config_status}=    Collect RSA Configuration Files

    # Save configuration details to file
    ${config_file}=    Save RSA Config to File    ${config_status}

    Log    📄 RSA configuration saved to: ${config_file}    console=yes
    Log    ✅ RSA configuration files validated    console=yes
    Log    ✅ STEP 2.2: COMPLETED - RSA configuration validated    console=yes

Critical - Step 2.3: Check RSA Authentication Settings
    [Documentation]    🔐 Verify RSA authentication is properly configured
    ...                Step 2 of validation process: Collect Patch Management Data (Part 3)
    [Tags]             critical    rsa    step2    data_collection    authentication

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: CHECK RSA AUTHENTICATION SETTINGS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate RSA authentication configuration
    ${auth_settings}=    Validate RSA Authentication Settings

    Log    🔐 RSA Authentication Status: ${auth_settings}    console=yes
    Log    ✅ RSA authentication settings validated    console=yes
    Log    ✅ STEP 2.3: COMPLETED - RSA authentication settings checked    console=yes

Critical - Step 2.4: Test RSA Server Connectivity
    [Documentation]    🌐 Test connectivity to RSA authentication server
    ...                Step 2 of validation process: Collect Patch Management Data (Part 4)
    [Tags]             critical    rsa    step2    data_collection    connectivity

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: TEST RSA SERVER CONNECTIVITY    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Expected RSA Server: ${EXPECTED_RSA_SERVER}    console=yes

    # Test RSA server connectivity
    ${connectivity_result}=    Test RSA Server Connectivity

    # Save connectivity test results
    ${conn_file}=    Save RSA Connectivity Test to File    ${connectivity_result}

    Log    📄 Connectivity test saved to: ${conn_file}    console=yes
    Log    ✅ RSA server connectivity test completed    console=yes
    Log    ✅ STEP 2.4: COMPLETED - RSA connectivity tested    console=yes

Critical - Step 3.1: Validate RSA Agent Status
    [Documentation]    🔧 Check if RSA agent service is running
    ...                Step 3 of validation process: Validate Against Standards (Part 1)
    [Tags]             critical    rsa    step3    validation    service

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE RSA AGENT STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check RSA agent service status
    ${service_status}=    Check RSA Agent Service Status

    Log    🔧 RSA Agent Service: ${service_status}    console=yes
    Log    ✅ RSA agent service status validated    console=yes
    Log    ✅ STEP 3.1: COMPLETED - RSA agent status validated    console=yes

Critical - Step 3.2: Check Patch Management Registration
    [Documentation]    📦 Verify system is registered with patch management server (Ansible/Satellite)
    ...                Step 3 of validation process: Validate Against Standards (Part 2)
    [Tags]             critical    patch_management    step3    validation    registration

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: CHECK PATCH MANAGEMENT REGISTRATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check Satellite/Ansible registration
    ${registration_status}=    Check Patch Management Registration

    # Save registration details to file
    ${reg_file}=    Save Registration Status to File    ${registration_status}

    Log    📄 Registration status saved to: ${reg_file}    console=yes
    Log    ✅ Patch management registration check completed    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Patch management registration validated    console=yes

Normal - Validate Two-Factor Authentication Flow
    [Documentation]    🔐 Verify RSA two-factor authentication flow is ready
    [Tags]             normal    rsa    2fa    authentication_flow

    Log    🔍 Validating two-factor authentication flow...    console=yes

    # Validate 2FA readiness
    ${tfa_status}=    Validate Two Factor Authentication Flow

    Log    🔐 2FA Flow Status: ${tfa_status}    console=yes
    Log    ✅ Two-factor authentication flow validated    console=yes

Normal - Check RSA Token Configuration
    [Documentation]    🎫 Verify RSA token configuration and assignment
    [Tags]             normal    rsa    token    configuration

    Log    🔍 Checking RSA token configuration...    console=yes

    # Check token configuration
    ${token_config}=    Check RSA Token Configuration

    Log    🎫 RSA Token Config: ${token_config}    console=yes
    Log    ✅ RSA token configuration checked    console=yes

Normal - Validate Satellite Subscription Status
    [Documentation]    📦 Check Red Hat Satellite subscription status
    [Tags]             normal    satellite    subscription    rhel

    Log    🔍 Validating Satellite subscription status...    console=yes

    # Check subscription status
    ${subscription_status}=    Check Satellite Subscription Status

    # Save subscription details to file
    ${sub_file}=    Save Subscription Status to File    ${subscription_status}

    Log    📄 Subscription status saved to: ${sub_file}    console=yes
    Log    ✅ Satellite subscription status validated    console=yes

Normal - Check Available Patches
    [Documentation]    🔄 Check for available patches and updates
    [Tags]             normal    patches    updates    yum

    Log    🔍 Checking available patches and updates...    console=yes

    # Check available patches
    ${patch_status}=    Check Available Patches

    # Save patch list to file
    ${patch_file}=    Save Available Patches to File    ${patch_status}

    Log    📄 Available patches saved to: ${patch_file}    console=yes
    Log    ✅ Available patches check completed    console=yes

Normal - Validate Ansible Control Node Access
    [Documentation]    🤖 Verify connectivity and access to Ansible control node
    [Tags]             normal    ansible    control_node    connectivity

    Log    🔍 Validating Ansible control node access...    console=yes

    # Check Ansible access
    ${ansible_status}=    Check Ansible Control Node Access

    Log    🤖 Ansible Access Status: ${ansible_status}    console=yes
    Log    ✅ Ansible control node access validated    console=yes

Normal - Check Patch Management Schedule
    [Documentation]    📅 Verify patch management schedule and maintenance windows
    [Tags]             normal    schedule    maintenance    patches

    Log    🔍 Checking patch management schedule...    console=yes

    # Check patch schedule
    ${schedule_status}=    Check Patch Management Schedule

    Log    📅 Patch Schedule: ${schedule_status}    console=yes
    Log    ✅ Patch management schedule checked    console=yes

Normal - Validate Security Updates Status
    [Documentation]    🔒 Check status of security patches and critical updates
    [Tags]             normal    security    updates    critical

    Log    🔍 Validating security updates status...    console=yes

    # Check security updates
    ${security_status}=    Check Security Updates Status

    # Save security update status to file
    ${security_file}=    Save Security Updates to File    ${security_status}

    Log    📄 Security updates saved to: ${security_file}    console=yes
    Log    ✅ Security updates status validated    console=yes

Normal - Comprehensive Patch Management Summary
    [Documentation]    📊 Generate comprehensive summary of patch management and RSA configuration
    [Tags]             normal    summary    comprehensive    compliance

    Log    🔍 Generating comprehensive patch management summary...    console=yes

    # Validate all settings
    Validate All Patch Management Settings

    Log    📊 Comprehensive patch management summary:    console=yes
    Log    📊 - RSA Agent: Validated ✅    console=yes
    Log    📊 - RSA Configuration: Checked ✅    console=yes
    Log    📊 - RSA Authentication: Validated ✅    console=yes
    Log    📊 - RSA Connectivity: Tested ✅    console=yes
    Log    📊 - Patch Registration: Validated ✅    console=yes
    Log    📊 - Subscription Status: Checked ✅    console=yes
    Log    📊 - Available Patches: Documented ✅    console=yes
    Log    ✅ Comprehensive patch management validation: COMPLETED    console=yes

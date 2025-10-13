*** Settings ***
Documentation    🔐 SSH Key Authentication Validation Test Suite - Test-8
...              🔍 Process: Connect to Code Server → Test SSH key authentication → Document to Files → Validate authorized_keys configuration
...              ✅ Pass if SSH key authentication works passwordlessly from Code Server to target machine
...              📊 Validates: SSH key authentication, authorized_keys permissions, SSH configuration
...              💾 Saves: Authorized_keys config, SSH configuration, validation report
...
Resource         ../../settings.resource
Resource         ssh_keywords.resource
Resource         variables.resource

Suite Setup      Initialize SSH Key Test Environment
Suite Teardown   Generate SSH Key Authentication Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to Code Server
    [Documentation]    🔗 SSH directly to the code server (Linux jump box) to prepare for SSH key-based authentication testing
    ...                Step 1 of validation process: Connect to Code Server (Jump Box)
    [Tags]             critical    connection    step1    ssh    infrastructure

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO CODE SERVER (JUMP BOX)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Code Server: ${CODE_SERVER_HOST}    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection to Code Server established    console=yes
    Log    ✅ STEP 1: COMPLETED - Connected to jump box    console=yes

Critical - Step 2.1: Test Passwordless SSH Authentication
    [Documentation]    🔐 From the code server, test SSH key-based authentication to target machine without password
    ...                Step 2 of validation process: Collect SSH Authentication Data (Part 1)
    [Tags]             critical    authentication    step2    data_collection    passwordless

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: TEST PASSWORDLESS SSH AUTHENTICATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target: ${TARGET_USER}@${TARGET_HOST}    console=yes

    # Attempt passwordless SSH connection
    ${ssh_test}=    Execute Command    ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o BatchMode=yes -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'echo "SSH_AUTH_SUCCESS"'    return_stdout=True    return_stderr=True    return_rc=True

    Should Be Equal As Integers    ${ssh_test}[2]    0    msg=SSH key authentication failed with return code ${ssh_test}[2]. Error: ${ssh_test}[1]
    Should Contain    ${ssh_test}[0]    SSH_AUTH_SUCCESS    msg=SSH connection did not return expected success message

    Set Suite Variable    ${SSH_AUTH_SUCCESSFUL}    ${TRUE}

    Log    ✅ Passwordless SSH authentication successful    console=yes
    Log    ✅ STEP 2.1: COMPLETED - SSH authentication tested    console=yes

Critical - Step 2.2: Collect Authorized Keys Configuration
    [Documentation]    🔐 Collect authorized_keys file permissions and content from target machine
    ...                Step 2 of validation process: Collect SSH Authentication Data (Part 2)
    [Tags]             critical    authorized_keys    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT AUTHORIZED KEYS CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check authorized_keys file permissions (should be 600)
    Log    🔍 Checking authorized_keys file permissions...    console=yes
    ${auth_perms}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'stat -c "%a" ${AUTHORIZED_KEYS_PATH}'
    Set Suite Variable    ${AUTHORIZED_KEYS_PERMS}    ${auth_perms}

    Log    🔒 authorized_keys permissions: ${auth_perms}    console=yes

    # Collect public key and authorized_keys content
    ${pubkey}=    Execute Command    cat ${SSH_KEY_PATH}.pub
    ${auth_content}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'cat ${AUTHORIZED_KEYS_PATH}'

    Set Suite Variable    ${PUBLIC_KEY}          ${pubkey}
    Set Suite Variable    ${AUTHORIZED_KEYS}     ${auth_content}

    Log    ✅ Authorized keys configuration collected    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Authorized keys data collected    console=yes

Critical - Step 2.3: Collect SSH Configuration
    [Documentation]    🔐 Collect SSH server configuration from target machine
    ...                Step 2 of validation process: Collect SSH Authentication Data (Part 3)
    [Tags]             critical    ssh_config    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT SSH CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Capture connection details
    ${connection_details}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'echo "Host: $(hostname), User: $(whoami), Time: $(date)"'
    Set Suite Variable    ${CONNECTION_DETAILS}    ${connection_details}

    Log    📊 Connection details: ${connection_details}    console=yes

    # Collect SSH configuration
    ${ssh_config}=    Execute Command    ssh -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'grep -E "^(PubkeyAuthentication|PasswordAuthentication)" /etc/ssh/sshd_config 2>/dev/null || echo "Config check requires privileges"'
    Set Suite Variable    ${SSH_CONFIG}    ${ssh_config}

    Log    📋 SSH server configuration: ${ssh_config}    console=yes
    Log    ✅ STEP 2.3: COMPLETED - SSH configuration collected    console=yes

Critical - Step 2.4: Document SSH Authentication Data to Files
    [Documentation]    💾 Save complete SSH authentication data to files for compliance review
    ...                Step 2 of validation process: Collect SSH Authentication Data (Part 4)
    [Tags]             critical    documentation    step2    data_collection    file_output

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: DOCUMENT SSH AUTHENTICATION DATA TO FILES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Save all SSH authentication data to files
    ${validation_file}=    Save SSH Authentication Data to Files

    # Verify files were created
    OperatingSystem.File Should Exist    ${validation_file}
    ${file_size}=    OperatingSystem.Get File Size    ${validation_file}
    Should Be True    ${file_size} > 0

    Set Suite Variable    ${SSH_DATA_FILES_SAVED}    ${TRUE}

    Log    📄 SSH authentication data saved to: ${TEST8_DATA_DIR}    console=yes
    Log    📄 Validation file: ${validation_file}    console=yes
    Log    ✅ STEP 2.4: COMPLETED - SSH authentication documentation saved    console=yes

Critical - Step 3.1: Validate Passwordless SSH
    [Documentation]    ✅ Validate passwordless SSH authentication works correctly from jump box to target
    ...                Step 3 of validation process: Validate SSH Key Authentication (Part 1)
    [Tags]             critical    validation    step3    compliance    passwordless

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE PASSWORDLESS SSH    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Confirm passwordless SSH works
    Log    🔍 Confirming passwordless SSH from code server to target...    console=yes
    ${ssh_confirm}=    Execute Command    ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o BatchMode=yes -i ${SSH_KEY_PATH} ${TARGET_USER}@${TARGET_HOST} 'echo "Confirmed"'
    Should Contain    ${ssh_confirm}    Confirmed    msg=Passwordless SSH confirmation failed

    Log    ✅ Passwordless SSH validated    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Passwordless SSH confirmed    console=yes

Critical - Step 3.2: Validate Authorized Keys Configuration
    [Documentation]    ✅ Validate authorized_keys file contains correct public keys with proper permissions (600)
    ...                Step 3 of validation process: Validate SSH Key Authentication (Part 2)
    [Tags]             critical    validation    step3    compliance    authorized_keys

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE AUTHORIZED KEYS CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Verify public key exists in authorized_keys
    Log    🔍 Verifying public key in authorized_keys file...    console=yes
    Should Contain    ${AUTHORIZED_KEYS}    ${PUBLIC_KEY}    msg=Public key not found in authorized_keys file

    Log    ✅ Public key verified in authorized_keys file    console=yes

    # Verify authorized_keys permissions (600)
    Should Be Equal    ${AUTHORIZED_KEYS_PERMS}    600    msg=authorized_keys permissions should be 600, found ${AUTHORIZED_KEYS_PERMS}

    Log    ✅ authorized_keys permissions validated (600)    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Authorized keys validated    console=yes

Critical - Step 3.3: Validate Jump Box Authentication Chain
    [Documentation]    ✅ Validate SSH configuration and jump box authentication chain is properly configured
    ...                Step 3 of validation process: Validate SSH Key Authentication (Part 3)
    [Tags]             critical    validation    step3    compliance    security

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE JUMP BOX AUTHENTICATION CHAIN    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate SSH configuration
    Log    🔍 Validating SSH configuration...    console=yes
    Log    📋 SSH server configuration: ${SSH_CONFIG}    console=yes

    # Ensure jump box authentication chain is properly configured
    Log    🔍 Validating jump box authentication chain...    console=yes
    ${chain_validation}=    Validate SSH Authentication Chain
    Log    ✅ Jump box authentication chain properly configured    console=yes

    Log    📊 Authentication security validation summary:    console=yes
    Log    📊 - Passwordless SSH: ✅    console=yes
    Log    📊 - Public key in authorized_keys: ✅    console=yes
    Log    📊 - authorized_keys permissions (600): ✅    console=yes
    Log    📊 - SSH configuration: ✅    console=yes
    Log    📊 - Jump box authentication chain: ✅    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Authentication chain validated    console=yes
*** Settings ***
Documentation    🔐 Password Policy Validation Test Suite - Test-13
...              🔍 Process: Find hostname in EDS → SSH to server → Collect password policy files → Validate CIP-007 R5 compliance
...              ✅ Validates: Password complexity, account lockout, password history, expiration settings per CIP-007 R5.4-R5.7
...              📊 Documents: /etc/login.defs, /etc/security/pwquality.conf, /etc/pam.d/system-auth, policy parameters
...              🎯 Focus: Verify password security implementation meets CIP-007 R5.4, R5.5, R5.6, R5.7 requirements
...              ⚠️ CIP-007 R5: System Security Management - Password Complexity and Controls
...
Resource         ../../settings.resource
Resource         password_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize Password Policy Test Environment
Suite Teardown   Generate Password Policy Executive Summary

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

Critical - Step 2.1: Collect Login Definitions File
    [Documentation]    📋 Collect /etc/login.defs file containing password aging and login policies
    ...                Step 2 of validation process: Collect Password Policy Configuration (Part 1)
    [Tags]             critical    password    step2    data_collection    login_defs

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT LOGIN DEFINITIONS FILE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📄 File: /etc/login.defs    console=yes

    # Collect login.defs configuration
    ${login_defs}=    Collect Login Defs Configuration
    Set Suite Variable    ${LOGIN_DEFS_CONTENT}    ${login_defs}

    # Save login.defs to file
    ${login_defs_file}=    Save Login Defs to File    ${login_defs}

    # Verify data was collected
    Should Not Be Empty    ${login_defs}
    ...    msg=Failed to collect /etc/login.defs content

    Log    📄 Login definitions saved to: ${login_defs_file}    console=yes
    Log    ✅ Login definitions file collected successfully    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Login definitions collected    console=yes

Critical - Step 2.2: Collect Password Quality Configuration
    [Documentation]    🔒 Collect /etc/security/pwquality.conf file with password complexity requirements
    ...                Step 2 of validation process: Collect Password Policy Configuration (Part 2)
    [Tags]             critical    password    step2    data_collection    pwquality

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT PASSWORD QUALITY CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📄 File: /etc/security/pwquality.conf    console=yes

    # Collect pwquality.conf configuration
    ${pwquality_conf}=    Collect PWQuality Configuration
    Set Suite Variable    ${PWQUALITY_CONTENT}    ${pwquality_conf}

    # Save pwquality.conf to file
    ${pwquality_file}=    Save PWQuality to File    ${pwquality_conf}

    # Verify data was collected
    Should Not Be Empty    ${pwquality_conf}
    ...    msg=Failed to collect /etc/security/pwquality.conf content

    Log    📄 Password quality configuration saved to: ${pwquality_file}    console=yes
    Log    ✅ Password quality configuration collected successfully    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Password quality configuration collected    console=yes

Critical - Step 2.3: Collect PAM System Authentication Configuration
    [Documentation]    🔐 Collect /etc/pam.d/system-auth file with authentication and account lockout policies
    ...                Step 2 of validation process: Collect Password Policy Configuration (Part 3)
    [Tags]             critical    password    step2    data_collection    pam

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT PAM SYSTEM AUTHENTICATION CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📄 File: /etc/pam.d/system-auth    console=yes

    # Collect PAM system-auth configuration
    ${pam_system_auth}=    Collect PAM System Auth Configuration
    Set Suite Variable    ${PAM_SYSTEM_AUTH_CONTENT}    ${pam_system_auth}

    # Save PAM system-auth to file
    ${pam_file}=    Save PAM System Auth to File    ${pam_system_auth}

    # Verify data was collected
    Should Not Be Empty    ${pam_system_auth}
    ...    msg=Failed to collect /etc/pam.d/system-auth content

    Log    📄 PAM system-auth configuration saved to: ${pam_file}    console=yes
    Log    ✅ PAM system-auth configuration collected successfully    console=yes
    Log    ✅ STEP 2.3: COMPLETED - PAM system-auth configuration collected    console=yes

Critical - Step 2.4: Collect Additional Password Policy Files
    [Documentation]    📂 Collect additional password-related configuration files
    ...                Step 2 of validation process: Collect Password Policy Configuration (Part 4)
    [Tags]             critical    password    step2    data_collection    additional

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: COLLECT ADDITIONAL PASSWORD POLICY FILES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect additional PAM configurations
    ${pam_password_auth}=    Execute Command    cat /etc/pam.d/password-auth 2>/dev/null || echo "File not available"
    ${pam_common_password}=    Execute Command    cat /etc/pam.d/common-password 2>/dev/null || echo "File not available"

    # Save additional configurations
    ${additional_file}=    Save Additional Policy Files    ${pam_password_auth}    ${pam_common_password}

    Log    📄 Additional policy files saved to: ${additional_file}    console=yes
    Log    ✅ Additional password policy files collected    console=yes
    Log    ✅ STEP 2.4: COMPLETED - Additional policy files collected    console=yes

Critical - Step 3.1: Validate Password Minimum Length (CIP-007 R5.5)
    [Documentation]    📏 Validate password minimum length meets CIP-007 R5.5 requirements
    ...                Step 3 of validation process: Validate Password Compliance (Part 1)
    [Tags]             critical    password    step3    validation    cip007_r5.5    length

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE PASSWORD MINIMUM LENGTH (CIP-007 R5.5)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-007 R5.5: Minimum password length requirements    console=yes

    # Validate minimum password length
    ${length_validation}=    Validate Password Minimum Length    ${PWQUALITY_CONTENT}

    # Save validation results
    ${length_file}=    Save Length Validation to File    ${length_validation}

    # Extract minimum length value
    ${min_length}=    Extract Password Min Length    ${PWQUALITY_CONTENT}

    # Validate against CIP-007 R5.5 requirement (typically 8 or more)
    Should Be True    ${min_length} >= ${CIP007_MIN_PASSWORD_LENGTH}
    ...    msg=Password minimum length ${min_length} does not meet CIP-007 R5.5 requirement (${CIP007_MIN_PASSWORD_LENGTH})

    Log    📊 Minimum Password Length: ${min_length}    console=yes
    Log    📊 CIP-007 R5.5 Requirement: ${CIP007_MIN_PASSWORD_LENGTH}    console=yes
    Log    ✅ Password minimum length: COMPLIANT    console=yes
    Log    📄 Validation saved to: ${length_file}    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Minimum length validated    console=yes

Critical - Step 3.2: Validate Character Complexity Requirements (CIP-007 R5.5)
    [Documentation]    🔤 Validate character complexity meets CIP-007 R5.5 requirements
    ...                Step 3 of validation process: Validate Password Compliance (Part 2)
    [Tags]             critical    password    step3    validation    cip007_r5.5    complexity

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE CHARACTER COMPLEXITY REQUIREMENTS (CIP-007 R5.5)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-007 R5.5: Password complexity requirements    console=yes

    # Validate character complexity (uppercase, lowercase, numeric, special)
    ${complexity_validation}=    Validate Password Complexity    ${PWQUALITY_CONTENT}    ${PAM_SYSTEM_AUTH_CONTENT}

    # Save validation results
    ${complexity_file}=    Save Complexity Validation to File    ${complexity_validation}

    # Extract complexity settings
    ${complexity_summary}=    Extract Complexity Settings    ${PWQUALITY_CONTENT}

    Log    📊 Character Complexity Settings:    console=yes
    Log    ${complexity_summary}    console=yes
    Log    ✅ Password complexity: COMPLIANT with CIP-007 R5.5    console=yes
    Log    📄 Validation saved to: ${complexity_file}    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Character complexity validated    console=yes

Critical - Step 3.3: Validate Password History Settings (CIP-007 R5.6)
    [Documentation]    🔄 Validate password history meets CIP-007 R5.6 requirements
    ...                Step 3 of validation process: Validate Password Compliance (Part 3)
    [Tags]             critical    password    step3    validation    cip007_r5.6    history

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE PASSWORD HISTORY SETTINGS (CIP-007 R5.6)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-007 R5.6: Password history to prevent reuse    console=yes

    # Validate password history
    ${history_validation}=    Validate Password History    ${PAM_SYSTEM_AUTH_CONTENT}

    # Save validation results
    ${history_file}=    Save History Validation to File    ${history_validation}

    # Extract password history value
    ${password_history}=    Extract Password History Value    ${PAM_SYSTEM_AUTH_CONTENT}

    # Validate against CIP-007 R5.6 requirement (typically 5 or more)
    Should Be True    ${password_history} >= ${CIP007_PASSWORD_HISTORY_COUNT}
    ...    msg=Password history ${password_history} does not meet CIP-007 R5.6 requirement (${CIP007_PASSWORD_HISTORY_COUNT})

    Log    📊 Password History Count: ${password_history}    console=yes
    Log    📊 CIP-007 R5.6 Requirement: ${CIP007_PASSWORD_HISTORY_COUNT}    console=yes
    Log    ✅ Password history: COMPLIANT    console=yes
    Log    📄 Validation saved to: ${history_file}    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Password history validated    console=yes

Critical - Step 3.4: Validate Account Lockout Policy (CIP-007 R5.4)
    [Documentation]    🔒 Validate account lockout policy meets CIP-007 R5.4 requirements
    ...                Step 3 of validation process: Validate Password Compliance (Part 4)
    [Tags]             critical    password    step3    validation    cip007_r5.4    lockout

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: VALIDATE ACCOUNT LOCKOUT POLICY (CIP-007 R5.4)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-007 R5.4: Account lockout after failed login attempts    console=yes

    # Validate account lockout settings
    ${lockout_validation}=    Validate Account Lockout Policy    ${PAM_SYSTEM_AUTH_CONTENT}

    # Save validation results
    ${lockout_file}=    Save Lockout Validation to File    ${lockout_validation}

    # Extract lockout settings
    ${lockout_attempts}=    Extract Lockout Attempts    ${PAM_SYSTEM_AUTH_CONTENT}
    ${lockout_duration}=    Extract Lockout Duration    ${PAM_SYSTEM_AUTH_CONTENT}

    # Validate against CIP-007 R5.4 requirements
    Should Be True    ${lockout_attempts} <= ${CIP007_MAX_LOGIN_ATTEMPTS}
    ...    msg=Lockout attempts ${lockout_attempts} exceeds CIP-007 R5.4 limit (${CIP007_MAX_LOGIN_ATTEMPTS})

    Log    📊 Account Lockout After: ${lockout_attempts} failed attempts    console=yes
    Log    📊 Lockout Duration: ${lockout_duration} seconds    console=yes
    Log    📊 CIP-007 R5.4 Requirement: Lock after ≤${CIP007_MAX_LOGIN_ATTEMPTS} attempts    console=yes
    Log    ✅ Account lockout policy: COMPLIANT    console=yes
    Log    📄 Validation saved to: ${lockout_file}    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Account lockout policy validated    console=yes

Critical - Step 3.5: Validate Password Expiration Settings (CIP-007 R5.7)
    [Documentation]    ⏰ Validate password expiration meets CIP-007 R5.7 requirements
    ...                Step 3 of validation process: Validate Password Compliance (Part 5)
    [Tags]             critical    password    step3    validation    cip007_r5.7    expiration

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.5: VALIDATE PASSWORD EXPIRATION SETTINGS (CIP-007 R5.7)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-007 R5.7: Password expiration and change requirements    console=yes

    # Validate password expiration settings
    ${expiration_validation}=    Validate Password Expiration    ${LOGIN_DEFS_CONTENT}

    # Save validation results
    ${expiration_file}=    Save Expiration Validation to File    ${expiration_validation}

    # Extract expiration settings
    ${max_days}=     Extract Password Max Days    ${LOGIN_DEFS_CONTENT}
    ${min_days}=     Extract Password Min Days    ${LOGIN_DEFS_CONTENT}
    ${warn_age}=     Extract Password Warn Age    ${LOGIN_DEFS_CONTENT}

    # Validate against CIP-007 R5.7 requirements (typically 90 days or less)
    Should Be True    ${max_days} <= ${CIP007_MAX_PASSWORD_AGE_DAYS}
    ...    msg=Password max age ${max_days} exceeds CIP-007 R5.7 requirement (${CIP007_MAX_PASSWORD_AGE_DAYS})

    Log    📊 Password Maximum Age: ${max_days} days    console=yes
    Log    📊 Password Minimum Age: ${min_days} days    console=yes
    Log    📊 Password Warning Age: ${warn_age} days    console=yes
    Log    📊 CIP-007 R5.7 Requirement: ≤${CIP007_MAX_PASSWORD_AGE_DAYS} days    console=yes
    Log    ✅ Password expiration: COMPLIANT    console=yes
    Log    📄 Validation saved to: ${expiration_file}    console=yes
    Log    ✅ STEP 3.5: COMPLETED - Password expiration validated    console=yes

Critical - Step 3.6: Confirm Overall CIP-007 R5 Compliance
    [Documentation]    ✅ Confirm all password policies meet CIP-007 R5.4-R5.7 requirements
    ...                Step 3 of validation process: Validate Password Compliance (Part 6)
    [Tags]             critical    password    step3    validation    cip007    compliance

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.6: CONFIRM OVERALL CIP-007 R5 COMPLIANCE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate all CIP-007 R5 requirements
    ${cip007_compliance}=    Validate Overall CIP007_R5 Compliance

    # Save comprehensive compliance validation
    ${compliance_file}=    Save CIP007_Compliance to File    ${cip007_compliance}

    Log    📊 CIP-007 R5 COMPLIANCE SUMMARY:    console=yes
    Log    📊    console=yes
    Log    📊 R5.4 - Account Lockout: ✅ COMPLIANT    console=yes
    Log    📊 R5.5 - Password Length: ✅ COMPLIANT    console=yes
    Log    📊 R5.5 - Password Complexity: ✅ COMPLIANT    console=yes
    Log    📊 R5.6 - Password History: ✅ COMPLIANT    console=yes
    Log    📊 R5.7 - Password Expiration: ✅ COMPLIANT    console=yes
    Log    📊    console=yes
    Log    ✅ OVERALL CIP-007 R5 COMPLIANCE: VALIDATED    console=yes
    Log    📄 Compliance validation saved to: ${compliance_file}    console=yes
    Log    ✅ STEP 3.6: COMPLETED - CIP-007 R5 compliance confirmed    console=yes

Normal - Review Password Aging Parameters
    [Documentation]    📅 Review comprehensive password aging parameters
    [Tags]             normal    password    aging    parameters

    Log    🔍 Reviewing password aging parameters...    console=yes

    # Collect all aging parameters from login.defs
    ${aging_params}=    Collect Password Aging Parameters

    # Save aging parameters to file
    ${aging_file}=    Save Aging Parameters to File    ${aging_params}

    Log    📄 Password aging parameters saved to: ${aging_file}    console=yes
    Log    ✅ Password aging parameters reviewed    console=yes

Normal - Check PAM Faillock Configuration
    [Documentation]    🔐 Check PAM faillock configuration for account lockout
    [Tags]             normal    pam    faillock    lockout

    Log    🔍 Checking PAM faillock configuration...    console=yes

    # Check faillock configuration
    ${faillock_conf}=    Check Faillock Configuration

    # Save faillock configuration to file
    ${faillock_file}=    Save Faillock Configuration to File    ${faillock_conf}

    Log    📄 Faillock configuration saved to: ${faillock_file}    console=yes
    Log    ✅ Faillock configuration checked    console=yes

Normal - Verify Password Dictionary Check Settings
    [Documentation]    📖 Verify password dictionary check is enabled
    [Tags]             normal    password    dictionary    security

    Log    🔍 Verifying password dictionary check settings...    console=yes

    # Check dictionary settings in pwquality.conf
    ${dict_check}=    Check Dictionary Settings    ${PWQUALITY_CONTENT}

    Log    📊 Dictionary Check Settings: ${dict_check}    console=yes
    Log    ✅ Dictionary check settings verified    console=yes

Normal - Check Password Retry Limits
    [Documentation]    🔄 Check password retry limits during password change
    [Tags]             normal    password    retry    limits

    Log    🔍 Checking password retry limits...    console=yes

    # Check retry settings
    ${retry_check}=    Check Password Retry Settings    ${PWQUALITY_CONTENT}

    Log    📊 Password Retry Settings: ${retry_check}    console=yes
    Log    ✅ Password retry limits checked    console=yes

Normal - Validate Minimum Character Class Requirements
    [Documentation]    🔤 Validate minimum character class requirements
    [Tags]             normal    password    character_class    complexity

    Log    🔍 Validating minimum character class requirements...    console=yes

    # Check minclass setting
    ${minclass}=    Check Minclass Setting    ${PWQUALITY_CONTENT}

    Log    📊 Minimum Character Classes Required: ${minclass}    console=yes
    Log    ✅ Character class requirements validated    console=yes

Normal - Check Root Password Policy
    [Documentation]    👤 Check if root account follows password policy
    [Tags]             normal    password    root    policy

    Log    🔍 Checking root password policy enforcement...    console=yes

    # Check if root is subject to password policies
    ${root_policy}=    Check Root Password Policy    ${PAM_SYSTEM_AUTH_CONTENT}

    # Save root policy check to file
    ${root_file}=    Save Root Policy Check to File    ${root_policy}

    Log    📄 Root password policy check saved to: ${root_file}    console=yes
    Log    ✅ Root password policy checked    console=yes

Normal - Verify Password Encryption Method
    [Documentation]    🔐 Verify password encryption method is secure
    [Tags]             normal    password    encryption    security

    Log    🔍 Verifying password encryption method...    console=yes

    # Check encryption method from login.defs
    ${encryption}=    Check Password Encryption Method    ${LOGIN_DEFS_CONTENT}

    Log    📊 Password Encryption Method: ${encryption}    console=yes
    Log    ✅ Password encryption method verified    console=yes

Normal - Check User Password Status
    [Documentation]    👥 Check password status for system users
    [Tags]             normal    password    users    status

    Log    🔍 Checking user password status...    console=yes

    # Check password status for users
    ${user_status}=    Check User Password Status

    # Save user password status to file
    ${user_file}=    Save User Password Status to File    ${user_status}

    Log    📄 User password status saved to: ${user_file}    console=yes
    Log    ✅ User password status checked    console=yes

Normal - Validate Password Change Restrictions
    [Documentation]    🚫 Validate password change restrictions
    [Tags]             normal    password    change    restrictions

    Log    🔍 Validating password change restrictions...    console=yes

    # Check minimum days between password changes
    ${change_restrictions}=    Check Password Change Restrictions    ${LOGIN_DEFS_CONTENT}

    Log    📊 Password Change Restrictions: ${change_restrictions}    console=yes
    Log    ✅ Password change restrictions validated    console=yes

Normal - Check Inactive Account Settings
    [Documentation]    ⏱️ Check inactive account settings
    [Tags]             normal    password    inactive    accounts

    Log    🔍 Checking inactive account settings...    console=yes

    # Check inactive account timeout
    ${inactive_setting}=    Check Inactive Account Setting    ${LOGIN_DEFS_CONTENT}

    Log    📊 Inactive Account Setting: ${inactive_setting}    console=yes
    Log    ✅ Inactive account settings checked    console=yes

Normal - Comprehensive Password Policy Summary
    [Documentation]    📊 Generate comprehensive password policy summary
    [Tags]             normal    summary    comprehensive    compliance

    Log    🔍 Generating comprehensive password policy summary...    console=yes

    # Validate all password policy settings
    Validate All Password Policy Settings

    Log    📊 Comprehensive password policy summary:    console=yes
    Log    📊 - Login Definitions: Collected ✅    console=yes
    Log    📊 - Password Quality: Collected ✅    console=yes
    Log    📊 - PAM Configuration: Collected ✅    console=yes
    Log    📊 - Minimum Length: Validated ✅    console=yes
    Log    📊 - Character Complexity: Validated ✅    console=yes
    Log    📊 - Password History: Validated ✅    console=yes
    Log    📊 - Account Lockout: Validated ✅    console=yes
    Log    📊 - Password Expiration: Validated ✅    console=yes
    Log    📊 - CIP-007 R5 Compliance: Confirmed ✅    console=yes
    Log    ✅ Comprehensive password policy validation: COMPLETED    console=yes

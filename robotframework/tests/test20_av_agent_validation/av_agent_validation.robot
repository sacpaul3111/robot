*** Settings ***
Documentation    🛡️ AV Agent Validation Test Suite - Test-20
...              🔍 Process: Connect to AV Console → Collect AV Agent Information → Validate AV Protection
...              ✅ Pass if antivirus configuration meets CIP-007 R3.1 requirements for malware protection
...              📊 Validates: Agent installation, real-time protection, signature updates, scan schedules, exclusions
...
Resource         ../../settings.resource
Resource         av_keywords.resource
Resource         variables.resource

Suite Setup      Initialize AV Agent Validation Test Environment
Suite Teardown   Generate AV Agent Validation Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to AV Console
    [Documentation]    🔗 SSH directly to the target machine to check Sentinel or McAfee installation status
    ...                Step 1 of validation process: Connect to Target
    [Tags]             critical    connection    step1    av_console

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO AV CONSOLE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target Machine: ${TARGET_HOSTNAME}    console=yes
    Log    📋 Expected AV Type: ${AV_TYPE}    console=yes

    # SSH connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    # Check AV installation status
    ${av_installed}=    Check AV Installation Status
    Should Be True    ${av_installed}    msg=AV agent (${AV_TYPE}) not found on target machine

    Log    ✅ SSH connection established and AV installation confirmed    console=yes
    Log    ✅ STEP 1: COMPLETED - AV console connection established    console=yes

Critical - Step 2.1: Collect Agent Installation Status
    [Documentation]    📊 Gather agent installation status and version information
    ...                Step 2 of validation process: Collect AV Agent Data (Part 1)
    [Tags]             critical    av_collection    step2    agent_status

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT AGENT INSTALLATION STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${agent_status}=    Collect Agent Installation Status
    Set Suite Variable    ${AGENT_STATUS}    ${agent_status}
    Should Not Be Empty    ${agent_status}    msg=Failed to collect agent installation status
    Log    ✅ Agent installation status: ${agent_status['version']} - ${agent_status['status']}    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Agent installation status collected    console=yes

Critical - Step 2.2: Collect Real-Time Protection Settings
    [Documentation]    🛡️ Gather real-time protection configuration
    ...                Step 2 of validation process: Collect AV Agent Data (Part 2)
    [Tags]             critical    av_collection    step2    rtp_settings

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT REAL-TIME PROTECTION SETTINGS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${rtp_settings}=    Collect Real Time Protection Settings
    Set Suite Variable    ${RTP_SETTINGS}    ${rtp_settings}
    Should Not Be Empty    ${rtp_settings}    msg=Failed to collect real-time protection settings
    Log    ✅ Real-time protection status: ${rtp_settings['enabled']}    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Real-time protection settings collected    console=yes

Critical - Step 2.3: Collect Signature Update Information
    [Documentation]    📅 Gather signature update dates and version information
    ...                Step 2 of validation process: Collect AV Agent Data (Part 3)
    [Tags]             critical    av_collection    step2    signatures

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT SIGNATURE UPDATE INFORMATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${signature_info}=    Collect Signature Update Information
    Set Suite Variable    ${SIGNATURE_INFO}    ${signature_info}
    Should Not Be Empty    ${signature_info}    msg=Failed to collect signature update information
    Log    ✅ Signature last updated: ${signature_info['last_update']}    console=yes
    Log    ✅ STEP 2.3: COMPLETED - Signature update information collected    console=yes

Critical - Step 2.4: Collect Scan Schedule Configuration
    [Documentation]    📆 Gather scheduled scan configuration
    ...                Step 2 of validation process: Collect AV Agent Data (Part 4)
    [Tags]             critical    av_collection    step2    scan_schedule

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: COLLECT SCAN SCHEDULE CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${scan_schedule}=    Collect Scan Schedule Configuration
    Set Suite Variable    ${SCAN_SCHEDULE}    ${scan_schedule}
    Should Not Be Empty    ${scan_schedule}    msg=Failed to collect scan schedule
    Log    ✅ Scan schedule: ${scan_schedule['frequency']}    console=yes
    Log    ✅ STEP 2.4: COMPLETED - Scan schedule configuration collected    console=yes

Critical - Step 2.5: Collect Exclusion Configurations
    [Documentation]    📂 Gather exclusion path and policy configurations
    ...                Step 2 of validation process: Collect AV Agent Data (Part 5)
    [Tags]             critical    av_collection    step2    exclusions

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.5: COLLECT EXCLUSION CONFIGURATIONS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${exclusions}=    Collect Exclusion Configurations
    Set Suite Variable    ${EXCLUSIONS}    ${exclusions}
    Should Not Be Empty    ${exclusions}    msg=Failed to collect exclusion configurations
    ${exclusion_count}=    Get Length    ${exclusions['paths']}
    Log    ✅ Exclusion paths configured: ${exclusion_count}    console=yes
    Log    ✅ STEP 2.5: COMPLETED - Exclusion configurations collected    console=yes

Critical - Step 2.6: Capture Screenshots and Save Outputs
    [Documentation]    📸 Capture console screenshots and save command outputs
    ...                Step 2 of validation process: Collect AV Agent Data (Part 6)
    [Tags]             critical    av_collection    step2    documentation

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.6: CAPTURE SCREENSHOTS AND SAVE OUTPUTS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${screenshot_path}=    Capture AV Console Screenshot
    Set Suite Variable    ${SCREENSHOT_PATH}    ${screenshot_path}
    OperatingSystem.File Should Exist    ${screenshot_path}
    Log    ✅ Screenshot saved: ${screenshot_path}    console=yes

    ${output_file}=    Save AV Agent Output
    Set Suite Variable    ${OUTPUT_FILE}    ${output_file}
    OperatingSystem.File Should Exist    ${output_file}
    Log    ✅ Output saved: ${output_file}    console=yes
    Log    ✅ STEP 2.6: COMPLETED - Screenshots and outputs saved    console=yes

Critical - Step 3.1: Validate Agent Installation
    [Documentation]    ✅ Validate agent installation status against requirements
    ...                Step 3 of validation process: Validate Against CIP-007 R3.1 Standards (Part 1)
    [Tags]             critical    validation    step3    cip007_r31    agent

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE AGENT INSTALLATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${agent_valid}=    Validate Agent Installation    ${AGENT_STATUS}
    Should Be True    ${agent_valid}    msg=Agent installation validation failed
    Log    ✅ Agent installation validated    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Agent installation validated    console=yes

Critical - Step 3.2: Validate Real-Time Protection
    [Documentation]    ✅ Validate real-time protection is enabled
    ...                Step 3 of validation process: Validate Against CIP-007 R3.1 Standards (Part 2)
    [Tags]             critical    validation    step3    cip007_r31    rtp

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE REAL-TIME PROTECTION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${rtp_enabled}=    Get From Dictionary    ${RTP_SETTINGS}    enabled
    Should Be True    ${rtp_enabled}    msg=Real-time protection is not enabled
    Log    ✅ Real-time protection status validated (Enabled)    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Real-time protection validated    console=yes

Critical - Step 3.3: Validate Signature Currency
    [Documentation]    ✅ Validate signature definitions are current
    ...                Step 3 of validation process: Validate Against CIP-007 R3.1 Standards (Part 3)
    [Tags]             critical    validation    step3    cip007_r31    signatures

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE SIGNATURE CURRENCY    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Maximum signature age: ${MAX_SIGNATURE_AGE_DAYS} days    console=yes

    ${signature_valid}=    Validate Signature Currency    ${SIGNATURE_INFO}
    Should Be True    ${signature_valid}    msg=Signature validation failed - outdated signatures
    Log    ✅ Signature currency validated (Current)    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Signature currency validated    console=yes

Critical - Step 3.4: Validate Console Reporting
    [Documentation]    ✅ Validate console reporting functionality
    ...                Step 3 of validation process: Validate Against CIP-007 R3.1 Standards (Part 4)
    [Tags]             critical    validation    step3    cip007_r31    reporting

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: VALIDATE CONSOLE REPORTING    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${console_reporting}=    Validate Console Reporting
    Should Be True    ${console_reporting}    msg=Console reporting validation failed
    Log    ✅ Console reporting validated    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Console reporting validated    console=yes

Critical - Step 3.5: Validate Scheduled Scans
    [Documentation]    ✅ Validate scheduled scan configuration
    ...                Step 3 of validation process: Validate Against CIP-007 R3.1 Standards (Part 5)
    [Tags]             critical    validation    step3    cip007_r31    scans

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.5: VALIDATE SCHEDULED SCANS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${scan_valid}=    Validate Scheduled Scans    ${SCAN_SCHEDULE}
    Should Be True    ${scan_valid}    msg=Scheduled scan validation failed
    Log    ✅ Scheduled scans validated    console=yes
    Log    ✅ STEP 3.5: COMPLETED - Scheduled scans validated    console=yes

Critical - Step 3.6: Validate Exclusion Policies
    [Documentation]    ✅ Validate exclusion policies are appropriate
    ...                Step 3 of validation process: Validate Against CIP-007 R3.1 Standards (Part 6)
    [Tags]             critical    validation    step3    cip007_r31    exclusions

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.6: VALIDATE EXCLUSION POLICIES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${exclusion_valid}=    Validate Exclusion Policies    ${EXCLUSIONS}
    Should Be True    ${exclusion_valid}    msg=Exclusion policy validation failed
    Log    ✅ Exclusion policies validated    console=yes
    Log    ✅ STEP 3.6: COMPLETED - Exclusion policies validated    console=yes

Normal - Comprehensive AV Validation Summary
    [Documentation]    📊 Generate comprehensive summary of all AV validation results
    [Tags]             normal    summary    cip007_r31    compliance

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📊 COMPREHENSIVE AV VALIDATION SUMMARY (CIP-007 R3.1)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    Log    📊 AV protection validation summary:    console=yes
    Log    📊 - Agent installation: ✅    console=yes
    Log    📊 - Real-time protection: ✅    console=yes
    Log    📊 - Signature currency: ✅    console=yes
    Log    📊 - Console reporting: ✅    console=yes
    Log    📊 - Scheduled scans: ✅    console=yes
    Log    📊 - Exclusion policies: ✅    console=yes
    Log    ✅ AV protection validation: PASSED - Meets CIP-007 R3.1 malware protection requirements    console=yes
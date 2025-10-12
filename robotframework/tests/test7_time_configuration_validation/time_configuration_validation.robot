*** Settings ***
Documentation    ⏰ Time Configuration Validation Test Suite - Test-7
...              🔍 Process: Find hostname in EDS → SSH to server → Collect time/NTP data → Validate timezone and NTP configuration
...              ✅ Pass if timezone is Pacific/Los Angeles and NTP server is ntpx.domain.com with proper synchronization
...              📊 Validates: Timezone setting, Chrony service status, NTP server configuration, time synchronization
...
Resource         ../../settings.resource
Resource         time_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize Time Test Environment
Suite Teardown   Generate Time Configuration Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to Target Server
    [Documentation]    🔗 Establish direct SSH connection to target machine
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

Critical - Step 2.1: Collect Timezone Configuration
    [Documentation]    ⏰ Execute commands to gather timezone configuration from server
    ...                Step 2 of validation process: Collect Time Configuration Data (Part 1)
    [Tags]             critical    timezone    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT TIMEZONE CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Execute time configuration collection
    Collect Time Configuration Data

    # Verify data was collected
    Should Not Be Empty    ${TIMEDATECTL_OUTPUT}

    Set Suite Variable    ${TIMEZONE_DATA_COLLECTED}    ${TRUE}

    Log    📋 Timedatectl output: ${TIMEDATECTL_OUTPUT[:100]}...    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Timezone configuration collected    console=yes

Critical - Step 2.2: Collect Chrony Service Status
    [Documentation]    📡 Execute commands to gather chrony service status from server
    ...                Step 2 of validation process: Collect Time Configuration Data (Part 2)
    [Tags]             critical    chrony    service    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT CHRONY SERVICE STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Chrony data already collected in Step 2.1
    Should Not Be Empty    ${CHRONY_SOURCES_OUTPUT}
    Should Not Be Empty    ${CHRONY_TRACKING_OUTPUT}

    Set Suite Variable    ${CHRONY_DATA_COLLECTED}    ${TRUE}

    Log    📋 Chrony sources: ${CHRONY_SOURCES_OUTPUT[:100]}...    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Chrony service status collected    console=yes

Critical - Step 2.3: Collect NTP Configuration
    [Documentation]    🕐 Execute commands to gather NTP server configuration from server
    ...                Step 2 of validation process: Collect Time Configuration Data (Part 3)
    [Tags]             critical    ntp    server    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT NTP CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # NTP data already collected in Step 2.1
    Should Not Be Empty    ${CHRONY_SOURCES_OUTPUT}

    Set Suite Variable    ${NTP_DATA_COLLECTED}    ${TRUE}

    Log    📋 NTP sources collected    console=yes
    Log    ✅ STEP 2.3: COMPLETED - NTP configuration collected    console=yes

Critical - Step 3.1: Validate Timezone Against Standards
    [Documentation]    ✅ Validate collected timezone is set to Pacific/Los Angeles (America/Los_Angeles)
    ...                Step 3 of validation process: Validate Against Standards (Part 1)
    [Tags]             critical    validation    step3    compliance    timezone

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE TIMEZONE AGAINST STANDARDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Expected: Pacific/Los Angeles (America/Los_Angeles)    console=yes

    # Validate timezone matches Pacific/Los Angeles
    ${timezone_result}=    Validate Timezone Configuration

    Log    ⏰ Timezone validation: ${timezone_result}    console=yes
    Log    ✅ Timezone validation: PASSED    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Timezone validated    console=yes

Critical - Step 3.2: Validate Chrony Service Status
    [Documentation]    ✅ Validate collected chrony service status is active and running
    ...                Step 3 of validation process: Validate Against Standards (Part 2)
    [Tags]             critical    validation    step3    compliance    chrony    service

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE CHRONY SERVICE STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Expected: Chrony service active and running    console=yes

    # Validate chrony service is running
    Validate Chrony Service Status

    Log    ✅ Chrony service validation: PASSED    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Chrony service validated    console=yes

Critical - Step 3.3: Validate NTP Server Configuration
    [Documentation]    ✅ Validate collected NTP server is configured to use ntpx.domain.com
    ...                Step 3 of validation process: Validate Against Standards (Part 3)
    [Tags]             critical    validation    step3    compliance    ntp    server

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE NTP SERVER CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Expected NTP Server: ntpx.domain.com    console=yes

    # Validate NTP server configuration
    ${ntp_servers}=    Validate NTP Server Configuration

    Log    🕐 Configured NTP servers: ${ntp_servers}    console=yes
    Log    ✅ NTP server configuration: VALIDATED    console=yes
    Log    ✅ STEP 3.3: COMPLETED - NTP server validated    console=yes

Critical - Step 3.4: Validate Time Synchronization Status
    [Documentation]    ✅ Validate collected time synchronization status is working properly
    ...                Step 3 of validation process: Validate Against Standards (Part 4)
    [Tags]             critical    validation    step3    compliance    synchronization    time

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: VALIDATE TIME SYNCHRONIZATION STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Expected: System clock synchronized with NTP server    console=yes

    # Validate time synchronization
    ${sync_status}=    Validate Time Synchronization Status

    Log    🔄 Synchronization status: ${sync_status}    console=yes
    Log    ✅ Time synchronization: VALIDATED    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Time synchronization validated    console=yes

Normal - Comprehensive Time Configuration Validation
    [Documentation]    📊 Perform comprehensive validation of all time configuration settings
    [Tags]             normal    comprehensive    validation    compliance

    Log    🔍 Performing comprehensive time configuration validation...    console=yes

    # Validate all time settings
    Validate All Time Settings

    Log    📊 Comprehensive validation summary:    console=yes
    Log    📊 - Timezone: Pacific/Los Angeles ✅    console=yes
    Log    📊 - Chrony Service: Active ✅    console=yes
    Log    📊 - NTP Server: Configured ✅    console=yes
    Log    📊 - Synchronization: Verified ✅    console=yes
    Log    ✅ Comprehensive time configuration validation: PASSED    console=yes

Normal - Hardware Clock Verification
    [Documentation]    🕰️ Verify hardware clock and its synchronization with system clock
    [Tags]             normal    hardware    clock    verification

    Log    🔍 Verifying hardware clock configuration...    console=yes

    # Check hardware clock
    ${hwclock_output}=    Execute Command    hwclock --show 2>/dev/null || echo "hwclock requires privileges"
    ${current_date}=      Execute Command    date

    Log    🕰️ Hardware Clock: ${hwclock_output}    console=yes
    Log    📅 System Date: ${current_date}    console=yes

    # Log hardware clock information
    Log    ℹ️ Hardware clock information collected for review    console=yes
    Log    ✅ Hardware clock verification: INFORMATIONAL    console=yes

Normal - NTP Source Analysis
    [Documentation]    📊 Analyze NTP source details and server reachability
    [Tags]             normal    analysis    ntp    sources

    Log    🔍 Analyzing NTP source details...    console=yes

    # Get detailed NTP source information
    ${sources_verbose}=    Execute Command    chronyc sources -v
    ${sourcestats}=        Execute Command    chronyc sourcestats

    Log    📊 NTP Sources (Verbose): ${sources_verbose}    console=yes
    Log    📊 NTP Source Statistics: ${sourcestats}    console=yes

    # Save NTP analysis
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${ntp_analysis_file}=    Set Variable    ${DATA_DIR}/ntp_source_analysis_${timestamp}.txt

    ${ntp_analysis_data}=    Catenate    SEPARATOR=\n
    ...    === NTP Source Analysis ===
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    === Chrony Sources (Verbose) ===
    ...    ${sources_verbose}
    ...
    ...    === Chrony Source Statistics ===
    ...    ${sourcestats}

    Create File    ${ntp_analysis_file}    ${ntp_analysis_data}
    Log    📄 NTP source analysis saved to: ${ntp_analysis_file}    console=yes
    Log    ✅ NTP source analysis: INFORMATIONAL - Available for review    console=yes

Normal - Clock Drift Monitoring
    [Documentation]    📉 Monitor clock drift and synchronization accuracy
    [Tags]             normal    monitoring    drift    accuracy

    Log    🔍 Monitoring clock drift and accuracy...    console=yes

    # Get tracking information for drift analysis
    ${tracking_output}=    Execute Command    chronyc tracking

    Log    📉 Chrony Tracking Info: ${tracking_output}    console=yes

    # Extract key metrics if available
    ${system_time_line}=    Execute Command    chronyc tracking | grep "System time" || echo "N/A"
    ${last_offset_line}=    Execute Command    chronyc tracking | grep "Last offset" || echo "N/A"
    ${rms_offset_line}=     Execute Command    chronyc tracking | grep "RMS offset" || echo "N/A"

    Log    📊 System Time Offset: ${system_time_line}    console=yes
    Log    📊 Last Offset: ${last_offset_line}    console=yes
    Log    📊 RMS Offset: ${rms_offset_line}    console=yes

    Log    ℹ️ Clock drift monitoring: Data collected for analysis    console=yes
    Log    ✅ Clock drift monitoring: INFORMATIONAL    console=yes
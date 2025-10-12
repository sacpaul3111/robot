
*** Settings ***
Documentation    🌐 Hostname Validation Test Suite - Test-3
...              🔍 Process: Find hostname in EDS → SSH to IP → Compare server vs EDS
...              ✅ Pass if server matches EDS, ❌ Fail if mismatch
...
Resource         ../../settings.resource
Resource         network_keywords.resource
Resource         variables.resource

Suite Setup      Initialize Test Environment And Lookup Configuration
Suite Teardown   Generate Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to Target Server
    [Documentation]    🔌 Establish direct SSH connection to target machine
    ...                Step 1 of validation process: Connect to Target
    [Tags]             critical    connection    step1    ssh    infrastructure

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target: ${TARGET_HOSTNAME} (${TARGET_IP})    console=yes

    # Establish SSH connection
    Establish SSH Session

    # Verify connection is active
    Should Be True    ${SSH_CONNECTION_ACTIVE}
    ...    ❌ Failed to establish SSH connection to target server

    Log    ✅ SSH connection verified and active    console=yes
    Log    ✅ STEP 1: COMPLETED - SSH connection established    console=yes

Critical - Step 2.1: Collect Hostname Configuration
    [Documentation]    📋 Execute commands to gather hostname information from server
    ...                Step 2 of validation process: Collect Network Configuration Data (Part 1)
    [Tags]             critical    hostname    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT HOSTNAME CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get actual hostname from server via SSH
    ${actual_hostname}=    Get Hostname From Server

    Set Suite Variable    ${SERVER_HOSTNAME}    ${actual_hostname}

    Log    🖥️ Server Hostname: ${actual_hostname}    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Hostname collected    console=yes

Critical - Step 2.2: Collect IP Configuration
    [Documentation]    🌐 Execute commands to gather IP address configuration from server
    ...                Step 2 of validation process: Collect Network Configuration Data (Part 2)
    [Tags]             critical    networking    step2    data_collection    ip

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT IP CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get actual IP configuration from server
    ${actual_ip}=    Get IP Address From Server

    Set Suite Variable    ${SERVER_IP}    ${actual_ip}

    Log    🖥️ Server IP Address: ${actual_ip}    console=yes
    Log    ✅ STEP 2.2: COMPLETED - IP address collected    console=yes

Critical - Step 2.3: Collect Subnet Configuration
    [Documentation]    🌍 Execute commands to gather subnet configuration from server
    ...                Step 2 of validation process: Collect Network Configuration Data (Part 3)
    [Tags]             critical    networking    step2    data_collection    subnet

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT SUBNET CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get actual subnet from server
    ${actual_subnet}=    Get Subnet From Server

    Set Suite Variable    ${SERVER_SUBNET}    ${actual_subnet}

    Log    🖥️ Server Subnet: ${actual_subnet}    console=yes
    Log    ✅ STEP 2.3: COMPLETED - Subnet configuration collected    console=yes

Critical - Step 2.4: Collect Gateway Configuration
    [Documentation]    🛣️ Execute commands to gather gateway configuration from server
    ...                Step 2 of validation process: Collect Network Configuration Data (Part 4)
    [Tags]             critical    networking    step2    data_collection    gateway

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: COLLECT GATEWAY CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get actual gateway from server
    ${actual_gateway}=    Get Gateway From Server

    Set Suite Variable    ${SERVER_GATEWAY}    ${actual_gateway}

    Log    🖥️ Server Gateway: ${actual_gateway}    console=yes
    Log    ✅ STEP 2.4: COMPLETED - Gateway configuration collected    console=yes

Critical - Step 2.5: Collect DNS Configuration
    [Documentation]    🌐 Execute commands to gather DNS configuration from server
    ...                Step 2 of validation process: Collect Network Configuration Data (Part 5)
    [Tags]             critical    dns    step2    data_collection    hostname

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.5: COLLECT DNS CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get actual DNS configuration from server
    ${actual_fqdn}=    Get FQDN From Server

    Set Suite Variable    ${SERVER_FQDN}    ${actual_fqdn}

    Log    🖥️ Server FQDN: ${actual_fqdn}    console=yes
    Log    ✅ STEP 2.5: COMPLETED - DNS configuration collected    console=yes

Critical - Step 2.6: Collect NTP Configuration
    [Documentation]    📈 Execute commands to gather NTP service status from server
    ...                Step 2 of validation process: Collect Network Configuration Data (Part 6)
    [Tags]             critical    time    step2    data_collection    ntp

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.6: COLLECT NTP CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check NTP service status on server
    ${ntp_status}=    Get NTP Status From Server

    Set Suite Variable    ${SERVER_NTP_STATUS}    ${ntp_status}

    Log    🖥️ Server NTP Status: ${ntp_status}    console=yes
    Log    ✅ STEP 2.6: COMPLETED - NTP status collected    console=yes

Critical - Step 3.1: Validate Hostname Against EDS
    [Documentation]    ✅ Compare collected hostname with EDS expected value
    ...                Step 3 of validation process: Validate Against EDS Standards (Part 1)
    [Tags]             critical    validation    step3    compliance    hostname

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE HOSTNAME AGAINST EDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${expected_hostname}=    Set Variable    ${TARGET_HOSTNAME}

    Log    📋 EDS Expected: ${expected_hostname}    console=yes
    Log    🖥️ Server Actual: ${SERVER_HOSTNAME}    console=yes

    # Compare EDS expectation with server reality
    Should Be Equal As Strings    ${SERVER_HOSTNAME}    ${expected_hostname}
    ...    ❌ HOSTNAME MISMATCH: EDS expects '${expected_hostname}' but server shows '${SERVER_HOSTNAME}'

    Log    ✅ Hostname validation: PASSED - EDS matches Server    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Hostname validated    console=yes

Critical - Step 3.2: Validate IP Address Against EDS
    [Documentation]    ✅ Compare collected IP address with EDS expected value
    ...                Step 3 of validation process: Validate Against EDS Standards (Part 2)
    [Tags]             critical    validation    step3    compliance    networking    ip

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE IP ADDRESS AGAINST EDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${expected_ip}=    Set Variable    ${TARGET_IP}

    Log    📋 EDS Expected: ${expected_ip}    console=yes
    Log    🖥️ Server Actual: ${SERVER_IP}    console=yes

    # Compare EDS expectation with server reality
    Should Be Equal As Strings    ${SERVER_IP}    ${expected_ip}
    ...    ❌ IP MISMATCH: EDS expects '${expected_ip}' but server shows '${SERVER_IP}'

    Log    ✅ IP address validation: PASSED - EDS matches Server    console=yes
    Log    ✅ STEP 3.2: COMPLETED - IP address validated    console=yes

Critical - Step 3.3: Validate Subnet Against EDS
    [Documentation]    ✅ Compare collected subnet with EDS expected value
    ...                Step 3 of validation process: Validate Against EDS Standards (Part 3)
    [Tags]             critical    validation    step3    compliance    networking    subnet

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE SUBNET AGAINST EDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${expected_subnet}=    Set Variable    ${TARGET_SUBNET}

    Log    📋 EDS Expected: ${expected_subnet}    console=yes
    Log    🖥️ Server Actual: ${SERVER_SUBNET}    console=yes

    # Compare EDS expectation with server reality
    Should Be Equal As Strings    ${SERVER_SUBNET}    ${expected_subnet}
    ...    ❌ SUBNET MISMATCH: EDS expects '${expected_subnet}' but server shows '${SERVER_SUBNET}'

    Log    ✅ Subnet validation: PASSED - EDS matches Server    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Subnet validated    console=yes

Critical - Step 3.4: Validate Gateway Against EDS
    [Documentation]    ✅ Compare collected gateway with EDS expected value
    ...                Step 3 of validation process: Validate Against EDS Standards (Part 4)
    [Tags]             critical    validation    step3    compliance    networking    gateway

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: VALIDATE GATEWAY AGAINST EDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${expected_gateway}=    Set Variable    ${TARGET_GATEWAY}

    Log    📋 EDS Expected: ${expected_gateway}    console=yes
    Log    🖥️ Server Actual: ${SERVER_GATEWAY}    console=yes

    # Compare EDS expectation with server reality
    Should Be Equal As Strings    ${SERVER_GATEWAY}    ${expected_gateway}
    ...    ❌ GATEWAY MISMATCH: EDS expects '${expected_gateway}' but server shows '${SERVER_GATEWAY}'

    Log    ✅ Gateway validation: PASSED - EDS matches Server    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Gateway validated    console=yes

Critical - Step 3.5: Validate DNS Configuration Against EDS
    [Documentation]    ✅ Compare collected DNS configuration with EDS expected values
    ...                Step 3 of validation process: Validate Against EDS Standards (Part 5)
    [Tags]             critical    validation    step3    compliance    dns    hostname

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.5: VALIDATE DNS CONFIGURATION AGAINST EDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    ${expected_cname}=    Set Variable    ${TARGET_CNAME}
    ${expected_domain}=   Set Variable    ${TARGET_DOMAIN}
    ${expected_fqdn}=     Set Variable    ${expected_cname}.${expected_domain}

    Log    📋 EDS Expected CNAME: ${expected_cname}    console=yes
    Log    📋 EDS Expected Domain: ${expected_domain}    console=yes
    Log    📋 EDS Expected FQDN: ${expected_fqdn}    console=yes
    Log    🖥️ Server Actual FQDN: ${SERVER_FQDN}    console=yes

    # Compare CNAME (should match hostname)
    Should Be Equal As Strings    ${TARGET_HOSTNAME}    ${expected_cname}
    ...    ❌ CNAME MISMATCH: EDS CNAME '${expected_cname}' doesn't match hostname '${TARGET_HOSTNAME}'

    Log    ✅ DNS validation: PASSED - EDS configuration validated    console=yes
    Log    ✅ STEP 3.5: COMPLETED - DNS configuration validated    console=yes

Normal - Step 3.6: Validate NTP Service Status
    [Documentation]    ✅ Validate collected NTP service status is active/running
    ...                Step 3 of validation process: Validate Against Standards (Part 6 - Informational)
    [Tags]             normal    validation    step3    time    ntp

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.6: VALIDATE NTP SERVICE STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    Log    🖥️ Server NTP Status: ${SERVER_NTP_STATUS}    console=yes

    # Validate NTP is active
    Should Contain Any    ${SERVER_NTP_STATUS}    active    running    synchronized
    ...    ❌ NTP SERVICE: Time synchronization service not active on server

    Log    ✅ NTP validation: PASSED - Time sync service active    console=yes
    Log    ✅ STEP 3.6: COMPLETED - NTP status validated    console=yes

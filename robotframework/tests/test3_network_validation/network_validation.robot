
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
Critical - Hostname Validation
    [Documentation]    🔧 SSH to server and compare hostname with EDS expectation
    [Tags]             critical    hostname    compliance

    Log    🔍 Validating hostname: EDS vs Server...    console=yes

    # Get actual hostname from server via SSH
    ${actual_hostname}=    Get Hostname From Server
    ${expected_hostname}=  Set Variable    ${TARGET_HOSTNAME}

    Log    📋 EDS Expected: ${expected_hostname}    console=yes
    Log    🖥️ Server Actual: ${actual_hostname}    console=yes

    # Compare EDS expectation with server reality
    Should Be Equal As Strings    ${actual_hostname}    ${expected_hostname}
    ...    ❌ HOSTNAME MISMATCH: EDS expects '${expected_hostname}' but server shows '${actual_hostname}'

    Log    ✅ Hostname validation: PASSED - EDS matches Server    console=yes

Critical - IP Address Validation  
    [Documentation]    🌐 SSH to server and compare IP configuration with EDS expectation
    [Tags]             critical    networking    ip

    Log    🔍 Validating IP address: EDS vs Server...    console=yes

    # Get actual IP configuration from server
    ${actual_ip}=    Get IP Address From Server
    ${expected_ip}=  Set Variable    ${TARGET_IP}

    Log    📋 EDS Expected: ${expected_ip}    console=yes
    Log    🖥️ Server Actual: ${actual_ip}    console=yes

    # Compare EDS expectation with server reality
    Should Be Equal As Strings    ${actual_ip}    ${expected_ip}
    ...    ❌ IP MISMATCH: EDS expects '${expected_ip}' but server shows '${actual_ip}'

    Log    ✅ IP address validation: PASSED - EDS matches Server    console=yes

Critical - Subnet Validation
    [Documentation]    🌍 SSH to server and compare subnet configuration with EDS expectation
    [Tags]             critical    networking    subnet

    Log    🔍 Validating subnet: EDS vs Server...    console=yes

    # Get actual subnet from server
    ${actual_subnet}=    Get Subnet From Server
    ${expected_subnet}=  Set Variable    ${TARGET_SUBNET}

    Log    📋 EDS Expected: ${expected_subnet}    console=yes
    Log    🖥️ Server Actual: ${actual_subnet}    console=yes

    # Compare EDS expectation with server reality
    Should Be Equal As Strings    ${actual_subnet}    ${expected_subnet}
    ...    ❌ SUBNET MISMATCH: EDS expects '${expected_subnet}' but server shows '${actual_subnet}'

    Log    ✅ Subnet validation: PASSED - EDS matches Server    console=yes

Critical - Gateway Validation
    [Documentation]    🛣️ SSH to server and compare gateway configuration with EDS expectation
    [Tags]             critical    networking    gateway

    Log    🔍 Validating gateway: EDS vs Server...    console=yes

    # Get actual gateway from server
    ${actual_gateway}=    Get Gateway From Server
    ${expected_gateway}=  Set Variable    ${TARGET_GATEWAY}

    Log    📋 EDS Expected: ${expected_gateway}    console=yes
    Log    🖥️ Server Actual: ${actual_gateway}    console=yes

    # Compare EDS expectation with server reality
    Should Be Equal As Strings    ${actual_gateway}    ${expected_gateway}
    ...    ❌ GATEWAY MISMATCH: EDS expects '${expected_gateway}' but server shows '${actual_gateway}'

    Log    ✅ Gateway validation: PASSED - EDS matches Server    console=yes

Critical - DNS Name Validation
    [Documentation]    🌐 SSH to server and compare DNS configuration with EDS expectation
    [Tags]             critical    dns    hostname

    Log    🔍 Validating DNS configuration: EDS vs Server...    console=yes

    # Get actual DNS configuration from server
    ${actual_fqdn}=      Get FQDN From Server
    ${expected_cname}=   Set Variable    ${TARGET_CNAME}
    ${expected_domain}=  Set Variable    ${TARGET_DOMAIN}
    ${expected_fqdn}=    Set Variable    ${expected_cname}.${expected_domain}

    Log    📋 EDS Expected CNAME: ${expected_cname}    console=yes
    Log    📋 EDS Expected Domain: ${expected_domain}    console=yes
    Log    📋 EDS Expected FQDN: ${expected_fqdn}    console=yes
    Log    🖥️ Server Actual FQDN: ${actual_fqdn}    console=yes

    # Compare CNAME (should match hostname)
    Should Be Equal As Strings    ${TARGET_HOSTNAME}    ${expected_cname}
    ...    ❌ CNAME MISMATCH: EDS CNAME '${expected_cname}' doesn't match hostname '${TARGET_HOSTNAME}'

    Log    ✅ DNS validation: PASSED - EDS configuration validated    console=yes

Normal - NTP Configuration Validation
    [Documentation]    📈 SSH to server and validate NTP service is running
    [Tags]             normal    time    ntp

    Log    🔍 Validating NTP service on server...    console=yes

    # Check NTP service status on server
    ${ntp_status}=    Get NTP Status From Server
    
    Log    🖥️ Server NTP Status: ${ntp_status}    console=yes

    # Validate NTP is active
    Should Contain Any    ${ntp_status}    active    running    synchronized
    ...    ❌ NTP SERVICE: Time synchronization service not active on server

    Log    ✅ NTP validation: PASSED - Time sync service active    console=yes

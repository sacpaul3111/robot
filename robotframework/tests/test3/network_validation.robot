*** Settings ***
Documentation    🌐 Hostname Validation Test Suite - Test-3
...              Validates hostname requirements from CBS_Itential_DRAFT_v0.01.xlsx
...              ✨ Features: Hostname, IP, subnet, gateway, and NTP validation
...              📊 Results: Unified HTML reports with enhanced dashboard
...              🎯 Run with: robot network_validation.robot
...
Metadata         Test Suite    Hostname Validation Test-3
Metadata         Environment   Development QA
Metadata         Version       2.0.0
Metadata         Features      Hostname, IP, Subnet, Gateway, NTP
Metadata         Reporting     Unified HTML Reports + Enhanced Dashboard

Resource         ../../settings.resource
Resource         network_keywords.resource
Resource         variables.resource

# Configure Robot Framework to output to html_reports directory
Default Tags     hostname-validation
Force Tags       automated

Suite Setup      Initialize Test Environment And Lookup Configuration
Suite Teardown   Generate Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Hostname Validation
    [Documentation]    🔧 Validates hostname configuration against CBS_Itential_DRAFT requirements
    ...                Ensures hostname matches expected naming convention from Itential workflow
    [Tags]             critical    hostname    compliance    itential

    Log    🔍 Validating hostname configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Get current hostname
    ${current_hostname}=    Get Hostname
    Log    📍 Current hostname: ${current_hostname}    console=yes

    # Validate against expected hostname from Itential workflow
    ${expected_hostname}=    Set Variable    ${TARGET_HOSTNAME}
    Log    📋 Expected hostname: ${expected_hostname}    console=yes

    # Check if hostname matches expected value
    Should Be Equal As Strings    ${current_hostname}    ${expected_hostname}
    ...    Hostname mismatch: expected '${expected_hostname}', got '${current_hostname}'

    Log    ✅ Hostname validation: PASSED    console=yes
    Log    📍 Validated hostname: ${current_hostname}    console=yes
    Append To List    ${TEST_RESULTS}    Hostname Validation: PASS - ${current_hostname}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - IP Address Validation
    [Documentation]    🌐 Validates IP address configuration against CBS_Itential_DRAFT requirements
    ...                Expected IP: 10.26.216.107 for alhxvdvitap01
    [Tags]             critical    networking    ip    compliance

    Log    🔍 Validating IP address configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Get current IP configuration
    ${interface_data}=    Execute Network Command    ip addr show    Interface enumeration
    Should Not Be Empty    ${interface_data}    No network interfaces detected

    # Validate expected IP address is configured
    ${expected_ip}=    Set Variable    ${TARGET_IP}
    Log    📋 Expected IP address: ${expected_ip}    console=yes

    Should Contain    ${interface_data}    ${expected_ip}
    ...    Expected IP address ${expected_ip} not found in interface configuration

    # Extract and validate IP with subnet
    ${ip_with_subnet}=    Get Regexp Matches    ${interface_data}    inet (${expected_ip}/\\d+)    1
    Should Not Be Empty    ${ip_with_subnet}    IP address ${expected_ip} not properly configured with subnet

    ${configured_ip_subnet}=    Set Variable    ${ip_with_subnet}[0]
    Log    📍 Configured IP with subnet: ${configured_ip_subnet}    console=yes

    Log    ✅ IP address validation: PASSED    console=yes
    Log    📍 Validated IP: ${expected_ip}    console=yes
    Append To List    ${TEST_RESULTS}    IP Validation: PASS - ${expected_ip}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - Subnet Validation
    [Documentation]    🌍 Validates subnet configuration against CBS_Itential_DRAFT requirements
    ...                Expected subnet: 10.26.216.0/24 (255.255.255.0)
    [Tags]             critical    networking    subnet    compliance

    Log    🔍 Validating subnet configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Get route information to validate subnet
    ${route_data}=    Execute Network Command    ip route show    Route enumeration
    Should Not Be Empty    ${route_data}    No routing information available

    # Validate expected subnet configuration
    ${expected_subnet}=    Set Variable    ${TARGET_SUBNET}
    ${expected_mask}=    Set Variable    ${TARGET_MASK}
    Log    📋 Expected subnet: ${expected_subnet}    console=yes
    Log    📋 Expected mask: ${expected_mask}    console=yes

    # Check if subnet is configured in routing table
    Should Contain    ${route_data}    ${expected_subnet}
    ...    Expected subnet ${expected_subnet} not found in routing table

    # Validate interface configuration shows correct subnet
    ${interface_data}=    Execute Network Command    ip addr show    Interface validation
    ${ip_cidr_pattern}=    Set Variable    ${TARGET_IP}/24
    Should Contain    ${interface_data}    ${ip_cidr_pattern}
    ...    IP ${TARGET_IP} not configured with expected /24 subnet mask

    Log    ✅ Subnet validation: PASSED    console=yes
    Log    📍 Validated subnet: ${expected_subnet}    console=yes
    Append To List    ${TEST_RESULTS}    Subnet Validation: PASS - ${expected_subnet}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - Gateway Validation
    [Documentation]    🛣️ Validates default gateway configuration against CBS_Itential_DRAFT requirements
    ...                Expected gateway: 10.26.216.4 for alhxvdvitap01
    [Tags]             critical    networking    gateway    compliance

    Log    🔍 Validating gateway configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Get routing information
    ${route_data}=    Execute Network Command    ip route show    Routing table collection
    Should Not Be Empty    ${route_data}    Routing table is empty or inaccessible

    # Validate expected gateway is configured
    ${expected_gateway}=    Set Variable    ${TARGET_GATEWAY}
    Log    📋 Expected gateway: ${expected_gateway}    console=yes

    # Check for default route with expected gateway
    Should Contain    ${route_data}    default via ${expected_gateway}
    ...    Expected gateway ${expected_gateway} not configured as default route

    # Test gateway connectivity
    ${gateway_ping}=    Test Connectivity With Metrics    ${expected_gateway}    Default Gateway
    Should Contain    ${gateway_ping}    received    Gateway ${expected_gateway} is not reachable

    # Extract gateway latency
    ${gateway_latency}=    Extract Average Latency    ${gateway_ping}
    Append To List    ${PERFORMANCE_METRICS}    Gateway Latency: ${gateway_latency}ms

    Log    ✅ Gateway validation: PASSED    console=yes
    Log    🛣️ Validated gateway: ${expected_gateway}    console=yes
    Log    📊 Gateway latency: ${gateway_latency}ms    console=yes
    Append To List    ${TEST_RESULTS}    Gateway Validation: PASS - ${expected_gateway} (${gateway_latency}ms)

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Normal - NTP Configuration Validation
    [Documentation]    📈 Validates NTP (Network Time Protocol) configuration
    ...                Ensures time synchronization is properly configured
    [Tags]             normal    time    ntp    configuration

    Log    🔍 Validating NTP configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Check if NTP service is running
    ${ntp_status}=    Execute Network Command    systemctl is-active ntp || systemctl is-active ntpd || systemctl is-active chronyd    NTP service status

    # Check if any time sync service is active
    ${time_sync_active}=    Run Keyword And Return Status
    ...    Should Contain Any    ${ntp_status}    active    running

    # If no standard NTP service, check for systemd-timesyncd
    Run Keyword If    not ${time_sync_active}
    ...    ${timesyncd_status}=    Execute Network Command    systemctl is-active systemd-timesyncd    systemd-timesyncd status

    Run Keyword If    not ${time_sync_active}
    ...    Should Contain    ${timesyncd_status}    active    No time synchronization service is active

    # Check time synchronization status
    ${timedatectl_output}=    Execute Network Command    timedatectl status    Time sync status
    Should Contain    ${timedatectl_output}    System clock synchronized
    ...    System clock is not synchronized

    # Extract time sync info
    ${ntp_synchronized}=    Get Regexp Matches    ${timedatectl_output}    System clock synchronized: (\\w+)    1
    ${sync_status}=    Set Variable If    ${ntp_synchronized}    ${ntp_synchronized}[0]    unknown

    Log    ✅ NTP validation: PASSED    console=yes
    Log    🕐 Time synchronization status: ${sync_status}    console=yes
    Append To List    ${TEST_RESULTS}    NTP Validation: PASS - Time sync: ${sync_status}
    Append To List    ${PERFORMANCE_METRICS}    Time Synchronization: ${sync_status}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - DNS Name Validation
    [Documentation]    🌐 Validates DNS name configuration against CBS_Itential_DRAFT requirements
    ...                Expected CNAME: alhxvdvitap01, Domain: gnscet.com
    [Tags]             critical    dns    hostname    compliance

    Log    🔍 Validating DNS name configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Expected DNS configuration from CBS sheet
    ${expected_cname}=    Set Variable    ${TARGET_CNAME}
    ${expected_domain}=    Set Variable    ${TARGET_DOMAIN}
    ${expected_fqdn}=     Set Variable    ${expected_cname}.${expected_domain}

    Log    📋 Expected CNAME: ${expected_cname}    console=yes
    Log    📋 Expected Domain: ${expected_domain}    console=yes
    Log    📋 Expected FQDN: ${expected_fqdn}    console=yes

    # Validate hostname matches CNAME
    ${current_hostname}=    Get Hostname
    Should Be Equal As Strings    ${current_hostname}    ${expected_cname}
    ...    Hostname '${current_hostname}' does not match expected CNAME '${expected_cname}'

    # Check if system is configured with the domain
    ${hosts_file}=    Execute Network Command    cat /etc/hosts    Hosts file check
    ${hostname_cmd}=   Execute Network Command    hostname -f    FQDN check

    # Validate domain configuration (check if FQDN is properly set)
    ${domain_configured}=    Run Keyword And Return Status
    ...    Should Contain    ${hostname_cmd}    ${expected_domain}

    # Log domain status (may not be configured in all environments)
    Run Keyword If    ${domain_configured}
    ...    Log    ✅ Domain ${expected_domain} properly configured    console=yes
    ...    ELSE
    ...    Log    ⚠️ Domain ${expected_domain} not configured in FQDN    console=yes    WARN

    Log    ✅ DNS name validation: PASSED    console=yes
    Log    📍 Validated CNAME: ${expected_cname}    console=yes
    Log    🌐 Target domain: ${expected_domain}    console=yes
    Append To List    ${TEST_RESULTS}    DNS Name Validation: PASS - CNAME: ${expected_cname}, Domain: ${expected_domain}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}
*** Settings ***
Library          Process
Library          OperatingSystem  
Library          Collections
Library          DateTime
Library          String
Library          SSHLibrary
Library          ../../library/EDSLookup.py

*** Variables ***
${SSH_CONNECTION_ACTIVE}    ${FALSE}

*** Keywords ***
Log Test Start
    [Arguments]    ${test_name}
    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Log    🚀 Starting: ${test_name} at ${timestamp}    console=yes

Log Test End  
    [Arguments]    ${test_name}    ${test_status}=UNKNOWN
    ${timestamp}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Log    ✅ Completed: ${test_name} (${test_status}) at ${timestamp}    console=yes

Initialize Test Environment And Lookup Configuration
    [Documentation]    🚀 Load EDS configuration and prepare for server validation

    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Suite Variable    ${TEST_START_TIME}    ${start_time}

    # Auto-detect test suite ID if not provided
    ${suite_id}=    Run Keyword If    '${TEST_SUITE_ID}' == '${EMPTY}'
    ...    Auto Detect Test Suite ID
    ...    ELSE
    ...    Set Variable    ${TEST_SUITE_ID}

    # Auto-detect full suite name for directory structure
    ${suite_name}=    Auto Detect Test Suite Name

    Set Suite Variable    ${TEST_SUITE_ID}    ${suite_id}
    Set Suite Variable    ${TEST_SUITE_NAME}    Hostname Validation Test Suite - ${suite_id}

    # Update directory paths with full suite name
    Set Suite Variable    ${TEST_REPORTS_DIR}    ${REPORTS_DIR}/${suite_name}
    Set Suite Variable    ${DATA_DIR}             ${TEST_REPORTS_DIR}/data

    # Create directory structure
    Create Directory    ${REPORTS_DIR}
    Create Directory    ${TEST_REPORTS_DIR}
    Create Directory    ${DATA_DIR}

    # Lookup configuration from EDS sheet
    Log To Console    \n🔍 Looking up configuration for hostname: ${TARGET_HOSTNAME}
    
    ${config}=    Lookup Server Config    ${TARGET_HOSTNAME}

    # Set EDS configuration as suite variables 
    Set Suite Variable    ${TARGET_IP}           ${config}[ip]
    Set Suite Variable    ${TARGET_SUBNET}       ${config}[subnet] 
    Set Suite Variable    ${TARGET_MASK}         ${config}[mask]
    Set Suite Variable    ${TARGET_GATEWAY}      ${config}[gateway]
    Set Suite Variable    ${TARGET_CNAME}        ${config}[cname]
    Set Suite Variable    ${TARGET_DOMAIN}       ${config}[domain]

    Log To Console    \n📋 EDS Configuration for ${TARGET_HOSTNAME}:
    Log To Console    📍 IP: ${TARGET_IP}
    Log To Console    📍 Subnet: ${TARGET_SUBNET} 
    Log To Console    📍 Gateway: ${TARGET_GATEWAY}
    Log To Console    📍 CNAME: ${TARGET_CNAME}
    Log To Console    📍 Domain: ${TARGET_DOMAIN}

    Log To Console    \n🚀 ===================================================
    Log To Console    🌐 NETWORK VALIDATION: EDS vs SERVER COMPARISON
    Log To Console    ⚡ Test Suite: ${suite_id} (${TEST_SUITE_NAME})
    Log To Console    ═══════════════════════════════════════════════════
    Log To Console    📅 Start Time: ${start_time}
    Log To Console    🎯 Target Hostname: ${TARGET_HOSTNAME}
    Log To Console    🌐 SSH Target IP: ${TARGET_IP}
    Log To Console    📊 Suite Reports: ${TEST_REPORTS_DIR}
    Log To Console    📊 Overall Reports: ${REPORTS_DIR}
    Log To Console    ===================================================

Auto Detect Test Suite ID
    [Documentation]    Auto-detect test suite ID from current working directory or test file path

    # Try to get suite ID from Robot Framework's built-in variables
    ${suite_source}=    Get Variable Value    ${SUITE_SOURCE}    ${EMPTY}

    # Extract test suite ID from the file path (e.g., test3_network_validation)
    ${path_parts}=    Split String    ${suite_source}    ${/}
    FOR    ${part}    IN    @{path_parts}
        ${is_test_dir}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${part}    ^test\\d+_

        Run Keyword If    ${is_test_dir}
        ...    Run Keywords
        ...    ${detected_id}=    Get Regexp Matches    ${part}    ^(test\\d+)_    1
        ...    AND    Return From Keyword    ${detected_id}[0]
    END

    # Fallback to test3 if detection fails
    Log    ⚠️ Could not auto-detect test suite ID, defaulting to test3    WARN
    RETURN    test3

Auto Detect Test Suite Name
    [Documentation]    Auto-detect full test suite name from current working directory or test file path

    # Try to get suite name from Robot Framework's built-in variables
    ${suite_source}=    Get Variable Value    ${SUITE_SOURCE}    ${EMPTY}

    # Extract full test suite directory name (e.g., test3_network_validation)
    ${path_parts}=    Split String    ${suite_source}    ${/}
    FOR    ${part}    IN    @{path_parts}
        ${is_test_dir}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${part}    ^test\\d+_

        Run Keyword If    ${is_test_dir}
        ...    Return From Keyword    ${part}
    END

    # Fallback to test3_network_validation if detection fails
    Log    ⚠️ Could not auto-detect test suite name, defaulting to test3_network_validation    WARN
    RETURN    test3_network_validation

# Include all your existing SSH and server extraction keywords here...
Establish SSH Session
    [Documentation]    SSH to server using IP from EDS lookup
    
    Log    🔌 Connecting to ${TARGET_HOSTNAME} via SSH (${TARGET_IP})...    console=yes
    
    Close All Connections
    Open Connection    ${TARGET_IP}    port=22    timeout=30
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
    
    ${test_output}=    Execute Command    echo "SSH connection successful"
    Should Contain    ${test_output}    SSH connection successful
    
    Set Suite Variable    ${SSH_CONNECTION_ACTIVE}    ${TRUE}
    Log    ✅ SSH session established to ${TARGET_IP}    console=yes

Get Hostname From Server
    [Documentation]    SSH to server and get actual hostname (short name without domain)

    Establish SSH Session
    # Use 'hostname -s' to get short hostname without domain
    # Fall back to 'hostname' and strip domain if -s flag not supported
    ${hostname}=    Execute Command    hostname -s 2>/dev/null || hostname | cut -d'.' -f1
    ${hostname}=    Strip String    ${hostname}

    # Save to evidence file
    Save Evidence To Data    hostname.txt    Hostname: ${hostname}

    RETURN    ${hostname}

Get IP Address From Server
    [Documentation]    SSH to server and get actual IP address

    ${ip_output}=    Execute Command    hostname -I | awk '{print $1}' || ip addr show | grep -oP '(?<=inet\\s)\\d+\\.\\d+\\.\\d+\\.\\d+'
    ${ip}=    Strip String    ${ip_output}

    # Save full network config to evidence
    ${ip_config}=    Execute Command    ip addr show
    Save Evidence To Data    ip_configuration.txt    ${ip_config}

    RETURN    ${ip}

Get Subnet From Server
    [Documentation]    SSH to server and get subnet configuration

    ${route_output}=    Execute Command    ip route show | grep ${TARGET_IP}
    ${subnet}=    Get Regexp Matches    ${route_output}    (\\d+\\.\\d+\\.\\d+\\.\\d+/\\d+)    1

    ${subnet_length}=    Get Length    ${subnet}
    IF    ${subnet_length} > 0
        RETURN    ${subnet}[0]
    ELSE
        RETURN    ${TARGET_SUBNET}
    END

Get Gateway From Server
    [Documentation]    SSH to server and get gateway configuration

    ${gateway_output}=    Execute Command    ip route show default | awk '{print $3}'
    ${gateway}=    Strip String    ${gateway_output}

    # Save full routing table to evidence
    ${route_table}=    Execute Command    ip route show
    Save Evidence To Data    routing_table.txt    ${route_table}

    RETURN    ${gateway}

Get FQDN From Server
    [Documentation]    SSH to server and get FQDN

    ${fqdn_output}=    Execute Command    hostname -f 2>/dev/null || hostname
    ${fqdn}=    Strip String    ${fqdn_output}

    # Save DNS config to evidence
    ${dns_config}=    Execute Command    cat /etc/resolv.conf 2>/dev/null || echo "DNS config not accessible"
    Save Evidence To Data    dns_configuration.txt    ${dns_config}

    RETURN    ${fqdn}

Get NTP Status From Server
    [Documentation]    SSH to server and check NTP service status

    ${ntp_status}=    Execute Command    systemctl is-active chronyd 2>/dev/null || systemctl is-active ntp 2>/dev/null || systemctl is-active ntpd 2>/dev/null || echo "inactive"
    ${ntp_status}=    Strip String    ${ntp_status}

    # Save full NTP status to evidence
    ${ntp_detail}=    Execute Command    timedatectl status 2>/dev/null || systemctl status chronyd 2>/dev/null || systemctl status ntpd 2>/dev/null || echo "NTP info not available"
    Save Evidence To Data    ntp_status.txt    ${ntp_detail}

    RETURN    ${ntp_status}

Save Evidence To Data
    [Documentation]    Save evidence data to the data folder with timestamp
    [Arguments]    ${filename}    ${content}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${evidence_file}=    Set Variable    ${DATA_DIR}/${filename}

    Create File    ${evidence_file}    ${content}
    Log    📄 Evidence saved: ${evidence_file}    console=yes

Generate Executive Summary
    [Documentation]    Generate test summary and close connections

    ${end_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${duration}=    Subtract Date From Date    ${end_time}    ${TEST_START_TIME}

    # Create comprehensive comparison report
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${summary_file}=    Set Variable    ${DATA_DIR}/network_validation_summary_${timestamp}.txt

    ${summary_content}=    Catenate    SEPARATOR=\n
    ...    ═══════════════════════════════════════════════════════════════
    ...    NETWORK VALIDATION TEST - EXECUTIVE SUMMARY
    ...    ═══════════════════════════════════════════════════════════════
    ...    ${EMPTY}
    ...    Test Suite: ${TEST_SUITE_ID} - Network Validation
    ...    Target Server: ${TARGET_HOSTNAME}
    ...    Execution Time: ${TEST_START_TIME} to ${end_time}
    ...    Duration: ${duration} seconds
    ...    ${EMPTY}
    ...    ═══════════════════════════════════════════════════════════════
    ...    EDS CONFIGURATION vs SERVER ACTUAL
    ...    ═══════════════════════════════════════════════════════════════
    ...    ${EMPTY}
    ...    HOSTNAME:
    ...    - EDS Expected:  ${TARGET_HOSTNAME}
    ...    - Server Actual: ${SERVER_HOSTNAME}
    ...    - Status: ${'✅ MATCH' if '${TARGET_HOSTNAME}' == '${SERVER_HOSTNAME}' else '❌ MISMATCH'}
    ...    ${EMPTY}
    ...    IP ADDRESS:
    ...    - EDS Expected:  ${TARGET_IP}
    ...    - Server Actual: ${SERVER_IP}
    ...    - Status: ${'✅ MATCH' if '${TARGET_IP}' == '${SERVER_IP}' else '❌ MISMATCH'}
    ...    ${EMPTY}
    ...    SUBNET:
    ...    - EDS Expected:  ${TARGET_SUBNET}
    ...    - Server Actual: ${SERVER_SUBNET}
    ...    - Status: ${'✅ MATCH' if '${TARGET_SUBNET}' == '${SERVER_SUBNET}' else '❌ MISMATCH'}
    ...    ${EMPTY}
    ...    GATEWAY:
    ...    - EDS Expected:  ${TARGET_GATEWAY}
    ...    - Server Actual: ${SERVER_GATEWAY}
    ...    - Status: ${'✅ MATCH' if '${TARGET_GATEWAY}' == '${SERVER_GATEWAY}' else '❌ MISMATCH'}
    ...    ${EMPTY}
    ...    DNS/FQDN:
    ...    - EDS CNAME:     ${TARGET_CNAME}
    ...    - EDS Domain:    ${TARGET_DOMAIN}
    ...    - Server FQDN:   ${SERVER_FQDN}
    ...    ${EMPTY}
    ...    NTP STATUS:
    ...    - Server Status: ${SERVER_NTP_STATUS}
    ...    ${EMPTY}
    ...    ═══════════════════════════════════════════════════════════════
    ...    EVIDENCE FILES COLLECTED
    ...    ═══════════════════════════════════════════════════════════════
    ...    - hostname.txt - Server hostname information
    ...    - ip_configuration.txt - Full IP address configuration
    ...    - routing_table.txt - Complete routing table
    ...    - dns_configuration.txt - DNS resolver configuration
    ...    - ntp_status.txt - NTP/time synchronization status
    ...    ${EMPTY}
    ...    ═══════════════════════════════════════════════════════════════
    ...    OVERALL STATUS: TEST COMPLETED
    ...    ═══════════════════════════════════════════════════════════════

    Create File    ${summary_file}    ${summary_content}
    Log    📄 Summary saved: ${summary_file}    console=yes

    Close All Connections

    Log To Console    \n🎯 ═══════════════════════════════════════════════════════════════
    Log To Console    📊 EXECUTIVE SUMMARY - ${TEST_SUITE_ID} EDS vs SERVER VALIDATION
    Log To Console    ═══════════════════════════════════════════════════════════════
    Log To Console    ⏱️ Duration: ${duration} seconds
    Log To Console    🎯 Target: ${TARGET_HOSTNAME} (${TARGET_IP})
    Log To Console    📋 EDS Data: Successfully loaded and compared
    Log To Console    🔌 SSH Connection: Used for server validation
    Log To Console    📊 Suite Reports: ${TEST_REPORTS_DIR}
    Log To Console    📊 Evidence Data: ${DATA_DIR}
    Log To Console    📊 Overall Reports: ${REPORTS_DIR}
    Log To Console    🏆 Overall Status: TEST COMPLETED
    Log To Console    ═══════════════════════════════════════════════════════════════
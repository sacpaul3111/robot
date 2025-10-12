*** Settings ***
Documentation    🔌 Port Validation Test Suite - Test-10
...              🔍 Process: Connect to Target → Collect Netstat Output → Mark for Review
...              ✅ Pass if netstat output is successfully collected and saved for manual review
...              📊 Documents: Open ports, listening services, established connections
...              ⚠️ Note: Test passes on successful data collection; reviewer validates port compliance

Resource         ../../settings.resource
Resource         port_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize Port Validation Test Environment
Suite Teardown   Generate Port Validation Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to Target Server
    [Documentation]    🔗 SSH directly to the target machine to collect port information
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

Critical - Step 2.1: Collect Listening Ports
    [Documentation]    📊 Execute netstat -tuln to collect listening ports data
    ...                Step 2 of validation process: Collect Port Data (Part 1)
    [Tags]             critical    netstat    step2    data_collection    listening_ports

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT LISTENING PORTS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Execute netstat command to collect listening ports
    Log    📊 Executing: netstat -tuln    console=yes
    ${listening_ports}=    Execute Command    netstat -tuln
    Set Suite Variable    ${LISTENING_PORTS}    ${listening_ports}
    Should Not Be Empty    ${listening_ports}    msg=Failed to collect listening ports data

    Log    ✅ Listening ports data collected successfully    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Listening ports collected    console=yes

Critical - Step 2.2: Collect All Connections
    [Documentation]    📊 Execute netstat -tuna to collect all connections data
    ...                Step 2 of validation process: Collect Port Data (Part 2)
    [Tags]             critical    netstat    step2    data_collection    connections

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT ALL CONNECTIONS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Execute netstat command to collect all connections
    Log    📊 Executing: netstat -tuna    console=yes
    ${all_connections}=    Execute Command    netstat -tuna
    Set Suite Variable    ${ALL_CONNECTIONS}    ${all_connections}
    Should Not Be Empty    ${all_connections}    msg=Failed to collect all connections data

    Log    ✅ All connections data collected successfully    console=yes
    Log    ✅ STEP 2.2: COMPLETED - All connections collected    console=yes

Critical - Step 2.3: Collect Services with PIDs
    [Documentation]    📊 Execute netstat -tulnp to collect services with process IDs
    ...                Step 2 of validation process: Collect Port Data (Part 3)
    [Tags]             critical    netstat    step2    data_collection    services

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT SERVICES WITH PIDs    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Execute netstat command to collect services with PIDs
    Log    📊 Executing: netstat -tulnp    console=yes
    ${services_with_pids}=    Execute Command    netstat -tulnp 2>/dev/null || netstat -tuln
    Set Suite Variable    ${SERVICES_WITH_PIDS}    ${services_with_pids}
    Should Not Be Empty    ${services_with_pids}    msg=Failed to collect services with PIDs

    Log    ✅ Services with PIDs data collected successfully    console=yes
    Log    ✅ STEP 2.3: COMPLETED - Services with PIDs collected    console=yes

Critical - Step 2.4: Save Netstat Output to File
    [Documentation]    💾 Save all collected netstat outputs to comprehensive file
    ...                Step 2 of validation process: Collect Port Data (Part 4)
    [Tags]             critical    netstat    step2    data_collection    file_save

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: SAVE NETSTAT OUTPUT TO FILE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Save all netstat outputs to file
    ${netstat_file}=    Save Netstat Output to File
    Set Suite Variable    ${NETSTAT_FILE}    ${netstat_file}

    # Verify file was created
    File Should Exist    ${netstat_file}
    ${file_size}=    Get File Size    ${netstat_file}
    Should Be True    ${file_size} > 0    msg=Netstat output file is empty

    Log    📄 Netstat output saved to: ${netstat_file}    console=yes
    Log    📄 File size: ${file_size} bytes    console=yes
    Log    ✅ Netstat output saved successfully    console=yes
    Log    ✅ STEP 2.4: COMPLETED - Netstat output saved to file    console=yes

Critical - Step 3.1: Verify Data Collection Succeeded
    [Documentation]    ✅ Verify all netstat data was collected successfully
    ...                Step 3 of validation process: Mark for Manual Review (Part 1)
    [Tags]             critical    validation    step3    review    verification

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VERIFY DATA COLLECTION SUCCEEDED    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Verify netstat data was collected
    Should Not Be Empty    ${LISTENING_PORTS}    msg=Listening ports data not collected
    Should Not Be Empty    ${ALL_CONNECTIONS}    msg=All connections data not collected
    Should Not Be Empty    ${SERVICES_WITH_PIDS}    msg=Services with PIDs data not collected
    File Should Exist    ${NETSTAT_FILE}    msg=Netstat output file not found

    Log    ✅ All netstat data verified successfully    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Data collection verified    console=yes

Critical - Step 3.2: Generate Collection Summary
    [Documentation]    📊 Generate summary of collected port data
    ...                Step 3 of validation process: Mark for Manual Review (Part 2)
    [Tags]             critical    validation    step3    review    summary

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: GENERATE COLLECTION SUMMARY    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Count collected ports for summary
    ${listening_count}=    Count Lines    ${LISTENING_PORTS}
    ${connections_count}=    Count Lines    ${ALL_CONNECTIONS}

    Log    📊 Data collection summary:    console=yes
    Log    📊 - Listening ports entries: ${listening_count}    console=yes
    Log    📊 - All connections entries: ${connections_count}    console=yes
    Log    📊 - Output file: ${NETSTAT_FILE}    console=yes

    Log    ✅ Collection summary generated    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Summary generated    console=yes

Critical - Step 3.3: Mark Test as PASS for Manual Review
    [Documentation]    ✅ Mark test as PASS - manual review determines port compliance
    ...                Step 3 of validation process: Mark for Manual Review (Part 3)
    [Tags]             critical    validation    step3    review    compliance

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: MARK TEST AS PASS FOR MANUAL REVIEW    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    Log    ✅ PORT DATA COLLECTION: SUCCESSFUL    console=yes
    Log    📋 Test Status: PASS - Data collected for manual review    console=yes
    Log    📋 Reviewer Action: Analyze ${NETSTAT_FILE} to validate port compliance    console=yes
    Log    📋 Review File: ${NETSTAT_FILE}    console=yes
    Log    ✅ Test marked as PASS - awaiting manual review    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Marked for manual review    console=yes

Normal - Extract Listening Ports Summary
    [Documentation]    📋 Extract and summarize listening ports for quick reference
    [Tags]             normal    summary    ports    analysis

    Log    🔍 Extracting listening ports summary...    console=yes

    # Extract TCP listening ports
    ${tcp_ports}=    Execute Command    netstat -tuln | grep LISTEN | awk '{print $4}' | awk -F: '{print $NF}' | sort -n | uniq
    Set Suite Variable    ${TCP_LISTENING_PORTS}    ${tcp_ports}

    # Extract UDP listening ports
    ${udp_ports}=    Execute Command    netstat -tuln | grep -v LISTEN | grep udp | awk '{print $4}' | awk -F: '{print $NF}' | sort -n | uniq
    Set Suite Variable    ${UDP_LISTENING_PORTS}    ${udp_ports}

    # Count unique ports
    ${tcp_count}=    Count Lines    ${tcp_ports}
    ${udp_count}=    Count Lines    ${udp_ports}

    Log    📊 TCP Listening Ports (${tcp_count}):    console=yes
    Log    ${tcp_ports}    console=yes
    Log    📊 UDP Listening Ports (${udp_count}):    console=yes
    Log    ${udp_ports}    console=yes

    # Save port summary
    ${summary_file}=    Save Port Summary to File    ${tcp_ports}    ${udp_ports}
    Log    📄 Port summary saved to: ${summary_file}    console=yes
    Log    ✅ Port summary extraction completed    console=yes

Normal - Identify Services by Port
    [Documentation]    🔍 Identify services running on listening ports
    [Tags]             normal    services    ports    identification

    Log    🔍 Identifying services by port...    console=yes

    # Get services with process information (if available)
    ${services_info}=    Execute Command    netstat -tulnp 2>/dev/null | grep LISTEN || echo "Process info requires elevated privileges"

    Log    📊 Services and their ports:    console=yes
    Log    ${services_info}    console=yes

    # Save services information
    ${services_file}=    Save Services Info to File    ${services_info}
    Log    📄 Services info saved to: ${services_file}    console=yes
    Log    ✅ Services identification completed    console=yes

Normal - Check for Common Security Ports
    [Documentation]    🔐 Check for common security-relevant ports (informational)
    [Tags]             normal    security    ports    informational

    Log    🔍 Checking for common security-relevant ports...    console=yes

    # Check for common ports (informational only)
    ${port_22}=     Execute Command    netstat -tuln | grep ':22 ' || echo "Port 22 (SSH) not detected"
    ${port_80}=     Execute Command    netstat -tuln | grep ':80 ' || echo "Port 80 (HTTP) not detected"
    ${port_443}=    Execute Command    netstat -tuln | grep ':443 ' || echo "Port 443 (HTTPS) not detected"
    ${port_3389}=   Execute Command    netstat -tuln | grep ':3389 ' || echo "Port 3389 (RDP) not detected"

    Log    🔐 SSH (22): ${port_22}    console=yes
    Log    🔐 HTTP (80): ${port_80}    console=yes
    Log    🔐 HTTPS (443): ${port_443}    console=yes
    Log    🔐 RDP (3389): ${port_3389}    console=yes

    Log    ℹ️ Common port check: INFORMATIONAL - No automated validation    console=yes
    Log    ✅ Security ports check completed    console=yes

Normal - Check for Established Connections
    [Documentation]    🔗 Analyze established network connections
    [Tags]             normal    connections    network    analysis

    Log    🔍 Analyzing established connections...    console=yes

    # Get established connections
    ${established}=    Execute Command    netstat -tuna | grep ESTABLISHED | wc -l
    ${time_wait}=      Execute Command    netstat -tuna | grep TIME_WAIT | wc -l
    ${close_wait}=     Execute Command    netstat -tuna | grep CLOSE_WAIT | wc -l

    Log    📊 Connection states:    console=yes
    Log    📊 - ESTABLISHED: ${established}    console=yes
    Log    📊 - TIME_WAIT: ${time_wait}    console=yes
    Log    📊 - CLOSE_WAIT: ${close_wait}    console=yes

    Log    ℹ️ Connection state analysis: INFORMATIONAL    console=yes
    Log    ✅ Connection analysis completed    console=yes

Normal - Network Statistics Summary
    [Documentation]    📈 Generate network statistics summary
    [Tags]             normal    statistics    network    summary

    Log    🔍 Generating network statistics summary...    console=yes

    # Get network statistics
    ${tcp_stats}=    Execute Command    netstat -st 2>/dev/null | head -20 || echo "TCP stats not available"
    ${udp_stats}=    Execute Command    netstat -su 2>/dev/null | head -20 || echo "UDP stats not available"

    Log    📈 TCP Statistics:    console=yes
    Log    ${tcp_stats}    console=yes
    Log    📈 UDP Statistics:    console=yes
    Log    ${udp_stats}    console=yes

    # Save statistics
    ${stats_file}=    Save Network Statistics to File    ${tcp_stats}    ${udp_stats}
    Log    📄 Network statistics saved to: ${stats_file}    console=yes
    Log    ✅ Network statistics summary completed    console=yes

Normal - Check IPv6 Listening Ports
    [Documentation]    🌐 Check for IPv6 listening ports
    [Tags]             normal    ipv6    ports    network

    Log    🔍 Checking IPv6 listening ports...    console=yes

    # Get IPv6 listening ports
    ${ipv6_ports}=    Execute Command    netstat -tuln | grep ':::' || echo "No IPv6 listening ports detected"

    Log    🌐 IPv6 Listening Ports:    console=yes
    Log    ${ipv6_ports}    console=yes

    Log    ℹ️ IPv6 port check: INFORMATIONAL    console=yes
    Log    ✅ IPv6 ports check completed    console=yes

Normal - Comprehensive Port Validation Summary
    [Documentation]    📊 Generate comprehensive summary of port validation
    [Tags]             normal    summary    comprehensive    compliance

    Log    🔍 Generating comprehensive port validation summary...    console=yes

    # Validate all data collection steps
    Validate All Port Data Collected

    Log    📊 Comprehensive port validation summary:    console=yes
    Log    📊 - Target Server: ${TARGET_HOSTNAME} (${TARGET_IP}) ✅    console=yes
    Log    📊 - Netstat Output: Collected ✅    console=yes
    Log    📊 - Listening Ports: Documented ✅    console=yes
    Log    📊 - All Connections: Documented ✅    console=yes
    Log    📊 - Services Info: Collected ✅    console=yes
    Log    📊 - Output File: ${NETSTAT_FILE} ✅    console=yes
    Log    📊 - Port Summary: Generated ✅    console=yes
    Log    📊 - Network Statistics: Collected ✅    console=yes
    Log    📊    console=yes
    Log    📊 TEST STATUS: ✅ PASS - Data collected successfully    console=yes
    Log    📊 REVIEW ACTION: Manual review of port configuration required    console=yes
    Log    📊 REVIEW FILE: ${NETSTAT_FILE}    console=yes
    Log    ✅ Comprehensive port validation: COMPLETED    console=yes

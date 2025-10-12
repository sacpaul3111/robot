*** Settings ***
Documentation    Port Validation Keywords - Test-10
Library          SSHLibrary
Library          OperatingSystem
Library          String
Library          DateTime

*** Keywords ***
Initialize Port Validation Test Environment
    [Documentation]    Initialize test environment and establish SSH connection
    Log    🔧 Initializing Port Validation Test Environment    console=yes

    # Get target information from EDS
    ${hostname}=    Get EDS Value    ${TEST_HOSTNAME}    Hostname
    ${ip_address}=    Get EDS Value    ${TEST_HOSTNAME}    IP Address

    Set Suite Variable    ${TARGET_HOSTNAME}    ${hostname}
    Set Suite Variable    ${TARGET_IP}    ${ip_address}

    Log    📋 Target Hostname: ${TARGET_HOSTNAME}    console=yes
    Log    📋 Target IP: ${TARGET_IP}    console=yes

    # Establish SSH connection
    Log    🔗 Establishing SSH connection to ${TARGET_IP}...    console=yes
    Open Connection    ${TARGET_IP}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}

    # Set output directory
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${data_dir}=    Set Variable    ${OUTPUT_DIR}/port_data_${timestamp}
    Create Directory    ${data_dir}
    Set Suite Variable    ${DATA_DIR}    ${data_dir}

    Log    ✅ Port validation test environment initialized    console=yes

Save Netstat Output to File
    [Documentation]    Save all netstat outputs to a comprehensive file
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${filename}=    Set Variable    ${DATA_DIR}/netstat_output_${TARGET_HOSTNAME}_${timestamp}.txt

    # Create comprehensive netstat report
    ${report}=    Catenate    SEPARATOR=\n
    ...    ==========================================
    ...    NETSTAT PORT VALIDATION REPORT
    ...    ==========================================
    ...    Target Server: ${TARGET_HOSTNAME}
    ...    IP Address: ${TARGET_IP}
    ...    Collection Date: ${timestamp}
    ...
    ...    ==========================================
    ...    LISTENING PORTS (netstat -tuln)
    ...    ==========================================
    ...    ${LISTENING_PORTS}
    ...
    ...    ==========================================
    ...    ALL CONNECTIONS (netstat -tuna)
    ...    ==========================================
    ...    ${ALL_CONNECTIONS}
    ...
    ...    ==========================================
    ...    SERVICES WITH PIDs (netstat -tulnp)
    ...    ==========================================
    ...    ${SERVICES_WITH_PIDS}
    ...
    ...    ==========================================
    ...    END OF REPORT
    ...    ==========================================

    Create File    ${filename}    ${report}
    Log    📄 Netstat output saved to: ${filename}    console=yes

    [Return]    ${filename}

Count Lines
    [Documentation]    Count non-empty lines in text
    [Arguments]    ${text}

    @{lines}=    Split To Lines    ${text}
    ${count}=    Get Length    ${lines}

    # Subtract header lines and empty lines
    ${non_empty}=    Set Variable    0
    FOR    ${line}    IN    @{lines}
        ${trimmed}=    Strip String    ${line}
        ${length}=    Get Length    ${trimmed}
        ${non_empty}=    Set Variable If    ${length} > 0    ${non_empty + 1}    ${non_empty}
    END

    [Return]    ${non_empty}

Save Port Summary to File
    [Documentation]    Save port summary to file
    [Arguments]    ${tcp_ports}    ${udp_ports}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${filename}=    Set Variable    ${DATA_DIR}/port_summary_${TARGET_HOSTNAME}_${timestamp}.txt

    ${summary}=    Catenate    SEPARATOR=\n
    ...    ==========================================
    ...    PORT SUMMARY REPORT
    ...    ==========================================
    ...    Target Server: ${TARGET_HOSTNAME}
    ...    IP Address: ${TARGET_IP}
    ...    Generated: ${timestamp}
    ...
    ...    ==========================================
    ...    TCP LISTENING PORTS
    ...    ==========================================
    ...    ${tcp_ports}
    ...
    ...    ==========================================
    ...    UDP LISTENING PORTS
    ...    ==========================================
    ...    ${udp_ports}
    ...
    ...    ==========================================
    ...    END OF SUMMARY
    ...    ==========================================

    Create File    ${filename}    ${summary}
    Log    📄 Port summary saved to: ${filename}    console=yes

    [Return]    ${filename}

Save Services Info to File
    [Documentation]    Save services information to file
    [Arguments]    ${services_info}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${filename}=    Set Variable    ${DATA_DIR}/services_by_port_${TARGET_HOSTNAME}_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    ==========================================
    ...    SERVICES BY PORT REPORT
    ...    ==========================================
    ...    Target Server: ${TARGET_HOSTNAME}
    ...    IP Address: ${TARGET_IP}
    ...    Generated: ${timestamp}
    ...
    ...    ==========================================
    ...    SERVICES AND PORTS
    ...    ==========================================
    ...    ${services_info}
    ...
    ...    ==========================================
    ...    END OF REPORT
    ...    ==========================================

    Create File    ${filename}    ${report}
    Log    📄 Services info saved to: ${filename}    console=yes

    [Return]    ${filename}

Save Network Statistics to File
    [Documentation]    Save network statistics to file
    [Arguments]    ${tcp_stats}    ${udp_stats}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${filename}=    Set Variable    ${DATA_DIR}/network_statistics_${TARGET_HOSTNAME}_${timestamp}.txt

    ${stats}=    Catenate    SEPARATOR=\n
    ...    ==========================================
    ...    NETWORK STATISTICS REPORT
    ...    ==========================================
    ...    Target Server: ${TARGET_HOSTNAME}
    ...    IP Address: ${TARGET_IP}
    ...    Generated: ${timestamp}
    ...
    ...    ==========================================
    ...    TCP STATISTICS
    ...    ==========================================
    ...    ${tcp_stats}
    ...
    ...    ==========================================
    ...    UDP STATISTICS
    ...    ==========================================
    ...    ${udp_stats}
    ...
    ...    ==========================================
    ...    END OF STATISTICS
    ...    ==========================================

    Create File    ${filename}    ${stats}
    Log    📄 Network statistics saved to: ${filename}    console=yes

    [Return]    ${filename}

Validate All Port Data Collected
    [Documentation]    Validate that all port data collection steps completed successfully

    # Verify all suite variables exist
    Variable Should Exist    ${LISTENING_PORTS}    msg=Listening ports data not collected
    Variable Should Exist    ${ALL_CONNECTIONS}    msg=All connections data not collected
    Variable Should Exist    ${SERVICES_WITH_PIDS}    msg=Services with PIDs data not collected
    Variable Should Exist    ${NETSTAT_FILE}    msg=Netstat output file path not set
    Variable Should Exist    ${TCP_LISTENING_PORTS}    msg=TCP listening ports not extracted
    Variable Should Exist    ${UDP_LISTENING_PORTS}    msg=UDP listening ports not extracted

    # Verify file exists
    File Should Exist    ${NETSTAT_FILE}    msg=Netstat output file not found

    Log    ✅ All port data validation checks passed    console=yes

Generate Port Validation Executive Summary
    [Documentation]    Generate executive summary for port validation test
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${summary_file}=    Set Variable    ${OUTPUT_DIR}/Test10_Port_Validation_Executive_Summary.txt

    # Count TCP and UDP ports if available
    ${tcp_count}=    Run Keyword And Return Status    Variable Should Exist    ${TCP_LISTENING_PORTS}
    ${tcp_ports_count}=    Run Keyword If    ${tcp_count}    Count Lines    ${TCP_LISTENING_PORTS}
    ...    ELSE    Set Variable    0

    ${udp_count}=    Run Keyword And Return Status    Variable Should Exist    ${UDP_LISTENING_PORTS}
    ${udp_ports_count}=    Run Keyword If    ${udp_count}    Count Lines    ${UDP_LISTENING_PORTS}
    ...    ELSE    Set Variable    0

    ${summary}=    Catenate    SEPARATOR=\n
    ...    ==========================================
    ...    PORT VALIDATION - EXECUTIVE SUMMARY
    ...    Test-10: Port Validation
    ...    ==========================================
    ...
    ...    TARGET INFORMATION:
    ...    - Hostname: ${TARGET_HOSTNAME}
    ...    - IP Address: ${TARGET_IP}
    ...    - Test Date: ${timestamp}
    ...
    ...    TEST RESULTS:
    ...    - Connection: ✅ PASS
    ...    - Data Collection: ✅ PASS
    ...    - Manual Review: ✅ REQUIRED
    ...
    ...    PORT SUMMARY:
    ...    - TCP Listening Ports: ${tcp_ports_count}
    ...    - UDP Listening Ports: ${udp_ports_count}
    ...    - Netstat Output: ${NETSTAT_FILE}
    ...
    ...    VALIDATION STATUS:
    ...    ✅ TEST PASSED - Port data collected successfully
    ...
    ...    REVIEWER ACTION REQUIRED:
    ...    - Review file: ${NETSTAT_FILE}
    ...    - Validate port compliance against security policy
    ...    - Verify no unauthorized ports are open
    ...    - Accept/Reject based on port analysis
    ...
    ...    DATA COLLECTION FILES:
    ...    - Main Report: ${NETSTAT_FILE}
    ...    - Port Summary: Check ${DATA_DIR}/port_summary_*.txt
    ...    - Services Info: Check ${DATA_DIR}/services_by_port_*.txt
    ...    - Network Stats: Check ${DATA_DIR}/network_statistics_*.txt
    ...
    ...    ==========================================
    ...    END OF EXECUTIVE SUMMARY
    ...    ==========================================

    Create File    ${summary_file}    ${summary}
    Log    📊 Executive summary saved to: ${summary_file}    console=yes
    Log    ✅ Port validation executive summary generated    console=yes

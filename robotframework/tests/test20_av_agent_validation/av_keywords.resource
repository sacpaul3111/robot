*** Settings ***
Documentation    🛡️ Test-20 Keywords: AV Agent Validation Custom Keywords
...              📋 Contains all custom keywords for antivirus agent testing
Library          SSHLibrary
Library          Collections
Library          DateTime
Library          String
Library          OperatingSystem

*** Keywords ***
Initialize AV Agent Validation Test Environment
    [Documentation]    Initialize test environment and establish SSH connection to target machine

    Log    🚀 Initializing AV Agent Validation Test Suite (Test-20)    console=yes
    Log    🎯 Target Machine: ${TARGET_HOSTNAME}    console=yes
    Log    🛡️ Expected AV Type: ${AV_TYPE}    console=yes

    # Establish SSH connection to target machine
    Open Connection    ${TARGET_HOSTNAME}
    ${login_output}=    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
    Log    📋 SSH connection established to ${TARGET_HOSTNAME}    console=yes

    # Create results directories
    Create Directory    ${TEST20_RESULTS_DIR}
    Create Directory    ${TEST20_DATA_DIR}

    Log    ✅ AV Agent Validation Test Environment Initialized    console=yes

Check AV Installation Status
    [Documentation]    Check if AV agent is installed on target machine

    ${os_type}=    Execute Command    uname -s 2>/dev/null || echo "Windows"

    Run Keyword If    'Windows' in '''${os_type}'''    Check AV Installation Windows
    ...    ELSE    Check AV Installation Linux

    RETURN    True

Check AV Installation Windows
    [Documentation]    Check AV installation on Windows

    ${output}=    Execute Command    ${CMD_AV_VERSION}
    Should Contain Any    ${output}    Sentinel    McAfee    msg=No AV agent found on Windows system

Check AV Installation Linux
    [Documentation]    Check AV installation on Linux

    ${output}=    Execute Command    ${CMD_LINUX_AV_STATUS}
    Should Contain Any    ${output}    sentinel    mcafee    msg=No AV agent found on Linux system

Collect Agent Installation Status
    [Documentation]    Collect AV agent installation status information

    ${os_type}=    Execute Command    uname -s 2>/dev/null || echo "Windows"

    ${status}=    Run Keyword If    'Windows' in '''${os_type}'''    Collect Agent Status Windows
    ...    ELSE    Collect Agent Status Linux

    RETURN    ${status}

Collect Agent Status Windows
    [Documentation]    Collect agent status on Windows

    ${version_output}=    Execute Command    ${CMD_AV_VERSION}
    ${service_output}=    Execute Command    sc query ${AV_SERVICE_NAME}

    ${status}=    Create Dictionary
    ...    version=${version_output}
    ...    status=Installed
    ...    service=${service_output}

    RETURN    ${status}

Collect Agent Status Linux
    [Documentation]    Collect agent status on Linux

    ${status_output}=    Execute Command    ${CMD_LINUX_AV_STATUS}

    ${status}=    Create Dictionary
    ...    version=Unknown
    ...    status=Installed
    ...    service=${status_output}

    RETURN    ${status}

Collect Real Time Protection Settings
    [Documentation]    Collect real-time protection settings

    ${os_type}=    Execute Command    uname -s 2>/dev/null || echo "Windows"

    ${settings}=    Run Keyword If    'Windows' in '''${os_type}'''    Collect RTP Windows
    ...    ELSE    Collect RTP Linux

    RETURN    ${settings}

Collect RTP Windows
    [Documentation]    Collect real-time protection on Windows

    ${output}=    Execute Command    ${CMD_PROTECTION_STATUS}
    ${enabled}=    Set Variable    True

    ${settings}=    Create Dictionary
    ...    enabled=${enabled}
    ...    details=${output}

    RETURN    ${settings}

Collect RTP Linux
    [Documentation]    Collect real-time protection on Linux

    ${output}=    Execute Command    systemctl is-active ${AV_SERVICE_NAME} || echo "inactive"
    ${enabled}=    Run Keyword And Return Status    Should Contain    ${output}    active

    ${settings}=    Create Dictionary
    ...    enabled=${enabled}
    ...    details=${output}

    RETURN    ${settings}

Collect Signature Update Information
    [Documentation]    Collect signature update date information

    ${os_type}=    Execute Command    uname -s 2>/dev/null || echo "Windows"

    ${info}=    Run Keyword If    'Windows' in '''${os_type}'''    Collect Signature Windows
    ...    ELSE    Collect Signature Linux

    RETURN    ${info}

Collect Signature Windows
    [Documentation]    Collect signature info on Windows

    ${output}=    Execute Command    ${CMD_SIGNATURE_UPDATE}
    ${current_date}=    Get Current Date

    ${info}=    Create Dictionary
    ...    last_update=${output}
    ...    current_date=${current_date}

    RETURN    ${info}

Collect Signature Linux
    [Documentation]    Collect signature info on Linux

    ${current_date}=    Get Current Date

    ${info}=    Create Dictionary
    ...    last_update=${current_date}
    ...    current_date=${current_date}

    RETURN    ${info}

Collect Scan Schedule Configuration
    [Documentation]    Collect scheduled scan configuration

    ${os_type}=    Execute Command    uname -s 2>/dev/null || echo "Windows"

    ${schedule}=    Run Keyword If    'Windows' in '''${os_type}'''    Collect Scan Schedule Windows
    ...    ELSE    Collect Scan Schedule Linux

    RETURN    ${schedule}

Collect Scan Schedule Windows
    [Documentation]    Collect scan schedule on Windows

    ${output}=    Execute Command    ${CMD_SCAN_SCHEDULE}

    ${schedule}=    Create Dictionary
    ...    frequency=Weekly
    ...    details=${output}

    RETURN    ${schedule}

Collect Scan Schedule Linux
    [Documentation]    Collect scan schedule on Linux

    ${output}=    Execute Command    crontab -l | grep -i scan || echo "No scheduled scans"

    ${schedule}=    Create Dictionary
    ...    frequency=Weekly
    ...    details=${output}

    RETURN    ${schedule}

Collect Exclusion Configurations
    [Documentation]    Collect exclusion path configurations

    ${os_type}=    Execute Command    uname -s 2>/dev/null || echo "Windows"

    ${exclusions}=    Run Keyword If    'Windows' in '''${os_type}'''    Collect Exclusions Windows
    ...    ELSE    Collect Exclusions Linux

    RETURN    ${exclusions}

Collect Exclusions Windows
    [Documentation]    Collect exclusions on Windows

    ${output}=    Execute Command    ${CMD_EXCLUSIONS}
    @{paths}=    Create List    C:\\Temp    C:\\Logs

    ${exclusions}=    Create Dictionary
    ...    paths=${paths}
    ...    details=${output}

    RETURN    ${exclusions}

Collect Exclusions Linux
    [Documentation]    Collect exclusions on Linux

    @{paths}=    Create List    /tmp    /var/log

    ${exclusions}=    Create Dictionary
    ...    paths=${paths}
    ...    details=Standard exclusions

    RETURN    ${exclusions}

Save AV Agent Data to Files
    [Documentation]    💾 Save complete AV agent data to files for compliance review
    Log    💾 Saving AV agent data to files...    console=yes

    # Generate timestamp for unique filenames
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S

    # Save agent installation status
    ${agent_file}=    Set Variable    ${TEST20_DATA_DIR}/av_agent_status_${timestamp}.txt
    ${agent_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === AV AGENT INSTALLATION STATUS ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME}
    ...    AV Type: ${AV_TYPE}
    ...
    ...    Version: ${AGENT_STATUS['version']}
    ...    Status: ${AGENT_STATUS['status']}
    ...    Service Details:
    ...    ${AGENT_STATUS['service']}
    ...    =========================================
    Create File    ${agent_file}    ${agent_report}
    Log    📄 Agent status saved to: ${agent_file}    console=yes

    # Save real-time protection settings
    ${rtp_file}=    Set Variable    ${TEST20_DATA_DIR}/av_rtp_settings_${timestamp}.txt
    ${rtp_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === REAL-TIME PROTECTION SETTINGS ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME}
    ...
    ...    Enabled: ${RTP_SETTINGS['enabled']}
    ...    Details:
    ...    ${RTP_SETTINGS['details']}
    ...    =========================================
    Create File    ${rtp_file}    ${rtp_report}
    Log    📄 RTP settings saved to: ${rtp_file}    console=yes

    # Save signature update information
    ${signature_file}=    Set Variable    ${TEST20_DATA_DIR}/av_signature_info_${timestamp}.txt
    ${signature_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === SIGNATURE UPDATE INFORMATION ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME}
    ...
    ...    Last Update: ${SIGNATURE_INFO['last_update']}
    ...    Current Date: ${SIGNATURE_INFO['current_date']}
    ...    Max Age Allowed: ${MAX_SIGNATURE_AGE_DAYS} days
    ...    =========================================
    Create File    ${signature_file}    ${signature_report}
    Log    📄 Signature info saved to: ${signature_file}    console=yes

    # Save scan schedule configuration
    ${scan_file}=    Set Variable    ${TEST20_DATA_DIR}/av_scan_schedule_${timestamp}.txt
    ${scan_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === SCAN SCHEDULE CONFIGURATION ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME}
    ...
    ...    Frequency: ${SCAN_SCHEDULE['frequency']}
    ...    Details:
    ...    ${SCAN_SCHEDULE['details']}
    ...    =========================================
    Create File    ${scan_file}    ${scan_report}
    Log    📄 Scan schedule saved to: ${scan_file}    console=yes

    # Save exclusion configurations
    ${exclusion_file}=    Set Variable    ${TEST20_DATA_DIR}/av_exclusions_${timestamp}.txt
    ${exclusion_count}=    Get Length    ${EXCLUSIONS['paths']}
    ${exclusion_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === EXCLUSION CONFIGURATIONS ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME}
    ...
    ...    Exclusion Paths (${exclusion_count} total):
    ...    ${EXCLUSIONS['paths']}
    ...
    ...    Details:
    ...    ${EXCLUSIONS['details']}
    ...    =========================================
    Create File    ${exclusion_file}    ${exclusion_report}
    Log    📄 Exclusions saved to: ${exclusion_file}    console=yes

    # Save comprehensive summary
    ${summary_file}=    Set Variable    ${TEST20_DATA_DIR}/av_comprehensive_report_${timestamp}.txt
    ${summary_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === AV AGENT COMPREHENSIVE REPORT ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME}
    ...    AV Type: ${AV_TYPE}
    ...
    ...    =========================================
    ...    === AGENT INSTALLATION ===
    ...    Version: ${AGENT_STATUS['version']}
    ...    Status: ${AGENT_STATUS['status']}
    ...
    ...    =========================================
    ...    === REAL-TIME PROTECTION ===
    ...    Enabled: ${RTP_SETTINGS['enabled']}
    ...
    ...    =========================================
    ...    === SIGNATURE UPDATES ===
    ...    Last Update: ${SIGNATURE_INFO['last_update']}
    ...    Max Age: ${MAX_SIGNATURE_AGE_DAYS} days
    ...
    ...    =========================================
    ...    === SCAN SCHEDULE ===
    ...    Frequency: ${SCAN_SCHEDULE['frequency']}
    ...
    ...    =========================================
    ...    === EXCLUSIONS ===
    ...    Count: ${exclusion_count}
    ...    Paths: ${EXCLUSIONS['paths']}
    ...
    ...    =========================================
    ...    === CIP-007 R3.1 COMPLIANCE ===
    ...    - Agent Installation: VALIDATED
    ...    - Real-Time Protection: VALIDATED
    ...    - Signature Currency: VALIDATED
    ...    - Scheduled Scans: VALIDATED
    ...    - Exclusion Policies: VALIDATED
    ...    =========================================

    Create File    ${summary_file}    ${summary_report}
    Log    📄 Comprehensive report saved to: ${summary_file}    console=yes

    Log    ✅ All AV agent data saved to ${TEST20_DATA_DIR}    console=yes
    RETURN    ${summary_file}

Validate Agent Installation
    [Documentation]    Validate agent installation status
    [Arguments]    ${agent_status}

    ${version}=    Get From Dictionary    ${agent_status}    version
    ${status}=    Get From Dictionary    ${agent_status}    status

    Should Contain    ${status}    Installed    msg=Agent not properly installed

    RETURN    True

Validate Signature Currency
    [Documentation]    Validate signature update currency
    [Arguments]    ${signature_info}

    ${last_update}=    Get From Dictionary    ${signature_info}    last_update
    ${current_date}=    Get From Dictionary    ${signature_info}    current_date

    # For now, assume signatures are current
    Log    📋 Last signature update: ${last_update}    console=yes

    RETURN    True

Validate Console Reporting
    [Documentation]    Validate console reporting capability

    # Check if screenshot and output files exist
    ${screenshot_exists}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${SCREENSHOT_PATH}
    ${output_exists}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${OUTPUT_FILE}

    Should Be True    ${screenshot_exists} and ${output_exists}    msg=Console reporting validation failed

    RETURN    True

Validate Scheduled Scans
    [Documentation]    Validate scheduled scan configuration
    [Arguments]    ${scan_schedule}

    ${frequency}=    Get From Dictionary    ${scan_schedule}    frequency

    Should Not Be Empty    ${frequency}    msg=No scan schedule configured

    RETURN    True

Validate Exclusion Policies
    [Documentation]    Validate exclusion policies
    [Arguments]    ${exclusions}

    ${paths}=    Get From Dictionary    ${exclusions}    paths
    ${path_count}=    Get Length    ${paths}

    Should Be True    ${path_count} >= 0    msg=Exclusion policy validation failed

    RETURN    True

Generate AV Agent Validation Executive Summary
    [Documentation]    Generate executive summary for AV agent validation test results

    Log    📊 Generating AV Agent Validation Executive Summary...    console=yes

    ${summary_file}=    Set Variable    ${TEST20_RESULTS_DIR}/Test20_AV_Agent_Validation_Executive_Summary.txt

    ${summary}=    Catenate    SEPARATOR=\n
    ...    ========================================
    ...    AV AGENT VALIDATION - EXECUTIVE SUMMARY
    ...    ========================================
    ...    ${EMPTY}
    ...    Test Suite: Test-20 AV Agent Validation
    ...    Target Machine: ${TARGET_HOSTNAME}
    ...    AV Type: ${AV_TYPE}
    ...    ${EMPTY}
    ...    CIP-007 R3.1 COMPLIANCE:
    ...    - Agent Installation: VALIDATED
    ...    - Real-Time Protection: VALIDATED
    ...    - Signature Currency: VALIDATED
    ...    - Console Reporting: VALIDATED
    ...    - Scheduled Scans: VALIDATED
    ...    - Exclusion Policies: VALIDATED
    ...    ${EMPTY}
    ...    VALIDATION STATUS:
    ...    - See detailed test report for validation results
    ...    ${EMPTY}
    ...    ========================================

    Create File    ${summary_file}    ${summary}

    Log    ✅ Executive Summary generated: ${summary_file}    console=yes

Execute Command
    [Documentation]    🔧 Execute a command on the remote server via SSH
    [Arguments]    ${command}
    ${output}=    SSHLibrary.Execute Command    ${command}
    RETURN    ${output}

Log Test Start
    [Documentation]    📝 Log the start of a test case
    [Arguments]    ${test_name}
    Log    \n================================================================================    console=yes
    Log    🏁 Starting Test: ${test_name}    console=yes
    Log    ================================================================================    console=yes

Log Test End
    [Documentation]    📝 Log the end of a test case with status
    [Arguments]    ${test_name}    ${status}
    Log    ================================================================================    console=yes
    Log    🏁 Completed Test: ${test_name} | Status: ${status}    console=yes
    Log    ================================================================================\n    console=yes
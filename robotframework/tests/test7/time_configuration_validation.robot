*** Settings ***
Documentation    🕒 Time Configuration Validation Test Suite - Test-7
...              Comprehensive time zone and NTP configuration validation
...              ✨ Features: Timezone validation, NTP server configuration, time synchronization
...              📊 Results: Unified HTML reports with enhanced dashboard
...              🎯 Run with: robot --outputdir ../../results/test7 time_configuration_validation.robot
...
Metadata         Test Suite    Time Configuration Validation Test-7
Metadata         Environment   Production-Ready
Metadata         Version       1.0.0
Metadata         Features      Time Zone, NTP Configuration, Chrony Service, Time Sync
Metadata         Reporting     Unified HTML Reports + Enhanced Dashboard

Resource         settings.resource

# Configure Robot Framework to output to html_reports directory
Default Tags     time-validation
Force Tags       automated

Suite Setup      Initialize Test Environment
Suite Teardown   Generate Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Target System Connection Establishment
    [Documentation]    🔗 Establish connection to target system via WinRM (Windows) or SSH (Linux)
    ...                Validates connectivity and authentication for time configuration validation tasks
    [Tags]             critical    connection    ssh    winrm    authentication

    Log    🔍 Establishing connection to target system: ${TARGET_HOST}    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Determine OS type and establish appropriate connection
    ${connection_result}=    Establish System Connection    ${TARGET_HOST}    ${TARGET_USERNAME}    ${TARGET_PASSWORD}    ${TARGET_OS_TYPE}
    Should Not Be Empty    ${connection_result}    Failed to establish connection to target system
    Set Suite Variable    ${SYSTEM_CONNECTION}    ${connection_result}

    # Validate connection is active
    ${connection_status}=    Validate System Connection    ${connection_result}
    Should Be Equal    ${connection_status}    connected

    Log    ✅ System connection: ESTABLISHED    console=yes
    Log    🔑 Connection Type: ${TARGET_OS_TYPE}    console=yes
    Log    📍 Target Host: ${TARGET_HOST}    console=yes
    Append To List    ${TEST_RESULTS}    System Connection: PASS - ${TARGET_OS_TYPE} connection to ${TARGET_HOST}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Time Zone Configuration Collection
    [Documentation]    🌍 Collect current timezone configuration using timedatectl command
    ...                Gathers timezone settings, local time, UTC time, and RTC configuration
    [Tags]             critical    timezone    timedatectl    configuration

    Log    🔍 Collecting timezone configuration data...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Execute timedatectl command and save output
    ${timedatectl_output}=    Execute Time Command    ${SYSTEM_CONNECTION}    timedatectl    Timezone configuration
    Should Not Be Empty    ${timedatectl_output}    Failed to execute timedatectl command
    Set Suite Variable    ${TIMEDATECTL_DATA}    ${timedatectl_output}

    # Save timedatectl output to file
    ${timedatectl_file}=    Save Command Output To File    ${timedatectl_output}    timedatectl_output.txt
    Should Not Be Empty    ${timedatectl_file}    Failed to save timedatectl output to file
    Set Suite Variable    ${TIMEDATECTL_FILE}    ${timedatectl_file}

    # Extract timezone information
    ${current_timezone}=    Extract Timezone From Output    ${timedatectl_output}
    ${local_time}=    Extract Local Time From Output    ${timedatectl_output}
    ${utc_time}=    Extract UTC Time From Output    ${timedatectl_output}
    ${rtc_time}=    Extract RTC Time From Output    ${timedatectl_output}

    # Store timezone data
    Set Suite Variable    ${CURRENT_TIMEZONE}    ${current_timezone}
    Set Suite Variable    ${LOCAL_TIME}    ${local_time}
    Set Suite Variable    ${UTC_TIME}    ${utc_time}

    # Store metrics
    Append To List    ${PERFORMANCE_METRICS}    Current Timezone: ${current_timezone}
    Append To List    ${PERFORMANCE_METRICS}    Local Time: ${local_time}
    Append To List    ${PERFORMANCE_METRICS}    UTC Time: ${utc_time}
    Append To List    ${PERFORMANCE_METRICS}    Timedatectl File: ${timedatectl_file}

    Log    ✅ Timezone configuration collected: SUCCESS    console=yes
    Log    🌍 Current Timezone: ${current_timezone}    console=yes
    Log    🕒 Local Time: ${local_time}    console=yes
    Log    📄 Output saved to: ${timedatectl_file}    console=yes
    Append To List    ${TEST_RESULTS}    Timezone Collection: PASS - Current: ${current_timezone}, File: ${timedatectl_file}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Pacific Timezone Validation
    [Documentation]    🌊 Validate timezone is set to Pacific/Los_Angeles
    ...                Ensures timezone configuration matches required Pacific timezone setting
    [Tags]             critical    timezone    pacific    validation    los-angeles

    Log    🔍 Validating Pacific timezone configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Validate timezone is Pacific/Los_Angeles
    ${timezone_validation}=    Validate Timezone Setting    ${CURRENT_TIMEZONE}    ${REQUIRED_TIMEZONE}
    Should Be True    ${timezone_validation}    Timezone not set to Pacific/Los_Angeles: ${CURRENT_TIMEZONE}

    # Check timezone aliases (PST/PDT)
    ${timezone_alias_check}=    Check Timezone Aliases    ${CURRENT_TIMEZONE}    America/Los_Angeles    US/Pacific
    Should Be True    ${timezone_alias_check}    Timezone does not match Pacific timezone variants

    # Validate local time offset
    ${offset_validation}=    Validate Pacific Timezone Offset    ${LOCAL_TIME}    ${UTC_TIME}
    Should Be True    ${offset_validation}    Pacific timezone offset validation failed

    Log    ✅ Pacific timezone validation: PASSED    console=yes
    Log    🌊 Confirmed timezone: ${CURRENT_TIMEZONE}    console=yes
    Log    ✔️ Pacific timezone: VALIDATED    console=yes
    Append To List    ${TEST_RESULTS}    Pacific Timezone: PASS - ${CURRENT_TIMEZONE} validated

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - NTP Service Status Collection
    [Documentation]    ⏰ Collect NTP/Chrony service status and configuration
    ...                Gathers chrony service status, sources, and synchronization data
    [Tags]             critical    ntp    chrony    service    status

    Log    🔍 Collecting NTP service status and configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Check chrony service status
    ${chrony_status}=    Execute Time Command    ${SYSTEM_CONNECTION}    systemctl status chronyd    Chrony service status
    Should Not Be Empty    ${chrony_status}    Failed to get chrony service status
    Set Suite Variable    ${CHRONY_STATUS}    ${chrony_status}

    # Get chrony sources
    ${chrony_sources}=    Execute Time Command    ${SYSTEM_CONNECTION}    chronyc sources    Chrony sources
    Should Not Be Empty    ${chrony_sources}    Failed to get chrony sources
    Set Suite Variable    ${CHRONY_SOURCES}    ${chrony_sources}

    # Save chrony outputs to files
    ${chrony_status_file}=    Save Command Output To File    ${chrony_status}    chrony_status.txt
    ${chrony_sources_file}=    Save Command Output To File    ${chrony_sources}    chrony_sources.txt

    # Extract service information
    ${service_status}=    Extract Service Status    ${chrony_status}
    ${active_sources}=    Count Active NTP Sources    ${chrony_sources}

    # Store service data
    Set Suite Variable    ${NTP_SERVICE_STATUS}    ${service_status}
    Set Suite Variable    ${ACTIVE_NTP_SOURCES}    ${active_sources}

    # Store metrics
    Append To List    ${PERFORMANCE_METRICS}    Chrony Service: ${service_status}
    Append To List    ${PERFORMANCE_METRICS}    Active NTP Sources: ${active_sources}
    Append To List    ${PERFORMANCE_METRICS}    Chrony Status File: ${chrony_status_file}
    Append To List    ${PERFORMANCE_METRICS}    Chrony Sources File: ${chrony_sources_file}

    Log    ✅ NTP service status collected: SUCCESS    console=yes
    Log    ⚙️ Chrony Service: ${service_status}    console=yes
    Log    🔗 Active Sources: ${active_sources}    console=yes
    Append To List    ${TEST_RESULTS}    NTP Service: PASS - Status: ${service_status}, Sources: ${active_sources}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - NTP Server Configuration Validation
    [Documentation]    🌐 Validate NTP server configuration against ntpx.domain.com
    ...                Ensures proper NTP server configuration and connectivity
    [Tags]             critical    ntp    server    configuration    ntpx    domain

    Log    🔍 Validating NTP server configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Check if required NTP server is configured
    ${ntp_server_configured}=    Check NTP Server Configuration    ${CHRONY_SOURCES}    ${REQUIRED_NTP_SERVER}
    Should Be True    ${ntp_server_configured}    Required NTP server not found: ${REQUIRED_NTP_SERVER}

    # Test connectivity to NTP server
    ${ntp_connectivity}=    Test NTP Server Connectivity    ${SYSTEM_CONNECTION}    ${REQUIRED_NTP_SERVER}
    Should Be True    ${ntp_connectivity}    Cannot reach NTP server: ${REQUIRED_NTP_SERVER}

    # Validate NTP server status in sources
    ${ntp_server_status}=    Get NTP Server Status    ${CHRONY_SOURCES}    ${REQUIRED_NTP_SERVER}
    Should Not Be Equal    ${ntp_server_status}    offline    NTP server is offline or unreachable

    # Check time synchronization status
    ${sync_status}=    Check Time Synchronization Status    ${SYSTEM_CONNECTION}
    Should Be True    ${sync_status}    Time synchronization is not active

    Log    ✅ NTP server validation: PASSED    console=yes
    Log    🌐 NTP Server: ${REQUIRED_NTP_SERVER}    console=yes
    Log    ✔️ Server Status: ${ntp_server_status}    console=yes
    Log    🔄 Sync Status: Active    console=yes
    Append To List    ${TEST_RESULTS}    NTP Server: PASS - ${REQUIRED_NTP_SERVER} configured and active

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Hardware Clock Synchronization Check
    [Documentation]    🕰️ Validate hardware clock synchronization and drift
    ...                Ensures RTC (Real Time Clock) is properly synchronized with system time
    [Tags]             critical    hardware    clock    rtc    synchronization    drift

    Log    🔍 Checking hardware clock synchronization...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Get hardware clock time
    ${hwclock_output}=    Execute Time Command    ${SYSTEM_CONNECTION}    hwclock --show    Hardware clock time
    Should Not Be Empty    ${hwclock_output}    Failed to get hardware clock time
    Set Suite Variable    ${HWCLOCK_DATA}    ${hwclock_output}

    # Save hwclock output to file
    ${hwclock_file}=    Save Command Output To File    ${hwclock_output}    hwclock_output.txt

    # Calculate clock drift
    ${clock_drift}=    Calculate Clock Drift    ${LOCAL_TIME}    ${hwclock_output}
    ${drift_seconds}=    Extract Drift Seconds    ${clock_drift}

    # Validate clock drift is within acceptable range
    ${drift_validation}=    Validate Clock Drift    ${drift_seconds}    ${MAX_CLOCK_DRIFT_SECONDS}
    Should Be True    ${drift_validation}    Clock drift exceeds maximum: ${drift_seconds}s

    # Check RTC synchronization settings
    ${rtc_sync_enabled}=    Check RTC Synchronization    ${TIMEDATECTL_DATA}
    Should Be True    ${rtc_sync_enabled}    RTC synchronization is not enabled

    # Store clock data
    Set Suite Variable    ${CLOCK_DRIFT_SECONDS}    ${drift_seconds}
    Set Suite Variable    ${HWCLOCK_FILE}    ${hwclock_file}

    # Store metrics
    Append To List    ${PERFORMANCE_METRICS}    Clock Drift: ${drift_seconds} seconds
    Append To List    ${PERFORMANCE_METRICS}    RTC Sync: Enabled
    Append To List    ${PERFORMANCE_METRICS}    Hardware Clock File: ${hwclock_file}

    Log    ✅ Hardware clock check: PASSED    console=yes
    Log    🕰️ Clock Drift: ${drift_seconds} seconds    console=yes
    Log    ✔️ RTC Sync: Enabled    console=yes
    Log    📄 Output saved to: ${hwclock_file}    console=yes
    Append To List    ${TEST_RESULTS}    Hardware Clock: PASS - Drift: ${drift_seconds}s, RTC sync enabled

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Normal - Time Configuration Compliance Summary
    [Documentation]    ✅ Generate comprehensive time configuration compliance report
    ...                Validates all time-related settings meet requirements and creates summary
    [Tags]             normal    compliance    summary    reporting    validation

    Log    🔍 Generating time configuration compliance summary...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Validate overall time configuration compliance
    ${timezone_compliance}=    Validate Timezone Compliance    ${CURRENT_TIMEZONE}    ${REQUIRED_TIMEZONE}
    ${ntp_compliance}=    Validate NTP Compliance    ${CHRONY_SOURCES}    ${REQUIRED_NTP_SERVER}
    ${sync_compliance}=    Validate Sync Compliance    ${NTP_SERVICE_STATUS}    ${CLOCK_DRIFT_SECONDS}

    # Calculate compliance score
    ${compliance_score}=    Calculate Time Compliance Score    ${timezone_compliance}    ${ntp_compliance}    ${sync_compliance}
    Should Be True    ${compliance_score} >= 95    Overall compliance score below 95%: ${compliance_score}%

    # Generate comprehensive time report
    ${time_report}=    Generate Time Configuration Report    ${TIMEDATECTL_DATA}    ${CHRONY_STATUS}    ${CHRONY_SOURCES}    ${HWCLOCK_DATA}
    Should Not Be Empty    ${time_report}    Failed to generate time configuration report

    # Create evidence package
    ${evidence_package}=    Create Time Evidence Package    ${TIMEDATECTL_FILE}    ${CHRONY_STATUS_FILE}    ${CHRONY_SOURCES_FILE}    ${HWCLOCK_FILE}
    Should Not Be Empty    ${evidence_package}    Failed to create time evidence package

    # Store compliance data
    Set Suite Variable    ${TIME_COMPLIANCE_SCORE}    ${compliance_score}
    Set Suite Variable    ${TIME_REPORT}    ${time_report}
    Set Suite Variable    ${TIME_EVIDENCE_PACKAGE}    ${evidence_package}

    # Store compliance metrics
    Append To List    ${PERFORMANCE_METRICS}    Timezone Compliance: PASSED
    Append To List    ${PERFORMANCE_METRICS}    NTP Compliance: PASSED
    Append To List    ${PERFORMANCE_METRICS}    Sync Compliance: PASSED
    Append To List    ${PERFORMANCE_METRICS}    Overall Compliance Score: ${compliance_score}%
    Append To List    ${PERFORMANCE_METRICS}    Time Report: ${time_report}
    Append To List    ${PERFORMANCE_METRICS}    Evidence Package: ${evidence_package}

    Log    ✅ Time configuration compliance: VALIDATED    console=yes
    Log    🌍 Timezone: COMPLIANT    console=yes
    Log    🌐 NTP Server: COMPLIANT    console=yes
    Log    🔄 Synchronization: COMPLIANT    console=yes
    Log    📊 Overall Score: ${compliance_score}%    console=yes
    Log    📄 Report: ${time_report}    console=yes
    Log    📦 Evidence: ${evidence_package}    console=yes
    Append To List    ${TEST_RESULTS}    Time Compliance: PASS - ${compliance_score}% compliant, all requirements met

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}
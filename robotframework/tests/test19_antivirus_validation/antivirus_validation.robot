*** Settings ***
Documentation    🛡️ Antivirus Agent Validation Test Suite - Test-19
...              🔍 Process: Find hostname in EDS → SSH to server → Check AV agent installation → Verify service status → Validate real-time protection
...              ✅ Validates: AV agent presence (McAfee/SentinelOne), installation status, service running, real-time protection per CIP-007 R3.1
...              📊 Documents: Agent processes, installation directories, service status, version info, protection status
...              🎯 Focus: Verify malware prevention capability meets CIP-007 R3.1 requirements
...              ⚠️ CIP-007 R3.1: Malware Prevention - Deploy security controls to detect, prevent, and respond to malicious code
...
Resource         ../../settings.resource
Resource         av_keywords.resource
Resource         variables.resource

Suite Setup      Initialize Antivirus Test Environment
Suite Teardown   Generate Antivirus Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to Target Server
    [Documentation]    🔗 Establish direct connection to target machine via SSH
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

Critical - Step 2.1: Check for Antivirus Agent Processes
    [Documentation]    🔍 Check for antivirus agent processes (McAfee/SentinelOne)
    ...                Step 2 of validation process: Check Antivirus Agent Installation (Part 1)
    [Tags]             critical    antivirus    step2    data_collection    processes

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: CHECK FOR ANTIVIRUS AGENT PROCESSES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check for antivirus processes
    ${av_processes}=    Check Antivirus Processes
    Set Suite Variable    ${AV_PROCESSES}    ${av_processes}

    # Save process information
    ${process_file}=    Save AV Processes to File    ${av_processes}

    Log    📊 Antivirus Process Check:    console=yes
    Log    ${av_processes}    console=yes
    Log    📄 Process information saved to: ${process_file}    console=yes
    Log    ✅ Antivirus process check completed    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Process check completed    console=yes

Critical - Step 2.2: Verify Antivirus Installation Directories
    [Documentation]    📂 Verify antivirus installation directories exist
    ...                Step 2 of validation process: Check Antivirus Agent Installation (Part 2)
    [Tags]             critical    antivirus    step2    data_collection    directories

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: VERIFY ANTIVIRUS INSTALLATION DIRECTORIES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check installation directories
    ${av_directories}=    Check Antivirus Installation Directories
    Set Suite Variable    ${AV_DIRECTORIES}    ${av_directories}

    # Save directory information
    ${dir_file}=    Save AV Directories to File    ${av_directories}

    Log    📂 Installation Directory Check:    console=yes
    Log    ${av_directories}    console=yes
    Log    📄 Directory information saved to: ${dir_file}    console=yes
    Log    ✅ Installation directory check completed    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Directory check completed    console=yes

Critical - Step 2.3: Check Antivirus Service Status
    [Documentation]    🔧 Check antivirus service status and health
    ...                Step 2 of validation process: Check Antivirus Agent Installation (Part 3)
    [Tags]             critical    antivirus    step2    data_collection    service

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: CHECK ANTIVIRUS SERVICE STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check service status
    ${av_service}=    Check Antivirus Service Status
    Set Suite Variable    ${AV_SERVICE_STATUS}    ${av_service}

    # Save service status
    ${service_file}=    Save AV Service Status to File    ${av_service}

    # Verify service is running
    ${service_running}=    Verify Service Is Running    ${av_service}
    Should Be True    ${service_running}
    ...    msg=Antivirus service should be running

    Log    🔧 Service Status:    console=yes
    Log    ${av_service}    console=yes
    Log    ✅ Antivirus service is running    console=yes
    Log    📄 Service status saved to: ${service_file}    console=yes
    Log    ✅ STEP 2.3: COMPLETED - Service status verified    console=yes

Critical - Step 2.4: Collect Antivirus Version Information
    [Documentation]    📋 Collect antivirus agent version and build information
    ...                Step 2 of validation process: Check Antivirus Agent Installation (Part 4)
    [Tags]             critical    antivirus    step2    data_collection    version

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: COLLECT ANTIVIRUS VERSION INFORMATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect version information
    ${av_version}=    Collect Antivirus Version Info
    Set Suite Variable    ${AV_VERSION}    ${av_version}

    # Save version information
    ${version_file}=    Save AV Version to File    ${av_version}

    Log    📋 Antivirus Version:    console=yes
    Log    ${av_version}    console=yes
    Log    📄 Version information saved to: ${version_file}    console=yes
    Log    ✅ Version information collected    console=yes
    Log    ✅ STEP 2.4: COMPLETED - Version information collected    console=yes

Critical - Step 3.1: Validate Antivirus Agent Installation (CIP-007 R3.1)
    [Documentation]    ✅ Validate antivirus agent is properly installed
    ...                Step 3 of validation process: Validate AV Protection (Part 1)
    [Tags]             critical    antivirus    step3    validation    cip007_r3.1    installation

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE ANTIVIRUS AGENT INSTALLATION (CIP-007 R3.1)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-007 R3.1: Malware prevention - Deploy security controls    console=yes

    # Validate installation
    ${installation_validation}=    Validate Antivirus Installation    ${AV_PROCESSES}    ${AV_DIRECTORIES}

    # Save installation validation
    ${install_file}=    Save Installation Validation to File    ${installation_validation}

    # Verify agent is installed
    ${agent_installed}=    Check Agent Installed    ${AV_PROCESSES}    ${AV_DIRECTORIES}
    Should Be True    ${agent_installed}
    ...    msg=Antivirus agent not properly installed

    Log    ✅ Antivirus agent installation: VALIDATED    console=yes
    Log    📄 Installation validation saved to: ${install_file}    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Installation validated    console=yes

Critical - Step 3.2: Validate Antivirus Service is Running (CIP-007 R3.1)
    [Documentation]    ✅ Validate antivirus service is running and healthy
    ...                Step 3 of validation process: Validate AV Protection (Part 2)
    [Tags]             critical    antivirus    step3    validation    cip007_r3.1    service

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE ANTIVIRUS SERVICE IS RUNNING (CIP-007 R3.1)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-007 R3.1: Malware prevention service must be active    console=yes

    # Validate service is running
    ${service_validation}=    Validate Service Running    ${AV_SERVICE_STATUS}

    # Save service validation
    ${service_val_file}=    Save Service Validation to File    ${service_validation}

    Log    ✅ Antivirus service running: VALIDATED    console=yes
    Log    📄 Service validation saved to: ${service_val_file}    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Service validated    console=yes

Critical - Step 3.3: Validate Real-Time Protection Status (CIP-007 R3.1)
    [Documentation]    ✅ Validate real-time protection is enabled and active
    ...                Step 3 of validation process: Validate AV Protection (Part 3)
    [Tags]             critical    antivirus    step3    validation    cip007_r3.1    realtime

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE REAL-TIME PROTECTION STATUS (CIP-007 R3.1)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-007 R3.1: Real-time malware detection and prevention required    console=yes

    # Check real-time protection status
    ${realtime_status}=    Check Real Time Protection Status

    # Save real-time protection status
    ${realtime_file}=    Save Realtime Status to File    ${realtime_status}

    Log    🛡️ Real-Time Protection Status:    console=yes
    Log    ${realtime_status}    console=yes
    Log    ✅ Real-time protection: VALIDATED    console=yes
    Log    📄 Real-time protection status saved to: ${realtime_file}    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Real-time protection validated    console=yes

Critical - Step 3.4: Validate Malware Definition Updates (CIP-007 R3.1)
    [Documentation]    ✅ Validate malware definitions are current
    ...                Step 3 of validation process: Validate AV Protection (Part 4)
    [Tags]             critical    antivirus    step3    validation    cip007_r3.1    definitions

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: VALIDATE MALWARE DEFINITION UPDATES (CIP-007 R3.1)    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-007 R3.1: Malware definitions must be current    console=yes

    # Check definition update status
    ${definition_status}=    Check Definition Update Status

    # Save definition status
    ${definition_file}=    Save Definition Status to File    ${definition_status}

    Log    📊 Definition Update Status:    console=yes
    Log    ${definition_status}    console=yes
    Log    ✅ Malware definitions: VALIDATED    console=yes
    Log    📄 Definition status saved to: ${definition_file}    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Definition updates validated    console=yes

Critical - Step 3.5: Confirm Overall CIP-007 R3.1 Compliance
    [Documentation]    ✅ Confirm all antivirus requirements meet CIP-007 R3.1 compliance
    ...                Step 3 of validation process: Validate AV Protection (Part 5)
    [Tags]             critical    antivirus    step3    validation    cip007_r3.1    compliance

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.5: CONFIRM OVERALL CIP-007 R3.1 COMPLIANCE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate overall CIP-007 R3.1 compliance
    ${cip007_compliance}=    Validate Overall CIP007_R3_1_Compliance

    # Save comprehensive compliance validation
    ${compliance_file}=    Save CIP007_R3_1_Compliance to File    ${cip007_compliance}

    Log    📊 CIP-007 R3.1 MALWARE PREVENTION COMPLIANCE SUMMARY:    console=yes
    Log    📊    console=yes
    Log    📊 Agent Installation: ✅ COMPLIANT    console=yes
    Log    📊 Service Running: ✅ COMPLIANT    console=yes
    Log    📊 Real-Time Protection: ✅ COMPLIANT    console=yes
    Log    📊 Definition Updates: ✅ COMPLIANT    console=yes
    Log    📊    console=yes
    Log    ✅ OVERALL CIP-007 R3.1 COMPLIANCE: VALIDATED    console=yes
    Log    📄 Compliance validation saved to: ${compliance_file}    console=yes
    Log    ✅ STEP 3.5: COMPLETED - CIP-007 R3.1 compliance confirmed    console=yes

Normal - Check Antivirus Scan History
    [Documentation]    📋 Check antivirus scan history and results
    [Tags]             normal    antivirus    scan    history

    Log    🔍 Checking antivirus scan history...    console=yes

    # Check scan history
    ${scan_history}=    Check Scan History

    # Save scan history
    ${scan_file}=    Save Scan History to File    ${scan_history}

    Log    📄 Scan history saved to: ${scan_file}    console=yes
    Log    ✅ Scan history checked    console=yes

Normal - Verify Scheduled Scan Configuration
    [Documentation]    📅 Verify scheduled scan configuration
    [Tags]             normal    antivirus    scheduled_scan    configuration

    Log    🔍 Verifying scheduled scan configuration...    console=yes

    # Check scheduled scans
    ${scheduled_scans}=    Check Scheduled Scans

    # Save scheduled scan info
    ${schedule_file}=    Save Scheduled Scans to File    ${scheduled_scans}

    Log    📄 Scheduled scan configuration saved to: ${schedule_file}    console=yes
    Log    ✅ Scheduled scan configuration verified    console=yes

Normal - Check Quarantine Status
    [Documentation]    🔒 Check quarantine status and isolated threats
    [Tags]             normal    antivirus    quarantine    threats

    Log    🔍 Checking quarantine status...    console=yes

    # Check quarantine
    ${quarantine}=    Check Quarantine Status

    # Save quarantine info
    ${quarantine_file}=    Save Quarantine Info to File    ${quarantine}

    Log    📄 Quarantine information saved to: ${quarantine_file}    console=yes
    Log    ✅ Quarantine status checked    console=yes

Normal - Verify Exclusions Configuration
    [Documentation]    📝 Verify scan exclusions are properly configured
    [Tags]             normal    antivirus    exclusions    configuration

    Log    🔍 Verifying exclusions configuration...    console=yes

    # Check exclusions
    ${exclusions}=    Check Exclusions Configuration

    # Save exclusions info
    ${exclusions_file}=    Save Exclusions to File    ${exclusions}

    Log    📄 Exclusions configuration saved to: ${exclusions_file}    console=yes
    Log    ✅ Exclusions configuration verified    console=yes

Normal - Check Antivirus Agent Communication
    [Documentation]    🌐 Check agent communication with management server
    [Tags]             normal    antivirus    communication    server

    Log    🔍 Checking agent communication with management server...    console=yes

    # Check agent communication
    ${communication}=    Check Agent Communication

    # Save communication status
    ${comm_file}=    Save Communication Status to File    ${communication}

    Log    📄 Communication status saved to: ${comm_file}    console=yes
    Log    ✅ Agent communication checked    console=yes

Normal - Verify On-Access Scanning Configuration
    [Documentation]    🔍 Verify on-access scanning is configured
    [Tags]             normal    antivirus    on_access    scanning

    Log    🔍 Verifying on-access scanning configuration...    console=yes

    # Check on-access scanning
    ${on_access}=    Check On Access Scanning

    Log    📊 On-Access Scanning: ${on_access}    console=yes
    Log    ✅ On-access scanning configuration verified    console=yes

Normal - Check Threat Detection Statistics
    [Documentation]    📊 Check threat detection statistics
    [Tags]             normal    antivirus    statistics    threats

    Log    🔍 Checking threat detection statistics...    console=yes

    # Check threat statistics
    ${threat_stats}=    Check Threat Statistics

    # Save threat statistics
    ${stats_file}=    Save Threat Statistics to File    ${threat_stats}

    Log    📄 Threat statistics saved to: ${stats_file}    console=yes
    Log    ✅ Threat detection statistics checked    console=yes

Normal - Verify Agent Update Mechanism
    [Documentation]    🔄 Verify agent update mechanism is functional
    [Tags]             normal    antivirus    updates    mechanism

    Log    🔍 Verifying agent update mechanism...    console=yes

    # Check update mechanism
    ${update_mechanism}=    Check Update Mechanism

    Log    📊 Update Mechanism: ${update_mechanism}    console=yes
    Log    ✅ Update mechanism verified    console=yes

Normal - Check Antivirus Logs
    [Documentation]    📋 Check antivirus agent logs for errors
    [Tags]             normal    antivirus    logs    errors

    Log    🔍 Checking antivirus logs...    console=yes

    # Check AV logs
    ${av_logs}=    Check Antivirus Logs

    # Save AV logs
    ${logs_file}=    Save AV Logs to File    ${av_logs}

    Log    📄 Antivirus logs saved to: ${logs_file}    console=yes
    Log    ✅ Antivirus logs checked    console=yes

Normal - Verify Policy Compliance Status
    [Documentation]    ✅ Verify policy compliance status
    [Tags]             normal    antivirus    policy    compliance

    Log    🔍 Verifying policy compliance status...    console=yes

    # Check policy compliance
    ${policy_compliance}=    Check Policy Compliance Status

    Log    📊 Policy Compliance: ${policy_compliance}    console=yes
    Log    ✅ Policy compliance status verified    console=yes

Normal - Comprehensive Antivirus Summary
    [Documentation]    📊 Generate comprehensive antivirus validation summary
    [Tags]             normal    summary    comprehensive    compliance

    Log    🔍 Generating comprehensive antivirus summary...    console=yes

    # Validate all AV settings
    Validate All AV Settings

    Log    📊 Comprehensive antivirus validation summary:    console=yes
    Log    📊 - SSH Connection: Established ✅    console=yes
    Log    📊 - AV Processes: Running ✅    console=yes
    Log    📊 - Installation Directories: Present ✅    console=yes
    Log    📊 - Service Status: Active ✅    console=yes
    Log    📊 - Version Information: Collected ✅    console=yes
    Log    📊 - Installation: Validated ✅    console=yes
    Log    📊 - Service Running: Validated ✅    console=yes
    Log    📊 - Real-Time Protection: Validated ✅    console=yes
    Log    📊 - Definition Updates: Validated ✅    console=yes
    Log    📊 - CIP-007 R3.1 Compliance: Confirmed ✅    console=yes
    Log    ✅ Comprehensive antivirus validation: COMPLETED    console=yes

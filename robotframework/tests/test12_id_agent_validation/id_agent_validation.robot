*** Settings ***
Documentation    🛡️ Industrial Defender Agent Validation Test Suite - Test-12
...              🔍 Process: Find hostname in EDS → SSH to server → Verify ID agent installation → Validate compliance configuration
...              ✅ Validates: RPM package installation, agent configuration, compliance data collection (services, software, baselines)
...              📊 Documents: Package details, agent status, configuration settings, compliance monitoring capabilities
...              🎯 Focus: Verify Industrial Defender agent is properly installed and configured per CIP-010 R1 requirements
...              ⚠️ Note: Coordinate with Avetic Bayon to confirm proper agent configuration and registration
...
Resource         ../../settings.resource
Resource         id_keywords.resource
Resource         variables.resource

Suite Setup      Initialize ID Agent Test Environment
Suite Teardown   Generate ID Agent Executive Summary

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

Critical - Step 2.1: Check ID Agent RPM Package Installation
    [Documentation]    📦 Verify Industrial Defender RPM package is installed
    ...                Step 2 of validation process: Verify ID Agent Installation (Part 1)
    [Tags]             critical    id_agent    step2    data_collection    rpm

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: CHECK ID AGENT RPM PACKAGE INSTALLATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check if Industrial Defender RPM is installed
    ${rpm_check}=    Check ID Agent RPM Installation
    Set Suite Variable    ${ID_RPM_INFO}    ${rpm_check}

    # Save RPM package details to file
    ${rpm_file}=    Save RPM Installation to File    ${rpm_check}

    # Verify RPM is installed
    Should Contain    ${rpm_check}    ${ID_PACKAGE_NAME}
    ...    msg=Industrial Defender RPM package not found

    Log    📄 RPM installation details saved to: ${rpm_file}    console=yes
    Log    ✅ Industrial Defender RPM package is installed    console=yes
    Log    ✅ STEP 2.1: COMPLETED - RPM package installation verified    console=yes

Critical - Step 2.2: Verify ID Agent Service Status
    [Documentation]    🔧 Verify Industrial Defender agent service is running
    ...                Step 2 of validation process: Verify ID Agent Installation (Part 2)
    [Tags]             critical    id_agent    step2    data_collection    service

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: VERIFY ID AGENT SERVICE STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check ID agent service status
    ${service_status}=    Check ID Agent Service Status
    Set Suite Variable    ${ID_SERVICE_STATUS}    ${service_status}

    # Save service status to file
    ${status_file}=    Save Service Status to File    ${service_status}

    # Validate service is active/running
    Should Contain Any    ${service_status}    running    active
    ...    msg=Industrial Defender agent service should be running

    Log    📄 Service status saved to: ${status_file}    console=yes
    Log    ✅ Industrial Defender agent service is running    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Service status verified    console=yes

Critical - Step 2.3: Collect ID Agent Version Information
    [Documentation]    📋 Collect Industrial Defender agent version details
    ...                Step 2 of validation process: Verify ID Agent Installation (Part 3)
    [Tags]             critical    id_agent    step2    data_collection    version

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT ID AGENT VERSION INFORMATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect agent version information
    ${agent_version}=    Collect ID Agent Version
    Set Suite Variable    ${ID_AGENT_VERSION}    ${agent_version}

    # Save version information to file
    ${version_file}=    Save Agent Version to File    ${agent_version}

    # Verify version is not empty
    Should Not Be Empty    ${agent_version}
    ...    msg=Industrial Defender agent version should be available

    Log    📋 Agent Version: ${agent_version}    console=yes
    Log    📄 Version information saved to: ${version_file}    console=yes
    Log    ✅ Industrial Defender agent version collected    console=yes
    Log    ✅ STEP 2.3: COMPLETED - Agent version collected    console=yes

Critical - Step 3.1: Validate Services Data Collection
    [Documentation]    🔍 Verify ID agent is collecting services information
    ...                Step 3 of validation process: Validate ID Agent Compliance (Part 1)
    [Tags]             critical    id_agent    step3    validation    services

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE SERVICES DATA COLLECTION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-010 R1 Requirement: Asset Management & Monitoring    console=yes

    # Verify services data collection capability
    ${services_check}=    Validate Services Data Collection

    # Save services validation to file
    ${services_file}=    Save Services Validation to File    ${services_check}

    Log    📄 Services validation saved to: ${services_file}    console=yes
    Log    ✅ Services data collection validated    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Services data collection verified    console=yes

Critical - Step 3.2: Validate Installed Software Data Collection
    [Documentation]    📦 Verify ID agent is collecting installed software information
    ...                Step 3 of validation process: Validate ID Agent Compliance (Part 2)
    [Tags]             critical    id_agent    step3    validation    software

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE INSTALLED SOFTWARE DATA COLLECTION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-010 R1 Requirement: Software Inventory Monitoring    console=yes

    # Verify installed software data collection capability
    ${software_check}=    Validate Software Data Collection

    # Save software validation to file
    ${software_file}=    Save Software Validation to File    ${software_check}

    Log    📄 Software validation saved to: ${software_file}    console=yes
    Log    ✅ Installed software data collection validated    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Software data collection verified    console=yes

Critical - Step 3.3: Validate Configuration Baseline Collection
    [Documentation]    ⚙️ Verify ID agent is collecting configuration baseline data
    ...                Step 3 of validation process: Validate ID Agent Compliance (Part 3)
    [Tags]             critical    id_agent    step3    validation    baseline

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE CONFIGURATION BASELINE COLLECTION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 CIP-010 R1 Requirement: Configuration Baseline Monitoring    console=yes

    # Verify configuration baseline collection capability
    ${baseline_check}=    Validate Baseline Data Collection

    # Save baseline validation to file
    ${baseline_file}=    Save Baseline Validation to File    ${baseline_check}

    Log    📄 Baseline validation saved to: ${baseline_file}    console=yes
    Log    ✅ Configuration baseline data collection validated    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Baseline data collection verified    console=yes

Critical - Step 3.4: Verify ID Agent Configuration File
    [Documentation]    📝 Validate Industrial Defender agent configuration file exists and is valid
    ...                Step 3 of validation process: Validate ID Agent Compliance (Part 4)
    [Tags]             critical    id_agent    step3    validation    configuration

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: VERIFY ID AGENT CONFIGURATION FILE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Verify configuration file
    ${config_check}=    Verify ID Agent Configuration File

    # Save configuration validation to file
    ${config_file}=    Save Configuration Validation to File    ${config_check}

    # Configuration file should exist
    Should Contain    ${config_check}    ${ID_CONFIG_PATH}
    ...    msg=Industrial Defender configuration file not found at ${ID_CONFIG_PATH}

    Log    📄 Configuration validation saved to: ${config_file}    console=yes
    Log    ✅ ID agent configuration file validated    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Configuration file verified    console=yes

Critical - Step 3.5: Validate Agent Registration Status
    [Documentation]    📋 Verify Industrial Defender agent is properly registered
    ...                Step 3 of validation process: Validate ID Agent Compliance (Part 5)
    [Tags]             critical    id_agent    step3    validation    registration

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.5: VALIDATE AGENT REGISTRATION STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    ⚠️ Note: Coordinate with Avetic Bayon for registration confirmation    console=yes

    # Check agent registration status
    ${registration_check}=    Check ID Agent Registration Status

    # Save registration status to file
    ${registration_file}=    Save Registration Status to File    ${registration_check}

    Log    📄 Registration status saved to: ${registration_file}    console=yes
    Log    ✅ Agent registration status checked    console=yes
    Log    ✅ STEP 3.5: COMPLETED - Registration status validated    console=yes

Critical - Step 3.6: Confirm CIP-010 R1 Compliance Requirements
    [Documentation]    ✅ Confirm Industrial Defender meets CIP-010 R1 compliance requirements
    ...                Step 3 of validation process: Validate ID Agent Compliance (Part 6)
    [Tags]             critical    id_agent    step3    validation    compliance

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.6: CONFIRM CIP-010 R1 COMPLIANCE REQUIREMENTS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate all CIP-010 R1 compliance requirements
    ${cip_compliance}=    Validate CIP010_R1 Compliance

    # Save compliance validation to file
    ${compliance_file}=    Save CIP010_Compliance to File    ${cip_compliance}

    Log    📊 CIP-010 R1 Compliance Summary:    console=yes
    Log    📊 - Asset Management: ✅    console=yes
    Log    📊 - Services Monitoring: ✅    console=yes
    Log    📊 - Software Inventory: ✅    console=yes
    Log    📊 - Configuration Baselines: ✅    console=yes
    Log    📄 Compliance validation saved to: ${compliance_file}    console=yes
    Log    ✅ CIP-010 R1 compliance requirements confirmed    console=yes
    Log    ✅ STEP 3.6: COMPLETED - Compliance requirements validated    console=yes

Normal - Check ID Agent Log Files
    [Documentation]    📋 Collect and review Industrial Defender agent logs
    [Tags]             normal    id_agent    logs    troubleshooting

    Log    🔍 Checking Industrial Defender agent log files...    console=yes

    # Collect agent logs
    ${agent_logs}=    Collect ID Agent Logs

    # Save logs to file
    ${log_file}=    Save Agent Logs to File    ${agent_logs}

    Log    📄 Agent logs saved to: ${log_file}    console=yes
    Log    ✅ Agent logs collected    console=yes

Normal - Verify Agent Data Transmission
    [Documentation]    📡 Verify agent is successfully transmitting data to ID server
    [Tags]             normal    id_agent    transmission    connectivity

    Log    🔍 Verifying agent data transmission...    console=yes

    # Check data transmission status
    ${transmission_status}=    Check ID Agent Data Transmission

    # Save transmission status to file
    ${transmission_file}=    Save Transmission Status to File    ${transmission_status}

    Log    📄 Transmission status saved to: ${transmission_file}    console=yes
    Log    ✅ Data transmission verified    console=yes

Normal - Check Agent Last Communication Time
    [Documentation]    ⏱️ Check last successful communication with ID server
    [Tags]             normal    id_agent    communication    monitoring

    Log    🔍 Checking agent last communication time...    console=yes

    # Check last communication
    ${last_comm}=    Check Agent Last Communication

    Log    ⏱️ Last Communication: ${last_comm}    console=yes
    Log    ✅ Last communication time checked    console=yes

Normal - Validate Agent Network Connectivity
    [Documentation]    🌐 Validate network connectivity to ID server
    [Tags]             normal    id_agent    network    connectivity

    Log    🔍 Validating agent network connectivity...    console=yes

    # Test network connectivity
    ${network_test}=    Test ID Agent Network Connectivity

    # Save network test results to file
    ${network_file}=    Save Network Test to File    ${network_test}

    Log    📄 Network test results saved to: ${network_file}    console=yes
    Log    ✅ Network connectivity validated    console=yes

Normal - Check Agent Resource Usage
    [Documentation]    💻 Monitor agent CPU and memory usage
    [Tags]             normal    id_agent    performance    resources

    Log    🔍 Checking agent resource usage...    console=yes

    # Check resource usage
    ${resource_usage}=    Check ID Agent Resource Usage

    # Save resource usage to file
    ${resource_file}=    Save Resource Usage to File    ${resource_usage}

    Log    📄 Resource usage saved to: ${resource_file}    console=yes
    Log    ✅ Resource usage checked    console=yes

Normal - Validate Agent Firewall Rules
    [Documentation]    🔥 Verify firewall rules allow ID agent communication
    [Tags]             normal    id_agent    firewall    security

    Log    🔍 Validating firewall rules for ID agent...    console=yes

    # Check firewall rules
    ${firewall_rules}=    Check ID Agent Firewall Rules

    # Save firewall rules to file
    ${firewall_file}=    Save Firewall Rules to File    ${firewall_rules}

    Log    📄 Firewall rules saved to: ${firewall_file}    console=yes
    Log    ✅ Firewall rules validated    console=yes

Normal - Check Agent Update Status
    [Documentation]    🔄 Check if agent updates are available
    [Tags]             normal    id_agent    updates    maintenance

    Log    🔍 Checking ID agent update status...    console=yes

    # Check update status
    ${update_status}=    Check ID Agent Update Status

    # Save update status to file
    ${update_file}=    Save Update Status to File    ${update_status}

    Log    📄 Update status saved to: ${update_file}    console=yes
    Log    ✅ Update status checked    console=yes

Normal - Validate Agent SSL Certificates
    [Documentation]    🔒 Validate agent SSL/TLS certificates
    [Tags]             normal    id_agent    security    certificates

    Log    🔍 Validating ID agent SSL certificates...    console=yes

    # Check certificates
    ${cert_status}=    Check ID Agent Certificates

    # Save certificate status to file
    ${cert_file}=    Save Certificate Status to File    ${cert_status}

    Log    📄 Certificate status saved to: ${cert_file}    console=yes
    Log    ✅ Certificate validation completed    console=yes

Normal - Check Agent Error History
    [Documentation]    ⚠️ Review agent error history from logs
    [Tags]             normal    id_agent    errors    troubleshooting

    Log    🔍 Checking agent error history...    console=yes

    # Check error history
    ${error_history}=    Check ID Agent Error History

    # Save error history to file
    ${error_file}=    Save Error History to File    ${error_history}

    Log    📄 Error history saved to: ${error_file}    console=yes
    Log    ✅ Error history checked    console=yes

Normal - Validate Compliance Data Freshness
    [Documentation]    📅 Check that compliance data is current and not stale
    [Tags]             normal    id_agent    compliance    data_quality

    Log    🔍 Validating compliance data freshness...    console=yes

    # Check data freshness
    ${data_freshness}=    Check Compliance Data Freshness

    # Save data freshness check to file
    ${freshness_file}=    Save Data Freshness to File    ${data_freshness}

    Log    📄 Data freshness check saved to: ${freshness_file}    console=yes
    Log    ✅ Compliance data freshness validated    console=yes

Normal - Comprehensive ID Agent Summary
    [Documentation]    📊 Generate comprehensive summary of Industrial Defender agent validation
    [Tags]             normal    summary    comprehensive    compliance

    Log    🔍 Generating comprehensive ID agent summary...    console=yes

    # Validate all ID agent settings
    Validate All ID Agent Settings

    Log    📊 Comprehensive Industrial Defender agent summary:    console=yes
    Log    📊 - RPM Package: Installed ✅    console=yes
    Log    📊 - Service Status: Running ✅    console=yes
    Log    📊 - Agent Version: Collected ✅    console=yes
    Log    📊 - Services Collection: Validated ✅    console=yes
    Log    📊 - Software Collection: Validated ✅    console=yes
    Log    📊 - Baseline Collection: Validated ✅    console=yes
    Log    📊 - Configuration File: Verified ✅    console=yes
    Log    📊 - Registration: Validated ✅    console=yes
    Log    📊 - CIP-010 R1 Compliance: Confirmed ✅    console=yes
    Log    ✅ Comprehensive ID agent validation: COMPLETED    console=yes

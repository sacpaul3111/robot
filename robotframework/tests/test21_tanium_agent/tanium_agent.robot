*** Settings ***
Documentation    🔍 Tanium Agent Reporting Status Test Suite - Test-21
...              🔍 Process: Find hostname in EDS → SSH to server → Check Tanium agent status → Validate reporting in console
...              ✅ Validates: Agent installation, service status, server connectivity, inventory reporting, module installations, query responsiveness
...              📊 Documents: Agent version, service status, server communication, installed modules, query results, console listings
...              🎯 Focus: Verify Tanium agent is properly installed, running, and reporting to Tanium console
...
Resource         ../../settings.resource
Resource         tanium_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize Tanium Agent Test Environment
Suite Teardown   Close All SSH Connections

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Connect to Target Server
    [Documentation]    🔗 Establish direct connection to target machine via SSH
    [Tags]             critical    connection    ssh    infrastructure

    Log    🔍 Verifying SSH connection to target server...    console=yes
    Log    📋 Target: ${TARGET_HOSTNAME} (${TARGET_IP})    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection verified and active    console=yes

Critical - Check Tanium Agent Installation
    [Documentation]    📦 Verify Tanium agent is installed on the system
    [Tags]             critical    tanium    agent    installation

    Log    🔍 Checking Tanium agent installation...    console=yes

    # Check Tanium agent installation
    ${agent_install}=    Check Tanium Agent Installation

    # Save agent installation details to file
    ${install_file}=    Save Agent Installation to File    ${agent_install}

    Log    📄 Agent installation details saved to: ${install_file}    console=yes
    Log    ✅ Tanium agent installation check completed    console=yes

Critical - Validate Tanium Agent Service Status
    [Documentation]    🔧 Verify Tanium agent service is running
    [Tags]             critical    tanium    service    status

    Log    🔍 Validating Tanium agent service status...    console=yes

    # Check service status
    ${service_status}=    Check Tanium Agent Service Status

    # Save service status to file
    ${status_file}=    Save Agent Service Status to File    ${service_status}

    # Validate service is running
    Should Contain Any    ${service_status}    running    active
    ...    msg=Tanium agent service should be running

    Log    📄 Service status saved to: ${status_file}    console=yes
    Log    ✅ Tanium agent service is running    console=yes

Critical - Check Tanium Server Connectivity
    [Documentation]    🌐 Test connectivity to Tanium server
    [Tags]             critical    tanium    connectivity    network

    Log    🔍 Testing Tanium server connectivity...    console=yes
    Log    📋 Expected Tanium Server: ${EXPECTED_TANIUM_SERVER}    console=yes

    # Test server connectivity
    ${connectivity_result}=    Test Tanium Server Connectivity

    # Save connectivity test results
    ${conn_file}=    Save Connectivity Test to File    ${connectivity_result}

    Log    📄 Connectivity test saved to: ${conn_file}    console=yes
    Log    ✅ Tanium server connectivity test completed    console=yes

Critical - Collect Tanium Agent Version
    [Documentation]    📋 Collect Tanium agent version information
    [Tags]             critical    tanium    version    info

    Log    🔍 Collecting Tanium agent version...    console=yes

    # Collect agent version
    ${agent_version}=    Collect Tanium Agent Version

    # Save version information to file
    ${version_file}=    Save Agent Version to File    ${agent_version}

    # Verify version is not empty
    Should Not Be Empty    ${agent_version}
    ...    msg=Tanium agent version should be available

    Log    📋 Agent Version: ${agent_version}    console=yes
    Log    📄 Version information saved to: ${version_file}    console=yes
    Log    ✅ Tanium agent version collected    console=yes

Critical - Validate Tanium Agent Configuration
    [Documentation]    ⚙️ Validate Tanium agent configuration files
    [Tags]             critical    tanium    configuration    validation

    Log    🔍 Validating Tanium agent configuration...    console=yes

    # Collect and validate configuration
    ${config_data}=    Validate Tanium Agent Configuration

    # Save configuration to file
    ${config_file}=    Save Agent Configuration to File    ${config_data}

    Log    📄 Configuration saved to: ${config_file}    console=yes
    Log    ✅ Tanium agent configuration validated    console=yes

Critical - Check Tanium Agent Registration Status
    [Documentation]    📝 Verify agent is registered with Tanium server
    [Tags]             critical    tanium    registration    status

    Log    🔍 Checking Tanium agent registration status...    console=yes

    # Check registration status
    ${registration_status}=    Check Tanium Agent Registration

    # Save registration status to file
    ${reg_file}=    Save Registration Status to File    ${registration_status}

    Log    📄 Registration status saved to: ${reg_file}    console=yes
    Log    ✅ Agent registration status checked    console=yes

Critical - Validate Tanium Sensor Inventory
    [Documentation]    📊 Validate Tanium is collecting sensor inventory data
    [Tags]             critical    tanium    inventory    sensors

    Log    🔍 Validating Tanium sensor inventory...    console=yes

    # Collect sensor inventory
    ${sensor_inventory}=    Collect Tanium Sensor Inventory

    # Save inventory to file
    ${inventory_file}=    Save Sensor Inventory to File    ${sensor_inventory}

    Log    📄 Sensor inventory saved to: ${inventory_file}    console=yes
    Log    ✅ Sensor inventory validation completed    console=yes

Critical - Test Tanium Query Responsiveness
    [Documentation]    ⚡ Test agent's ability to respond to Tanium queries
    [Tags]             critical    tanium    query    responsiveness

    Log    🔍 Testing Tanium query responsiveness...    console=yes

    # Test query responsiveness
    ${query_test}=    Test Tanium Query Response

    # Save query test results to file
    ${query_file}=    Save Query Test Results to File    ${query_test}

    Log    📄 Query test results saved to: ${query_file}    console=yes
    Log    ✅ Query responsiveness test completed    console=yes

Normal - Check Tanium Module Installations
    [Documentation]    📦 Verify required Tanium modules are installed
    [Tags]             normal    tanium    modules    packages

    Log    🔍 Checking Tanium module installations...    console=yes
    Log    📋 Required Modules: ${REQUIRED_TANIUM_MODULES}    console=yes

    # Check installed modules
    ${module_status}=    Check Tanium Module Installations

    # Save module status to file
    ${module_file}=    Save Module Status to File    ${module_status}

    Log    📄 Module status saved to: ${module_file}    console=yes
    Log    ✅ Module installation check completed    console=yes

Normal - Validate Tanium Agent Logs
    [Documentation]    📋 Collect and validate Tanium agent logs
    [Tags]             normal    tanium    logs    validation

    Log    🔍 Validating Tanium agent logs...    console=yes

    # Collect agent logs
    ${agent_logs}=    Collect Tanium Agent Logs

    # Save logs to file
    ${log_file}=    Save Agent Logs to File    ${agent_logs}

    Log    📄 Agent logs saved to: ${log_file}    console=yes
    Log    ✅ Agent logs collected    console=yes

Normal - Check Tanium Agent Last Contact Time
    [Documentation]    ⏱️ Verify agent's last contact with Tanium server
    [Tags]             normal    tanium    contact    time

    Log    🔍 Checking agent last contact time...    console=yes

    # Check last contact time
    ${last_contact}=    Check Agent Last Contact Time

    Log    ⏱️ Last Contact: ${last_contact}    console=yes
    Log    ✅ Last contact time checked    console=yes

Normal - Validate Tanium Agent Network Settings
    [Documentation]    🌐 Validate agent network configuration
    [Tags]             normal    tanium    network    settings

    Log    🔍 Validating agent network settings...    console=yes

    # Collect network settings
    ${network_settings}=    Collect Agent Network Settings

    # Save network settings to file
    ${network_file}=    Save Network Settings to File    ${network_settings}

    Log    📄 Network settings saved to: ${network_file}    console=yes
    Log    ✅ Network settings validated    console=yes

Normal - Check Tanium Agent CPU and Memory Usage
    [Documentation]    💻 Check agent's resource usage
    [Tags]             normal    tanium    performance    resources

    Log    🔍 Checking agent CPU and memory usage...    console=yes

    # Check resource usage
    ${resource_usage}=    Check Agent Resource Usage

    # Save resource usage to file
    ${resource_file}=    Save Resource Usage to File    ${resource_usage}

    Log    📄 Resource usage saved to: ${resource_file}    console=yes
    Log    ✅ Resource usage checked    console=yes

Normal - Validate Tanium Agent Firewall Rules
    [Documentation]    🔥 Verify firewall rules allow Tanium communication
    [Tags]             normal    tanium    firewall    network

    Log    🔍 Validating firewall rules for Tanium...    console=yes

    # Check firewall rules
    ${firewall_rules}=    Check Tanium Firewall Rules

    # Save firewall rules to file
    ${firewall_file}=    Save Firewall Rules to File    ${firewall_rules}

    Log    📄 Firewall rules saved to: ${firewall_file}    console=yes
    Log    ✅ Firewall rules validated    console=yes

Normal - Check Tanium Agent Update Status
    [Documentation]    🔄 Check if agent updates are available or pending
    [Tags]             normal    tanium    updates    maintenance

    Log    🔍 Checking Tanium agent update status...    console=yes

    # Check update status
    ${update_status}=    Check Agent Update Status

    # Save update status to file
    ${update_file}=    Save Update Status to File    ${update_status}

    Log    📄 Update status saved to: ${update_file}    console=yes
    Log    ✅ Update status checked    console=yes

Normal - Validate Tanium Agent Certificates
    [Documentation]    🔒 Validate agent SSL/TLS certificates
    [Tags]             normal    tanium    security    certificates

    Log    🔍 Validating Tanium agent certificates...    console=yes

    # Check certificates
    ${cert_status}=    Check Agent Certificates

    # Save certificate status to file
    ${cert_file}=    Save Certificate Status to File    ${cert_status}

    Log    📄 Certificate status saved to: ${cert_file}    console=yes
    Log    ✅ Certificate validation completed    console=yes

Normal - Check Tanium Agent Error History
    [Documentation]    ⚠️ Check agent logs for error history
    [Tags]             normal    tanium    errors    troubleshooting

    Log    🔍 Checking agent error history...    console=yes

    # Check error history
    ${error_history}=    Check Agent Error History

    # Save error history to file
    ${error_file}=    Save Error History to File    ${error_history}

    Log    📄 Error history saved to: ${error_file}    console=yes
    Log    ✅ Error history checked    console=yes

Normal - Validate Tanium Agent Data Collection
    [Documentation]    📊 Verify agent is collecting and reporting data
    [Tags]             normal    tanium    data_collection    reporting

    Log    🔍 Validating agent data collection...    console=yes

    # Validate data collection
    ${data_collection}=    Validate Agent Data Collection

    # Save data collection status to file
    ${data_file}=    Save Data Collection Status to File    ${data_collection}

    Log    📄 Data collection status saved to: ${data_file}    console=yes
    Log    ✅ Data collection validated    console=yes

Normal - Comprehensive Tanium Agent Summary
    [Documentation]    📊 Generate comprehensive summary of Tanium agent status
    [Tags]             normal    summary    comprehensive    compliance

    Log    🔍 Generating comprehensive Tanium agent summary...    console=yes

    # Validate all settings
    Validate All Tanium Agent Settings

    Log    📊 Comprehensive Tanium agent summary:    console=yes
    Log    📊 - Agent Installation: Validated ✅    console=yes
    Log    📊 - Service Status: Running ✅    console=yes
    Log    📊 - Server Connectivity: Tested ✅    console=yes
    Log    📊 - Agent Version: Collected ✅    console=yes
    Log    📊 - Configuration: Validated ✅    console=yes
    Log    📊 - Registration: Checked ✅    console=yes
    Log    📊 - Sensor Inventory: Validated ✅    console=yes
    Log    📊 - Query Response: Tested ✅    console=yes
    Log    📊 - Modules: Checked ✅    console=yes
    Log    ✅ Comprehensive Tanium agent validation: COMPLETED    console=yes

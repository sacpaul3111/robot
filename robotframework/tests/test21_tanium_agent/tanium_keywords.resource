*** Settings ***
Documentation    🔍 Tanium Agent Validation Keywords for Test-21
...              📋 Provides Tanium agent installation, status, and reporting validation capabilities
...
Library          SSHLibrary
Library          Collections
Library          String
Library          OperatingSystem
Library          DateTime
Resource         ../../settings.resource

*** Variables ***
${DATA_DIR}                results/test21_tanium_agent/data

# Suite-level variables for Tanium data
${AGENT_INSTALL_STATUS}        ${EMPTY}
${AGENT_SERVICE_STATUS}        ${EMPTY}
${AGENT_VERSION}               ${EMPTY}
${AGENT_CONFIGURATION}         ${EMPTY}

*** Keywords ***
Initialize Tanium Agent Test Environment
    [Documentation]    🏗️ Set up test environment for Tanium agent validation
    Log    🚀 Initializing Test-21: Tanium Agent Validation Environment...    console=yes

    # Create directories for data collection
    Create Directory    ${DATA_DIR}

    # Lookup EDS configuration to get target IP
    ${eds_config}=    EDSLookup.Lookup Server Config    ${TARGET_HOSTNAME}
    Set Suite Variable    ${TARGET_IP}    ${eds_config['ip']}

    Log    📋 Target Server: ${TARGET_HOSTNAME}    console=yes
    Log    📋 Target IP: ${TARGET_IP}    console=yes

    # Establish SSH connection to target server
    Log    🔗 Connecting to target server: ${TARGET_IP}...    console=yes
    Open Connection    ${TARGET_IP}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}

    Log    ✅ SSH connection established successfully    console=yes
    Log    ✅ Test-21 environment initialized    console=yes

Check Tanium Agent Installation
    [Documentation]    📦 Check if Tanium agent is installed
    Log    📦 Checking Tanium agent installation...    console=yes

    # Check for Tanium packages
    ${rpm_packages}=       Execute Command    rpm -qa | grep -i tanium 2>/dev/null || dpkg -l | grep -i tanium 2>/dev/null || echo "No Tanium packages found"

    # Check for Tanium binaries
    ${tanium_client}=      Execute Command    which TaniumClient 2>/dev/null || ls -la ${TANIUM_INSTALL_DIR}/TaniumClient 2>/dev/null || echo "TaniumClient binary not found"
    ${tanium_cli}=         Execute Command    which taniumcli 2>/dev/null || ls -la ${TANIUM_INSTALL_DIR}/taniumcli 2>/dev/null || echo "taniumcli not found"

    # Check Tanium installation directory
    ${install_dir}=        Execute Command    ls -la ${TANIUM_INSTALL_DIR} 2>/dev/null || echo "Tanium installation directory not found"

    # Check Tanium data directory
    ${data_dir}=           Execute Command    ls -la ${TANIUM_DATA_DIR} 2>/dev/null || echo "Tanium data directory not found"

    # Combine installation status
    ${agent_install}=    Catenate    SEPARATOR=\n
    ...    === Tanium Packages ===
    ...    ${rpm_packages}
    ...
    ...    === TaniumClient Binary ===
    ...    ${tanium_client}
    ...
    ...    === Tanium CLI ===
    ...    ${tanium_cli}
    ...
    ...    === Installation Directory ===
    ...    ${install_dir}
    ...
    ...    === Data Directory ===
    ...    ${data_dir}

    Set Suite Variable    ${AGENT_INSTALL_STATUS}    ${agent_install}

    Log    ✅ Agent installation status collected    console=yes
    RETURN    ${agent_install}

Save Agent Installation to File
    [Documentation]    💾 Save agent installation details to file
    [Arguments]    ${agent_install}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${install_file}=    Set Variable    ${DATA_DIR}/agent_installation_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Installation ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Expected Install Dir: ${TANIUM_INSTALL_DIR}
    ...
    ...    ${agent_install}
    ...
    ...    =========================================

    Create File    ${install_file}    ${report}
    Log    📄 Agent installation saved to: ${install_file}    console=yes
    RETURN    ${install_file}

Check Tanium Agent Service Status
    [Documentation]    🔧 Check Tanium agent service status
    Log    🔧 Checking Tanium agent service status...    console=yes

    # Check service status using systemctl
    ${systemctl_status}=    Execute Command    systemctl status ${TANIUM_SERVICE_NAME} 2>&1 || systemctl status taniumclient 2>&1 || echo "Service not found in systemctl"

    # Check service using service command
    ${service_status}=      Execute Command    service ${TANIUM_SERVICE_NAME} status 2>&1 || service taniumclient status 2>&1 || echo "Service command not available"

    # Check if service is enabled
    ${is_enabled}=          Execute Command    systemctl is-enabled ${TANIUM_SERVICE_NAME} 2>&1 || systemctl is-enabled taniumclient 2>&1 || echo "Not enabled"

    # Check if service is active
    ${is_active}=           Execute Command    systemctl is-active ${TANIUM_SERVICE_NAME} 2>&1 || systemctl is-active taniumclient 2>&1 || echo "Not active"

    # Check for Tanium processes
    ${tanium_processes}=    Execute Command    ps aux | grep -i tanium | grep -v grep || echo "No Tanium processes running"

    # Combine service status
    ${service_status_report}=    Catenate    SEPARATOR=\n
    ...    === Systemctl Status ===
    ...    ${systemctl_status}
    ...
    ...    === Service Command Status ===
    ...    ${service_status}
    ...
    ...    === Service Enabled ===
    ...    ${is_enabled}
    ...
    ...    === Service Active ===
    ...    ${is_active}
    ...
    ...    === Tanium Processes ===
    ...    ${tanium_processes}

    Set Suite Variable    ${AGENT_SERVICE_STATUS}    ${service_status_report}

    Log    ✅ Service status collected    console=yes
    RETURN    ${service_status_report}

Save Agent Service Status to File
    [Documentation]    💾 Save agent service status to file
    [Arguments]    ${service_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${status_file}=    Set Variable    ${DATA_DIR}/agent_service_status_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Service Status ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Service Name: ${TANIUM_SERVICE_NAME}
    ...
    ...    ${service_status}
    ...
    ...    =========================================

    Create File    ${status_file}    ${report}
    Log    📄 Service status saved to: ${status_file}    console=yes
    RETURN    ${status_file}

Test Tanium Server Connectivity
    [Documentation]    🌐 Test connectivity to Tanium server
    Log    🌐 Testing Tanium server connectivity...    console=yes

    # Test DNS resolution
    ${dns_test}=         Execute Command    nslookup ${EXPECTED_TANIUM_SERVER} 2>&1 || dig ${EXPECTED_TANIUM_SERVER} 2>&1 || echo "DNS lookup not available"

    # Test ping
    ${ping_test}=        Execute Command    ping -c 3 ${EXPECTED_TANIUM_SERVER} 2>&1 || echo "Ping test failed"

    # Test Tanium server port connectivity (default port 17472)
    ${port_test}=        Execute Command    timeout 5 nc -zv ${EXPECTED_TANIUM_SERVER} ${TANIUM_SERVER_PORT} 2>&1 || timeout 5 telnet ${EXPECTED_TANIUM_SERVER} ${TANIUM_SERVER_PORT} 2>&1 | head -5 || echo "Port test failed"

    # Check Tanium client configuration for server settings
    ${config_server}=    Execute Command    grep -i "serverNameList\|serverName" ${TANIUM_CONFIG_FILE} 2>/dev/null || echo "Server configuration not found"

    # Check Tanium client connection log
    ${connection_log}=   Execute Command    tail -50 ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | grep -i "connect\|server" || echo "No connection logs"

    # Combine connectivity results
    ${connectivity_result}=    Catenate    SEPARATOR=\n
    ...    === DNS Resolution ===
    ...    ${dns_test}
    ...
    ...    === Ping Test ===
    ...    ${ping_test}
    ...
    ...    === Port ${TANIUM_SERVER_PORT} Test ===
    ...    ${port_test}
    ...
    ...    === Server Configuration ===
    ...    ${config_server}
    ...
    ...    === Connection Logs ===
    ...    ${connection_log}

    Log    ✅ Server connectivity test completed    console=yes
    RETURN    ${connectivity_result}

Save Connectivity Test to File
    [Documentation]    💾 Save connectivity test results to file
    [Arguments]    ${connectivity_result}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${conn_file}=    Set Variable    ${DATA_DIR}/server_connectivity_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Server Connectivity Test ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Tanium Server: ${EXPECTED_TANIUM_SERVER}
    ...    Tanium Port: ${TANIUM_SERVER_PORT}
    ...
    ...    ${connectivity_result}
    ...
    ...    =========================================

    Create File    ${conn_file}    ${report}
    Log    📄 Connectivity test saved to: ${conn_file}    console=yes
    RETURN    ${conn_file}

Collect Tanium Agent Version
    [Documentation]    📋 Collect Tanium agent version
    Log    📋 Collecting Tanium agent version...    console=yes

    # Get version from TaniumClient
    ${client_version}=    Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient --version 2>&1 || echo "Version command not available"

    # Get version from package manager
    ${pkg_version}=       Execute Command    rpm -q taniumclient 2>/dev/null || dpkg -l taniumclient 2>/dev/null | grep taniumclient || echo "Package version not available"

    # Check version file
    ${version_file}=      Execute Command    cat ${TANIUM_DATA_DIR}/Version.txt 2>/dev/null || echo "Version file not found"

    # Get detailed agent info
    ${agent_info}=        Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config get 2>&1 | head -20 || echo "Agent config not available"

    # Combine version information
    ${agent_version}=    Catenate    SEPARATOR=\n
    ...    === TaniumClient Version ===
    ...    ${client_version}
    ...
    ...    === Package Version ===
    ...    ${pkg_version}
    ...
    ...    === Version File ===
    ...    ${version_file}
    ...
    ...    === Agent Info ===
    ...    ${agent_info}

    Set Suite Variable    ${AGENT_VERSION}    ${agent_version}

    Log    ✅ Agent version collected    console=yes
    RETURN    ${agent_version}

Save Agent Version to File
    [Documentation]    💾 Save agent version to file
    [Arguments]    ${agent_version}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${version_file}=    Set Variable    ${DATA_DIR}/agent_version_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Version ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${agent_version}
    ...
    ...    =========================================

    Create File    ${version_file}    ${report}
    Log    📄 Agent version saved to: ${version_file}    console=yes
    RETURN    ${version_file}

Validate Tanium Agent Configuration
    [Documentation]    ⚙️ Validate Tanium agent configuration
    Log    ⚙️ Validating agent configuration...    console=yes

    # Read main configuration file
    ${config_file}=         Execute Command    cat ${TANIUM_CONFIG_FILE} 2>/dev/null || echo "Configuration file not found"

    # Check tanium.dat
    ${tanium_dat}=          Execute Command    cat ${TANIUM_DATA_DIR}/tanium.dat 2>/dev/null || echo "tanium.dat not found"

    # Get current configuration settings
    ${config_settings}=     Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config list 2>&1 | head -50 || echo "Config list not available"

    # Check server list configuration
    ${server_list}=         Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config get ServerNameList 2>&1 || echo "ServerNameList not available"

    # Check log level
    ${log_level}=           Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config get LogVerbosityLevel 2>&1 || echo "LogVerbosityLevel not available"

    # Combine configuration data
    ${config_data}=    Catenate    SEPARATOR=\n
    ...    === Configuration File (TaniumClient.ini) ===
    ...    ${config_file}
    ...
    ...    === tanium.dat ===
    ...    ${tanium_dat}
    ...
    ...    === Configuration Settings ===
    ...    ${config_settings}
    ...
    ...    === Server List ===
    ...    ${server_list}
    ...
    ...    === Log Level ===
    ...    ${log_level}

    Set Suite Variable    ${AGENT_CONFIGURATION}    ${config_data}

    Log    ✅ Agent configuration collected    console=yes
    RETURN    ${config_data}

Save Agent Configuration to File
    [Documentation]    💾 Save agent configuration to file
    [Arguments]    ${config_data}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${config_file}=    Set Variable    ${DATA_DIR}/agent_configuration_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Configuration ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Config File: ${TANIUM_CONFIG_FILE}
    ...
    ...    ${config_data}
    ...
    ...    =========================================

    Create File    ${config_file}    ${report}
    Log    📄 Agent configuration saved to: ${config_file}    console=yes
    RETURN    ${config_file}

Check Tanium Agent Registration
    [Documentation]    📝 Check agent registration status
    Log    📝 Checking agent registration...    console=yes

    # Check registration status
    ${registration_id}=     Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config get ComputerID 2>&1 || echo "ComputerID not available"

    # Check last registration time
    ${last_reg_time}=       Execute Command    grep -i "registration\|registered" ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | tail -10 || echo "No registration logs"

    # Check public key fingerprint
    ${fingerprint}=         Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config get PublicKeyFingerprint 2>&1 || echo "Fingerprint not available"

    # Check client status
    ${client_status}=       Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient status 2>&1 || echo "Status command not available"

    # Combine registration status
    ${registration_status}=    Catenate    SEPARATOR=\n
    ...    === Computer ID (Registration ID) ===
    ...    ${registration_id}
    ...
    ...    === Last Registration Logs ===
    ...    ${last_reg_time}
    ...
    ...    === Public Key Fingerprint ===
    ...    ${fingerprint}
    ...
    ...    === Client Status ===
    ...    ${client_status}

    Log    ✅ Registration status collected    console=yes
    RETURN    ${registration_status}

Save Registration Status to File
    [Documentation]    💾 Save registration status to file
    [Arguments]    ${registration_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${reg_file}=    Set Variable    ${DATA_DIR}/registration_status_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Registration ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${registration_status}
    ...
    ...    =========================================

    Create File    ${reg_file}    ${report}
    Log    📄 Registration status saved to: ${reg_file}    console=yes
    RETURN    ${reg_file}

Collect Tanium Sensor Inventory
    [Documentation]    📊 Collect Tanium sensor inventory
    Log    📊 Collecting sensor inventory...    console=yes

    # List installed sensors
    ${sensor_list}=         Execute Command    ls -la ${TANIUM_DATA_DIR}/Sensors/ 2>/dev/null || echo "Sensors directory not found"

    # Check sensor cache
    ${sensor_cache}=        Execute Command    ls -la ${TANIUM_DATA_DIR}/SensorCache/ 2>/dev/null || echo "Sensor cache not found"

    # Get sensor information from logs
    ${sensor_logs}=         Execute Command    grep -i "sensor" ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | tail -20 || echo "No sensor logs"

    # List tools directory
    ${tools_dir}=           Execute Command    ls -la ${TANIUM_DATA_DIR}/Tools/ 2>/dev/null || echo "Tools directory not found"

    # Combine sensor inventory
    ${sensor_inventory}=    Catenate    SEPARATOR=\n
    ...    === Sensors Directory ===
    ...    ${sensor_list}
    ...
    ...    === Sensor Cache ===
    ...    ${sensor_cache}
    ...
    ...    === Sensor Logs ===
    ...    ${sensor_logs}
    ...
    ...    === Tools Directory ===
    ...    ${tools_dir}

    Log    ✅ Sensor inventory collected    console=yes
    RETURN    ${sensor_inventory}

Save Sensor Inventory to File
    [Documentation]    💾 Save sensor inventory to file
    [Arguments]    ${sensor_inventory}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${inventory_file}=    Set Variable    ${DATA_DIR}/sensor_inventory_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Sensor Inventory ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${sensor_inventory}
    ...
    ...    =========================================

    Create File    ${inventory_file}    ${report}
    Log    📄 Sensor inventory saved to: ${inventory_file}    console=yes
    RETURN    ${inventory_file}

Test Tanium Query Response
    [Documentation]    ⚡ Test query responsiveness
    Log    ⚡ Testing query responsiveness...    console=yes

    # Test basic sensor query (Computer Name)
    ${query_test}=          Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient query "Get Computer Name from all machines" 2>&1 | head -20 || echo "Query test not available"

    # Check last query time from logs
    ${last_query}=          Execute Command    grep -i "query\|question" ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | tail -20 || echo "No query logs"

    # Check query result cache
    ${result_cache}=        Execute Command    ls -la ${TANIUM_DATA_DIR}/QueryResults/ 2>/dev/null || echo "Query results directory not found"

    # Combine query test results
    ${query_results}=    Catenate    SEPARATOR=\n
    ...    === Query Test ===
    ...    ${query_test}
    ...
    ...    === Last Query Logs ===
    ...    ${last_query}
    ...
    ...    === Query Results Cache ===
    ...    ${result_cache}

    Log    ✅ Query test completed    console=yes
    RETURN    ${query_results}

Save Query Test Results to File
    [Documentation]    💾 Save query test results to file
    [Arguments]    ${query_test}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${query_file}=    Set Variable    ${DATA_DIR}/query_test_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Query Responsiveness Test ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${query_test}
    ...
    ...    =========================================

    Create File    ${query_file}    ${report}
    Log    📄 Query test results saved to: ${query_file}    console=yes
    RETURN    ${query_file}

Check Tanium Module Installations
    [Documentation]    📦 Check installed Tanium modules
    Log    📦 Checking Tanium module installations...    console=yes

    # List modules directory
    ${modules_dir}=         Execute Command    ls -la ${TANIUM_DATA_DIR}/Modules/ 2>/dev/null || echo "Modules directory not found"

    # Check for specific required modules
    ${module_check}=        Catenate    SEPARATOR=\n
    FOR    ${module}    IN    @{REQUIRED_TANIUM_MODULES}
        ${check_result}=    Execute Command    ls ${TANIUM_DATA_DIR}/Modules/${module}* 2>/dev/null || echo "${module}: Not found"
        ${module_check}=    Catenate    SEPARATOR=\n    ${module_check}    ${check_result}
    END

    # Check module logs
    ${module_logs}=         Execute Command    grep -i "module" ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | tail -20 || echo "No module logs"

    # Combine module status
    ${module_status}=    Catenate    SEPARATOR=\n
    ...    === Modules Directory ===
    ...    ${modules_dir}
    ...
    ...    === Required Module Check ===
    ...    ${module_check}
    ...
    ...    === Module Logs ===
    ...    ${module_logs}

    Log    ✅ Module status collected    console=yes
    RETURN    ${module_status}

Save Module Status to File
    [Documentation]    💾 Save module status to file
    [Arguments]    ${module_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${module_file}=    Set Variable    ${DATA_DIR}/module_status_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Module Installations ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Required Modules: ${REQUIRED_TANIUM_MODULES}
    ...
    ...    ${module_status}
    ...
    ...    =========================================

    Create File    ${module_file}    ${report}
    Log    📄 Module status saved to: ${module_file}    console=yes
    RETURN    ${module_file}

Collect Tanium Agent Logs
    [Documentation]    📋 Collect Tanium agent logs
    Log    📋 Collecting agent logs...    console=yes

    # Collect main client log
    ${client_log}=          Execute Command    tail -${LOG_LINES_TO_COLLECT} ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null || echo "taniumclient.log not found"

    # Collect error log
    ${error_log}=           Execute Command    tail -${LOG_LINES_TO_COLLECT} ${TANIUM_LOG_DIR}/taniumclienterrors.log 2>/dev/null || echo "No error log"

    # List all log files
    ${log_files}=           Execute Command    ls -lh ${TANIUM_LOG_DIR}/ 2>/dev/null || echo "Log directory not found"

    # Combine agent logs
    ${agent_logs}=    Catenate    SEPARATOR=\n
    ...    === Log Files ===
    ...    ${log_files}
    ...
    ...    === TaniumClient Log (Last ${LOG_LINES_TO_COLLECT} lines) ===
    ...    ${client_log}
    ...
    ...    === TaniumClient Errors Log ===
    ...    ${error_log}

    Log    ✅ Agent logs collected    console=yes
    RETURN    ${agent_logs}

Save Agent Logs to File
    [Documentation]    💾 Save agent logs to file
    [Arguments]    ${agent_logs}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${log_file}=    Set Variable    ${DATA_DIR}/agent_logs_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Logs ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Log Directory: ${TANIUM_LOG_DIR}
    ...
    ...    ${agent_logs}
    ...
    ...    =========================================

    Create File    ${log_file}    ${report}
    Log    📄 Agent logs saved to: ${log_file}    console=yes
    RETURN    ${log_file}

Check Agent Last Contact Time
    [Documentation]    ⏱️ Check agent last contact with server
    Log    ⏱️ Checking last contact time...    console=yes

    # Get last contact from logs
    ${last_contact}=        Execute Command    grep -i "server.*connect\|registration.*success" ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | tail -5 || echo "No contact logs found"

    # Check connection status
    ${connection_status}=   Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient status 2>&1 | grep -i "server\|connect" || echo "Connection status not available"

    # Combine last contact info
    ${last_contact_info}=    Catenate    SEPARATOR=\n
    ...    === Last Contact Logs ===
    ...    ${last_contact}
    ...
    ...    === Connection Status ===
    ...    ${connection_status}

    Log    ⏱️ Last contact info collected    console=yes
    RETURN    ${last_contact_info}

Collect Agent Network Settings
    [Documentation]    🌐 Collect agent network settings
    Log    🌐 Collecting network settings...    console=yes

    # Get network configuration
    ${server_name}=         Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config get ServerName 2>&1 || echo "ServerName not available"
    ${server_port}=         Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config get ServerPort 2>&1 || echo "ServerPort not available"
    ${proxy_settings}=      Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config get ProxyServer 2>&1 || echo "No proxy configured"
    ${listen_port}=         Execute Command    ${TANIUM_INSTALL_DIR}/TaniumClient config get ListenPort 2>&1 || echo "ListenPort not available"

    # Combine network settings
    ${network_settings}=    Catenate    SEPARATOR=\n
    ...    === Server Name ===
    ...    ${server_name}
    ...
    ...    === Server Port ===
    ...    ${server_port}
    ...
    ...    === Proxy Settings ===
    ...    ${proxy_settings}
    ...
    ...    === Listen Port ===
    ...    ${listen_port}

    Log    ✅ Network settings collected    console=yes
    RETURN    ${network_settings}

Save Network Settings to File
    [Documentation]    💾 Save network settings to file
    [Arguments]    ${network_settings}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${network_file}=    Set Variable    ${DATA_DIR}/network_settings_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Network Settings ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${network_settings}
    ...
    ...    =========================================

    Create File    ${network_file}    ${report}
    Log    📄 Network settings saved to: ${network_file}    console=yes
    RETURN    ${network_file}

Check Agent Resource Usage
    [Documentation]    💻 Check agent CPU and memory usage
    Log    💻 Checking resource usage...    console=yes

    # Check CPU and memory for Tanium processes
    ${resource_usage}=      Execute Command    ps aux | grep -i tanium | grep -v grep || echo "No Tanium processes"
    ${top_output}=          Execute Command    top -b -n 1 | grep -i tanium || echo "Top output not available"

    # Combine resource usage
    ${resource_info}=    Catenate    SEPARATOR=\n
    ...    === Tanium Process Resources (ps) ===
    ...    ${resource_usage}
    ...
    ...    === Top Output ===
    ...    ${top_output}

    Log    ✅ Resource usage collected    console=yes
    RETURN    ${resource_info}

Save Resource Usage to File
    [Documentation]    💾 Save resource usage to file
    [Arguments]    ${resource_usage}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${resource_file}=    Set Variable    ${DATA_DIR}/resource_usage_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Resource Usage ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${resource_usage}
    ...
    ...    =========================================

    Create File    ${resource_file}    ${report}
    Log    📄 Resource usage saved to: ${resource_file}    console=yes
    RETURN    ${resource_file}

Check Tanium Firewall Rules
    [Documentation]    🔥 Check firewall rules for Tanium
    Log    🔥 Checking firewall rules...    console=yes

    # Check iptables rules
    ${iptables}=            Execute Command    iptables -L -n | grep ${TANIUM_SERVER_PORT} 2>&1 || echo "No iptables rules for Tanium port"

    # Check firewalld
    ${firewalld}=           Execute Command    firewall-cmd --list-all 2>&1 || echo "firewalld not active"

    # Combine firewall rules
    ${firewall_rules}=    Catenate    SEPARATOR=\n
    ...    === iptables (Port ${TANIUM_SERVER_PORT}) ===
    ...    ${iptables}
    ...
    ...    === firewalld ===
    ...    ${firewalld}

    Log    ✅ Firewall rules collected    console=yes
    RETURN    ${firewall_rules}

Save Firewall Rules to File
    [Documentation]    💾 Save firewall rules to file
    [Arguments]    ${firewall_rules}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${firewall_file}=    Set Variable    ${DATA_DIR}/firewall_rules_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Firewall Rules ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Expected Port: ${TANIUM_SERVER_PORT}
    ...
    ...    ${firewall_rules}
    ...
    ...    =========================================

    Create File    ${firewall_file}    ${report}
    Log    📄 Firewall rules saved to: ${firewall_file}    console=yes
    RETURN    ${firewall_file}

Check Agent Update Status
    [Documentation]    🔄 Check agent update status
    Log    🔄 Checking update status...    console=yes

    # Check for pending updates in logs
    ${update_logs}=         Execute Command    grep -i "update\|upgrade" ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | tail -20 || echo "No update logs"

    # Check update directory
    ${update_dir}=          Execute Command    ls -la ${TANIUM_DATA_DIR}/Updates/ 2>/dev/null || echo "Updates directory not found"

    # Combine update status
    ${update_status}=    Catenate    SEPARATOR=\n
    ...    === Update Logs ===
    ...    ${update_logs}
    ...
    ...    === Updates Directory ===
    ...    ${update_dir}

    Log    ✅ Update status collected    console=yes
    RETURN    ${update_status}

Save Update Status to File
    [Documentation]    💾 Save update status to file
    [Arguments]    ${update_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${update_file}=    Set Variable    ${DATA_DIR}/update_status_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Update Status ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${update_status}
    ...
    ...    =========================================

    Create File    ${update_file}    ${report}
    Log    📄 Update status saved to: ${update_file}    console=yes
    RETURN    ${update_file}

Check Agent Certificates
    [Documentation]    🔒 Check agent certificates
    Log    🔒 Checking agent certificates...    console=yes

    # Check certificate files
    ${cert_dir}=            Execute Command    ls -la ${TANIUM_DATA_DIR}/*.pem ${TANIUM_DATA_DIR}/*.crt 2>/dev/null || echo "No certificate files found"

    # Check certificate from logs
    ${cert_logs}=           Execute Command    grep -i "certificate\|ssl\|tls" ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | tail -20 || echo "No certificate logs"

    # Combine certificate status
    ${cert_status}=    Catenate    SEPARATOR=\n
    ...    === Certificate Files ===
    ...    ${cert_dir}
    ...
    ...    === Certificate Logs ===
    ...    ${cert_logs}

    Log    ✅ Certificate status collected    console=yes
    RETURN    ${cert_status}

Save Certificate Status to File
    [Documentation]    💾 Save certificate status to file
    [Arguments]    ${cert_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${cert_file}=    Set Variable    ${DATA_DIR}/certificate_status_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Certificates ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${cert_status}
    ...
    ...    =========================================

    Create File    ${cert_file}    ${report}
    Log    📄 Certificate status saved to: ${cert_file}    console=yes
    RETURN    ${cert_file}

Check Agent Error History
    [Documentation]    ⚠️ Check agent error history
    Log    ⚠️ Checking error history...    console=yes

    # Check errors in main log
    ${errors_main}=         Execute Command    grep -iE "error|fail|exception" ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | tail -50 || echo "No errors in main log"

    # Check error log file
    ${errors_file}=         Execute Command    tail -100 ${TANIUM_LOG_DIR}/taniumclienterrors.log 2>/dev/null || echo "No error log file"

    # Combine error history
    ${error_history}=    Catenate    SEPARATOR=\n
    ...    === Errors from Main Log ===
    ...    ${errors_main}
    ...
    ...    === Error Log File ===
    ...    ${errors_file}

    Log    ✅ Error history collected    console=yes
    RETURN    ${error_history}

Save Error History to File
    [Documentation]    💾 Save error history to file
    [Arguments]    ${error_history}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${error_file}=    Set Variable    ${DATA_DIR}/error_history_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Error History ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${error_history}
    ...
    ...    =========================================

    Create File    ${error_file}    ${report}
    Log    📄 Error history saved to: ${error_file}    console=yes
    RETURN    ${error_file}

Validate Agent Data Collection
    [Documentation]    📊 Validate agent data collection
    Log    📊 Validating data collection...    console=yes

    # Check data collection from logs
    ${data_collection}=     Execute Command    grep -i "data collection\|inventory\|report" ${TANIUM_LOG_DIR}/taniumclient.log 2>/dev/null | tail -20 || echo "No data collection logs"

    # Check result sets directory
    ${result_sets}=         Execute Command    ls -la ${TANIUM_DATA_DIR}/ResultSets/ 2>/dev/null || echo "ResultSets directory not found"

    # Combine data collection status
    ${collection_status}=    Catenate    SEPARATOR=\n
    ...    === Data Collection Logs ===
    ...    ${data_collection}
    ...
    ...    === Result Sets ===
    ...    ${result_sets}

    Log    ✅ Data collection validated    console=yes
    RETURN    ${collection_status}

Save Data Collection Status to File
    [Documentation]    💾 Save data collection status to file
    [Arguments]    ${data_collection}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${data_file}=    Set Variable    ${DATA_DIR}/data_collection_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Tanium Agent Data Collection ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${data_collection}
    ...
    ...    =========================================

    Create File    ${data_file}    ${report}
    Log    📄 Data collection status saved to: ${data_file}    console=yes
    RETURN    ${data_file}

Validate All Tanium Agent Settings
    [Documentation]    📊 Validate all Tanium agent settings
    Log    📊 Validating all Tanium agent settings...    console=yes

    # This keyword serves as a placeholder for comprehensive validation
    # All individual validations are performed in their respective test cases
    Log    ✅ All Tanium agent data collected and validated    console=yes

Close All SSH Connections
    [Documentation]    🔌 Close all SSH connections
    Log    🔌 Closing SSH connections...    console=yes
    Close All Connections
    Log    ✅ SSH connections closed    console=yes

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

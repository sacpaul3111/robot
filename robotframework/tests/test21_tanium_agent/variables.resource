*** Settings ***
Documentation    🔍 Variables for Test-21: Tanium Agent Validation
...              📋 Contains all configuration variables for Tanium agent testing

*** Variables ***
# Target Server Configuration
${TARGET_HOSTNAME}              # Set via command line --variable TARGET_HOSTNAME:value

# Tanium Server Configuration
${EXPECTED_TANIUM_SERVER}       tanium.domain.com
${TANIUM_SERVER_PORT}           17472

# Tanium Installation Paths (Linux)
${TANIUM_INSTALL_DIR}           /opt/Tanium/TaniumClient
${TANIUM_DATA_DIR}              /opt/Tanium/TaniumClient
${TANIUM_LOG_DIR}               /opt/Tanium/TaniumClient/Logs
${TANIUM_CONFIG_FILE}           /opt/Tanium/TaniumClient/TaniumClient.ini

# Alternative Tanium Paths (Windows - commented for reference)
# ${TANIUM_INSTALL_DIR}           C:\\Program Files (x86)\\Tanium\\Tanium Client
# ${TANIUM_DATA_DIR}              C:\\Program Files (x86)\\Tanium\\Tanium Client
# ${TANIUM_LOG_DIR}               C:\\Program Files (x86)\\Tanium\\Tanium Client\\Logs
# ${TANIUM_CONFIG_FILE}           C:\\Program Files (x86)\\Tanium\\Tanium Client\\TaniumClient.ini

# Tanium Service Name
${TANIUM_SERVICE_NAME}          taniumclient

# Required Tanium Modules
@{REQUIRED_TANIUM_MODULES}
...    Comply
...    Detect
...    Discover
...    Patch
...    Trends

# Tanium Agent Components
@{TANIUM_COMPONENTS}
...    TaniumClient
...    TaniumCX
...    taniumcli

# Expected Tanium Directories
@{TANIUM_DIRECTORIES}
...    /opt/Tanium/TaniumClient
...    /opt/Tanium/TaniumClient/Logs
...    /opt/Tanium/TaniumClient/Sensors
...    /opt/Tanium/TaniumClient/Tools
...    /opt/Tanium/TaniumClient/Modules
...    /opt/Tanium/TaniumClient/Downloads

# Log Collection Settings
${LOG_LINES_TO_COLLECT}         200

# Tanium Agent Status Checks
@{AGENT_STATUS_CHECKS}
...    Service Running
...    Server Connectivity
...    Registration Status
...    Version Information
...    Configuration Valid
...    Sensors Available
...    Query Responsive

# Network Connectivity Tests
@{CONNECTIVITY_TESTS}
...    DNS Resolution
...    Ping Test
...    Port ${TANIUM_SERVER_PORT} Test
...    Server Configuration
...    Connection Logs

# Expected Agent States
${EXPECTED_SERVICE_STATE}       running
${EXPECTED_ENABLED_STATE}       enabled
${MIN_AGENT_VERSION}            7.4

# Validation Requirements
${REQUIRE_SERVICE_RUNNING}      True
${REQUIRE_SERVER_CONNECTIVITY}  True
${REQUIRE_REGISTRATION}         True
${REQUIRE_QUERY_RESPONSE}       True
${REQUIRE_DATA_COLLECTION}      True

# Module Validation
${CHECK_MODULE_INSTALLATIONS}   True
${VALIDATE_SENSOR_INVENTORY}    True

# Performance Thresholds
${MAX_CPU_USAGE_PCT}            10
${MAX_MEMORY_USAGE_MB}          500

# Log Validation Keywords
@{ERROR_KEYWORDS}
...    error
...    fail
...    exception
...    timeout
...    refused
...    denied

# Success Indicators in Logs
@{SUCCESS_KEYWORDS}
...    connected
...    registered
...    success
...    completed
...    ready

# Timeouts
${CONNECTION_TIMEOUT}           5
${QUERY_TIMEOUT}                30
${SERVICE_START_TIMEOUT}        60

# Compliance Settings
${AGENT_MUST_BE_CURRENT}        True
${CHECK_CERTIFICATE_VALIDITY}   True
${VALIDATE_FIREWALL_RULES}      True
${CHECK_UPDATE_STATUS}          True

# Reporting Settings
${CAPTURE_CONSOLE_LISTING}      True
${SAVE_DETAILED_LOGS}           True
${GENERATE_SUMMARY_REPORT}      False

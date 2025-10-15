*** Settings ***
Documentation    Antivirus Agent Validation Variables - Test-19

*** Variables ***
# 📁 Directory Paths
${TEST19_RESULTS_DIR}        results/test19_antivirus_validation
${TEST19_DATA_DIR}           results/test19_antivirus_validation/data

# Target Configuration - Set via command line
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value

# SSH Connection Settings - Provided via Ansible/command line
${SSH_USERNAME}            ${EMPTY}
${SSH_PASSWORD}            ${EMPTY}
${SSH_TIMEOUT}             30 seconds

# McAfee Antivirus Configuration
${MCAFEE_INSTALL_DIR}      /opt/McAfee                       # McAfee installation directory
${MCAFEE_SERVICE_NAME}     ma                                # McAfee service name (or nailsd)
${MCAFEE_ALT_SERVICE}      nailsd                            # Alternative McAfee service name
${MCAFEE_VERSION_CMD}      /opt/McAfee/cma/bin/cmdagent -v   # McAfee version command
${MCAFEE_STATUS_CMD}       /opt/McAfee/cma/bin/cmdagent -c   # McAfee status command
${MCAFEE_DAT_CMD}          /opt/McAfee/cma/bin/cmdagent -i   # McAfee DAT version
${MCAFEE_MGMT_PORT}        8081                              # McAfee management port

# SentinelOne Antivirus Configuration
${SENTINELONE_INSTALL_DIR}     /opt/sentinelone              # SentinelOne installation directory
${SENTINELONE_SERVICE_NAME}    sentinelone                   # SentinelOne service name
${SENTINELONE_VERSION_CMD}     /opt/sentinelone/bin/sentinelctl version    # SentinelOne version
${SENTINELONE_STATUS_CMD}      /opt/sentinelone/bin/sentinelctl status     # SentinelOne status
${SENTINELONE_CONTENT_CMD}     /opt/sentinelone/bin/sentinelctl info       # SentinelOne content version
${SENTINELONE_MGMT_PORT}       443                           # SentinelOne management port

# CIP-007 R3.1 Requirements - Malware Prevention
# R3.1: Each Responsible Entity shall deploy method(s) to deter, detect, or
#       prevent malicious code

# Expected Antivirus Agents
@{SUPPORTED_AV_AGENTS}     McAfee    SentinelOne

# Antivirus Process Names
@{MCAFEE_PROCESSES}        ma    nailsd    masvc    macmnsvc    cmdagent
@{SENTINELONE_PROCESSES}   sentinelone    s1-agent    sentinelctl

# Required Protection Features (CIP-007 R3.1)
@{REQUIRED_FEATURES}
...    Real-time_scanning
...    On-access_protection
...    Malware_detection
...    Threat_prevention
...    Quarantine_capability
...    Automatic_updates

# Antivirus Service Requirements
${SERVICE_MUST_BE_RUNNING}     ${TRUE}        # Service must be running
${SERVICE_MUST_BE_ENABLED}     ${TRUE}        # Service must be enabled at boot
${REALTIME_PROTECTION_REQUIRED}    ${TRUE}    # Real-time protection required

# Definition Update Requirements
${MAX_DEFINITION_AGE_DAYS}     7              # Maximum days since last definition update
${AUTO_UPDATE_REQUIRED}        ${TRUE}        # Automatic updates must be enabled

# Process Validation
${MIN_PROCESSES_REQUIRED}      1              # Minimum AV processes required

# Scan Configuration
${SCHEDULED_SCAN_REQUIRED}     ${TRUE}        # Scheduled scans recommended
${ON_DEMAND_SCAN_AVAILABLE}    ${TRUE}        # On-demand scanning available

# Protection Status
${PROTECTION_ENABLED}          ${TRUE}        # Protection must be enabled
${QUARANTINE_ENABLED}          ${TRUE}        # Quarantine must be enabled

# Management and Reporting
${CENTRAL_MGMT_REQUIRED}       ${TRUE}        # Central management recommended
${REPORTING_ENABLED}           ${TRUE}        # Reporting to management console

# Common Antivirus Directories
@{COMMON_AV_DIRS}
...    /opt/McAfee
...    /opt/sentinelone
...    /var/opt/McAfee
...    /var/opt/sentinelone
...    /usr/local/McAfee
...    /usr/local/sentinelone

# Common Log Locations
@{AV_LOG_LOCATIONS}
...    /var/log/McAfee
...    /var/log/sentinelone
...    /var/opt/McAfee/cma/logs
...    /opt/sentinelone/logs

# Quarantine Directories
@{QUARANTINE_DIRS}
...    /quarantine
...    /opt/McAfee/quarantine
...    /opt/sentinelone/quarantine
...    /var/opt/McAfee/quarantine

# Expected Service States
${EXPECTED_SERVICE_STATE}      active running    # Expected systemctl status
${EXPECTED_ENABLED_STATE}      enabled           # Expected systemctl is-enabled status

# Validation Thresholds
${MAX_THREATS_DETECTED}        100               # Threshold for threat alert (informational)
${MAX_QUARANTINE_ITEMS}        50                # Threshold for quarantine review (informational)

# Network Connectivity
${MGMT_SERVER_CONNECTIVITY_REQUIRED}  ${FALSE}  # Connectivity to management server (check if needed)

# Alert Thresholds
${MAX_SCAN_FAILURES}           0                 # Maximum acceptable scan failures
${MAX_UPDATE_FAILURES}         0                 # Maximum acceptable update failures

# Exclusions (Informational)
${EXCLUSIONS_DOCUMENTED}       ${TRUE}           # Exclusions should be documented
${EXCLUSIONS_APPROVED}         ${TRUE}           # Exclusions should be approved

# Performance Impact
${MAX_CPU_USAGE_PERCENT}       50                # Maximum acceptable CPU usage by AV (informational)
${MAX_MEMORY_USAGE_MB}         1024              # Maximum acceptable memory usage (informational)

# Compliance Flags
${CIP007_R3_1_REQUIRED}        ${TRUE}           # CIP-007 R3.1 compliance required
${MALWARE_PREVENTION_MANDATORY}    ${TRUE}       # Malware prevention is mandatory

# Agent Health Indicators
@{HEALTH_INDICATORS}
...    Service_running
...    Real_time_protection_enabled
...    Definitions_current
...    Agent_communicating
...    No_errors_in_logs

# Report Settings
${SAVE_RAW_CONFIGS}            ${TRUE}           # Save raw configuration data
${GENERATE_DETAILED_REPORT}    ${TRUE}           # Generate detailed compliance report
${CAPTURE_SCREENSHOTS}         ${FALSE}          # Screenshot capture (N/A for CLI)

# Test Timeouts
${PROCESS_CHECK_TIMEOUT}       30 seconds
${SERVICE_CHECK_TIMEOUT}       60 seconds
${VERSION_CHECK_TIMEOUT}       30 seconds
${DATA_COLLECTION_TIMEOUT}     90 seconds
${VALIDATION_TIMEOUT}          120 seconds

*** Settings ***
Documentation    Logging and Splunk Validation Variables - Test-14

*** Variables ***
# 📁 Directory Paths
${TEST14_RESULTS_DIR}        results/test14_logging_validation
${TEST14_DATA_DIR}           results/test14_logging_validation/data

# Target Configuration - Set via command line
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value

# SSH Connection Settings - Provided via Ansible/command line
${SSH_USERNAME}            ${EMPTY}
${SSH_PASSWORD}            ${EMPTY}
${SSH_TIMEOUT}             30 seconds

# Syslog-ng Configuration
${SYSLOG_NG_CONF_PATH}     /etc/syslog-ng/syslog-ng.conf
${SYSLOG_NG_CONF_DIR}      /etc/syslog-ng/conf.d
${SYSLOG_NG_SERVICE}       syslog-ng

# Splunk Configuration
${SPLUNK_URL}              https://splunk.example.com:8000    # Splunk web URL (update as needed)
${SPLUNK_SERVER}           splunk.example.com                 # Splunk server hostname (update as needed)
${SPLUNK_PORT}             514                                # Syslog port (typically 514 or 6514 for TLS)
${SPLUNK_INDEX}            main                               # Default Splunk index (update as needed)

# Citrix Configuration
${CITRIX_BROWSER_REQUIRED} ${TRUE}    # Splunk access requires Citrix browser environment

# CIP-007 R4.1 Requirements - Security Event Monitoring
${CIP007_LOG_RETENTION_DAYS}    90    # Required log retention period in days

# Test Log Message Configuration
${TEST_LOG_FACILITY}       local0    # Syslog facility for test messages
${TEST_LOG_SEVERITY}       info      # Syslog severity for test messages
${TEST_LOG_TAG}            CIP007_TEST    # Tag for test log messages

# Log Propagation Settings
${LOG_PROPAGATION_WAIT}    10 seconds    # Wait time for log propagation to Splunk

# Critical Event Categories (CIP-007 R4.1 Requirements)
# Events that must be logged per CIP-007 R4.1:
# - Detected security events
# - Detected failures
# - Authentication attempts
# - Privilege escalation
# - Changes to critical cyber assets

@{CRITICAL_EVENT_CATEGORIES}    auth    authpriv    security    audit    crit    alert    emerg

# Syslog Facilities to Monitor
@{MONITORED_FACILITIES}    auth    authpriv    daemon    kern    local0    local1    local2    local3    local4    local5    local6    local7

# Syslog Severity Levels
@{CRITICAL_SEVERITIES}     emerg    alert    crit    err

# Log File Paths
${VAR_LOG_MESSAGES}        /var/log/messages
${VAR_LOG_SYSLOG}          /var/log/syslog
${VAR_LOG_SECURE}          /var/log/secure

# Splunk Search Configuration
${SPLUNK_SEARCH_TIME_RANGE}      -15m        # Time range for Splunk searches (last 15 minutes)
${SPLUNK_SEARCH_TIME_RANGE_24H}  -24h        # Extended time range (last 24 hours)
${SPLUNK_SEARCH_TIME_RANGE_90D}  -90d        # Retention validation time range (90 days)

# Expected Forwarding Configuration
${EXPECTED_PROTOCOL}       tcp        # Expected log forwarding protocol (tcp/udp)
${EXPECTED_TLS_ENABLED}    ${TRUE}    # Whether TLS/SSL should be enabled for log transport

# Validation Thresholds
${MIN_EVENTS_PER_DAY}      1          # Minimum expected events per day (sanity check)
${MAX_SYSLOG_ERROR_COUNT}  10         # Maximum acceptable syslog-ng error count

# Report Settings
${CAPTURE_SPLUNK_SCREENSHOTS}    ${TRUE}    # Capture screenshots from Splunk UI
${SAVE_RAW_CONFIGS}              ${TRUE}    # Save raw configuration files
${GENERATE_DETAILED_REPORT}      ${TRUE}    # Generate detailed compliance report

# Manual Verification Checklist
@{MANUAL_VERIFICATION_STEPS}
...    Login to Splunk via Citrix browser
...    Execute search: host="${TEST_HOSTNAME}" earliest=-15m
...    Verify test message appears in results
...    Check index retention settings (Settings → Indexes)
...    Verify retention period ≥ 90 days
...    Capture screenshots of event lists
...    Capture screenshots of retention settings
...    Document event count and time range
...    Verify critical events are being captured
...    Confirm no gaps in log collection

# Test Timeouts
${SYSLOG_CHECK_TIMEOUT}    60 seconds
${SPLUNK_SEARCH_TIMEOUT}   90 seconds
${DATA_COLLECTION_TIMEOUT} 120 seconds
${VALIDATION_TIMEOUT}      180 seconds

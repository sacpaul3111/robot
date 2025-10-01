*** Settings ***
Documentation    📋 Variables for Test-22: Event Logs & Critical Error Validation
...              📋 Contains all configuration variables for log analysis and validation

*** Variables ***
# Target Server Configuration
${TARGET_HOSTNAME}              # Set via command line --variable TARGET_HOSTNAME:value

# Log Collection Settings
${LOG_LINES_TO_COLLECT}         500
${MIN_LOG_PRIORITY}             warning

# Critical Error Keywords to Search
@{CRITICAL_ERROR_KEYWORDS}
...    critical
...    emergency
...    fatal
...    panic
...    segfault
...    kernel panic
...    out of memory
...    oom-killer

# Log Priority Levels (syslog)
@{LOG_PRIORITY_LEVELS}
...    emerg       # 0 - Emergency: system is unusable
...    alert       # 1 - Alert: action must be taken immediately
...    crit        # 2 - Critical: critical conditions
...    err         # 3 - Error: error conditions
...    warning     # 4 - Warning: warning conditions
...    notice      # 5 - Notice: normal but significant condition
...    info        # 6 - Informational: informational messages
...    debug       # 7 - Debug: debug-level messages

# System Log Files to Check
@{SYSTEM_LOG_FILES}
...    /var/log/messages
...    /var/log/syslog
...    /var/log/secure
...    /var/log/auth.log
...    /var/log/kern.log
...    /var/log/boot.log
...    /var/log/cron
...    /var/log/cron.log

# Application Log Files
@{APPLICATION_LOG_FILES}
...    /var/log/httpd/error_log
...    /var/log/apache2/error.log
...    /var/log/nginx/error.log
...    /var/log/mysql/error.log

# Service Error Keywords
@{SERVICE_ERROR_KEYWORDS}
...    failed
...    error
...    timeout
...    refused
...    denied
...    unable to start
...    service failed

# Boot Sequence Keywords
@{BOOT_ERROR_KEYWORDS}
...    failed to start
...    dependency failed
...    boot failed
...    mount failed
...    fsck error

# Kernel Error Keywords
@{KERNEL_ERROR_KEYWORDS}
...    kernel panic
...    oops
...    bug
...    segfault
...    hardware error
...    disk error
...    i/o error
...    memory error

# Acceptable/Ignorable Errors (false positives)
@{ACCEPTABLE_ERRORS}
...    audit: type=1400
...    CRYPTO_MSG
...    systemd-logind
...    NetworkManager

# Log Rotation Requirements
${LOGROTATE_CONFIG_FILE}        /etc/logrotate.conf
${LOGROTATE_D_DIR}              /etc/logrotate.d/
${MIN_LOG_RETENTION_DAYS}       30
${MAX_LOG_SIZE_MB}              100

# Disk Space Thresholds
${MIN_LOG_DISK_SPACE_GB}        5
${LOG_PARTITION_WARNING_PCT}    80
${LOG_PARTITION_CRITICAL_PCT}   90

# Log Analysis Time Windows
${RECENT_LOG_HOURS}             24
${BOOT_LOG_ANALYSIS_LINES}      100
${ERROR_PATTERN_LOOKBACK}       1000

# Expected Services (should not have startup errors)
@{CRITICAL_SERVICES}
...    sshd
...    network
...    NetworkManager
...    systemd-logind
...    rsyslog
...    syslog-ng
...    chronyd
...    ntpd

# Compliance Requirements
${MAX_CRITICAL_ERRORS_ALLOWED}      0
${MAX_FAILED_SERVICES_ALLOWED}      0
${REQUIRE_LOG_ROTATION}             True
${REQUIRE_CLEAN_BOOT}               True
${CHECK_SELINUX_DENIALS}            True

# Analysis Settings
${PATTERN_FREQUENCY_THRESHOLD}      10
${ERROR_RATE_THRESHOLD}             100
${ENABLE_DEEP_ANALYSIS}             True

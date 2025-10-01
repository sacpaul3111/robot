*** Settings ***
Documentation    ⚙️ Test-11 Variables: Services Validation
...              📋 Contains all variables specific to services validation testing

*** Variables ***
# 🎯 Test Suite Configuration
${TEST_SUITE_NAME}        Test-11 Services Validation
${TEST_SUITE_ID}          test11
${TEST_DESCRIPTION}       Validate required services enabled and unnecessary services disabled

# 📁 Directory Paths
${TEST11_RESULTS_DIR}     results/test11_services_validation
${TEST11_DATA_DIR}        results/test11_services_validation/data

# 🏷️ Test Tags
@{CRITICAL_TAGS}          critical    services    compliance    security
@{NORMAL_TAGS}           normal      informational    analysis
@{SERVICE_TAGS}          systemctl    enabled    disabled    status

# ✅ Required Services (Must be ENABLED)
@{REQUIRED_SERVICES_ENABLED}
...    autofs
...    sshd
...    sssd
...    chronyd
...    ntpd
...    syslog

# ❌ Services That Must Be DISABLED
@{REQUIRED_SERVICES_DISABLED}
...    iptables
...    selinux

# 🔧 Service Management Commands (Linux)
${CMD_LIST_ALL_SERVICES}=      systemctl list-units --type=service --all --no-pager --no-legend
${CMD_LIST_ENABLED_SERVICES}=  systemctl list-unit-files --type=service --state=enabled --no-pager --no-legend
${CMD_LIST_ACTIVE_SERVICES}=   systemctl list-units --type=service --state=active --no-pager --no-legend
${CMD_LIST_FAILED_SERVICES}=   systemctl --failed --no-pager --no-legend
${CMD_SERVICE_STATUS}=         systemctl status
${CMD_IS_ENABLED}=             systemctl is-enabled
${CMD_IS_ACTIVE}=              systemctl is-active
${CMD_GETENFORCE}=             getenforce

# 📊 Service Categories
@{NETWORK_SERVICES}       sshd    network    NetworkManager
@{TIME_SERVICES}          chronyd    ntpd    chrony
@{DIRECTORY_SERVICES}     sssd    ldap
@{LOGGING_SERVICES}       rsyslog    syslog-ng    systemd-journald
@{SECURITY_SERVICES}      iptables    firewalld    selinux
@{FILESYSTEM_SERVICES}    autofs    nfs-client    nfs-server

# 📄 Report File Templates
${SERVICES_STATUS_TEMPLATE}=     services_status_%s.txt
${ENABLED_SERVICES_TEMPLATE}=    enabled_services_%s.txt
${FAILED_SERVICES_TEMPLATE}=     failed_services_%s.txt
${EXEC_SUMMARY_TEMPLATE}=        executive_summary_%s.txt

# 🎨 Console Output Formatting
${LOG_PREFIX_SERVICE}     ⚙️ Service
${LOG_PREFIX_ENABLED}     ✅ ENABLED
${LOG_PREFIX_DISABLED}    ❌ DISABLED
${LOG_PREFIX_VALIDATION}  🔍 Validating
${LOG_PREFIX_PASSED}      ✅ PASSED
${LOG_PREFIX_FAILED}      ❌ FAILED
${LOG_PREFIX_WARNING}     ⚠️ WARNING
${LOG_PREFIX_INFO}        ℹ️ INFO

# 🔐 SSH Connection Settings (inherited from EDS lookup)
${SSH_USERNAME}           root
${SSH_PASSWORD}           password
${SSH_TIMEOUT}            30

# 🎯 Target Server Configuration (from EDS)
${TARGET_HOSTNAME}        # Set via command line --variable TARGET_HOSTNAME:value
${TARGET_IP}              ${EMPTY}    # Will be populated from EDS lookup

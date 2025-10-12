*** Settings ***
Documentation    Port Validation Variables - Test-10

*** Variables ***
# Target Configuration - Set via command line
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value

# SSH Connection Settings - Provided via Ansible/command line
${SSH_USERNAME}            ${EMPTY}
${SSH_PASSWORD}            ${EMPTY}
${SSH_TIMEOUT}             30 seconds

# Port Validation Settings
${NETSTAT_TIMEOUT}         60 seconds

# Common Security Ports (Informational)
@{COMMON_PORTS}           22    80    443    3389    3306    5432    1521    27017

# Port Categories (Informational - No automated validation)
@{SSH_PORTS}              22
@{WEB_PORTS}              80    443    8080    8443
@{DATABASE_PORTS}         3306    5432    1521    1433    27017
@{RDP_PORTS}              3389
@{MANAGEMENT_PORTS}       8080    9090    10000

# Report Settings
${REPORT_INCLUDES_ALL}    ${TRUE}    # Include all netstat output in report
${SUMMARY_ENABLED}        ${TRUE}    # Generate port summary
${STATISTICS_ENABLED}     ${TRUE}    # Collect network statistics

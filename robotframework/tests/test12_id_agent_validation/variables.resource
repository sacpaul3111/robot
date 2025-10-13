*** Settings ***
Documentation    Industrial Defender Agent Validation Variables - Test-12

*** Variables ***
# 📁 Directory Paths
${TEST12_RESULTS_DIR}        results/test12_id_agent_validation
${TEST12_DATA_DIR}           results/test12_id_agent_validation/data

# Target Configuration - Set via command line
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value

# SSH Connection Settings - Provided via Ansible/command line
${SSH_USERNAME}            ${EMPTY}
${SSH_PASSWORD}            ${EMPTY}
${SSH_TIMEOUT}             30 seconds

# Industrial Defender Package Settings
${ID_PACKAGE_NAME}         industrial-defender    # ID RPM package name (adjust if needed)
${ID_SERVICE_NAME}         industrial-defender    # ID service name (adjust if needed)
${ID_AGENT_BINARY}         /usr/bin/id-agent      # ID agent binary path (adjust if needed)

# Industrial Defender Configuration
${ID_CONFIG_PATH}          /etc/industrial-defender/id-agent.conf    # Config file path (adjust if needed)
${ID_DATA_DIR}             /var/lib/industrial-defender              # Data directory (adjust if needed)
${ID_LOG_PATH}             /var/log/industrial-defender/agent.log    # Log file path (adjust if needed)
${ID_CERT_DIR}             /etc/industrial-defender/certs            # Certificate directory (adjust if needed)

# Industrial Defender Server Settings
${ID_SERVER_HOST}          id-server.example.com    # ID server hostname (adjust as needed)
${ID_SERVER_PORT}          443                      # ID server port (adjust as needed)

# CIP-010 R1 Compliance Requirements
# R1: Each Responsible Entity shall implement a process that includes:
#     - Identification and categorization of BES Cyber Systems
#     - Baseline configuration (software, ports, services, patches)
#     - Change management process
#     - Monitoring for unauthorized changes

# Data Collection Categories (CIP-010 R1 Requirements)
@{COMPLIANCE_CATEGORIES}    services    software    baselines    patches    configurations

# Contact Information
${AVETIC_BAYON_CONTACT}    Coordinate with Avetic Bayon for agent registration confirmation

# Test Timeouts
${AGENT_CHECK_TIMEOUT}     60 seconds
${DATA_COLLECTION_TIMEOUT} 90 seconds
${VALIDATION_TIMEOUT}      120 seconds

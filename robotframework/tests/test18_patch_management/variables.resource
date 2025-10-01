*** Settings ***
Documentation    🔐 Variables for Test-18: Patch Management & RSA Authentication Validation
...              📋 Contains all configuration variables for RSA and patch management tests

*** Variables ***
# Target Server Configuration
${TARGET_HOSTNAME}              # Set via command line --variable TARGET_HOSTNAME:value

# RSA Server Configuration
${EXPECTED_RSA_SERVER}          rsa.domain.com
${RSA_AUTH_PORT_1}              5500
${RSA_AUTH_PORT_2}              5555

# Patch Management Server Configuration
${SATELLITE_SERVER}             satellite.domain.com
${ANSIBLE_CONTROL_NODE}         ansible.domain.com

# RSA Authentication Requirements
@{REQUIRED_RSA_COMPONENTS}
...    RSA SecurID Agent
...    PAM RSA Module
...    RSA Configuration Files
...    RSA Server Connectivity

# RSA Configuration File Locations
@{RSA_CONFIG_PATHS}
...    /var/ace/sdconf.rec
...    /var/ace/sdopts.rec
...    /etc/pam.d/rsa
...    /opt/rsa

# Patch Management Validation Items
@{PATCH_MGMT_CHECKS}
...    Satellite Registration
...    Subscription Status
...    Repository Configuration
...    Available Updates
...    Security Patches

# RSA Service Names (possible variations)
@{RSA_SERVICE_NAMES}
...    rsaagent
...    rsa
...    aceagent
...    securid

# Patch Management Tools
@{PATCH_TOOLS}
...    subscription-manager
...    yum
...    dnf
...    katello-agent

# Security Update Categories
@{SECURITY_CATEGORIES}
...    security
...    critical
...    important

# Expected RSA Packages (RHEL/CentOS)
@{EXPECTED_RSA_PACKAGES}
...    pam_radius
...    rsa-auth
...    securid

# Ansible Requirements
@{ANSIBLE_REQUIREMENTS}
...    SSH Access
...    Python Installed
...    Sudo Access
...    Authorized Keys

# Compliance Requirements
${MIN_RSA_VERSION}              8.0
${REQUIRE_TWO_FACTOR}           True
${REQUIRE_SATELLITE_REG}        True
${REQUIRE_ANSIBLE_ACCESS}       True

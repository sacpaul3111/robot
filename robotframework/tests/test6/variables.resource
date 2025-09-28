*** Variables ***
# 🌐 Target System Configuration
${TARGET_HOST}              10.1.1.100
${TARGET_USERNAME}          testuser
${TARGET_PASSWORD}          testpass123
${TARGET_OS_TYPE}           linux              # Options: linux, windows

# 📊 Test Result Tracking
@{TEST_RESULTS}
@{PERFORMANCE_METRICS}
${TOTAL_TESTS}              0
${PASSED_TESTS}             0

# 🔒 CIP-007 R2 Compliance Requirements
${MAX_PATCH_AGE_DAYS}       30                 # Maximum days since last patch
${CIP007_OS_REQUIREMENTS}   /etc/compliance/os_requirements.json
${CIP007_PACKAGE_REQUIREMENTS}    /etc/compliance/package_requirements.json
${CIP007_PATCH_REQUIREMENTS}      /etc/compliance/patch_requirements.json
${CIP007_TEMPLATE_REQUIREMENTS}   /etc/compliance/template_requirements.json

# 📦 Base Package Requirements
@{REQUIRED_BASE_PACKAGES}   kernel
...                         systemd
...                         openssh-server
...                         firewalld
...                         chrony
...                         audit
...                         rsyslog
...                         yum-utils

# 🚫 Excluded Packages (for minimal installation)
@{EXCLUDED_PACKAGES}        gcc
...                         make
...                         kernel-devel
...                         development-tools
...                         graphical-desktop
...                         x11
...                         gnome
...                         kde

# 🤖 Approved Ansible Templates
@{APPROVED_TEMPLATES}       rhel8-minimal-base
...                         rhel9-minimal-base
...                         centos8-minimal-base
...                         rocky8-minimal-base
...                         alma8-minimal-base

# 📁 Output Directories
${REPORTS_DIR}              ../../results/test6/reports
${EVIDENCE_DIR}             ../../results/test6/evidence

# 🔧 Connection Settings
${SSH_TIMEOUT}              30
${WINRM_TIMEOUT}            30
${COMMAND_TIMEOUT}          300

# 📋 Expected Results Template Variables (populated during test execution)
${OS_NAME}                  ${EMPTY}
${OS_VERSION}               ${EMPTY}
${KERNEL_VERSION}           ${EMPTY}
${TEMPLATE_NAME}            ${EMPTY}
${TEMPLATE_VERSION}         ${EMPTY}
${LAST_PATCH_DATE}          ${EMPTY}
${PACKAGE_COUNT}            ${EMPTY}
${AVAILABLE_UPDATES}        ${EMPTY}

# 💾 System Information Storage
${SYSTEM_CONNECTION}        ${EMPTY}
${OS_INFO_DATA}             ${EMPTY}
${PACKAGE_DATA}             ${EMPTY}
${PATCH_DATA}               ${EMPTY}
${TEMPLATE_INFO}            ${EMPTY}
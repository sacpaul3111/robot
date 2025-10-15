*** Settings ***
Documentation    📦 Test-6 Variables: OS and Package Validation Configuration
...              📋 Contains all variables specific to OS version, packages, patches, and CIP-007 R2 compliance testing

*** Variables ***
# 🎯 Test Suite Configuration
${TEST_SUITE_NAME}        Test-6 OS and Package Validation
${TEST_SUITE_ID}          test6
${TEST_DESCRIPTION}       Validate OS version, installed packages, patch history, kernel version, and Ansible build template against CIP-007 R2 compliance

# 📁 Directory Paths
${TEST6_RESULTS_DIR}      results/test6_os_package_validation
${TEST6_DATA_DIR}         results/test6_os_package_validation/data

# 🏷️ Test Tags
@{CRITICAL_TAGS}          critical    os    packages    compliance    cip007
@{NORMAL_TAGS}           normal      informational
@{OS_TAGS}               os_version    kernel    distribution
@{PACKAGE_TAGS}          packages     patches    updates    security
@{COMPLIANCE_TAGS}       cip007_r2    nerc      standards

# 🎯 Target Server Configuration (from command line)
${TARGET_HOSTNAME}        # Set via command line --variable TARGET_HOSTNAME:value
${TARGET_IP}              ${EMPTY}    # Will be populated from EDS lookup
${TARGET_OS_TYPE}         ${EMPTY}    # Will be populated from EDS lookup (Linux/Windows)

# 🔧 Connection Configuration
${CONNECTION_TYPE}        ${EMPTY}    # Will be set to 'SSH' or 'WinRM' based on OS type
${SSH_USERNAME}           ${EMPTY}    # Set via environment or command line
${SSH_PASSWORD}           ${EMPTY}    # Set via environment or command line
${WINRM_USERNAME}         ${EMPTY}    # Set via environment or command line
${WINRM_PASSWORD}         ${EMPTY}    # Set via environment or command line

# 🐧 Linux OS Commands
${CMD_LINUX_OS_VERSION}          cat /etc/os-release
${CMD_LINUX_KERNEL}              uname -r
${CMD_LINUX_PACKAGES}            rpm -qa --qf "\%{NAME}-\%{VERSION}-\%{RELEASE}.\%{ARCH}\\n" || dpkg -l
${CMD_LINUX_PATCH_HISTORY}       rpm -qa --last | head -100 || dpkg -l | tail -100
${CMD_LINUX_BASE_PACKAGES}       rpm -qa --qf "\%{NAME}\\n" | sort || dpkg -query -f '\${Package}\\n' -W | sort
${CMD_LINUX_SECURITY_UPDATES}    yum list updates --security 2>/dev/null || dnf list updates --security 2>/dev/null || apt list --upgradable 2>/dev/null

# 🪟 Windows OS Commands (PowerShell)
${CMD_WIN_OS_VERSION}         Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
${CMD_WIN_KERNEL}             Get-ComputerInfo | Select-Object OsBuildNumber, OsVersion
${CMD_WIN_PACKAGES}           Get-Package | Select-Object Name, Version, ProviderName
${CMD_WIN_PATCH_HISTORY}      Get-HotFix | Select-Object Description, HotFixID, InstalledOn | Sort-Object InstalledOn -Descending
${CMD_WIN_BASE_PACKAGES}      Get-WindowsFeature | Where-Object {$_.Installed -eq $true}
${CMD_WIN_SECURITY_UPDATES}   Get-WindowsUpdate -MicrosoftUpdate

# 📊 CIP-007 R2 Compliance Requirements
${CIP007_R2_TITLE}            CIP-007-6 R2 - Patch Management
${CIP007_R2_DESCRIPTION}      Systems, Structures, and Components Security Management - Security Patch Management
@{CIP007_R2_REQUIREMENTS}
...    R2.1: Track security patches for applicable Cyber Assets
...    R2.2: Evaluate security patches for applicability within 35 calendar days
...    R2.3: Apply applicable security patches or document technical/risk-based justification
...    R2.4: Document mitigation measures for patches not installed within 35 days

# 🔍 Validation Standards
@{APPROVED_OS_VERSIONS_RHEL}      7.9    8.6    8.7    8.8    9.0    9.1    9.2
@{APPROVED_OS_VERSIONS_CENTOS}    7.9    8.5
@{APPROVED_OS_VERSIONS_UBUNTU}    20.04    22.04
@{APPROVED_OS_VERSIONS_WINDOWS}   2019    2022

# 📦 Required Base Packages (Linux)
@{REQUIRED_BASE_PACKAGES_LINUX}
...    openssh-server
...    chrony
...    rsyslog
...    audit
...    sudo
...    vim
...    net-tools
...    curl
...    wget

# 📦 Required Base Packages (Windows)
@{REQUIRED_BASE_PACKAGES_WINDOWS}
...    OpenSSH.Server
...    WindowsDefender
...    PowerShell

# 🚫 Prohibited Packages (Security)
@{PROHIBITED_PACKAGES}
...    telnet
...    rsh
...    rsh-server
...    telnet-server

# 📄 Report File Templates
${OS_INFO_TEMPLATE}=              os_information_%s.txt
${PACKAGE_LIST_TEMPLATE}=         installed_packages_%s.txt
${PATCH_HISTORY_TEMPLATE}=        patch_history_%s.txt
${KERNEL_INFO_TEMPLATE}=          kernel_information_%s.txt
${COMPLIANCE_REPORT_TEMPLATE}=    cip007_r2_compliance_%s.txt
${ANSIBLE_TEMPLATE_TEMPLATE}=     ansible_build_template_%s.txt

# 📊 Patch Management Thresholds
${PATCH_EVALUATION_DAYS}      35          # CIP-007 R2.2 requirement
${PATCH_WARNING_DAYS}         28          # Warning threshold before 35 days
${CRITICAL_PATCH_DAYS}        7           # Critical security patches should be applied within 7 days

# 🎨 Console Output Formatting
${LOG_PREFIX_OS}              🐧 OS
${LOG_PREFIX_WIN}             🪟 Windows
${LOG_PREFIX_PACKAGE}         📦 Package
${LOG_PREFIX_PATCH}           🔄 Patch
${LOG_PREFIX_KERNEL}          🔧 Kernel
${LOG_PREFIX_COMPLIANCE}      📋 CIP-007 R2
${LOG_PREFIX_VALIDATION}      🔍 Validating
${LOG_PREFIX_PASSED}          ✅ PASSED
${LOG_PREFIX_FAILED}          ❌ FAILED
${LOG_PREFIX_WARNING}         ⚠️ WARNING
${LOG_PREFIX_INFO}            ℹ️ INFO

# 🗂️ Ansible Build Template Information
${ANSIBLE_TEMPLATE_FILE}      /root/.ansible_build_info    # Linux location
${ANSIBLE_TEMPLATE_FILE_WIN}  C:\ProgramData\ansible_build_info.txt    # Windows location
@{ANSIBLE_TEMPLATE_FIELDS}
...    template_name
...    template_version
...    build_date
...    ansible_version
...    playbook_version

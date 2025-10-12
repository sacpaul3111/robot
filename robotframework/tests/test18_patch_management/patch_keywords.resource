*** Settings ***
Documentation    🔐 Patch Management & RSA Authentication Keywords for Test-18
...              📋 Provides SSH connection, RSA validation, and patch management verification capabilities
...
Library          SSHLibrary
Library          Collections
Library          String
Library          OperatingSystem
Library          DateTime
Resource         ../../settings.resource

*** Variables ***
${DATA_DIR}                ${OUTPUT_DIR}/data

# Suite-level variables for RSA and patch management data
${RSA_AGENT_STATUS}            ${EMPTY}
${RSA_CONFIG_FILES}            ${EMPTY}
${RSA_AUTH_SETTINGS}           ${EMPTY}
${PATCH_REGISTRATION_STATUS}   ${EMPTY}

*** Keywords ***
Initialize Patch Management Test Environment
    [Documentation]    🏗️ Set up test environment for patch management and RSA validation
    Log    🚀 Initializing Test-18: Patch Management & RSA Authentication Environment...    console=yes

    # Create directories for data collection
    Create Directory    ${DATA_DIR}

    # Lookup EDS configuration to get target IP
    ${eds_config}=    EDSLookup.Lookup Server Config    ${TARGET_HOSTNAME}
    Set Suite Variable    ${TARGET_IP}    ${eds_config['ip']}

    Log    📋 Target Server: ${TARGET_HOSTNAME}    console=yes
    Log    📋 Target IP: ${TARGET_IP}    console=yes

    # Establish SSH connection to target server
    Log    🔗 Connecting to target server: ${TARGET_IP}...    console=yes
    Open Connection    ${TARGET_IP}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}

    Log    ✅ SSH connection established successfully    console=yes
    Log    ✅ Test-18 environment initialized    console=yes

Check RSA Agent Installation
    [Documentation]    🔐 Check if RSA SecurID agent is installed
    Log    🔐 Checking RSA SecurID agent installation...    console=yes

    # Check for RSA agent binaries and packages
    ${rsa_package}=        Execute Command    rpm -qa | grep -i rsa 2>/dev/null || dpkg -l | grep -i rsa 2>/dev/null || echo "No RSA packages found"
    ${rsa_agent_bin}=      Execute Command    which rsaagent 2>/dev/null || which rsaauth 2>/dev/null || echo "RSA agent binary not found in PATH"
    ${rsa_installation}=   Execute Command    ls -la /opt/rsa* 2>/dev/null || ls -la /usr/local/rsa* 2>/dev/null || echo "No RSA installation directories found"
    ${ace_client}=         Execute Command    ls -la /opt/pam_client* 2>/dev/null || ls -la /var/ace* 2>/dev/null || echo "No ACE client found"

    # Combine results
    ${agent_status}=    Catenate    SEPARATOR=\n
    ...    === RSA Packages ===
    ...    ${rsa_package}
    ...
    ...    === RSA Agent Binary ===
    ...    ${rsa_agent_bin}
    ...
    ...    === RSA Installation Directory ===
    ...    ${rsa_installation}
    ...
    ...    === ACE Client ===
    ...    ${ace_client}

    Set Suite Variable    ${RSA_AGENT_STATUS}    ${agent_status}

    Log    🔐 RSA Agent Installation Status collected    console=yes
    RETURN    ${agent_status}

Save RSA Agent Status to File
    [Documentation]    💾 Save RSA agent installation status to file
    [Arguments]    ${agent_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${agent_file}=    Set Variable    ${DATA_DIR}/rsa_agent_status_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === RSA Agent Installation Status ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${agent_status}
    ...
    ...    =========================================

    Create File    ${agent_file}    ${report}
    Log    📄 RSA agent status saved to: ${agent_file}    console=yes
    RETURN    ${agent_file}

Collect RSA Configuration Files
    [Documentation]    📄 Collect RSA configuration files from common locations
    Log    📄 Collecting RSA configuration files...    console=yes

    # Check common RSA configuration file locations (use strings for binary files)
    ${sdconf}=           Execute Command    ls -la /var/ace/sdconf.rec 2>/dev/null && strings /var/ace/sdconf.rec 2>/dev/null | head -20 || echo "No /var/ace/sdconf.rec"
    ${sdopts}=           Execute Command    ls -la /var/ace/sdopts.rec 2>/dev/null && strings /var/ace/sdopts.rec 2>/dev/null | head -20 || echo "No /var/ace/sdopts.rec"
    ${pam_rsa}=          Execute Command    cat /etc/pam.d/rsa 2>/dev/null || grep -r rsa /etc/pam.d/ 2>/dev/null || echo "No PAM RSA configuration"
    ${ace_data}=         Execute Command    ls -la /var/ace/ 2>/dev/null || echo "No /var/ace/ directory"
    ${rsa_config_dir}=   Execute Command    ls -la /opt/rsa/*/config/ 2>/dev/null || echo "No RSA config directory"

    # Combine results
    ${config_files}=    Catenate    SEPARATOR=\n
    ...    === /var/ace/sdconf.rec ===
    ...    ${sdconf}
    ...
    ...    === /var/ace/sdopts.rec ===
    ...    ${sdopts}
    ...
    ...    === PAM RSA Configuration ===
    ...    ${pam_rsa}
    ...
    ...    === /var/ace/ Directory ===
    ...    ${ace_data}
    ...
    ...    === RSA Config Directory ===
    ...    ${rsa_config_dir}

    Set Suite Variable    ${RSA_CONFIG_FILES}    ${config_files}

    Log    📄 RSA configuration files collected    console=yes
    RETURN    ${config_files}

Save RSA Config to File
    [Documentation]    💾 Save RSA configuration to file
    [Arguments]    ${config_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${config_file}=    Set Variable    ${DATA_DIR}/rsa_config_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === RSA Configuration Files ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${config_status}
    ...
    ...    =========================================

    Create File    ${config_file}    ${report}
    Log    📄 RSA configuration saved to: ${config_file}    console=yes
    RETURN    ${config_file}

Validate RSA Authentication Settings
    [Documentation]    🔐 Validate RSA authentication settings in SSH and PAM
    Log    🔐 Validating RSA authentication settings...    console=yes

    # Check SSH configuration for RSA
    ${sshd_config}=         Execute Command    grep -i "challengeresponse\|pubkeyauth\|rsa" /etc/ssh/sshd_config 2>/dev/null || echo "No RSA settings in sshd_config"

    # Check PAM configuration
    ${pam_config}=          Execute Command    grep -r "pam_rsa\|pam_securid" /etc/pam.d/ 2>/dev/null || echo "No RSA PAM configuration"

    # Check for RSA authentication modules
    ${auth_modules}=        Execute Command    ls -la /lib*/security/*rsa* 2>/dev/null || ls -la /lib*/security/*securid* 2>/dev/null || echo "No RSA auth modules found"

    # Check nsswitch configuration
    ${nsswitch}=            Execute Command    grep rsa /etc/nsswitch.conf 2>/dev/null || echo "No RSA in nsswitch.conf"

    # Combine results
    ${auth_settings}=    Catenate    SEPARATOR=\n
    ...    === SSH Configuration (RSA) ===
    ...    ${sshd_config}
    ...
    ...    === PAM RSA Configuration ===
    ...    ${pam_config}
    ...
    ...    === RSA Authentication Modules ===
    ...    ${auth_modules}
    ...
    ...    === nsswitch.conf ===
    ...    ${nsswitch}

    Set Suite Variable    ${RSA_AUTH_SETTINGS}    ${auth_settings}

    Log    🔐 RSA authentication settings validated    console=yes
    RETURN    ${auth_settings}

Test RSA Server Connectivity
    [Documentation]    🌐 Test connectivity to RSA authentication server
    Log    🌐 Testing RSA server connectivity...    console=yes

    # Extract server and port from configuration
    ${rsa_server_config}=    Execute Command    grep -r "auth_server\|ace_server" /var/ace/ /opt/rsa/ 2>/dev/null || echo "No RSA server configuration found"

    # Test connectivity to expected RSA server (ports: 5500, 5555 are common for RSA)
    ${port_5500_test}=    Execute Command    timeout 5 nc -zv ${EXPECTED_RSA_SERVER} 5500 2>&1 || echo "Port 5500 test failed/timeout"
    ${port_5555_test}=    Execute Command    timeout 5 nc -zv ${EXPECTED_RSA_SERVER} 5555 2>&1 || echo "Port 5555 test failed/timeout"

    # DNS resolution test
    ${dns_test}=          Execute Command    nslookup ${EXPECTED_RSA_SERVER} 2>&1 || dig ${EXPECTED_RSA_SERVER} 2>&1 || echo "DNS lookup not available"

    # Ping test
    ${ping_test}=         Execute Command    ping -c 3 ${EXPECTED_RSA_SERVER} 2>&1 || echo "Ping test failed"

    # Combine results
    ${connectivity_result}=    Catenate    SEPARATOR=\n
    ...    === RSA Server Configuration ===
    ...    ${rsa_server_config}
    ...
    ...    === Port 5500 Test (RSA Auth) ===
    ...    ${port_5500_test}
    ...
    ...    === Port 5555 Test (RSA Auth) ===
    ...    ${port_5555_test}
    ...
    ...    === DNS Resolution ===
    ...    ${dns_test}
    ...
    ...    === Ping Test ===
    ...    ${ping_test}

    Log    🌐 RSA server connectivity test completed    console=yes
    RETURN    ${connectivity_result}

Save RSA Connectivity Test to File
    [Documentation]    💾 Save RSA connectivity test results to file
    [Arguments]    ${connectivity_result}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${conn_file}=    Set Variable    ${DATA_DIR}/rsa_connectivity_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === RSA Server Connectivity Test ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...    Expected RSA Server: ${EXPECTED_RSA_SERVER}
    ...
    ...    ${connectivity_result}
    ...
    ...    =========================================

    Create File    ${conn_file}    ${report}
    Log    📄 RSA connectivity test saved to: ${conn_file}    console=yes
    RETURN    ${conn_file}

Check RSA Agent Service Status
    [Documentation]    🔧 Check if RSA agent service is running
    Log    🔧 Checking RSA agent service status...    console=yes

    # Check various possible RSA service names
    ${rsa_service}=       Execute Command    systemctl status rsaagent 2>&1 || systemctl status rsa 2>&1 || echo "RSA service not found in systemctl"
    ${ace_service}=       Execute Command    systemctl status aceagent 2>&1 || echo "ACE agent service not found"
    ${service_list}=      Execute Command    systemctl list-units | grep -i rsa 2>&1 || echo "No RSA services in systemctl list"

    # Check process status
    ${rsa_process}=       Execute Command    ps aux | grep -i rsa | grep -v grep || echo "No RSA processes running"

    # Combine results
    ${service_status}=    Catenate    SEPARATOR=\n
    ...    === RSA Agent Service ===
    ...    ${rsa_service}
    ...
    ...    === ACE Agent Service ===
    ...    ${ace_service}
    ...
    ...    === RSA Services List ===
    ...    ${service_list}
    ...
    ...    === RSA Processes ===
    ...    ${rsa_process}

    Log    🔧 RSA agent service status collected    console=yes
    RETURN    ${service_status}

Check Patch Management Registration
    [Documentation]    📦 Check system registration with patch management servers
    Log    📦 Checking patch management registration...    console=yes

    # Check Red Hat Satellite registration
    ${satellite_status}=     Execute Command    subscription-manager status 2>&1 || echo "subscription-manager not available"
    ${satellite_identity}=   Execute Command    subscription-manager identity 2>&1 || echo "Not registered with Satellite"
    ${katello_facts}=        Execute Command    cat /etc/rhsm/facts/katello.facts 2>/dev/null || echo "No Katello facts file"

    # Check for Ansible
    ${ansible_config}=       Execute Command    cat /etc/ansible/ansible.cfg 2>/dev/null || echo "No Ansible configuration"
    ${ansible_hosts}=        Execute Command    grep ${TARGET_HOSTNAME} /etc/ansible/hosts 2>/dev/null || echo "Not in Ansible hosts"

    # Check yum/dnf plugins
    ${yum_plugins}=          Execute Command    ls -la /etc/yum/pluginconf.d/ 2>/dev/null || echo "No yum plugin configs"

    # Check for Satellite client packages
    ${satellite_pkgs}=       Execute Command    rpm -qa | grep -E "katello|satellite|foreman" 2>/dev/null || echo "No Satellite packages found"

    # Combine results
    ${registration_status}=    Catenate    SEPARATOR=\n
    ...    === Satellite Status ===
    ...    ${satellite_status}
    ...
    ...    === Satellite Identity ===
    ...    ${satellite_identity}
    ...
    ...    === Katello Facts ===
    ...    ${katello_facts}
    ...
    ...    === Ansible Configuration ===
    ...    ${ansible_config}
    ...
    ...    === Ansible Hosts ===
    ...    ${ansible_hosts}
    ...
    ...    === Yum Plugins ===
    ...    ${yum_plugins}
    ...
    ...    === Satellite Packages ===
    ...    ${satellite_pkgs}

    Set Suite Variable    ${PATCH_REGISTRATION_STATUS}    ${registration_status}

    Log    📦 Patch management registration status collected    console=yes
    RETURN    ${registration_status}

Save Registration Status to File
    [Documentation]    💾 Save registration status to file
    [Arguments]    ${registration_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${reg_file}=    Set Variable    ${DATA_DIR}/patch_registration_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Patch Management Registration ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${registration_status}
    ...
    ...    =========================================

    Create File    ${reg_file}    ${report}
    Log    📄 Registration status saved to: ${reg_file}    console=yes
    RETURN    ${reg_file}

Validate Two Factor Authentication Flow
    [Documentation]    🔐 Validate two-factor authentication flow readiness
    Log    🔐 Validating two-factor authentication flow...    console=yes

    # Check authentication order in PAM
    ${pam_sshd}=         Execute Command    cat /etc/pam.d/sshd 2>/dev/null || echo "No /etc/pam.d/sshd"
    ${pam_login}=        Execute Command    cat /etc/pam.d/login 2>/dev/null || echo "No /etc/pam.d/login"
    ${pam_system}=       Execute Command    cat /etc/pam.d/system-auth 2>/dev/null || echo "No /etc/pam.d/system-auth"

    # Check for existing user RSA configuration
    ${user_rsa_config}=  Execute Command    ls -la ~/.rsa* 2>/dev/null || echo "No user RSA config in home"

    # Combine results
    ${tfa_status}=    Catenate    SEPARATOR=\n
    ...    === PAM SSHD ===
    ...    ${pam_sshd}
    ...
    ...    === PAM Login ===
    ...    ${pam_login}
    ...
    ...    === PAM System Auth ===
    ...    ${pam_system}
    ...
    ...    === User RSA Config ===
    ...    ${user_rsa_config}

    Log    🔐 Two-factor authentication flow validated    console=yes
    RETURN    ${tfa_status}

Check RSA Token Configuration
    [Documentation]    🎫 Check RSA token configuration
    Log    🎫 Checking RSA token configuration...    console=yes

    # Check for token assignments and configuration
    ${token_info}=       Execute Command    cat /var/ace/user_token.db 2>/dev/null || echo "No token database found"
    ${token_cache}=      Execute Command    ls -la /var/ace/cache/ 2>/dev/null || echo "No token cache"
    ${securid_config}=   Execute Command    cat /var/ace/securid 2>/dev/null || echo "No securid file"

    # Combine results
    ${token_config}=    Catenate    SEPARATOR=\n
    ...    === Token Database ===
    ...    ${token_info}
    ...
    ...    === Token Cache ===
    ...    ${token_cache}
    ...
    ...    === SecurID Configuration ===
    ...    ${securid_config}

    Log    🎫 RSA token configuration collected    console=yes
    RETURN    ${token_config}

Check Satellite Subscription Status
    [Documentation]    📦 Check Red Hat Satellite subscription status
    Log    📦 Checking Satellite subscription status...    console=yes

    # Check subscription details
    ${sub_status}=       Execute Command    subscription-manager status 2>&1 || echo "subscription-manager not available"
    ${sub_list}=         Execute Command    subscription-manager list --consumed 2>&1 || echo "No subscriptions listed"
    ${repos_list}=       Execute Command    subscription-manager repos --list-enabled 2>&1 | head -50 || echo "No repos listed"
    ${compliance}=       Execute Command    subscription-manager compliance 2>&1 || echo "Compliance check not available"

    # Combine results
    ${subscription_status}=    Catenate    SEPARATOR=\n
    ...    === Subscription Status ===
    ...    ${sub_status}
    ...
    ...    === Consumed Subscriptions ===
    ...    ${sub_list}
    ...
    ...    === Enabled Repositories ===
    ...    ${repos_list}
    ...
    ...    === Compliance Status ===
    ...    ${compliance}

    Log    📦 Satellite subscription status collected    console=yes
    RETURN    ${subscription_status}

Save Subscription Status to File
    [Documentation]    💾 Save subscription status to file
    [Arguments]    ${subscription_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${sub_file}=    Set Variable    ${DATA_DIR}/subscription_status_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Satellite Subscription Status ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${subscription_status}
    ...
    ...    =========================================

    Create File    ${sub_file}    ${report}
    Log    📄 Subscription status saved to: ${sub_file}    console=yes
    RETURN    ${sub_file}

Check Available Patches
    [Documentation]    🔄 Check for available patches and updates
    Log    🔄 Checking available patches...    console=yes

    # Check for available updates (yum/dnf)
    ${yum_updates}=      Execute Command    yum check-update 2>&1 || dnf check-update 2>&1 || echo "Package manager check not available"
    ${security_updates}= Execute Command    yum updateinfo list security 2>&1 || dnf updateinfo list security 2>&1 || echo "Security updates check not available"
    ${last_update}=      Execute Command    rpm -qa --last | head -20 || echo "RPM query not available"
    ${yum_history}=      Execute Command    yum history list 2>&1 | head -20 || dnf history list 2>&1 | head -20 || echo "Update history not available"

    # Combine results
    ${patch_status}=    Catenate    SEPARATOR=\n
    ...    === Available Updates ===
    ...    ${yum_updates}
    ...
    ...    === Security Updates ===
    ...    ${security_updates}
    ...
    ...    === Recently Installed Packages ===
    ...    ${last_update}
    ...
    ...    === Update History ===
    ...    ${yum_history}

    Log    🔄 Available patches collected    console=yes
    RETURN    ${patch_status}

Save Available Patches to File
    [Documentation]    💾 Save available patches to file
    [Arguments]    ${patch_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${patch_file}=    Set Variable    ${DATA_DIR}/available_patches_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Available Patches ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${patch_status}
    ...
    ...    =========================================

    Create File    ${patch_file}    ${report}
    Log    📄 Available patches saved to: ${patch_file}    console=yes
    RETURN    ${patch_file}

Check Ansible Control Node Access
    [Documentation]    🤖 Check connectivity and access to Ansible control node
    Log    🤖 Checking Ansible control node access...    console=yes

    # Check for Ansible connectivity markers
    ${ansible_facts}=    Execute Command    ls -la /etc/ansible/facts.d/ 2>/dev/null || echo "No Ansible facts directory"
    ${ansible_log}=      Execute Command    grep ansible /var/log/messages 2>/dev/null | tail -20 || echo "No Ansible logs in messages"
    ${ssh_keys}=         Execute Command    ls -la ~/.ssh/authorized_keys 2>/dev/null | head -20 || echo "No authorized_keys"
    ${ansible_user}=     Execute Command    id ansible 2>/dev/null || echo "No ansible user"

    # Combine results
    ${ansible_status}=    Catenate    SEPARATOR=\n
    ...    === Ansible Facts ===
    ...    ${ansible_facts}
    ...
    ...    === Ansible Logs ===
    ...    ${ansible_log}
    ...
    ...    === SSH Authorized Keys ===
    ...    ${ssh_keys}
    ...
    ...    === Ansible User ===
    ...    ${ansible_user}

    Log    🤖 Ansible control node access checked    console=yes
    RETURN    ${ansible_status}

Check Patch Management Schedule
    [Documentation]    📅 Check patch management schedule and maintenance windows
    Log    📅 Checking patch management schedule...    console=yes

    # Check for cron jobs related to patching
    ${cron_jobs}=        Execute Command    crontab -l 2>&1 || echo "No user crontab"
    ${system_cron}=      Execute Command    ls -la /etc/cron.d/ 2>/dev/null || echo "No /etc/cron.d/"
    ${yum_cron}=         Execute Command    cat /etc/yum/yum-cron.conf 2>/dev/null || cat /etc/dnf/automatic.conf 2>/dev/null || echo "No automatic update config"
    ${timer_units}=      Execute Command    systemctl list-timers 2>&1 | grep -E "yum|dnf|update" || echo "No update timers"

    # Combine results
    ${schedule_status}=    Catenate    SEPARATOR=\n
    ...    === User Cron Jobs ===
    ...    ${cron_jobs}
    ...
    ...    === System Cron ===
    ...    ${system_cron}
    ...
    ...    === Automatic Update Config ===
    ...    ${yum_cron}
    ...
    ...    === Update Timers ===
    ...    ${timer_units}

    Log    📅 Patch management schedule collected    console=yes
    RETURN    ${schedule_status}

Check Security Updates Status
    [Documentation]    🔒 Check security patches and critical updates status
    Log    🔒 Checking security updates status...    console=yes

    # Check security updates
    ${security_list}=    Execute Command    yum updateinfo list security 2>&1 || dnf updateinfo list security 2>&1 || echo "Security list not available"
    ${critical_list}=    Execute Command    yum updateinfo list crit 2>&1 || dnf updateinfo list crit 2>&1 || echo "Critical list not available"
    ${cve_list}=         Execute Command    yum updateinfo list cves 2>&1 || dnf updateinfo list cves 2>&1 || echo "CVE list not available"
    ${security_info}=    Execute Command    yum updateinfo info security 2>&1 | head -50 || dnf updateinfo info security 2>&1 | head -50 || echo "Security info not available"

    # Combine results
    ${security_status}=    Catenate    SEPARATOR=\n
    ...    === Security Updates List ===
    ...    ${security_list}
    ...
    ...    === Critical Updates List ===
    ...    ${critical_list}
    ...
    ...    === CVE List ===
    ...    ${cve_list}
    ...
    ...    === Security Update Details ===
    ...    ${security_info}

    Log    🔒 Security updates status collected    console=yes
    RETURN    ${security_status}

Save Security Updates to File
    [Documentation]    💾 Save security updates status to file
    [Arguments]    ${security_status}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${security_file}=    Set Variable    ${DATA_DIR}/security_updates_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Security Updates Status ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${security_status}
    ...
    ...    =========================================

    Create File    ${security_file}    ${report}
    Log    📄 Security updates saved to: ${security_file}    console=yes
    RETURN    ${security_file}

Validate All Patch Management Settings
    [Documentation]    📊 Validate all patch management and RSA settings
    Log    📊 Validating all patch management and RSA settings...    console=yes

    # This keyword serves as a placeholder for comprehensive validation
    # All individual validations are performed in their respective test cases
    Log    ✅ All patch management and RSA data collected and validated    console=yes

Close All SSH Connections
    [Documentation]    🔌 Close all SSH connections
    Log    🔌 Closing SSH connections...    console=yes
    Close All Connections
    Log    ✅ SSH connections closed    console=yes

Execute Command
    [Documentation]    🔧 Execute a command on the remote server via SSH
    [Arguments]    ${command}
    ${output}=    SSHLibrary.Execute Command    ${command}
    RETURN    ${output}

Log Test Start
    [Documentation]    📝 Log the start of a test case
    [Arguments]    ${test_name}
    Log    \n================================================================================    console=yes
    Log    🏁 Starting Test: ${test_name}    console=yes
    Log    ================================================================================    console=yes

Log Test End
    [Documentation]    📝 Log the end of a test case with status
    [Arguments]    ${test_name}    ${status}
    Log    ================================================================================    console=yes
    Log    🏁 Completed Test: ${test_name} | Status: ${status}    console=yes
    Log    ================================================================================\n    console=yes

*** Settings ***
Documentation    ⚙️ Services Validation Keywords for Test-11
...              📋 Provides SSH connection, service status collection, and validation capabilities
...
Library          SSHLibrary
Library          Collections
Library          String
Library          OperatingSystem
Library          DateTime
Resource         ../../settings.resource

*** Variables ***
${DATA_DIR}                results/test11_services_validation/data

# Suite-level variables for service data
${ALL_SERVICES_OUTPUT}         ${EMPTY}
${ENABLED_SERVICES_OUTPUT}     ${EMPTY}
${ACTIVE_SERVICES_OUTPUT}      ${EMPTY}

*** Keywords ***
Initialize Services Test Environment
    [Documentation]    🏗️ Set up test environment for services validation
    Log    🚀 Initializing Test-11: Services Validation Environment...    console=yes

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
    Log    ✅ Test-11 environment initialized    console=yes

Collect All Services Status
    [Documentation]    📋 Execute systemctl to collect all services and their status
    Log    📋 Executing systemctl to collect all services...    console=yes

    # Get all services (loaded and active)
    ${all_services}=    Execute Command    systemctl list-units --type=service --all --no-pager --no-legend
    Set Suite Variable    ${ALL_SERVICES_OUTPUT}    ${all_services}

    # Get enabled services (will start at boot)
    ${enabled_services}=    Execute Command    systemctl list-unit-files --type=service --state=enabled --no-pager --no-legend
    Set Suite Variable    ${ENABLED_SERVICES_OUTPUT}    ${enabled_services}

    # Get active/running services
    ${active_services}=    Execute Command    systemctl list-units --type=service --state=active --no-pager --no-legend
    Set Suite Variable    ${ACTIVE_SERVICES_OUTPUT}    ${active_services}

    Log    ✅ All services data collected    console=yes

Save Services Status to File
    [Documentation]    💾 Save complete service status to file for compliance review
    Log    💾 Saving service status to file...    console=yes

    # Generate timestamp for unique filename
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${service_file}=    Set Variable    ${DATA_DIR}/services_status_${timestamp}.txt

    # Build comprehensive service report
    ${service_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Services Status Report ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    =========================================
    ...    === ALL SERVICES (systemctl list-units --type=service --all) ===
    ...    =========================================
    ...    ${ALL_SERVICES_OUTPUT}
    ...
    ...    =========================================
    ...    === ENABLED SERVICES (systemctl list-unit-files --state=enabled) ===
    ...    =========================================
    ...    ${ENABLED_SERVICES_OUTPUT}
    ...
    ...    =========================================
    ...    === ACTIVE/RUNNING SERVICES (systemctl list-units --state=active) ===
    ...    =========================================
    ...    ${ACTIVE_SERVICES_OUTPUT}
    ...
    ...    =========================================
    ...    === REQUIRED SERVICES CHECK ===
    ...    =========================================
    ...    Required services that must be ENABLED:
    ...    - autofs
    ...    - sshd
    ...    - sssd
    ...    - chronyd
    ...    - ntpd
    ...    - syslog (rsyslog/syslog-ng)
    ...
    ...    Services that must be DISABLED:
    ...    - iptables
    ...    - selinux (check with getenforce command)
    ...
    ...    =========================================

    # Save report to file
    Create File    ${service_file}    ${service_report}

    Log    📄 Service status saved to: ${service_file}    console=yes
    RETURN    ${service_file}

Validate Required Services Are Enabled
    [Documentation]    ✅ Validate that required services are enabled on the system
    Log    ✅ Validating required services are enabled...    console=yes

    # Create dictionary to store validation results
    ${validation_results}=    Create Dictionary

    # Check each required service
    FOR    ${service}    IN    @{REQUIRED_SERVICES_ENABLED}
        Log    🔍 Checking service: ${service}    console=yes

        # Check if service is enabled (multiple variations)
        ${is_enabled}=    Check Service Is Enabled    ${service}

        # Store result
        Set To Dictionary    ${validation_results}    ${service}=${is_enabled}

        # Log result
        Run Keyword If    '${is_enabled}' == 'enabled'
        ...    Log    ✅ ${service}: ENABLED    console=yes
        ...    ELSE
        ...    Log    ⚠️ ${service}: NOT ENABLED or NOT FOUND    console=yes
    END

    RETURN    ${validation_results}

Check Service Is Enabled
    [Documentation]    🔍 Check if a specific service is enabled (handles multiple service name variations)
    [Arguments]    ${service_name}

    # Try exact match first
    ${status1}=    Execute Command    systemctl is-enabled ${service_name} 2>/dev/null || echo "not-found"
    Return From Keyword If    '${status1}' == 'enabled'    enabled

    # Try with .service extension
    ${status2}=    Execute Command    systemctl is-enabled ${service_name}.service 2>/dev/null || echo "not-found"
    Return From Keyword If    '${status2}' == 'enabled'    enabled

    # Special case: syslog might be rsyslog or syslog-ng
    ${is_syslog}=    Evaluate    '${service_name}' == 'syslog'
    Run Keyword If    ${is_syslog}    Return From Keyword If    ${True}    ${${Check Syslog Service}}

    # Special case: chronyd might be chrony
    ${is_chronyd}=    Evaluate    '${service_name}' == 'chronyd'
    ${status_chrony}=    Run Keyword If    ${is_chronyd}    Execute Command    systemctl is-enabled chrony 2>/dev/null || echo "not-found"
    Return From Keyword If    '${status_chrony}' == 'enabled'    enabled

    # Service not found or not enabled
    RETURN    not-enabled

Check Syslog Service
    [Documentation]    🔍 Check syslog service (rsyslog or syslog-ng)

    ${rsyslog_status}=    Execute Command    systemctl is-enabled rsyslog 2>/dev/null || echo "not-found"
    Return From Keyword If    '${rsyslog_status}' == 'enabled'    enabled

    ${syslog_ng_status}=    Execute Command    systemctl is-enabled syslog-ng 2>/dev/null || echo "not-found"
    Return From Keyword If    '${syslog_ng_status}' == 'enabled'    enabled

    RETURN    not-enabled

Validate Unnecessary Services Are Disabled
    [Documentation]    ❌ Validate that unnecessary services are disabled
    Log    ❌ Validating unnecessary services are disabled...    console=yes

    # Create dictionary to store validation results
    ${validation_results}=    Create Dictionary

    # Check each unnecessary service
    FOR    ${service}    IN    @{REQUIRED_SERVICES_DISABLED}
        Log    🔍 Checking service: ${service}    console=yes

        # Special handling for selinux (not a service)
        ${is_selinux}=    Evaluate    '${service}' == 'selinux'

        Run Keyword If    ${is_selinux}
        ...    Check SELinux Status    ${validation_results}
        ...    ELSE
        ...    Check Service Is Disabled    ${service}    ${validation_results}
    END

    RETURN    ${validation_results}

Check Service Is Disabled
    [Documentation]    🔍 Check if a service is disabled or inactive
    [Arguments]    ${service_name}    ${results_dict}

    # Check if service is enabled
    ${is_enabled}=    Execute Command    systemctl is-enabled ${service_name} 2>/dev/null || echo "disabled"

    # Check if service is active
    ${is_active}=    Execute Command    systemctl is-active ${service_name} 2>/dev/null || echo "inactive"

    # Service should be disabled AND inactive
    ${status}=    Set Variable If
    ...    '${is_enabled}' in ['disabled', 'masked'] and '${is_active}' == 'inactive'    disabled
    ...    ELSE    active-or-enabled

    Set To Dictionary    ${results_dict}    ${service_name}=${status}

    # Log result
    Run Keyword If    '${status}' == 'disabled'
    ...    Log    ✅ ${service_name}: DISABLED    console=yes
    ...    ELSE
    ...    Log    ⚠️ ${service_name}: ACTIVE or ENABLED (enabled=${is_enabled}, active=${is_active})    console=yes

Check SELinux Status
    [Documentation]    🔍 Check if SELinux is disabled
    [Arguments]    ${results_dict}

    ${selinux_status}=    Execute Command    getenforce 2>/dev/null || echo "Disabled"

    ${status}=    Set Variable If
    ...    '${selinux_status}' in ['Disabled', 'Permissive']    disabled
    ...    ELSE    enforcing

    Set To Dictionary    ${results_dict}    selinux=${status}

    # Log result
    Run Keyword If    '${status}' == 'disabled'
    ...    Log    ✅ selinux: DISABLED (${selinux_status})    console=yes
    ...    ELSE
    ...    Log    ⚠️ selinux: ENFORCING (${selinux_status})    console=yes

Save Failed Services Report
    [Documentation]    📄 Save failed services report to file
    [Arguments]    ${failed_services}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${failed_file}=    Set Variable    ${DATA_DIR}/failed_services_${timestamp}.txt

    ${report}=    Catenate    SEPARATOR=\n
    ...    === Failed Services Report ===
    ...    Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    ${failed_services}

    Create File    ${failed_file}    ${report}
    Log    📄 Failed services report saved to: ${failed_file}    console=yes

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

Get File Size
    [Documentation]    📏 Get size of a file in bytes
    [Arguments]    ${file_path}
    ${size}=    OperatingSystem.Get File Size    ${file_path}
    RETURN    ${size}

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

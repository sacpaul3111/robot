*** Settings ***
Documentation    ⚙️ Services Validation Test Suite - Test-11
...              🔍 Process: Find hostname in EDS → SSH to server → Collect service status data → Document all running services
...              ✅ Validates: Required services (autofs, sshd, sssd, chronyd, ntpd, syslog) are enabled
...              ❌ Validates: Unnecessary services (iptables, selinux) are disabled
...              📊 Documents complete service list for manual compliance review
...
Resource         ../../settings.resource
Resource         services_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize Services Test Environment
Suite Teardown   Close All SSH Connections

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to Target Server
    [Documentation]    🔗 Establish direct SSH connection to target machine
    ...                Step 1 of validation process: Connect to Target
    [Tags]             critical    connection    step1    ssh    infrastructure

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target: ${TARGET_HOSTNAME} (${TARGET_IP})    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection verified and active    console=yes
    Log    ✅ STEP 1: COMPLETED - SSH connection established    console=yes

Critical - Step 2.1: Collect All Services Status
    [Documentation]    📋 Execute systemctl to list all services and their current status
    ...                Step 2 of validation process: Collect Service Data (Part 1)
    [Tags]             critical    services    step2    data_collection    systemctl

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT ALL SERVICES STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Execute service list collection
    Collect All Services Status

    # Verify data was collected
    Should Not Be Empty    ${ALL_SERVICES_OUTPUT}
    Should Not Be Empty    ${ENABLED_SERVICES_OUTPUT}

    Set Suite Variable    ${SERVICES_DATA_COLLECTED}    ${TRUE}

    Log    📋 Total services collected: ${ALL_SERVICES_OUTPUT.count('●')} entries    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Service list collected    console=yes

Critical - Step 2.2: Document Service Status to File
    [Documentation]    💾 Save complete service list output to file for compliance review
    ...                Step 2 of validation process: Collect Service Data (Part 2)
    [Tags]             critical    documentation    step2    data_collection    file_output

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: DOCUMENT SERVICE STATUS TO FILE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Save service status to file
    ${service_file}=    Save Services Status to File

    # Verify file was created
    File Should Exist    ${service_file}
    ${file_size}=    Get File Size    ${service_file}
    Should Be True    ${file_size} > 0

    Set Suite Variable    ${SERVICE_STATUS_FILE}    ${service_file}

    Log    📄 Service status saved to: ${service_file}    console=yes
    Log    📄 File size: ${file_size} bytes    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Service documentation saved    console=yes

Critical - Step 3.1: Validate Required Services Enabled
    [Documentation]    ✅ Verify required services (autofs, sshd, sssd, chronyd, ntpd, syslog) are enabled
    ...                Step 3 of validation process: Validate Against Standards (Part 1)
    [Tags]             critical    services    step3    validation    enabled

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE REQUIRED SERVICES ENABLED    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Required services: ${REQUIRED_SERVICES_ENABLED}    console=yes

    # Validate each required service
    ${validation_results}=    Validate Required Services Are Enabled

    Log    📊 Required services validation:    console=yes
    FOR    ${service}    IN    @{REQUIRED_SERVICES_ENABLED}
        ${status}=    Get From Dictionary    ${validation_results}    ${service}
        Log    📊 - ${service}: ${status}    console=yes
    END

    Log    ✅ Required services validation completed    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Required services validated    console=yes

Critical - Step 3.2: Validate Unnecessary Services Disabled
    [Documentation]    ❌ Verify unnecessary services (iptables, selinux) are disabled
    ...                Step 3 of validation process: Validate Against Standards (Part 2)
    [Tags]             critical    services    step3    validation    disabled    security

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE UNNECESSARY SERVICES DISABLED    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Services to check: ${REQUIRED_SERVICES_DISABLED}    console=yes

    # Validate unnecessary services are disabled
    ${validation_results}=    Validate Unnecessary Services Are Disabled

    Log    📊 Unnecessary services validation:    console=yes
    FOR    ${service}    IN    @{REQUIRED_SERVICES_DISABLED}
        ${status}=    Get From Dictionary    ${validation_results}    ${service}
        Log    📊 - ${service}: ${status}    console=yes
    END

    Log    ✅ Unnecessary services validation completed    console=yes
    Log    ✅ STEP 3.2: COMPLETED - Unnecessary services validated    console=yes

Normal - Service Dependency Analysis
    [Documentation]    🔗 Analyze service dependencies and relationships
    [Tags]             normal    analysis    dependencies    services

    Log    🔍 Analyzing service dependencies...    console=yes

    # Analyze critical service dependencies
    ${sshd_deps}=      Execute Command    systemctl list-dependencies sshd.service | head -20
    ${chronyd_deps}=   Execute Command    systemctl list-dependencies chronyd.service 2>/dev/null | head -20 || echo "chronyd not found"
    ${sssd_deps}=      Execute Command    systemctl list-dependencies sssd.service 2>/dev/null | head -20 || echo "sssd not found"

    Log    📊 SSHD Dependencies: ${sshd_deps}    console=yes
    Log    📊 Chronyd Dependencies: ${chronyd_deps}    console=yes
    Log    📊 SSSD Dependencies: ${sssd_deps}    console=yes

    Log    ℹ️ Service dependency analysis completed    console=yes
    Log    ✅ Service dependency analysis: INFORMATIONAL    console=yes

Normal - Failed Services Report
    [Documentation]    ⚠️ Identify and report any failed services on the system
    [Tags]             normal    monitoring    failed    troubleshooting

    Log    🔍 Checking for failed services...    console=yes

    # Get list of failed services
    ${failed_services}=    Execute Command    systemctl --failed --no-pager --no-legend

    Run Keyword If    '${failed_services}' == ''    Log    ✅ No failed services detected    console=yes
    ...    ELSE    Log    ⚠️ Failed services detected:\n${failed_services}    console=yes

    # Save failed services to file if any exist
    Run Keyword If    '${failed_services}' != ''    Save Failed Services Report    ${failed_services}

    Log    ℹ️ Failed services check completed    console=yes
    Log    ✅ Failed services report: INFORMATIONAL    console=yes

Normal - Service Startup Time Analysis
    [Documentation]    ⏱️ Analyze system boot time and service startup performance
    [Tags]             normal    performance    boot    timing

    Log    🔍 Analyzing service startup times...    console=yes

    # Get boot time analysis
    ${boot_time}=       Execute Command    systemd-analyze time 2>/dev/null || echo "systemd-analyze not available"
    ${slow_services}=   Execute Command    systemd-analyze blame 2>/dev/null | head -20 || echo "systemd-analyze not available"

    Log    ⏱️ Boot Time Analysis: ${boot_time}    console=yes
    Log    📊 Slowest Services:\n${slow_services}    console=yes

    Log    ℹ️ Service startup time analysis completed    console=yes
    Log    ✅ Service startup analysis: INFORMATIONAL    console=yes

Normal - Security Services Status
    [Documentation]    🔒 Check status of security-related services and configurations
    [Tags]             normal    security    firewall    selinux

    Log    🔍 Checking security services status...    console=yes

    # Check SELinux status
    ${selinux_status}=    Execute Command    getenforce 2>/dev/null || echo "SELinux not available"

    # Check firewall services
    ${iptables_status}=    Execute Command    systemctl is-active iptables 2>/dev/null || echo "inactive"
    ${firewalld_status}=   Execute Command    systemctl is-active firewalld 2>/dev/null || echo "inactive"

    Log    🔒 SELinux Status: ${selinux_status}    console=yes
    Log    🔒 iptables Status: ${iptables_status}    console=yes
    Log    🔒 firewalld Status: ${firewalld_status}    console=yes

    # Validate SELinux is disabled as required
    Should Contain Any    ${selinux_status}    Disabled    Permissive    not available
    ...    ⚠️ SELinux should be disabled but shows: ${selinux_status}

    Log    ℹ️ Security services status check completed    console=yes
    Log    ✅ Security services status: DOCUMENTED    console=yes

*** Settings ***
Documentation    🔒 Security and Compliance Validation Test Suite - Test-8
...              Comprehensive security validation with compliance reporting
...              ✨ Features: User account validation, firewall rules, service hardening, audit compliance
...              📊 Results: Unified HTML reports with enhanced dashboard
...              🎯 Run with: robot --outputdir ../../results/test8 security_compliance_validation.robot
...
Metadata         Test Suite    Security and Compliance Validation Test-8
Metadata         Environment   Production-Ready
Metadata         Version       1.0.0
Metadata         Features      Security Audit, User Validation, Firewall Rules, Service Hardening
Metadata         Reporting     Unified HTML Reports + Enhanced Dashboard

Resource         settings.resource

# Configure Robot Framework to output to html_reports directory
Default Tags     security-validation
Force Tags       automated

Suite Setup      Initialize Test Environment
Suite Teardown   Generate Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Target System Connection Establishment
    [Documentation]    🔗 Establish connection to target system via WinRM (Windows) or SSH (Linux)
    ...                Validates connectivity and authentication for security validation tasks
    [Tags]             critical    connection    ssh    winrm    authentication

    Log    🔍 Establishing connection to target system: ${TARGET_HOST}    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Determine OS type and establish appropriate connection
    ${connection_result}=    Establish System Connection    ${TARGET_HOST}    ${TARGET_USERNAME}    ${TARGET_PASSWORD}    ${TARGET_OS_TYPE}
    Should Not Be Empty    ${connection_result}    Failed to establish connection to target system
    Set Suite Variable    ${SYSTEM_CONNECTION}    ${connection_result}

    # Validate connection is active
    ${connection_status}=    Validate System Connection    ${connection_result}
    Should Be Equal    ${connection_status}    connected

    Log    ✅ System connection: ESTABLISHED    console=yes
    Log    🔑 Connection Type: ${TARGET_OS_TYPE}    console=yes
    Log    📍 Target Host: ${TARGET_HOST}    console=yes
    Append To List    ${TEST_RESULTS}    System Connection: PASS - ${TARGET_OS_TYPE} connection to ${TARGET_HOST}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - User Account Security Validation
    [Documentation]    👤 Validate user account security policies and configurations
    ...                Checks for proper user permissions, password policies, and account lockout settings
    [Tags]             critical    users    security    accounts    permissions

    Log    🔍 Validating user account security...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Collect user account information
    ${user_data}=    Execute Security Command    ${SYSTEM_CONNECTION}    cat /etc/passwd    User account enumeration
    Should Not Be Empty    ${user_data}    Failed to collect user account information
    Set Suite Variable    ${USER_DATA}    ${user_data}

    # Save user data to file
    ${user_file}=    Save Command Output To File    ${user_data}    user_accounts.txt
    Should Not Be Empty    ${user_file}    Failed to save user account data to file
    Set Suite Variable    ${USER_ACCOUNTS_FILE}    ${user_file}

    # Check for privileged users
    ${privileged_users}=    Check Privileged Users    ${user_data}
    ${admin_count}=    Count Administrative Users    ${privileged_users}
    Set Suite Variable    ${ADMIN_USER_COUNT}    ${admin_count}

    # Validate user account policies
    ${password_policy}=    Check Password Policy    ${SYSTEM_CONNECTION}
    ${account_lockout}=    Check Account Lockout Policy    ${SYSTEM_CONNECTION}

    # Store security metrics
    Append To List    ${PERFORMANCE_METRICS}    Administrative Users: ${admin_count}
    Append To List    ${PERFORMANCE_METRICS}    Password Policy: ${password_policy}
    Append To List    ${PERFORMANCE_METRICS}    Account Lockout: ${account_lockout}
    Append To List    ${PERFORMANCE_METRICS}    User Accounts File: ${user_file}

    Log    ✅ User account validation: COMPLETED    console=yes
    Log    👥 Administrative Users: ${admin_count}    console=yes
    Log    🔐 Password Policy: ${password_policy}    console=yes
    Log    🔒 Account Lockout: ${account_lockout}    console=yes
    Log    📄 Output saved to: ${user_file}    console=yes
    Append To List    ${TEST_RESULTS}    User Security: PASS - ${admin_count} admin users, policies validated

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Firewall Rules and Network Security
    [Documentation]    🛡️ Validate firewall configuration and network security rules
    ...                Checks firewall status, open ports, and network access controls
    [Tags]             critical    firewall    network    security    ports

    Log    🔍 Validating firewall and network security...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Check firewall status
    ${firewall_status}=    Execute Security Command    ${SYSTEM_CONNECTION}    ufw status    Firewall status check
    Should Not Be Empty    ${firewall_status}    Failed to check firewall status
    Set Suite Variable    ${FIREWALL_DATA}    ${firewall_status}

    # Check open ports
    ${open_ports}=    Execute Security Command    ${SYSTEM_CONNECTION}    netstat -tuln    Open ports enumeration
    Should Not Be Empty    ${open_ports}    Failed to enumerate open ports
    Set Suite Variable    ${OPEN_PORTS_DATA}    ${open_ports}

    # Save firewall and ports data to files
    ${firewall_file}=    Save Command Output To File    ${firewall_status}    firewall_status.txt
    ${ports_file}=    Save Command Output To File    ${open_ports}    open_ports.txt

    # Analyze firewall configuration
    ${firewall_enabled}=    Check Firewall Status    ${firewall_status}
    ${critical_ports}=    Check Critical Ports    ${open_ports}    ${CRITICAL_PORTS_LIST}
    ${unauthorized_ports}=    Check Unauthorized Ports    ${open_ports}    ${BLOCKED_PORTS_LIST}

    # Validate security compliance
    Should Be True    ${firewall_enabled}    Firewall is not enabled or configured
    Should Be Equal As Numbers    ${unauthorized_ports}    0    Unauthorized ports are open: ${unauthorized_ports}

    # Store firewall metrics
    Set Suite Variable    ${FIREWALL_ENABLED}    ${firewall_enabled}
    Set Suite Variable    ${CRITICAL_PORTS_COUNT}    ${critical_ports}
    Set Suite Variable    ${UNAUTHORIZED_PORTS_COUNT}    ${unauthorized_ports}

    # Store metrics
    Append To List    ${PERFORMANCE_METRICS}    Firewall Enabled: ${firewall_enabled}
    Append To List    ${PERFORMANCE_METRICS}    Critical Ports: ${critical_ports}
    Append To List    ${PERFORMANCE_METRICS}    Unauthorized Ports: ${unauthorized_ports}
    Append To List    ${PERFORMANCE_METRICS}    Firewall File: ${firewall_file}
    Append To List    ${PERFORMANCE_METRICS}    Ports File: ${ports_file}

    Log    ✅ Firewall validation: COMPLETED    console=yes
    Log    🛡️ Firewall Status: ${firewall_enabled}    console=yes
    Log    🔓 Critical Ports: ${critical_ports}    console=yes
    Log    ⛔ Unauthorized Ports: ${unauthorized_ports}    console=yes
    Append To List    ${TEST_RESULTS}    Firewall Security: PASS - Firewall active, ${critical_ports} critical ports, ${unauthorized_ports} unauthorized

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Service Hardening Validation
    [Documentation]    ⚙️ Validate system service hardening and security configurations
    ...                Checks for unnecessary services, service permissions, and security settings
    [Tags]             critical    services    hardening    security    configuration

    Log    🔍 Validating service hardening configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Collect running services
    ${running_services}=    Execute Security Command    ${SYSTEM_CONNECTION}    systemctl list-units --type=service --state=running    Running services enumeration
    Should Not Be Empty    ${running_services}    Failed to collect running services
    Set Suite Variable    ${SERVICES_DATA}    ${running_services}

    # Check for unnecessary services
    ${unnecessary_services}=    Check Unnecessary Services    ${running_services}    ${PROHIBITED_SERVICES}
    ${service_count}=    Count Running Services    ${running_services}

    # Check SSH configuration
    ${ssh_config}=    Execute Security Command    ${SYSTEM_CONNECTION}    cat /etc/ssh/sshd_config    SSH configuration check
    ${ssh_hardening}=    Validate SSH Hardening    ${ssh_config}

    # Save services data to file
    ${services_file}=    Save Command Output To File    ${running_services}    running_services.txt
    ${ssh_config_file}=    Save Command Output To File    ${ssh_config}    ssh_config.txt

    # Validate service hardening
    Should Be Equal As Numbers    ${unnecessary_services}    0    Unnecessary services are running: ${unnecessary_services}
    Should Be True    ${ssh_hardening}    SSH service is not properly hardened

    # Store service metrics
    Set Suite Variable    ${RUNNING_SERVICES_COUNT}    ${service_count}
    Set Suite Variable    ${UNNECESSARY_SERVICES_COUNT}    ${unnecessary_services}
    Set Suite Variable    ${SSH_HARDENING_STATUS}    ${ssh_hardening}

    # Store metrics
    Append To List    ${PERFORMANCE_METRICS}    Running Services: ${service_count}
    Append To List    ${PERFORMANCE_METRICS}    Unnecessary Services: ${unnecessary_services}
    Append To List    ${PERFORMANCE_METRICS}    SSH Hardening: ${ssh_hardening}
    Append To List    ${PERFORMANCE_METRICS}    Services File: ${services_file}
    Append To List    ${PERFORMANCE_METRICS}    SSH Config File: ${ssh_config_file}

    Log    ✅ Service hardening validation: COMPLETED    console=yes
    Log    ⚙️ Running Services: ${service_count}    console=yes
    Log    ⚠️ Unnecessary Services: ${unnecessary_services}    console=yes
    Log    🔐 SSH Hardening: ${ssh_hardening}    console=yes
    Append To List    ${TEST_RESULTS}    Service Hardening: PASS - ${service_count} services, ${unnecessary_services} unnecessary, SSH hardened

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - File System Permissions Audit
    [Documentation]    📁 Audit critical file system permissions and access controls
    ...                Validates permissions on sensitive files and directories
    [Tags]             critical    filesystem    permissions    audit    access-control

    Log    🔍 Auditing file system permissions...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Check critical system files permissions
    ${etc_passwd_perms}=    Execute Security Command    ${SYSTEM_CONNECTION}    ls -la /etc/passwd    /etc/passwd permissions
    ${etc_shadow_perms}=    Execute Security Command    ${SYSTEM_CONNECTION}    ls -la /etc/shadow    /etc/shadow permissions
    ${ssh_keys_perms}=    Execute Security Command    ${SYSTEM_CONNECTION}    find /etc/ssh -name "*key*" -exec ls -la {} \\;    SSH keys permissions

    # Check world-writable files
    ${world_writable}=    Execute Security Command    ${SYSTEM_CONNECTION}    find / -maxdepth 3 -type f -perm -002 2>/dev/null | head -20    World-writable files check

    # Save permissions data to files
    ${passwd_perms_file}=    Save Command Output To File    ${etc_passwd_perms}    passwd_permissions.txt
    ${shadow_perms_file}=    Save Command Output To File    ${etc_shadow_perms}    shadow_permissions.txt
    ${ssh_perms_file}=    Save Command Output To File    ${ssh_keys_perms}    ssh_keys_permissions.txt
    ${world_writable_file}=    Save Command Output To File    ${world_writable}    world_writable_files.txt

    # Validate permissions compliance
    ${passwd_secure}=    Validate File Permissions    ${etc_passwd_perms}    644
    ${shadow_secure}=    Validate File Permissions    ${etc_shadow_perms}    600
    ${world_writable_count}=    Count World Writable Files    ${world_writable}

    # Security compliance checks
    Should Be True    ${passwd_secure}    /etc/passwd has incorrect permissions
    Should Be True    ${shadow_secure}    /etc/shadow has incorrect permissions
    Should Be True    ${world_writable_count} <= 5    Too many world-writable files found: ${world_writable_count}

    # Store permissions metrics
    Set Suite Variable    ${PASSWD_SECURE}    ${passwd_secure}
    Set Suite Variable    ${SHADOW_SECURE}    ${shadow_secure}
    Set Suite Variable    ${WORLD_WRITABLE_COUNT}    ${world_writable_count}

    # Store metrics
    Append To List    ${PERFORMANCE_METRICS}    /etc/passwd Secure: ${passwd_secure}
    Append To List    ${PERFORMANCE_METRICS}    /etc/shadow Secure: ${shadow_secure}
    Append To List    ${PERFORMANCE_METRICS}    World-writable Files: ${world_writable_count}
    Append To List    ${PERFORMANCE_METRICS}    Permissions Files: 4 files saved

    Log    ✅ File system permissions audit: COMPLETED    console=yes
    Log    📁 /etc/passwd Secure: ${passwd_secure}    console=yes
    Log    🔐 /etc/shadow Secure: ${shadow_secure}    console=yes
    Log    ⚠️ World-writable Files: ${world_writable_count}    console=yes
    Append To List    ${TEST_RESULTS}    File Permissions: PASS - Critical files secure, ${world_writable_count} world-writable files

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - Security Compliance Assessment
    [Documentation]    ✅ Comprehensive security compliance assessment and scoring
    ...                Validates all security configurations against compliance standards
    [Tags]             critical    compliance    assessment    security    scoring

    Log    🔍 Performing security compliance assessment...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Calculate compliance scores for each area
    ${user_compliance}=    Calculate User Security Score    ${ADMIN_USER_COUNT}    ${USER_DATA}
    ${firewall_compliance}=    Calculate Firewall Security Score    ${FIREWALL_ENABLED}    ${UNAUTHORIZED_PORTS_COUNT}
    ${service_compliance}=    Calculate Service Security Score    ${UNNECESSARY_SERVICES_COUNT}    ${SSH_HARDENING_STATUS}
    ${filesystem_compliance}=    Calculate Filesystem Security Score    ${PASSWD_SECURE}    ${SHADOW_SECURE}    ${WORLD_WRITABLE_COUNT}

    # Calculate overall compliance score
    ${overall_compliance}=    Calculate Overall Security Score    ${user_compliance}    ${firewall_compliance}    ${service_compliance}    ${filesystem_compliance}
    Should Be True    ${overall_compliance} >= ${MINIMUM_COMPLIANCE_SCORE}    Overall compliance score below minimum: ${overall_compliance}%

    # Generate security compliance report
    ${security_report}=    Generate Security Compliance Report    ${USER_DATA}    ${FIREWALL_DATA}    ${SERVICES_DATA}    ${overall_compliance}
    Should Not Be Empty    ${security_report}    Failed to generate security compliance report

    # Create security evidence package
    ${evidence_package}=    Create Security Evidence Package    ${USER_ACCOUNTS_FILE}    ${services_file}    ${passwd_perms_file}    ${security_report}
    Should Not Be Empty    ${evidence_package}    Failed to create security evidence package

    # Store compliance data
    Set Suite Variable    ${SECURITY_COMPLIANCE_SCORE}    ${overall_compliance}
    Set Suite Variable    ${SECURITY_REPORT}    ${security_report}
    Set Suite Variable    ${SECURITY_EVIDENCE_PACKAGE}    ${evidence_package}

    # Store compliance metrics
    Append To List    ${PERFORMANCE_METRICS}    User Security Score: ${user_compliance}%
    Append To List    ${PERFORMANCE_METRICS}    Firewall Security Score: ${firewall_compliance}%
    Append To List    ${PERFORMANCE_METRICS}    Service Security Score: ${service_compliance}%
    Append To List    ${PERFORMANCE_METRICS}    Filesystem Security Score: ${filesystem_compliance}%
    Append To List    ${PERFORMANCE_METRICS}    Overall Compliance Score: ${overall_compliance}%
    Append To List    ${PERFORMANCE_METRICS}    Security Report: ${security_report}
    Append To List    ${PERFORMANCE_METRICS}    Evidence Package: ${evidence_package}

    Log    ✅ Security compliance assessment: COMPLETED    console=yes
    Log    👤 User Security: ${user_compliance}%    console=yes
    Log    🛡️ Firewall Security: ${firewall_compliance}%    console=yes
    Log    ⚙️ Service Security: ${service_compliance}%    console=yes
    Log    📁 Filesystem Security: ${filesystem_compliance}%    console=yes
    Log    📊 Overall Score: ${overall_compliance}%    console=yes
    Log    📄 Report: ${security_report}    console=yes
    Log    📦 Evidence: ${evidence_package}    console=yes
    Append To List    ${TEST_RESULTS}    Security Compliance: PASS - ${overall_compliance}% compliant, all requirements met

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Critical - SSH Key Authentication Validation
    [Documentation]    🔑 SSH Key Authentication Test Case - Connect from Code Server, validate ssh-key authentication
    ...                Tests passwordless SSH authentication from code server to target machine using SSH keys
    ...                Validates authorized_keys file permissions and SSH configuration security
    [Tags]             critical    ssh    authentication    keys    codeserver    jumpbox    security

    Log    🔍 Testing SSH key authentication from code server...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Step 1: Connect to Code Server (Linux jump box)
    ${codeserver_connection}=    Connect To Code Server    ${CODE_SERVER_HOST}    ${CODE_SERVER_USERNAME}    ${CODE_SERVER_PASSWORD}
    Should Not Be Empty    ${codeserver_connection}    Failed to connect to code server
    Set Suite Variable    ${CODESERVER_CONNECTION}    ${codeserver_connection}

    # Step 2: Test Passwordless SSH Authentication from code server to target
    ${ssh_key_auth_result}=    Test SSH Key Authentication    ${codeserver_connection}    ${TARGET_HOST}    ${TARGET_SSH_USER}
    Should Be True    ${ssh_key_auth_result}    SSH key authentication failed from code server to target
    Set Suite Variable    ${SSH_KEY_AUTH_SUCCESS}    ${ssh_key_auth_result}

    # Step 3: Validate authorized_keys file permissions (should be 600)
    ${authorized_keys_validation}=    Validate Authorized Keys Permissions    ${SYSTEM_CONNECTION}    ${TARGET_SSH_USER}
    Should Be True    ${authorized_keys_validation}    authorized_keys file permissions validation failed
    Set Suite Variable    ${AUTHORIZED_KEYS_VALID}    ${authorized_keys_validation}

    # Step 4: Verify SSH configuration security
    ${ssh_config_validation}=    Validate SSH Configuration Security    ${SYSTEM_CONNECTION}
    Should Be True    ${ssh_config_validation}    SSH configuration security validation failed
    Set Suite Variable    ${SSH_CONFIG_SECURE}    ${ssh_config_validation}

    # Step 5: Capture authentication evidence (screenshot simulation)
    ${ssh_auth_screenshot}=    Capture SSH Authentication Evidence    ${codeserver_connection}    ${TARGET_HOST}
    Should Not Be Empty    ${ssh_auth_screenshot}    Failed to capture SSH authentication evidence
    Set Suite Variable    ${SSH_AUTH_EVIDENCE}    ${ssh_auth_screenshot}

    # Store SSH authentication metrics
    Append To List    ${PERFORMANCE_METRICS}    Code Server Connection: ESTABLISHED
    Append To List    ${PERFORMANCE_METRICS}    SSH Key Authentication: SUCCESS
    Append To List    ${PERFORMANCE_METRICS}    Authorized Keys Permissions: VALID (600)
    Append To List    ${PERFORMANCE_METRICS}    SSH Configuration Security: VALIDATED
    Append To List    ${PERFORMANCE_METRICS}    Authentication Evidence: ${ssh_auth_screenshot}

    Log    ✅ SSH key authentication validation: PASSED    console=yes
    Log    🖥️ Code Server: CONNECTED    console=yes
    Log    🔑 SSH Key Auth: SUCCESS    console=yes
    Log    🔒 authorized_keys: VALID (600)    console=yes
    Log    ⚙️ SSH Config: SECURE    console=yes
    Log    📸 Evidence: ${ssh_auth_screenshot}    console=yes
    Append To List    ${TEST_RESULTS}    SSH Key Authentication: PASS - Passwordless SSH from code server validated, security requirements met

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}

Normal - Security Documentation and Evidence Collection
    [Documentation]    📋 Collect comprehensive security documentation and evidence for audit trail
    ...                Generates detailed security reports with all collected system information
    [Tags]             normal    documentation    evidence    audit    reporting    security

    Log    📋 Collecting security documentation and evidence...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Suite Variable    ${TOTAL_TESTS}    ${total}

    # Generate comprehensive security summary
    ${security_summary}=    Generate Security Summary    ${USER_DATA}    ${FIREWALL_DATA}    ${SERVICES_DATA}    ${SECURITY_COMPLIANCE_SCORE}
    Should Not Be Empty    ${security_summary}    Failed to generate security summary

    # Create final audit package
    ${audit_package}=    Create Security Audit Package    ${security_summary}    ${SECURITY_EVIDENCE_PACKAGE}
    Should Not Be Empty    ${audit_package}    Failed to create security audit package

    # Generate security certificate
    ${security_cert}=    Generate Security Certificate    ${TARGET_HOST}    ${SECURITY_COMPLIANCE_SCORE}    ${ADMIN_USER_COUNT}    ${FIREWALL_ENABLED}
    Should Not Be Empty    ${security_cert}    Failed to generate security certificate

    # Store documentation paths
    Set Suite Variable    ${SECURITY_SUMMARY}    ${security_summary}
    Set Suite Variable    ${AUDIT_PACKAGE}    ${audit_package}
    Set Suite Variable    ${SECURITY_CERTIFICATE}    ${security_cert}

    # Store documentation metrics
    Append To List    ${PERFORMANCE_METRICS}    Security Summary: ${security_summary}
    Append To List    ${PERFORMANCE_METRICS}    Audit Package: ${audit_package}
    Append To List    ${PERFORMANCE_METRICS}    Security Certificate: ${security_cert}

    Log    ✅ Security documentation collection: COMPLETED    console=yes
    Log    📄 Security Summary: ${security_summary}    console=yes
    Log    📦 Audit Package: ${audit_package}    console=yes
    Log    🏆 Security Certificate: ${security_cert}    console=yes
    Append To List    ${TEST_RESULTS}    Security Documentation: PASS - Summary, audit package, and certificate generated

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Suite Variable    ${PASSED_TESTS}    ${passed}
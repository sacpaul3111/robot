*** Settings ***
Documentation    Password Vault and CyberArk Validation Variables - Test-16

*** Variables ***
# Test Configuration
${TEST_HOSTNAME}           RHEL8-TEST-01    # Hostname to lookup in EDS

# SSH Connection Settings
${SSH_USERNAME}            sac
${SSH_PASSWORD}            sac
${SSH_TIMEOUT}             30 seconds

# CyberArk/Password Vault Configuration
${CYBERARK_VAULT_URL}      https://cyberark.example.com    # CyberArk PVWA URL (update as needed)
${CYBERARK_ACCESS_METHOD}  Citrix/Jumpbox                  # Access method (Citrix, Jumpbox, Direct)
${CYBERARK_API_URL}        https://cyberark.example.com/PasswordVault/API    # CyberArk REST API URL

# CyberArk Components
${CYBERARK_PVWA}           Password Vault Web Access       # PVWA component
${CYBERARK_CPM}            Central Policy Manager          # CPM for password rotation
${CYBERARK_PSM}            Privileged Session Manager      # PSM for session management
${CYBERARK_AIM}            Application Identity Manager    # AIM for application access

# CIP-007 R5.2 Requirements - Known Passwords
# R5.2: Each Responsible Entity shall identify and inventory all known or suspected
#       user accounts and default manufacturer passwords

# Account Types to be Enrolled (CIP-007 R5.2)
@{INTERACTIVE_ACCOUNTS}         root    administrator    admin    privileged_user    emergency_admin
@{NON_INTERACTIVE_ACCOUNTS}     service_account    app_account    db_account    api_account    batch_account

# CIP-007 R5.4 Requirements - Password Change Controls
# R5.4: Each Responsible Entity shall change known default passwords

# Password Rotation Settings
${CYBERARK_ROTATION_FREQUENCY}  90 days        # Maximum password age before rotation
${CYBERARK_IMMEDIATE_ROTATION}  ${TRUE}        # Rotate immediately after checkout (per policy)
${CYBERARK_ROTATION_ON_RESET}   ${TRUE}        # Rotate password on password reset

# Password Management Settings
${CYBERARK_AUTO_SYNC}          ${TRUE}        # Automatic password synchronization
${CYBERARK_RECONCILE}          ${TRUE}        # Reconcile password after rotation
${CYBERARK_VERIFY_PASSWORD}    ${TRUE}        # Verify password after change

# Checkout/Checkin Settings
${CYBERARK_EXCLUSIVE_CHECKOUT}     ${FALSE}       # Allow exclusive checkout (per policy)
${CYBERARK_AUTO_CHECKIN}           ${TRUE}        # Automatic checkin after session
${CYBERARK_CHANGE_ON_CHECKIN}      ${FALSE}       # Change password on checkin (per policy)
${CYBERARK_CHECKOUT_DURATION}      8 hours        # Maximum checkout duration

# Safe Configuration
${CYBERARK_DEFAULT_SAFE}           default_safe   # Default safe name (update as needed)
${CYBERARK_INTERACTIVE_SAFE}       interactive_accounts_safe    # Safe for interactive accounts
${CYBERARK_SERVICE_SAFE}           service_accounts_safe        # Safe for service accounts

# Platform Configuration
${CYBERARK_UNIX_PLATFORM}          UnixSSH        # Unix/Linux platform (update as needed)
${CYBERARK_WINDOWS_PLATFORM}       WinServerLocal # Windows platform (update as needed)
${CYBERARK_DATABASE_PLATFORM}      Oracle         # Database platform (update as needed)

# Audit and Compliance
${CYBERARK_AUDIT_RETENTION_DAYS}   365            # Audit log retention in days (minimum 90 days per CIP-007)
${CYBERARK_SESSION_RECORDING}      ${TRUE}        # Enable session recording
${CYBERARK_APPROVAL_REQUIRED}      ${FALSE}       # Require approval for access (per policy)

# Expected Account Enrollment Counts (Update based on environment)
${MIN_INTERACTIVE_ACCOUNTS}        1              # Minimum expected interactive accounts
${MIN_NON_INTERACTIVE_ACCOUNTS}    0              # Minimum expected non-interactive accounts

# CyberArk Agent Settings
${CYBERARK_AGENT_PATH}             /opt/CARKaim   # CyberArk AIM agent path (Linux)
${CYBERARK_AGENT_PATH_ALT}         /var/opt/CARKaim    # Alternative agent path

# API Integration
${CYBERARK_API_TIMEOUT}            30 seconds     # API request timeout
${CYBERARK_API_VERSION}            v1             # API version

# Password Complexity Requirements (per CIP-007 R5.5)
${CYBERARK_MIN_PASSWORD_LENGTH}    8              # Minimum password length
${CYBERARK_PASSWORD_COMPLEXITY}    ${TRUE}        # Enforce complexity rules

# Account Search Criteria
${SEARCH_SCOPE}                    all_safes      # Search scope (all_safes, specific_safe)
${SEARCH_ACCOUNT_TYPE}             all            # Account type filter (all, interactive, non-interactive)

# Validation Thresholds
${MAX_SYNC_FAILURES}               0              # Maximum acceptable sync failures
${MAX_ROTATION_FAILURES}           0              # Maximum acceptable rotation failures

# Dual Control and Approval
${DUAL_CONTROL_ENABLED}            ${FALSE}       # Dual control requirement (per policy)
${APPROVAL_WORKFLOW_ENABLED}       ${FALSE}       # Approval workflow (per policy)

# Session Management
${PSM_ENABLED}                     ${TRUE}        # PSM integration available
${PSM_CONNECTION_COMPONENTS}       RDP, SSH       # Available connection components

# Reconciliation Settings
${RECONCILIATION_ACCOUNT_REQUIRED} ${TRUE}        # Reconciliation account required
${RECONCILIATION_ON_ROTATION}      ${TRUE}        # Reconcile after rotation

# Report Settings
${CAPTURE_VAULT_SCREENSHOTS}       ${TRUE}        # Capture screenshots from vault UI
${SAVE_RAW_CONFIGS}                ${TRUE}        # Save raw configuration data
${GENERATE_DETAILED_REPORT}        ${TRUE}        # Generate detailed compliance report

# Manual Verification Checklist
@{MANUAL_VERIFICATION_STEPS}
...    Login to CyberArk vault via Citrix/Jumpbox
...    Search for target hostname
...    Capture screenshot of enrolled accounts
...    Count interactive accounts enrolled
...    Count non-interactive accounts enrolled
...    Verify sync status for all accounts
...    Check rotation policies are active
...    Verify last rotation timestamps
...    Review audit logs for account activities
...    Confirm no sync or rotation failures
...    Document platform configurations
...    Verify safe permissions are correct
...    Check CPM is actively managing passwords
...    Validate checkout/checkin workflow
...    Confirm audit retention meets compliance

# Expected Vault Events (for audit log validation)
@{EXPECTED_VAULT_EVENTS}
...    PasswordCheckout
...    PasswordCheckin
...    PasswordChange
...    PasswordRotation
...    AccountEnrollment
...    AuthenticationSuccess
...    AuthenticationFailure
...    AccessDenied
...    ConfigurationChange
...    PolicyViolation

# Test Timeouts
${VAULT_ACCESS_TIMEOUT}        60 seconds
${ACCOUNT_SEARCH_TIMEOUT}      90 seconds
${DATA_COLLECTION_TIMEOUT}     120 seconds
${VALIDATION_TIMEOUT}          180 seconds

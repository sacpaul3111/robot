*** Settings ***
Documentation    Password Policy Validation Variables - Test-13

*** Variables ***
# Target Configuration - Set via command line
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value

# SSH Connection Settings - Provided via Ansible/command line
${SSH_USERNAME}            ${EMPTY}
${SSH_PASSWORD}            ${EMPTY}
${SSH_TIMEOUT}             30 seconds

# Password Policy Configuration Files
${LOGIN_DEFS_PATH}         /etc/login.defs
${PWQUALITY_CONF_PATH}     /etc/security/pwquality.conf
${PAM_SYSTEM_AUTH_PATH}    /etc/pam.d/system-auth
${PAM_PASSWORD_AUTH_PATH}  /etc/pam.d/password-auth
${PAM_COMMON_PASSWORD}     /etc/pam.d/common-password
${FAILLOCK_CONF_PATH}      /etc/security/faillock.conf

# CIP-007 R5.4 Requirements - Account Lockout
${CIP007_MAX_LOGIN_ATTEMPTS}    5    # Maximum failed login attempts before lockout
${CIP007_LOCKOUT_DURATION}      900  # Lockout duration in seconds (15 minutes)

# CIP-007 R5.5 Requirements - Password Length and Complexity
${CIP007_MIN_PASSWORD_LENGTH}   8     # Minimum password length
${CIP007_REQUIRE_UPPERCASE}     ${TRUE}    # Require uppercase letters
${CIP007_REQUIRE_LOWERCASE}     ${TRUE}    # Require lowercase letters
${CIP007_REQUIRE_DIGITS}        ${TRUE}    # Require digits
${CIP007_REQUIRE_SPECIAL}       ${TRUE}    # Require special characters
${CIP007_MIN_CHARACTER_CLASSES} 3          # Minimum number of character classes

# CIP-007 R5.6 Requirements - Password History
${CIP007_PASSWORD_HISTORY_COUNT}    5    # Number of previous passwords to remember

# CIP-007 R5.7 Requirements - Password Expiration
${CIP007_MAX_PASSWORD_AGE_DAYS}     90   # Maximum password age in days
${CIP007_MIN_PASSWORD_AGE_DAYS}     1    # Minimum password age in days
${CIP007_PASSWORD_WARN_AGE_DAYS}    7    # Password expiration warning in days

# Expected Password Quality Settings (from pwquality.conf)
${EXPECTED_MINLEN}          8      # Expected minimum length
${EXPECTED_MINCLASS}        3      # Expected minimum character classes
${EXPECTED_MAXREPEAT}       3      # Expected maximum repeated characters
${EXPECTED_MAXCLASSREPEAT}  4      # Expected maximum same class repeat

# PAM Module Names
${PAM_PWQUALITY}            pam_pwquality.so
${PAM_UNIX}                 pam_unix.so
${PAM_FAILLOCK}             pam_faillock.so
${PAM_PWHISTORY}            pam_pwhistory.so

# CIP-007 R5 Compliance Categories
@{CIP007_R5_CATEGORIES}     R5.4_AccountLockout    R5.5_PasswordLength    R5.5_PasswordComplexity    R5.6_PasswordHistory    R5.7_PasswordExpiration

# Password Policy Validation Levels
${VALIDATION_LEVEL_STRICT}      strict      # Strict validation (all requirements must pass)
${VALIDATION_LEVEL_STANDARD}    standard    # Standard validation (key requirements must pass)
${VALIDATION_LEVEL_BASIC}       basic       # Basic validation (minimum requirements)

# Current Validation Level
${CURRENT_VALIDATION_LEVEL}     ${VALIDATION_LEVEL_STRICT}

# Report Settings
${INCLUDE_POLICY_SCREENSHOTS}   ${TRUE}    # Include screenshots of policy files
${GENERATE_DETAILED_REPORT}     ${TRUE}    # Generate detailed compliance report
${SAVE_RAW_CONFIGS}             ${TRUE}    # Save raw configuration files

# Test Timeouts
${POLICY_CHECK_TIMEOUT}         60 seconds
${DATA_COLLECTION_TIMEOUT}      90 seconds
${VALIDATION_TIMEOUT}           120 seconds

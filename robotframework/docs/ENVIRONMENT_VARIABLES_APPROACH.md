# Environment Variables Approach - Updated Architecture

## Overview

The Robot Framework test suite has been updated to use **pure environment variables** for all credentials and configuration. No credentials are passed via Ansible playbook parameters or Robot Framework command-line arguments.

---

## 🔄 How It Works

### Architecture Flow

```
1. Source credentials.env
   ↓
2. Environment variables loaded into shell
   ↓
3. Execute ./run_tests.sh (or ansible-playbook)
   ↓
4. Ansible playbook reads environment variables
   ↓
5. Ansible passes environment to Robot Framework process
   ↓
6. Robot Framework tests read environment variables directly
   ↓
7. Tests use appropriate credentials based on test requirements
```

---

## 📋 Updated Execution Methods

### Method 1: Using Wrapper Script (Recommended)

```bash
# 1. Source credentials (automatic with wrapper)
./run_tests.sh alhxvdvitap01

# The wrapper script:
# - Automatically sources credentials.env
# - Passes all environment variables to Ansible
# - Ansible passes them to Robot Framework
# - Robot Framework uses them as needed
```

### Method 2: Manual Execution

```bash
# 1. Source credentials manually
source credentials.env

# 2. Verify credentials loaded
echo $SSH_USERNAME
env | grep -E "(SSH|VCENTER|SPLUNK)"

# 3. Run Ansible playbook (NO credential parameters needed)
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01

# That's it! No --variable SSH_USERNAME or SSH_PASSWORD needed
```

---

## 🔧 What Changed

### Before (Old Approach - Removed):

```yaml
# OLD: Ansible playbook passed credentials as Robot variables
command: >
  python3 -m robot
  --variable TARGET_HOSTNAME:{{ target_hostname }}
  --variable SSH_USERNAME:{{ ssh_username }}        # ❌ REMOVED
  --variable SSH_PASSWORD:{{ ssh_password }}        # ❌ REMOVED
  --variable VCENTER_USERNAME:{{ vcenter_username }}  # ❌ REMOVED
  --variable VCENTER_PASSWORD:{{ vcenter_password }}  # ❌ REMOVED
  # ... all credentials as --variable parameters
```

**Problems with old approach:**
- ❌ Credentials visible in process list (`ps aux`)
- ❌ Credentials in Ansible logs
- ❌ Long command lines
- ❌ Required updating playbook for each new credential

---

### After (New Approach - Current):

```yaml
# NEW: Ansible passes environment variables to Robot process
command: >
  python3 -m robot
  --variable TARGET_HOSTNAME:{{ target_hostname }}
  --outputdir results/{{ test_suite_name }}
  {{ robot_file }}
environment:
  # All credentials passed as environment variables
  SSH_USERNAME: "{{ lookup('env', 'SSH_USERNAME') }}"
  SSH_PASSWORD: "{{ lookup('env', 'SSH_PASSWORD') }}"
  VCENTER_USERNAME: "{{ lookup('env', 'VCENTER_USERNAME') }}"
  VCENTER_PASSWORD: "{{ lookup('env', 'VCENTER_PASSWORD') }}"
  # ... all other credentials
```

**Benefits of new approach:**
- ✅ Credentials NOT visible in process list
- ✅ Credentials NOT in Ansible logs (unless verbose mode)
- ✅ Cleaner command line
- ✅ Easy to add new credentials (just add to credentials.env)
- ✅ Robot Framework reads directly from environment
- ✅ More secure

---

## 🔐 Security Improvements

### 1. Process List Security

**Before:**
```bash
ps aux | grep robot
# Shows: python3 -m robot --variable SSH_PASSWORD:MySecretPass123! ...
# ❌ PASSWORD VISIBLE IN PROCESS LIST!
```

**After:**
```bash
ps aux | grep robot
# Shows: python3 -m robot --variable TARGET_HOSTNAME:server01 --outputdir results/test3
# ✅ NO PASSWORDS VISIBLE - they're in environment
```

### 2. Log Security

**Before:**
Credentials appear in Ansible verbose logs

**After:**
Credentials in environment, not in command parameters

---

## 📝 How Robot Framework Tests Use Environment Variables

Robot Framework tests automatically access environment variables using the `%{VAR_NAME}` syntax or via OperatingSystem library.

### Example in Robot Framework Test:

```robot
*** Settings ***
Library    OperatingSystem

*** Variables ***
# Read from environment variables (set via Ansible environment block)
${SSH_USERNAME}      %{SSH_USERNAME}
${SSH_PASSWORD}      %{SSH_PASSWORD}
${VCENTER_USERNAME}  %{VCENTER_USERNAME=}    # = makes it optional
${VCENTER_PASSWORD}  %{VCENTER_PASSWORD=}

*** Test Cases ***
Test SSH Connection
    # SSH_USERNAME and SSH_PASSWORD are automatically available
    Connect To Server    ${SSH_USERNAME}    ${SSH_PASSWORD}
```

**Robot Framework automatically:**
1. Reads environment variables when using `%{VAR_NAME}` syntax
2. Makes them available as Robot variables
3. Uses them in test execution

---

## 🎯 Environment Variables by Test

Each test only uses the environment variables it needs:

| Test | Required Env Vars |
|------|-------------------|
| Test 3 - Network | `SSH_USERNAME`, `SSH_PASSWORD` |
| Test 4 - VM | `SSH_USERNAME`, `SSH_PASSWORD`, `VCENTER_USERNAME`, `VCENTER_PASSWORD`, `VCENTER_SERVER` |
| Test 5 - Disk Space | `SSH_USERNAME`, `SSH_PASSWORD` |
| Test 7 - Time Config | `SSH_USERNAME`, `SSH_PASSWORD`, `NTP_SERVER` |
| Test 9 - Datastore | `SSH_USERNAME`, `SSH_PASSWORD`, `VCENTER_USERNAME`, `VCENTER_PASSWORD`, `VCENTER_SERVER` |
| Test 11 - Services | `SSH_USERNAME`, `SSH_PASSWORD` |
| Test 14 - Logging | `SSH_USERNAME`, `SSH_PASSWORD`, `SPLUNK_USERNAME`, `SPLUNK_PASSWORD`, `SPLUNK_SERVER` |
| Test 15 - Backup | `SSH_USERNAME`, `SSH_PASSWORD`, `VCENTER_USERNAME`, `VCENTER_PASSWORD` |
| Test 16 - Password Vault | `SSH_USERNAME`, `SSH_PASSWORD`, `CYBERARK_USERNAME`, `CYBERARK_PASSWORD`, `CYBERARK_SERVER` |
| Test 17 - Mail | `SSH_USERNAME`, `SSH_PASSWORD`, `SMTP_SERVER`, `TEST_EMAIL_RECIPIENT` |
| Test 18 - Patch/RSA | `SSH_USERNAME`, `SSH_PASSWORD`, `RSA_SERVER` |
| Test 20 - Antivirus | `SSH_USERNAME`, `SSH_PASSWORD` |
| Test 22 - Event Logs | `SSH_USERNAME`, `SSH_PASSWORD` |

**Tests automatically skip credentials they don't need** - no configuration required!

---

## 📂 Complete Environment Variables List

From `credentials.env`:

```bash
# Core SSH (Required for ALL tests)
export SSH_USERNAME="admin"
export SSH_PASSWORD="SecurePassword123"

# vCenter (Test 4, 9, 15)
export VCENTER_USERNAME="vcenter_admin@vsphere.local"
export VCENTER_PASSWORD="vCenterPass456"
export VCENTER_SERVER="vcenter.domain.com"

# Splunk (Test 14)
export SPLUNK_USERNAME="splunk_admin"
export SPLUNK_PASSWORD="SplunkPass789"
export SPLUNK_SERVER="splunk.domain.com"
export SPLUNK_PORT="8089"

# CyberArk (Test 16)
export CYBERARK_USERNAME="vault_admin"
export CYBERARK_PASSWORD="CyberArkPass012"
export CYBERARK_SERVER="cyberark.domain.com"
export CYBERARK_SAFE="BES_Cyber_Assets"

# Tanium (Test 21)
export TANIUM_USERNAME="tanium_admin"
export TANIUM_PASSWORD="TaniumPass345"
export TANIUM_SERVER="tanium.domain.com"
export TANIUM_PORT="443"

# Ansible Tower (Test 24)
export ANSIBLE_TOWER_USERNAME="tower_admin"
export ANSIBLE_TOWER_PASSWORD="TowerPass678"
export ANSIBLE_TOWER_SERVER="tower.domain.com"
export ANSIBLE_TOWER_PORT="443"

# RSA (Test 18)
export RSA_SERVER="rsa.domain.com"
export RSA_PORT="5500"

# SMTP (Test 17)
export SMTP_SERVER="mail.domain.com"
export SMTP_PORT="25"
export TEST_EMAIL_RECIPIENT="admin@domain.com"

# NTP (Test 7)
export NTP_SERVER="ntpx.domain.com"

# EDS File
export EDS_FILE_PATH="/path/to/eds_file.xlsx"
export EDS_SHEET_NAME="Server_Inventory"

# Robot Framework Settings
export ROBOT_TIMEOUT="300"
export ROBOT_LOG_LEVEL="INFO"
export ROBOT_OUTPUT_DIR="results"
```

---

## ✅ Verification Steps

### 1. Verify Environment Variables Are Set

```bash
# Source credentials
source credentials.env

# Check critical variables
echo "SSH_USERNAME: $SSH_USERNAME"
echo "VCENTER_USERNAME: $VCENTER_USERNAME"
echo "SPLUNK_USERNAME: $SPLUNK_USERNAME"

# List all Robot-related variables
env | grep -E "(SSH|VCENTER|SPLUNK|CYBERARK|TANIUM|TOWER|RSA|SMTP|NTP|ROBOT)" | sort
```

### 2. Test Ansible Can Read Variables

```bash
# Test Ansible environment lookup
ansible localhost -m debug -a "msg={{ lookup('env', 'SSH_USERNAME') }}"

# Should output your SSH username
```

### 3. Test Robot Framework Can Read Variables

```bash
# Create test file
cat > test_env.robot << 'EOF'
*** Settings ***
Library    OperatingSystem

*** Test Cases ***
Test Environment Variables
    ${username}=    Get Environment Variable    SSH_USERNAME
    Log    SSH Username: ${username}
    Should Not Be Empty    ${username}
EOF

# Run test
python3 -m robot test_env.robot

# Clean up
rm test_env.robot
```

---

## 🚀 Migration from Old Approach

If you have existing test code using Robot variables:

### Old Code:
```robot
*** Settings ***
# Variables passed via --variable SSH_USERNAME:value
Library    SSHLibrary

*** Test Cases ***
Connect To Server
    Open Connection    ${TARGET_HOSTNAME}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
```

### New Code (Works with both approaches):
```robot
*** Settings ***
Library    SSHLibrary
Library    OperatingSystem

*** Variables ***
# Read from environment if not provided as Robot variable
${SSH_USERNAME}      ${SSH_USERNAME}${EMPTY}%{SSH_USERNAME}
${SSH_PASSWORD}      ${SSH_PASSWORD}${EMPTY}%{SSH_PASSWORD}

*** Test Cases ***
Connect To Server
    Open Connection    ${TARGET_HOSTNAME}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
```

**Note:** Most tests already use environment variables, so no changes needed!

---

## 🔧 Troubleshooting

### Issue 1: "SSH credentials required!" Error

**Cause:** Environment variables not set

**Solution:**
```bash
# Option 1: Use wrapper script (automatic)
./run_tests.sh alhxvdvitap01

# Option 2: Source credentials manually
source credentials.env
ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=alhxvdvitap01
```

---

### Issue 2: Environment Variables Not Available in Robot

**Cause:** Variables not passed through Ansible environment block

**Check:** Verify variable is in `execute_test_suite.yml` environment block

**Solution:**
```yaml
# Add to ansible_playbooks/execute_test_suite.yml
environment:
  YOUR_NEW_VAR: "{{ lookup('env', 'YOUR_NEW_VAR') }}"
```

---

### Issue 3: Variables Lost Between Commands

**Cause:** Environment variables are session-specific

**Solution:**
```bash
# Source credentials before EACH execution
source credentials.env
ansible-playbook run_tests.yml -e TargetHostname=server01

# OR add to shell profile (not recommended for passwords)
# OR use wrapper script (recommended)
```

---

## 📊 Comparison: Old vs New

| Aspect | Old Approach | New Approach |
|--------|-------------|--------------|
| **Security** | ❌ Credentials in process list | ✅ Hidden in environment |
| **Logs** | ❌ Credentials in verbose logs | ✅ Credentials not logged |
| **Flexibility** | ❌ Edit playbook for new creds | ✅ Add to credentials.env |
| **Command Length** | ❌ Very long commands | ✅ Short, clean commands |
| **Maintenance** | ❌ Update multiple files | ✅ Update one file |
| **Best Practice** | ❌ Against security guidelines | ✅ Industry standard |

---

## 🎯 Benefits Summary

### For Security:
- ✅ Credentials not visible in `ps aux` output
- ✅ Credentials not in Ansible logs (unless debug mode)
- ✅ Environment variables are process-isolated
- ✅ Follows security best practices

### For Developers:
- ✅ Simpler playbook code
- ✅ No need to update playbook for new credentials
- ✅ Just add to credentials.env
- ✅ Tests automatically use available credentials

### For Operations:
- ✅ Easier to integrate with CI/CD
- ✅ Works with secret management tools
- ✅ Consistent with Linux standards
- ✅ Easier debugging (no credential clutter)

---

## 🔗 Integration Examples

### Jenkins:

```groovy
pipeline {
    environment {
        CREDENTIALS = credentials('robot-credentials-file')
    }
    stages {
        stage('Test') {
            steps {
                sh '''
                    source $CREDENTIALS
                    ./run_tests.sh ${TARGET_HOSTNAME}
                '''
            }
        }
    }
}
```

### GitLab CI:

```yaml
test:
  variables:
    CREDENTIALS_FILE: /etc/robot_credentials.env
  script:
    - source $CREDENTIALS_FILE
    - ./run_tests.sh $TARGET_HOSTNAME
```

### Itential:

```python
# Itential provides environment variables
# No credentials in workflow code!
ansible_job = {
    'playbook': 'run_tests.yml',
    'extra_vars': {
        'TargetHostname': target_hostname
    },
    'environment': itential.get_credentials('robot_framework')
}
```

---

## 📚 Related Documentation

- [CREDENTIALS_SETUP.md](../CREDENTIALS_SETUP.md) - How to set up credentials.env
- [QUICKSTART.md](../QUICKSTART.md) - Quick start guide
- [Test Explanations](test_explanations/README.md) - Individual test documentation

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Architecture:** Environment Variables Only - No credential parameters in playbook

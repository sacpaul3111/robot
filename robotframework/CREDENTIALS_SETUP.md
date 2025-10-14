# Credentials Setup Guide

## Overview

This guide explains how to securely configure credentials for the Robot Framework Test Suite.

---

## 🔒 Security First

### ⚠️ CRITICAL: Never Commit Credentials to Git

**Files that are safe to commit:**
- ✅ `credentials.env.example` - Example file with dummy values
- ✅ `run_tests.sh` - Wrapper script
- ✅ `.gitignore` - Protects sensitive files

**Files that MUST NOT be committed:**
- ❌ `credentials.env` - Actual credentials file
- ❌ Any file containing real passwords
- ❌ SSH keys, certificates, tokens

The `.gitignore` file is configured to prevent accidental commits of credentials.

---

## 📋 Setup Instructions

### Step 1: Create Credentials File

```bash
# Navigate to project directory
cd /path/to/robotframework

# Copy example file to create your credentials file
cp credentials.env.example credentials.env
```

### Step 2: Edit Credentials File

```bash
# Edit with your preferred editor
nano credentials.env
# OR
vim credentials.env
# OR
vi credentials.env
```

**Update these required credentials:**

```bash
# SSH Credentials (REQUIRED for all tests)
export SSH_USERNAME="your_actual_username"
export SSH_PASSWORD="your_actual_password"

# vCenter Credentials (REQUIRED for test4, test9, test15)
export VCENTER_USERNAME="vcenter_admin@vsphere.local"
export VCENTER_PASSWORD="your_vcenter_password"
export VCENTER_SERVER="vcenter.yourdomain.com"

# Splunk Credentials (REQUIRED for test14)
export SPLUNK_USERNAME="splunk_admin"
export SPLUNK_PASSWORD="your_splunk_password"
export SPLUNK_SERVER="splunk.yourdomain.com"

# CyberArk Credentials (REQUIRED for test16)
export CYBERARK_USERNAME="vault_admin"
export CYBERARK_PASSWORD="your_cyberark_password"
export CYBERARK_SERVER="cyberark.yourdomain.com"

# ... update other credentials as needed
```

### Step 3: Secure the File

```bash
# Set restrictive permissions (only owner can read/write)
chmod 600 credentials.env

# Verify permissions
ls -la credentials.env
# Should show: -rw------- (600)

# Optionally, verify ownership
chown yourusername:yourgroup credentials.env
```

### Step 4: Make Wrapper Script Executable

```bash
chmod +x run_tests.sh
```

---

## 🚀 Usage

### Method 1: Using Wrapper Script (Recommended)

The wrapper script automatically loads credentials and executes tests:

```bash
# Basic execution
./run_tests.sh alhxvdvitap01

# With verbose output
./run_tests.sh alhxvdvitap01 -vv

# Dry run (check mode)
./run_tests.sh alhxvdvitap01 --check

# Run specific test tag
./run_tests.sh alhxvdvitap01 --tags test3
```

**What the wrapper script does:**
1. ✅ Checks prerequisites (Ansible, Python, Robot Framework)
2. ✅ Loads credentials from `credentials.env`
3. ✅ Validates credentials are loaded
4. ✅ Executes Ansible playbook with proper environment variables
5. ✅ Displays test results summary
6. ✅ Optionally unsets credentials after execution

---

### Method 2: Manual Execution

If you prefer to run Ansible directly:

```bash
# Load credentials into environment
source credentials.env

# Verify credentials are loaded
echo $SSH_USERNAME
env | grep SSH_

# Execute Ansible playbook
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01

# Optional: Unset sensitive variables after execution
unset SSH_PASSWORD VCENTER_PASSWORD SPLUNK_PASSWORD
```

---

## 📁 Storage Location Options

### Option 1: Project Directory (Development)

```bash
# Store in project root
/path/to/robotframework/credentials.env
chmod 600 credentials.env
```

**Pros:** Easy access during development
**Cons:** Risk of accidental commit (mitigated by .gitignore)

---

### Option 2: System-Wide (Production)

```bash
# Store in /etc (requires root)
sudo cp credentials.env /etc/robot_credentials.env
sudo chmod 600 /etc/robot_credentials.env
sudo chown root:root /etc/robot_credentials.env

# Update wrapper script or set environment variable
export CREDENTIALS_FILE=/etc/robot_credentials.env
./run_tests.sh alhxvdvitap01
```

**Pros:** Secure, centralized, protected
**Cons:** Requires root access to modify

---

### Option 3: User Home Directory

```bash
# Store in user home directory
cp credentials.env ~/.robot_credentials.env
chmod 600 ~/.robot_credentials.env

# Update wrapper script
export CREDENTIALS_FILE=~/.robot_credentials.env
./run_tests.sh alhxvdvitap01
```

**Pros:** User-specific, no root needed
**Cons:** Not shared across users

---

### Option 4: Secure Vault Location

```bash
# Store in dedicated secure location
sudo mkdir -p /opt/robot/secure
sudo cp credentials.env /opt/robot/secure/credentials.env
sudo chmod 600 /opt/robot/secure/credentials.env
sudo chown robot_user:robot_group /opt/robot/secure/credentials.env

# Update wrapper script
export CREDENTIALS_FILE=/opt/robot/secure/credentials.env
./run_tests.sh alhxvdvitap01
```

**Pros:** Dedicated location, clear separation
**Cons:** Requires setup and permissions management

---

## 🔐 Advanced Security Options

### Option A: Ansible Vault (Recommended for Production)

For production environments, use Ansible Vault to encrypt credentials:

```bash
# Create encrypted vault file
ansible-vault create vault_credentials.yml

# Enter vault password when prompted
# Add credentials in YAML format:
---
vault_ssh_username: "admin"
vault_ssh_password: "SecurePassword123"
vault_vcenter_username: "vcenter_admin"
vault_vcenter_password: "vCenterPass456"
# ... etc

# Update run_tests.yml to include vault file
# (See CREDENTIALS_SETUP.md for details)

# Execute with vault password
ansible-playbook run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  --ask-vault-pass

# OR use vault password file
echo "VaultPassword" > ~/.vault_pass
chmod 600 ~/.vault_pass
ansible-playbook run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  --vault-password-file ~/.vault_pass
```

---

### Option B: Enterprise Secret Management

If your organization uses CyberArk, HashiCorp Vault, or AWS Secrets Manager:

**CyberArk Example:**
```bash
# Fetch credentials from CyberArk
export SSH_PASSWORD=$(curl -s -H "Authorization: Bearer $CYBERARK_TOKEN" \
  https://cyberark.company.com/api/accounts/ssh_admin/password | jq -r '.password')

# Execute tests
./run_tests.sh alhxvdvitap01
```

**HashiCorp Vault Example:**
```bash
# Fetch credentials from Vault
export SSH_PASSWORD=$(vault kv get -field=password secret/robot/ssh)
export VCENTER_PASSWORD=$(vault kv get -field=password secret/robot/vcenter)

# Execute tests
./run_tests.sh alhxvdvitap01
```

---

## ✅ Verification

### Verify Credentials are Loaded

```bash
# Source credentials
source credentials.env

# Check if environment variables are set
echo "SSH Username: $SSH_USERNAME"
echo "vCenter Server: $VCENTER_SERVER"

# List all loaded credentials (passwords hidden)
env | grep -E "(USERNAME|SERVER)" | sort
```

### Test SSH Connection

```bash
# Verify SSH credentials work
ssh ${SSH_USERNAME}@alhxvdvitap01
# Enter password from SSH_PASSWORD variable
```

---

## 🔄 Credential Rotation

Best practice: Rotate credentials every 90 days.

```bash
# 1. Update credentials.env with new passwords
vim credentials.env

# 2. Test with one target
./run_tests.sh test-server-01

# 3. If successful, deploy to production
# 4. Update centralized credential store (if using)
```

---

## 🚨 Troubleshooting

### Issue 1: Credentials File Not Found

**Error:**
```
Credentials file not found: /path/to/credentials.env
```

**Solution:**
```bash
# Create credentials file
cp credentials.env.example credentials.env
# Edit with your credentials
vim credentials.env
# Set permissions
chmod 600 credentials.env
```

---

### Issue 2: Permissions Too Open

**Warning:**
```
Credentials file has insecure permissions: 644
```

**Solution:**
```bash
chmod 600 credentials.env
```

---

### Issue 3: SSH Credentials Not Loaded

**Error:**
```
SSH credentials not found in credentials.env
```

**Solution:**
```bash
# Verify file has SSH credentials
grep SSH_USERNAME credentials.env
grep SSH_PASSWORD credentials.env

# Ensure export statements are present
# Correct: export SSH_USERNAME="admin"
# Incorrect: SSH_USERNAME="admin" (missing export)
```

---

### Issue 4: Environment Variables Not Persisting

**Problem:** Variables set in one terminal don't appear in another

**Explanation:** Environment variables are session-specific

**Solution:**
```bash
# Option 1: Source credentials in each terminal
source credentials.env

# Option 2: Add to shell profile (NOT RECOMMENDED for passwords)
# Only for non-sensitive variables like ROBOT_LOG_LEVEL
echo "export ROBOT_LOG_LEVEL=INFO" >> ~/.bashrc

# Option 3: Use wrapper script (automatically sources)
./run_tests.sh alhxvdvitap01
```

---

## 📊 Credential Requirements by Test

| Test | SSH | vCenter | Splunk | CyberArk | Tanium | Tower |
|------|-----|---------|--------|----------|--------|-------|
| Test 3 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 4 | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Test 5 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 7 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 8 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 9 | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Test 11 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 12 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 13 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 14 | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Test 15 | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Test 16 | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Test 17 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 18 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 19 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 20 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 21 | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Test 22 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 23 | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Test 24 | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |

**Minimum Required:** SSH credentials (all tests use SSH)

---

## 🔗 Integration with CI/CD

### Jenkins Integration

```groovy
pipeline {
    agent any
    environment {
        CREDENTIALS_FILE = '/opt/jenkins/robot_credentials.env'
    }
    stages {
        stage('Run Tests') {
            steps {
                sh './run_tests.sh ${TARGET_HOSTNAME}'
            }
        }
    }
}
```

### GitLab CI Integration

```yaml
test:
  script:
    - source /etc/robot_credentials.env
    - ansible-playbook run_tests.yml -e TargetHostname=${TARGET_HOSTNAME}
  only:
    - main
```

### Itential Integration

Itential can securely inject credentials at runtime without storing them in files.

---

## 📚 Related Documentation

- [Test Explanations](docs/test_explanations/README.md)
- [Ansible Playbook Explanation](docs/test_explanations/ANSIBLE_run_tests_yml_Working_Explanation.md)
- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)

---

## 🆘 Support

For issues or questions:
1. Check troubleshooting section above
2. Review test documentation in `docs/test_explanations/`
3. Contact your Robot Framework administrator

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14

# Environment Variables Approach with Ansible Vault - Updated Architecture

## Overview

The Robot Framework test suite uses **Ansible Vault** for secure credential management on Linux servers. All credentials are encrypted and automatically decrypted at runtime using environment variables. No credentials are passed via command-line arguments or stored in plain text.

---

## 🔐 Security Architecture

### Architecture Flow with Ansible Vault

```
1. Create encrypted vault file (ansible-vault create)
   ↓
2. Vault file stored securely (/etc/ansible/vault/robot_credentials.yml)
   ↓
3. Vault password stored in secure location (file or environment)
   ↓
4. Ansible playbook decrypts vault at runtime
   ↓
5. Credentials loaded as environment variables
   ↓
6. Robot Framework tests read environment variables
   ↓
7. Tests execute with proper credentials
   ↓
8. Credentials never exposed in logs or process list
```

---

## 🚀 Quick Start - Ansible Vault Setup

### Step 1: Create Vault Password File

```bash
# Create a secure directory for vault password
sudo mkdir -p /etc/ansible/vault
sudo chmod 700 /etc/ansible/vault

# Create vault password file
echo "YourSecureVaultPassword123!" | sudo tee /etc/ansible/vault/.vault_pass
sudo chmod 600 /etc/ansible/vault/.vault_pass
```

### Step 2: Create Encrypted Credentials Vault

```bash
# Create encrypted vault file
ansible-vault create /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

**When the editor opens, add your credentials:**

```yaml
---
# Robot Framework Test Suite - Encrypted Credentials Vault
# Created with: ansible-vault create robot_credentials.yml

#############################################################################
# SSH Credentials (Required for ALL tests)
#############################################################################
ssh_username: "admin"
ssh_password: "SecurePassword123!"

#############################################################################
# vCenter/VMware Credentials (Test 4, 9, 15)
#############################################################################
vcenter_username: "vcenter_admin@vsphere.local"
vcenter_password: "vCenterPass456!"
vcenter_server: "vcenter.domain.com"

#############################################################################
# Splunk Credentials (Test 14)
#############################################################################
splunk_username: "splunk_admin"
splunk_password: "SplunkPass789!"
splunk_server: "splunk.domain.com"
splunk_port: "8089"

#############################################################################
# CyberArk/Password Vault Credentials (Test 16)
#############################################################################
cyberark_username: "vault_admin"
cyberark_password: "CyberArkPass012!"
cyberark_server: "cyberark.domain.com"
cyberark_safe: "BES_Cyber_Assets"

#############################################################################
# Tanium Credentials (Test 21)
#############################################################################
tanium_username: "tanium_admin"
tanium_password: "TaniumPass345!"
tanium_server: "tanium.domain.com"
tanium_port: "443"

#############################################################################
# BMC Helix Change Management System Credentials (Test 23)
#############################################################################
bmc_helix_url: "https://helix.company.com"
bmc_helix_username: "helix_admin"
bmc_helix_password: "HelixPassword123!"
change_request_number: "CHG0012345"
change_form_id: "CHGFORM001"

#############################################################################
# Ansible Tower/AWX Credentials (Test 24)
#############################################################################
ansible_tower_url: "https://tower.domain.com"
ansible_username: "tower_admin"
ansible_password: "TowerPass678!"
ansible_job_id: "12345"  # Job ID to validate (from Tower/AWX job execution)

#############################################################################
# RSA Authentication Server (Test 18)
#############################################################################
rsa_server: "rsa.domain.com"
rsa_port: "5500"

#############################################################################
# SMTP/Mail Configuration (Test 17)
#############################################################################
smtp_server: "mail.domain.com"
smtp_port: "25"
test_email_recipient: "admin@domain.com"

#############################################################################
# NTP Configuration (Test 7)
#############################################################################
ntp_server: "ntpx.domain.com"

#############################################################################
# EDS Configuration
#############################################################################
eds_file_path: "/opt/robot/data/EDS_Itential_DRAFT_v0.01.xlsx"
eds_sheet_name: "Server Requirements"

#############################################################################
# Robot Framework Settings
#############################################################################
robot_timeout: "300"
robot_log_level: "INFO"
robot_output_dir: "results"
```

**Save and exit the editor (vim: `:wq` or nano: `Ctrl+X, Y, Enter`)**

### Step 3: Verify Vault File

```bash
# View encrypted file (verify it's encrypted)
cat /etc/ansible/vault/robot_credentials.yml
# Should show: $ANSIBLE_VAULT;1.1;AES256...

# View decrypted content
ansible-vault view /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass

# Edit vault file
ansible-vault edit /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

### Step 4: Set Vault Password Environment Variable

```bash
# Add to ~/.bashrc or /etc/environment
export ANSIBLE_VAULT_PASSWORD_FILE="/etc/ansible/vault/.vault_pass"

# Or set vault password directly (less secure)
export ANSIBLE_VAULT_PASSWORD="YourSecureVaultPassword123!"

# Reload environment
source ~/.bashrc
```

---

## 📋 Execution Methods

### Method 1: Using Ansible Vault (Recommended for Production)

```bash
# Execute with vault file
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e @/etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass

# Or if ANSIBLE_VAULT_PASSWORD_FILE is set
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e @/etc/ansible/vault/robot_credentials.yml
```

### Method 2: Using Environment Variables (Development/Manual)

```bash
# Source credentials
source credentials.env

# Run playbook
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01
```

### Method 3: Using Wrapper Script (Automatic Vault Integration)

Create an updated wrapper script:

```bash
#!/bin/bash
#############################################################################
# Robot Framework Test Suite - Execution Wrapper with Ansible Vault
#############################################################################

# Configuration
VAULT_FILE="/etc/ansible/vault/robot_credentials.yml"
VAULT_PASSWORD_FILE="/etc/ansible/vault/.vault_pass"
PLAYBOOK_DIR="ansible_playbooks"

# Check if target hostname provided
if [ -z "$1" ]; then
    echo "Error: Target hostname required"
    echo "Usage: $0 <target_hostname>"
    echo "Example: $0 alhxvdvitap01"
    exit 1
fi

TARGET_HOSTNAME="$1"

# Check if vault file exists
if [ ! -f "$VAULT_FILE" ]; then
    echo "Error: Vault file not found: $VAULT_FILE"
    echo "Please create vault file first:"
    echo "  ansible-vault create $VAULT_FILE --vault-password-file=$VAULT_PASSWORD_FILE"
    exit 1
fi

# Check if vault password file exists
if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
    echo "Error: Vault password file not found: $VAULT_PASSWORD_FILE"
    echo "Set ANSIBLE_VAULT_PASSWORD environment variable or create password file"
    exit 1
fi

echo "=========================================="
echo "Robot Framework Test Suite"
echo "=========================================="
echo "Target: $TARGET_HOSTNAME"
echo "Vault:  $VAULT_FILE"
echo "=========================================="

# Execute Ansible playbook with vault
ansible-playbook "${PLAYBOOK_DIR}/run_tests.yml" \
  -e TargetHostname="$TARGET_HOSTNAME" \
  -e @"$VAULT_FILE" \
  --vault-password-file="$VAULT_PASSWORD_FILE"

exit $?
```

**Save as `run_tests_vault.sh` and make executable:**

```bash
chmod +x run_tests_vault.sh

# Execute
./run_tests_vault.sh alhxvdvitap01
```

---

## 🔧 Updated Ansible Playbook Integration

The playbook now supports **both** environment variables and Ansible Vault:

### Priority Order (Credentials Resolution):

1. **Ansible Vault variables** (highest priority - production)
2. **Environment variables** (fallback - development/manual)
3. **Default values** (lowest priority - optional settings)

### How It Works in `run_tests.yml`:

```yaml
- name: Load credentials from vault or environment
  set_fact:
    SSH_USERNAME: "{{ ssh_username | default(lookup('env', 'SSH_USERNAME')) }}"
    SSH_PASSWORD: "{{ ssh_password | default(lookup('env', 'SSH_PASSWORD')) }}"
    VCENTER_USERNAME: "{{ vcenter_username | default(lookup('env', 'VCENTER_USERNAME')) }}"
    VCENTER_PASSWORD: "{{ vcenter_password | default(lookup('env', 'VCENTER_PASSWORD')) }}"
    # ... all other credentials
```

**This allows:**
- ✅ Production systems use Ansible Vault
- ✅ Development systems use environment variables
- ✅ Seamless transition between environments
- ✅ No code changes needed

---

## 🎯 Environment Variables by Test

Each test only uses the credentials it needs:

| Test | Required Credentials (Vault Keys) |
|------|-----------------------------------|
| Test 3 - Network | `ssh_username`, `ssh_password` |
| Test 4 - VM | `ssh_username`, `ssh_password`, `vcenter_username`, `vcenter_password`, `vcenter_server` |
| Test 5 - Disk Space | `ssh_username`, `ssh_password` |
| Test 7 - Time Config | `ssh_username`, `ssh_password`, `ntp_server` |
| Test 9 - Datastore | `ssh_username`, `ssh_password`, `vcenter_username`, `vcenter_password`, `vcenter_server` |
| Test 11 - Services | `ssh_username`, `ssh_password` |
| Test 14 - Logging | `ssh_username`, `ssh_password`, `splunk_username`, `splunk_password`, `splunk_server` |
| Test 15 - Backup | `ssh_username`, `ssh_password`, `vcenter_username`, `vcenter_password` |
| Test 16 - Password Vault | `ssh_username`, `ssh_password`, `cyberark_username`, `cyberark_password`, `cyberark_server` |
| Test 17 - Mail | `ssh_username`, `ssh_password`, `smtp_server`, `test_email_recipient` |
| Test 18 - Patch/RSA | `ssh_username`, `ssh_password`, `rsa_server` |
| Test 20 - Antivirus | `ssh_username`, `ssh_password` |
| Test 22 - Event Logs | `ssh_username`, `ssh_password` |

---

## 📂 Ansible Vault File Structure

### Complete Vault Variables Reference

```yaml
# SSH (Required for ALL tests)
ssh_username: "admin"
ssh_password: "SecurePassword123!"

# vCenter (Test 4, 9, 15)
vcenter_username: "vcenter_admin@vsphere.local"
vcenter_password: "vCenterPass456!"
vcenter_server: "vcenter.domain.com"

# Splunk (Test 14)
splunk_username: "splunk_admin"
splunk_password: "SplunkPass789!"
splunk_server: "splunk.domain.com"
splunk_port: "8089"

# CyberArk (Test 16)
cyberark_username: "vault_admin"
cyberark_password: "CyberArkPass012!"
cyberark_server: "cyberark.domain.com"
cyberark_safe: "BES_Cyber_Assets"

# Tanium (Test 21)
tanium_username: "tanium_admin"
tanium_password: "TaniumPass345!"
tanium_server: "tanium.domain.com"
tanium_port: "443"

# BMC Helix Change Management (Test 23)
bmc_helix_url: "https://helix.company.com"
bmc_helix_username: "helix_admin"
bmc_helix_password: "HelixPassword123!"
change_request_number: "CHG0012345"
change_form_id: "CHGFORM001"

# Ansible Tower (Test 24)
ansible_tower_url: "https://tower.domain.com"
ansible_username: "tower_admin"
ansible_password: "TowerPass678!"
ansible_job_id: "12345"

# RSA (Test 18)
rsa_server: "rsa.domain.com"
rsa_port: "5500"

# SMTP (Test 17)
smtp_server: "mail.domain.com"
smtp_port: "25"
test_email_recipient: "admin@domain.com"

# NTP (Test 7)
ntp_server: "ntpx.domain.com"

# EDS Configuration
eds_file_path: "/opt/robot/data/EDS_Itential_DRAFT_v0.01.xlsx"
eds_sheet_name: "Server Requirements"

# Robot Framework Settings
robot_timeout: "300"
robot_log_level: "INFO"
robot_output_dir: "results"
```

---

## 🔐 Security Best Practices

### 1. Vault Password Security

```bash
# Option 1: Vault password file (recommended for servers)
echo "YourVaultPassword" > /etc/ansible/vault/.vault_pass
chmod 600 /etc/ansible/vault/.vault_pass
chown root:root /etc/ansible/vault/.vault_pass

# Option 2: Environment variable (CI/CD systems)
export ANSIBLE_VAULT_PASSWORD_FILE="/secure/location/.vault_pass"

# Option 3: Prompt for password (manual execution)
ansible-playbook run_tests.yml -e @vault.yml --ask-vault-pass
```

### 2. File Permissions

```bash
# Vault files
chmod 600 /etc/ansible/vault/robot_credentials.yml
chmod 600 /etc/ansible/vault/.vault_pass
chown root:ansible /etc/ansible/vault/*

# Credentials.env (if using)
chmod 600 credentials.env
chown yourusername:yourgroup credentials.env
```

### 3. Vault File Locations

```bash
# Production (system-wide)
/etc/ansible/vault/robot_credentials.yml

# Development (user-specific)
~/.ansible/vault/robot_credentials.yml

# CI/CD (project-specific)
/opt/robot/vault/robot_credentials.yml
```

### 4. Credential Rotation

```bash
# Edit vault to update credentials
ansible-vault edit /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass

# Rekey vault (change vault password)
ansible-vault rekey /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

---

## ✅ Verification Steps

### 1. Verify Vault File is Encrypted

```bash
# Should show encrypted content
cat /etc/ansible/vault/robot_credentials.yml
# Output: $ANSIBLE_VAULT;1.1;AES256...

# Should show decrypted content
ansible-vault view /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

### 2. Test Ansible Can Decrypt Vault

```bash
# Test vault decryption
ansible localhost -m debug \
  -a "msg={{ ssh_username }}" \
  -e @/etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass

# Should output your SSH username
```

### 3. Test Complete Playbook Execution

```bash
# Dry run with vault
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e @/etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass \
  --check

# Actual execution
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e @/etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

---

## 🔧 Ansible Vault Commands Reference

### Create and Manage Vaults

```bash
# Create new vault file
ansible-vault create robot_credentials.yml

# Edit existing vault
ansible-vault edit robot_credentials.yml

# View vault contents (read-only)
ansible-vault view robot_credentials.yml

# Encrypt existing file
ansible-vault encrypt credentials.yml

# Decrypt vault (to plain text - be careful!)
ansible-vault decrypt robot_credentials.yml

# Rekey vault (change password)
ansible-vault rekey robot_credentials.yml
```

### Using Vault Password Files

```bash
# All commands support --vault-password-file
ansible-vault create vault.yml --vault-password-file=.vault_pass
ansible-vault edit vault.yml --vault-password-file=.vault_pass
ansible-vault view vault.yml --vault-password-file=.vault_pass

# Or set environment variable
export ANSIBLE_VAULT_PASSWORD_FILE="/path/to/.vault_pass"
ansible-vault edit vault.yml  # No --vault-password-file needed
```

### Multiple Vault IDs (Advanced)

```bash
# Create vault with specific ID
ansible-vault create vault.yml --vault-id prod@.vault_pass_prod

# Create vault with different ID
ansible-vault create vault_dev.yml --vault-id dev@.vault_pass_dev

# Use specific vault in playbook
ansible-playbook run_tests.yml \
  -e @vault.yml \
  --vault-id prod@.vault_pass_prod
```

---

## 🚀 CI/CD Integration Examples

### Jenkins with Ansible Vault

```groovy
pipeline {
    environment {
        VAULT_PASSWORD = credentials('ansible-vault-password')
        VAULT_FILE = '/var/jenkins/ansible/vault/robot_credentials.yml'
    }
    stages {
        stage('Test') {
            steps {
                sh '''
                    echo "$VAULT_PASSWORD" > .vault_pass
                    chmod 600 .vault_pass

                    ansible-playbook ansible_playbooks/run_tests.yml \
                      -e TargetHostname=${TARGET_HOSTNAME} \
                      -e @${VAULT_FILE} \
                      --vault-password-file=.vault_pass

                    rm -f .vault_pass
                '''
            }
        }
    }
}
```

### GitLab CI with Ansible Vault

```yaml
test:
  variables:
    VAULT_FILE: /etc/ansible/vault/robot_credentials.yml
  before_script:
    - echo "$ANSIBLE_VAULT_PASSWORD" > .vault_pass
    - chmod 600 .vault_pass
  script:
    - |
      ansible-playbook ansible_playbooks/run_tests.yml \
        -e TargetHostname=$TARGET_HOSTNAME \
        -e @$VAULT_FILE \
        --vault-password-file=.vault_pass
  after_script:
    - rm -f .vault_pass
```

### Itential Integration with Vault

```python
# Itential workflow integration
import subprocess
import os

def execute_robot_tests(target_hostname):
    """Execute Robot Framework tests with Ansible Vault"""

    # Vault configuration
    vault_file = "/etc/ansible/vault/robot_credentials.yml"
    vault_password_file = "/etc/ansible/vault/.vault_pass"

    # Execute Ansible playbook
    cmd = [
        "ansible-playbook",
        "ansible_playbooks/run_tests.yml",
        "-e", f"TargetHostname={target_hostname}",
        "-e", f"@{vault_file}",
        "--vault-password-file", vault_password_file
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    return {
        "exit_code": result.returncode,
        "stdout": result.stdout,
        "stderr": result.stderr
    }
```

---

## 🆚 Comparison: Methods

| Method | Security | Ease of Use | Best For |
|--------|----------|-------------|----------|
| **Ansible Vault** | ✅ Excellent | ⭐⭐⭐ Good | Production, CI/CD |
| **Environment Variables** | ⚠️ Moderate | ⭐⭐⭐⭐⭐ Excellent | Development, Manual |
| **credentials.env** | ⚠️ Moderate | ⭐⭐⭐⭐ Good | Development |
| **Command Line** | ❌ Poor | ⭐⭐ Fair | Never use for production |

### When to Use Each Method:

**Ansible Vault:**
- ✅ Production servers
- ✅ CI/CD pipelines
- ✅ Multi-user environments
- ✅ Compliance requirements
- ✅ Itential integration

**Environment Variables:**
- ✅ Local development
- ✅ Quick testing
- ✅ Personal workstations
- ✅ Debugging

**credentials.env:**
- ✅ Development environments
- ✅ Team collaboration (with .gitignore)
- ✅ Quick setup

---

## 🔧 Troubleshooting

### Issue 1: "Vault password required"

**Cause:** Vault password not provided

**Solution:**
```bash
# Option 1: Use password file
ansible-playbook run_tests.yml \
  -e @vault.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass

# Option 2: Set environment variable
export ANSIBLE_VAULT_PASSWORD_FILE="/etc/ansible/vault/.vault_pass"

# Option 3: Prompt for password
ansible-playbook run_tests.yml -e @vault.yml --ask-vault-pass
```

### Issue 2: "Decryption failed"

**Cause:** Wrong vault password

**Solution:**
```bash
# Verify vault password
ansible-vault view /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass

# If password is correct but still fails, vault may be corrupted
# Recreate vault from backup
```

### Issue 3: "Variable not found in vault"

**Cause:** Credential missing from vault file

**Solution:**
```bash
# Edit vault and add missing credential
ansible-vault edit /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass

# Add the missing variable, save and exit
```

### Issue 4: "Permission denied" on vault file

**Cause:** Incorrect file permissions

**Solution:**
```bash
# Fix vault file permissions
sudo chmod 600 /etc/ansible/vault/robot_credentials.yml
sudo chown yourusername:yourgroup /etc/ansible/vault/robot_credentials.yml

# Fix vault password file
sudo chmod 600 /etc/ansible/vault/.vault_pass
```

### Issue 5: Environment variables override vault

**Cause:** Environment variables have priority in playbook

**Solution:**
```bash
# Unset environment variables to use vault only
unset SSH_PASSWORD VCENTER_PASSWORD SPLUNK_PASSWORD

# Or modify playbook to prioritize vault over environment
# (see playbook updates section)
```

---

## 📊 Benefits Summary

### Security Benefits:

| Feature | Without Vault | With Vault |
|---------|--------------|------------|
| **Credentials Encrypted** | ❌ Plain text | ✅ AES256 encrypted |
| **Password Rotation** | ❌ Manual file edits | ✅ `ansible-vault rekey` |
| **Access Control** | ⚠️ File permissions only | ✅ Vault password + file permissions |
| **Audit Trail** | ❌ None | ✅ Git commits (encrypted) |
| **Compliance Ready** | ❌ No | ✅ Yes (SOX, PCI-DSS, CIP) |
| **Process List Security** | ✅ Not visible | ✅ Not visible |
| **Log Security** | ✅ Not in logs | ✅ Not in logs |

### Operational Benefits:

- ✅ Centralized credential management
- ✅ Easy credential rotation
- ✅ Version control friendly (encrypted)
- ✅ Multi-environment support (dev/staging/prod vaults)
- ✅ Integration with secret management tools
- ✅ Automated CI/CD pipelines
- ✅ Compliance auditing

---

## 📚 Related Documentation

- [Ansible Vault Official Docs](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [CREDENTIALS_SETUP.md](../CREDENTIALS_SETUP.md) - Credentials configuration guide
- [QUICKSTART.md](../QUICKSTART.md) - Quick start guide
- [Test Explanations](test_explanations/) - Individual test documentation
- [ROBOT_COMMAND_REFERENCE.md](ROBOT_COMMAND_REFERENCE.md) - Command reference

---

## 📋 Appendix: Complete Setup Checklist

### Initial Setup:

- [ ] Create vault directory: `/etc/ansible/vault`
- [ ] Create vault password file: `.vault_pass`
- [ ] Set vault password file permissions: `chmod 600`
- [ ] Create encrypted vault: `ansible-vault create robot_credentials.yml`
- [ ] Add all required credentials to vault
- [ ] Verify vault decryption: `ansible-vault view`
- [ ] Set environment variable: `ANSIBLE_VAULT_PASSWORD_FILE`
- [ ] Test playbook execution with vault
- [ ] Document vault password location (securely!)
- [ ] Add vault password to password manager
- [ ] Create backup of vault file
- [ ] Update CI/CD pipelines with vault integration

### Regular Maintenance:

- [ ] Rotate credentials quarterly
- [ ] Rekey vault annually
- [ ] Audit vault access logs
- [ ] Review and update credentials
- [ ] Test vault backups
- [ ] Verify CI/CD integration
- [ ] Update documentation

---

**Document Version:** 2.0
**Last Updated:** 2025-10-14
**Architecture:** Ansible Vault + Environment Variables
**Security Level:** Production-Ready with AES256 Encryption

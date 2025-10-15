# Ansible Vault Setup - Quick Reference Guide

## Overview

This guide provides step-by-step instructions for setting up Ansible Vault to securely manage credentials for the Robot Framework test suite on Linux servers.

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Create Vault Directory and Password

```bash
# Create secure directory
sudo mkdir -p /etc/ansible/vault
sudo chmod 700 /etc/ansible/vault

# Create vault password file
echo "YourSecureVaultPassword123!" | sudo tee /etc/ansible/vault/.vault_pass
sudo chmod 600 /etc/ansible/vault/.vault_pass
sudo chown $USER:$USER /etc/ansible/vault/.vault_pass
```

### Step 2: Create Encrypted Credentials Vault

```bash
# Create encrypted vault (will open editor)
ansible-vault create /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

### Step 3: Add Credentials to Vault

**When the editor opens, paste this template and update with your credentials:**

```yaml
---
# SSH Credentials (Required for ALL tests)
ssh_username: "admin"
ssh_password: "YourActualSSHPassword"

# vCenter Credentials (Test 4, 9, 15)
vcenter_username: "vcenter_admin@vsphere.local"
vcenter_password: "YourVCenterPassword"
vcenter_server: "vcenter.domain.com"

# Splunk Credentials (Test 14)
splunk_username: "splunk_admin"
splunk_password: "YourSplunkPassword"
splunk_server: "splunk.domain.com"
splunk_port: "8089"

# CyberArk Credentials (Test 16)
cyberark_username: "vault_admin"
cyberark_password: "YourCyberArkPassword"
cyberark_server: "cyberark.domain.com"
cyberark_safe: "BES_Cyber_Assets"

# Tanium Credentials (Test 21)
tanium_username: "tanium_admin"
tanium_password: "YourTaniumPassword"
tanium_server: "tanium.domain.com"
tanium_port: "443"

# Ansible Tower Credentials (Test 24)
ansible_tower_username: "tower_admin"
ansible_tower_password: "YourTowerPassword"
ansible_tower_server: "tower.domain.com"
ansible_tower_port: "443"

# RSA Server (Test 18)
rsa_server: "rsa.domain.com"
rsa_port: "5500"

# SMTP Configuration (Test 17)
smtp_server: "mail.domain.com"
smtp_port: "25"
test_email_recipient: "admin@domain.com"

# NTP Server (Test 7)
ntp_server: "ntpx.domain.com"

# EDS Configuration
eds_file_path: "/opt/robot/data/EDS_Itential_DRAFT_v0.01.xlsx"
eds_sheet_name: "Server Requirements"

# Robot Framework Settings
robot_timeout: "300"
robot_log_level: "INFO"
robot_output_dir: "results"
```

**Save and exit:**
- **vim**: Press `Esc`, type `:wq`, press `Enter`
- **nano**: Press `Ctrl+X`, then `Y`, then `Enter`

### Step 4: Set Environment Variable (Optional but Recommended)

```bash
# Add to ~/.bashrc
echo 'export ANSIBLE_VAULT_PASSWORD_FILE="/etc/ansible/vault/.vault_pass"' >> ~/.bashrc

# Reload shell
source ~/.bashrc
```

### Step 5: Verify Setup

```bash
# Verify vault is encrypted
cat /etc/ansible/vault/robot_credentials.yml
# Should show: $ANSIBLE_VAULT;1.1;AES256...

# Verify you can decrypt vault
ansible-vault view /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass

# Test credential access
ansible localhost -m debug \
  -a "msg={{ ssh_username }}" \
  -e @/etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
# Should output: "msg": "admin"
```

### Step 6: Run Tests

```bash
# Method 1: Using wrapper script (easiest)
./run_tests_vault.sh alhxvdvitap01

# Method 2: Using ansible-playbook directly
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e @/etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

---

## 📝 Common Operations

### View Vault Contents (Read-Only)

```bash
ansible-vault view /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

### Edit Vault

```bash
ansible-vault edit /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

### Change Vault Password (Rekey)

```bash
ansible-vault rekey /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

### Encrypt Existing File

```bash
# If you have credentials.env file, encrypt it
ansible-vault encrypt credentials.env \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

### Decrypt Vault (⚠️ Use Carefully)

```bash
# This will decrypt to plain text - use with caution!
ansible-vault decrypt /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

---

## 🔐 Security Best Practices

### 1. File Permissions

```bash
# Vault file permissions
chmod 600 /etc/ansible/vault/robot_credentials.yml
chown $USER:$USER /etc/ansible/vault/robot_credentials.yml

# Vault password file permissions
chmod 600 /etc/ansible/vault/.vault_pass
chown $USER:$USER /etc/ansible/vault/.vault_pass

# Vault directory permissions
chmod 700 /etc/ansible/vault
chown $USER:$USER /etc/ansible/vault
```

### 2. Vault Password Storage Options

**Option 1: File (Recommended for servers)**
```bash
echo "YourVaultPassword" > /etc/ansible/vault/.vault_pass
chmod 600 /etc/ansible/vault/.vault_pass
export ANSIBLE_VAULT_PASSWORD_FILE="/etc/ansible/vault/.vault_pass"
```

**Option 2: Environment Variable (CI/CD systems)**
```bash
export ANSIBLE_VAULT_PASSWORD="YourVaultPassword"
```

**Option 3: Prompt (Manual execution)**
```bash
ansible-playbook run_tests.yml \
  -e @vault.yml \
  --ask-vault-pass
```

### 3. Git Configuration

```bash
# Make sure vault password is NEVER committed to git
echo ".vault_pass" >> .gitignore
echo "credentials.env" >> .gitignore
echo "/etc/ansible/vault/*" >> .gitignore

# Only commit the template
git add ansible_vault_template.yml
```

### 4. Backup Vault

```bash
# Create encrypted backup
cp /etc/ansible/vault/robot_credentials.yml \
   /etc/ansible/vault/robot_credentials.yml.backup.$(date +%Y%m%d)

# Store vault password securely
# - Password manager (LastPass, 1Password, etc.)
# - Hardware security module (HSM)
# - Secret management system (HashiCorp Vault, AWS Secrets Manager)
```

---

## 🛠️ Troubleshooting

### Issue: "ERROR! Attempting to decrypt but no vault secrets found"

**Cause:** File is not encrypted

**Solution:**
```bash
# Encrypt the file
ansible-vault encrypt /etc/ansible/vault/robot_credentials.yml \
  --vault-password-file=/etc/ansible/vault/.vault_pass
```

---

### Issue: "ERROR! Decryption failed"

**Cause:** Wrong vault password

**Solution:**
```bash
# Verify password file exists and is readable
cat /etc/ansible/vault/.vault_pass

# Try with --ask-vault-pass to manually enter password
ansible-vault view /etc/ansible/vault/robot_credentials.yml --ask-vault-pass
```

---

### Issue: "Permission denied"

**Cause:** Incorrect file permissions

**Solution:**
```bash
# Fix permissions
sudo chmod 600 /etc/ansible/vault/robot_credentials.yml
sudo chmod 600 /etc/ansible/vault/.vault_pass
sudo chown $USER:$USER /etc/ansible/vault/*
```

---

### Issue: Vault password in process list

**Cause:** Using ANSIBLE_VAULT_PASSWORD environment variable

**Solution:**
```bash
# Use password file instead
unset ANSIBLE_VAULT_PASSWORD
export ANSIBLE_VAULT_PASSWORD_FILE="/etc/ansible/vault/.vault_pass"
```

---

### Issue: "Variable 'ssh_username' is undefined"

**Cause:** Variable name mismatch between vault and playbook

**Solution:**
```bash
# Verify variable names in vault
ansible-vault view /etc/ansible/vault/robot_credentials.yml

# Variable names should be:
# ssh_username (NOT SSH_USERNAME)
# ssh_password (NOT SSH_PASSWORD)
# All lowercase with underscores
```

---

## 📊 Vault vs Environment Variables Comparison

| Feature | Environment Variables | Ansible Vault |
|---------|----------------------|---------------|
| **Encryption** | ❌ Plain text | ✅ AES256 encrypted |
| **Setup Time** | ⭐⭐⭐⭐⭐ 1 minute | ⭐⭐⭐ 5 minutes |
| **Security** | ⚠️ Moderate | ✅ High |
| **Version Control** | ❌ Cannot commit | ✅ Can commit (encrypted) |
| **Password Rotation** | ⚠️ Manual edits | ✅ ansible-vault rekey |
| **Best For** | Development | Production |

---

## 🚀 CI/CD Integration

### Jenkins

```groovy
pipeline {
    environment {
        VAULT_PASSWORD = credentials('ansible-vault-password')
    }
    stages {
        stage('Test') {
            steps {
                sh '''
                    echo "$VAULT_PASSWORD" > .vault_pass
                    chmod 600 .vault_pass

                    ansible-playbook ansible_playbooks/run_tests.yml \
                      -e TargetHostname=${TARGET_HOSTNAME} \
                      -e @/etc/ansible/vault/robot_credentials.yml \
                      --vault-password-file=.vault_pass

                    rm -f .vault_pass
                '''
            }
        }
    }
}
```

### GitLab CI

```yaml
test:
  before_script:
    - echo "$ANSIBLE_VAULT_PASSWORD" > .vault_pass
    - chmod 600 .vault_pass
  script:
    - ansible-playbook ansible_playbooks/run_tests.yml
        -e TargetHostname=$TARGET_HOSTNAME
        -e @/etc/ansible/vault/robot_credentials.yml
        --vault-password-file=.vault_pass
  after_script:
    - rm -f .vault_pass
```

### Itential

```python
import subprocess
import os

def execute_robot_tests(target_hostname):
    vault_file = "/etc/ansible/vault/robot_credentials.yml"
    vault_pass = "/etc/ansible/vault/.vault_pass"

    cmd = [
        "ansible-playbook", "ansible_playbooks/run_tests.yml",
        "-e", f"TargetHostname={target_hostname}",
        "-e", f"@{vault_file}",
        "--vault-password-file", vault_pass
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0
```

---

## 📚 Additional Resources

- **Ansible Vault Documentation**: https://docs.ansible.com/ansible/latest/user_guide/vault.html
- **Main Documentation**: [ENVIRONMENT_VARIABLES_APPROACH.md](ENVIRONMENT_VARIABLES_APPROACH.md)
- **Credentials Setup**: [CREDENTIALS_SETUP.md](CREDENTIALS_SETUP.md)
- **Vault Template**: [ansible_vault_template.yml](../ansible_vault_template.yml)

---

## ✅ Setup Checklist

- [ ] Created `/etc/ansible/vault` directory
- [ ] Created vault password file `.vault_pass`
- [ ] Set correct permissions (600) on password file
- [ ] Created encrypted vault `robot_credentials.yml`
- [ ] Added all required credentials to vault
- [ ] Verified vault can be decrypted
- [ ] Set `ANSIBLE_VAULT_PASSWORD_FILE` environment variable
- [ ] Tested playbook execution with vault
- [ ] Added `.vault_pass` to `.gitignore`
- [ ] Documented vault password location (securely!)
- [ ] Created backup of vault file
- [ ] Tested `run_tests_vault.sh` wrapper script

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Quick Setup Time:** ~5 minutes
**Security Level:** Production-Ready (AES256)

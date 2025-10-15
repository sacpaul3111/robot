# Installation Guide - Robot Framework Test Suite

## Overview

This guide provides complete installation instructions for setting up the Robot Framework Test Suite on a Linux server. The Ansible playbook includes **automatic prerequisite checking and installation**, but this guide provides manual steps if needed.

---

## 🚀 Quick Start (Automated)

The playbook **automatically installs all prerequisites** - just run it!

```bash
# 1. Clone repository
git clone https://github.com/your-org/robotframework.git
cd robotframework

# 2. Set up credentials
cp credentials.env.example credentials.env
vim credentials.env  # Edit with your credentials
chmod 600 credentials.env

# 3. Run tests (auto-installs prerequisites)
./run_tests.sh alhxvdvitap01
```

The playbook will automatically:
- ✅ Check for Python 3, pip3, git
- ✅ Install missing system packages
- ✅ Install Robot Framework and all required Python libraries
- ✅ Verify installation success
- ✅ Execute tests

---

## 📋 System Requirements

### Supported Operating Systems

- ✅ Red Hat Enterprise Linux (RHEL) 7, 8, 9
- ✅ CentOS 7, 8
- ✅ Rocky Linux 8, 9
- ✅ Ubuntu 18.04, 20.04, 22.04
- ✅ Debian 10, 11

### Minimum Hardware

- **CPU**: 2 cores
- **RAM**: 4 GB
- **Disk**: 10 GB free space
- **Network**: Internet access (for package installation)

### Required Privileges

- **For automatic installation**: `sudo` access (to install system packages)
- **For test execution only**: Regular user (no sudo needed)

---

## 🔧 Manual Installation (Optional)

If you prefer to install manually or the automatic installation fails:

### Step 1: Install System Packages

#### RHEL/CentOS/Rocky Linux:

```bash
# Install base packages
sudo yum install -y python3 python3-pip python3-devel git gcc \
                    libxml2-devel libxslt-devel libffi-devel \
                    openssl-devel sshpass

# Verify installation
python3 --version
pip3 --version
git --version
```

#### Ubuntu/Debian:

```bash
# Update package list
sudo apt update

# Install base packages
sudo apt install -y python3 python3-pip python3-dev git gcc \
                    libxml2-dev libxslt1-dev libffi-dev \
                    libssl-dev sshpass

# Verify installation
python3 --version
pip3 --version
git --version
```

---

### Step 2: Upgrade pip

```bash
# Upgrade pip to latest version
pip3 install --user --upgrade pip

# Verify pip version (should be 21.0+)
pip3 --version
```

---

### Step 3: Install Python Requirements

```bash
# Navigate to project directory
cd /path/to/robotframework

# Install from requirements.txt
pip3 install --user -r requirements.txt

# OR install individually
pip3 install --user \
  robotframework>=3.2.2 \
  robotframework-sshlibrary>=3.7.0 \
  robotframework-seleniumlibrary>=5.1.3 \
  requests>=2.27.1 \
  paramiko>=2.9.2 \
  cryptography>=36.0.1 \
  lxml>=4.7.1 \
  openpyxl>=3.0.9 \
  pandas>=1.3.5
```

---

### Step 4: Verify Installation

```bash
# Verify Robot Framework
python3 -m robot --version
# Should output: Robot Framework 3.x or higher

# Verify SSHLibrary
python3 -c "import SSHLibrary; print('SSHLibrary OK')"
# Should output: SSHLibrary OK

# Verify other libraries
python3 -c "import requests, paramiko, lxml, openpyxl, pandas; print('All libraries OK')"
# Should output: All libraries OK
```

---

## 📦 Package Details

### System Packages (Installed by playbook)

| Package | Purpose | RHEL/CentOS | Ubuntu/Debian |
|---------|---------|-------------|---------------|
| Python 3 | Core Python interpreter | `python3` | `python3` |
| pip3 | Python package manager | `python3-pip` | `python3-pip` |
| Python Dev | Development headers | `python3-devel` | `python3-dev` |
| Git | Version control | `git` | `git` |
| GCC | C compiler | `gcc` | `gcc` |
| XML libraries | XML parsing | `libxml2-devel`, `libxslt-devel` | `libxml2-dev`, `libxslt1-dev` |
| FFI library | Foreign function interface | `libffi-devel` | `libffi-dev` |
| OpenSSL | SSL/TLS support | `openssl-devel` | `libssl-dev` |
| sshpass | SSH password authentication | `sshpass` | `sshpass` |

---

### Python Packages (Installed by playbook)

| Package | Version | Purpose |
|---------|---------|---------|
| robotframework | ≥3.2.2 | Core test automation framework |
| robotframework-sshlibrary | ≥3.7.0 | SSH connectivity for remote testing |
| robotframework-seleniumlibrary | ≥5.1.3 | Web UI testing (Citrix/browser) |
| requests | ≥2.27.1 | HTTP/API requests (vCenter, Splunk, etc.) |
| paramiko | ≥2.9.2 | SSH protocol implementation |
| cryptography | ≥36.0.1 | Cryptographic operations |
| lxml | ≥4.7.1 | XML/HTML parsing |
| openpyxl | ≥3.0.9 | Excel file reading (EDS) |
| pandas | ≥1.3.5 | Data analysis and manipulation |

**See `requirements.txt` for complete list**

---

## 🔍 What the Playbook Does Automatically

### 1. Prerequisite Check Phase

```
✓ Check if Python 3 is installed
✓ Check if pip3 is installed
✓ Check if git is installed
✓ Display check results
```

### 2. System Package Installation Phase

```
✓ Detect OS family (RedHat vs Debian)
✓ Install missing system packages
  - Python 3 and pip3
  - Development tools (gcc, headers)
  - Security libraries (openssl, sshpass)
  - XML/XSLT libraries
✓ Upgrade pip to latest version
```

### 3. Python Package Installation Phase

```
✓ Check if Robot Framework is installed
✓ Check if SSHLibrary is installed
✓ Install all required Python packages
✓ Verify installation success
✓ Display installed versions
```

### 4. Validation Phase

```
✓ Verify Python 3 is available
✓ Verify Robot Framework is available
✓ Display software versions
```

**If any step fails, the playbook continues with warnings but may fail at test execution.**

---

## 🐛 Troubleshooting

### Issue 1: Permission Denied During Package Installation

**Error:**
```
FAILED! => {"msg": "You need to be root to perform this command."}
```

**Cause:** System package installation requires sudo privileges

**Solution 1:** Run playbook with sudo password:
```bash
ansible-playbook run_tests.yml -e TargetHostname=server01 --ask-become-pass
# Enter sudo password when prompted
```

**Solution 2:** Pre-install system packages manually:
```bash
sudo yum install python3 python3-pip python3-devel git gcc  # RHEL
# OR
sudo apt install python3 python3-pip python3-dev git gcc    # Ubuntu
```

---

### Issue 2: pip Install Fails with "No module named pip"

**Error:**
```
ERROR: No module named pip
```

**Cause:** pip not installed or corrupted

**Solution:**
```bash
# RHEL/CentOS
sudo yum install python3-pip

# Ubuntu/Debian
sudo apt install python3-pip

# OR bootstrap pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user
rm get-pip.py
```

---

### Issue 3: Robot Framework Import Error

**Error:**
```
ModuleNotFoundError: No module named 'robot'
```

**Cause:** Robot Framework not installed or not in Python path

**Solution:**
```bash
# Install Robot Framework
pip3 install --user robotframework

# Verify installation
python3 -m robot --version

# If still fails, check Python path
python3 -c "import sys; print(sys.path)"

# Add user site-packages to PATH
export PATH=$PATH:~/.local/bin
```

---

### Issue 4: SSHLibrary Import Error

**Error:**
```
ModuleNotFoundError: No module named 'SSHLibrary'
```

**Cause:** SSHLibrary not installed

**Solution:**
```bash
# Install SSHLibrary
pip3 install --user robotframework-sshlibrary

# Verify installation
python3 -c "import SSHLibrary; print('OK')"
```

---

### Issue 5: Compilation Errors During pip Install

**Error:**
```
error: command 'gcc' failed with exit status 1
```

**Cause:** Missing development tools or headers

**Solution:**
```bash
# RHEL/CentOS - Install development tools
sudo yum groupinstall "Development Tools"
sudo yum install python3-devel libxml2-devel libxslt-devel libffi-devel openssl-devel

# Ubuntu/Debian - Install build essentials
sudo apt install build-essential python3-dev libxml2-dev libxslt1-dev libffi-dev libssl-dev
```

---

### Issue 6: Certificate Verification Failed

**Error:**
```
SSL: CERTIFICATE_VERIFY_FAILED
```

**Cause:** Corporate proxy or outdated certificates

**Solution:**
```bash
# Option 1: Update certificates
sudo yum update ca-certificates     # RHEL
sudo apt update ca-certificates     # Ubuntu

# Option 2: Upgrade certifi
pip3 install --user --upgrade certifi

# Option 3: Use pip with trusted host (not recommended for production)
pip3 install --user --trusted-host pypi.org --trusted-host files.pythonhosted.org robotframework
```

---

### Issue 7: Installation Works But Robot Command Not Found

**Error:**
```
bash: robot: command not found
```

**Cause:** Robot Framework installed but not in PATH

**Solution:**
```bash
# Use python module syntax instead
python3 -m robot --version
python3 -m robot tests/test3_network_validation/

# OR add to PATH permanently
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc

# Now 'robot' command should work
robot --version
```

---

## 🔒 Security Considerations

### Running with Sudo

**The playbook needs sudo for system package installation only.**

```bash
# Run with become (sudo) - RECOMMENDED for first run
ansible-playbook run_tests.yml \
  -e TargetHostname=server01 \
  --ask-become-pass

# Run without become - use if packages already installed
ansible-playbook run_tests.yml \
  -e TargetHostname=server01
```

---

### Package Installation Location

**System packages:** Installed globally (`/usr/bin`, `/usr/lib`)
- Requires sudo
- Available to all users

**Python packages:** Installed per-user (`~/.local`)
- No sudo required
- User-specific installation
- Flag: `--user` in pip install

---

## 📊 Verification Checklist

After installation, verify:

```bash
# 1. Python 3
python3 --version
# Expected: Python 3.6.x or higher

# 2. pip3
pip3 --version
# Expected: pip 21.x or higher

# 3. Robot Framework
python3 -m robot --version
# Expected: Robot Framework 3.2.x or higher

# 4. SSHLibrary
python3 -c "import SSHLibrary; print(SSHLibrary.VERSION)"
# Expected: 3.7.0 or higher

# 5. All required libraries
python3 << 'EOF'
import robot
import SSHLibrary
import requests
import paramiko
import lxml
import openpyxl
import pandas
print("✅ All required libraries installed")
EOF
# Expected: ✅ All required libraries installed

# 6. Run test execution
./run_tests.sh alhxvdvitap01
# Expected: Tests execute successfully
```

---

## 🔄 Updating/Upgrading

### Update Python Packages

```bash
# Update all packages
pip3 install --user --upgrade -r requirements.txt

# Update specific package
pip3 install --user --upgrade robotframework
```

### Update System Packages

```bash
# RHEL/CentOS
sudo yum update

# Ubuntu/Debian
sudo apt update && sudo apt upgrade
```

---

## 📚 Related Documentation

- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [CREDENTIALS_SETUP.md](CREDENTIALS_SETUP.md) - Credentials setup
- [requirements.txt](requirements.txt) - Python package requirements
- [Test Explanations](docs/test_explanations/) - Individual test documentation

---

## 🆘 Getting Help

If installation fails:

1. Check this troubleshooting section
2. Review playbook output for specific errors
3. Verify system requirements are met
4. Check internet connectivity (for package downloads)
5. Verify sudo access (for system package installation)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Playbook Features:** Automatic prerequisite checking and installation

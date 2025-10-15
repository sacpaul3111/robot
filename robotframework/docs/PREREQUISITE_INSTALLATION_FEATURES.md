# Prerequisite Installation Features - Ansible Playbook

## Overview

The `run_tests.yml` Ansible playbook now includes **comprehensive prerequisite checking and automatic installation** of all required software packages for running Robot Framework tests on Linux servers.

---

## 🎯 What Was Added

### Automatic Prerequisite Management

The playbook now automatically:
1. ✅ **Checks** if prerequisites are installed
2. ✅ **Installs** missing system packages
3. ✅ **Installs** missing Python packages
4. ✅ **Verifies** installation success
5. ✅ **Displays** installed versions

**You don't need to manually install anything!** Just run the playbook.

---

## 🔧 Features Added to run_tests.yml

### 1. Prerequisite Check Phase

```yaml
- name: Check if Python 3 is installed
- name: Check if pip3 is installed
- name: Check if git is installed
- name: Display prerequisite check results
```

**What it does:**
- Checks for Python 3, pip3, and git
- Displays status of each prerequisite
- Continues even if missing (will install next)

---

### 2. System Package Installation

#### For RHEL/CentOS/Rocky Linux:

```yaml
- name: Install system packages (RHEL/CentOS/Rocky)
  yum:
    name:
      - python3
      - python3-pip
      - python3-devel
      - git
      - gcc
      - libxml2-devel
      - libxslt-devel
      - libffi-devel
      - openssl-devel
      - sshpass
```

#### For Ubuntu/Debian:

```yaml
- name: Install system packages (Ubuntu/Debian)
  apt:
    name:
      - python3
      - python3-pip
      - python3-dev
      - git
      - gcc
      - libxml2-dev
      - libxslt1-dev
      - libffi-dev
      - libssl-dev
      - sshpass
```

**What it does:**
- Auto-detects OS family (RedHat vs Debian)
- Installs appropriate packages for the OS
- Only installs if prerequisites are missing
- Requires sudo/become privileges

---

### 3. Python Package Installation

```yaml
- name: Install Robot Framework and required libraries
  pip:
    name:
      - robotframework>=3.2.2
      - robotframework-sshlibrary>=3.7.0
      - robotframework-seleniumlibrary>=5.1.3
      - requests>=2.27.1
      - paramiko>=2.9.2
      - cryptography>=36.0.1
      - lxml>=4.7.1
      - openpyxl>=3.0.9
      - pandas>=1.3.5
```

**What it does:**
- Checks if Robot Framework and SSHLibrary are installed
- Installs all required Python packages with specific versions
- Uses `--user` flag (no sudo required for Python packages)
- Only installs if not already present

---

### 4. Verification Phase

```yaml
- name: Verify Python 3 is available after installation
- name: Verify Robot Framework is available after installation
- name: Display installed versions
```

**What it does:**
- Verifies Python 3 and Robot Framework are working
- Fails playbook if verification fails
- Displays installed versions for troubleshooting

---

## 📦 Installed Packages

### System Packages (Requires Sudo)

| Package | Purpose |
|---------|---------|
| `python3` | Python 3 interpreter |
| `python3-pip` | Python package manager |
| `python3-devel/dev` | Python development headers |
| `git` | Version control system |
| `gcc` | C compiler (for building Python packages) |
| `libxml2-devel/dev` | XML library development files |
| `libxslt-devel/dev` | XSLT library development files |
| `libffi-devel/dev` | Foreign Function Interface library |
| `openssl-devel/dev` | SSL/TLS library |
| `sshpass` | SSH password authentication utility |

---

### Python Packages (No Sudo Required)

| Package | Version | Purpose |
|---------|---------|---------|
| robotframework | ≥3.2.2 | Core test automation framework |
| robotframework-sshlibrary | ≥3.7.0 | SSH connectivity |
| robotframework-seleniumlibrary | ≥5.1.3 | Web UI testing |
| requests | ≥2.27.1 | HTTP/API requests |
| paramiko | ≥2.9.2 | SSH protocol |
| cryptography | ≥36.0.1 | Cryptographic operations |
| lxml | ≥4.7.1 | XML/HTML parsing |
| openpyxl | ≥3.0.9 | Excel file reading (EDS) |
| pandas | ≥1.3.5 | Data analysis |

**Complete list in `requirements.txt`**

---

## 🚀 Usage

### Method 1: Automatic Installation with Sudo (First Run)

```bash
# Run playbook with sudo password for package installation
ansible-playbook run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  --ask-become-pass

# Enter sudo password when prompted
# Playbook will:
# 1. Check prerequisites
# 2. Install missing packages (requires sudo)
# 3. Verify installation
# 4. Run tests
```

---

### Method 2: Using Wrapper Script

```bash
# Wrapper script sources credentials automatically
./run_tests.sh alhxvdvitap01

# If sudo required, it will prompt during execution
```

---

### Method 3: Skip Installation (Already Installed)

```bash
# If packages already installed, run without become
ansible-playbook run_tests.yml \
  -e TargetHostname=alhxvdvitap01

# Playbook will:
# 1. Check prerequisites (all pass)
# 2. Skip installation (already present)
# 3. Run tests
```

---

## 📊 Playbook Output

### Sample Output with Installation:

```
TASK [Display banner]
ok: [localhost] =>
  msg:
  - ========================================================
  - '   GSA Itential Robot Framework - Test Execution'
  - ========================================================
  - 'Operating System:  RedHat 8.5'
  - ========================================================

TASK [Check if Python 3 is installed]
ok: [localhost]

TASK [Check if pip3 is installed]
ok: [localhost]

TASK [Check if git is installed]
ok: [localhost]

TASK [Display prerequisite check results]
ok: [localhost] =>
  msg:
  - 'Prerequisite Check Results:'
  - '  Python 3: Installed'
  - '  pip3:     Installed'
  - '  git:      Installed'

TASK [Install system packages (RHEL/CentOS/Rocky)]
skipping: [localhost]  # Already installed

TASK [Install Robot Framework and required libraries]
changed: [localhost]

TASK [Verify Python 3 is available after installation]
ok: [localhost]

TASK [Verify Robot Framework is available after installation]
ok: [localhost]

TASK [Display installed versions]
ok: [localhost] =>
  msg:
  - 'Installed Software Versions:'
  - '  Python 3.9.7'
  - '  Robot Framework 4.1.3 (Python 3.9.7 on linux)'
```

---

## 🔐 Permissions Required

### System Package Installation (Sudo Required)

Tasks that require sudo:
- Installing system packages (python3, gcc, libraries)
- System-wide package updates

**How to provide sudo:**
```bash
# Option 1: Ask for password at runtime
ansible-playbook run_tests.yml -e TargetHostname=server01 --ask-become-pass

# Option 2: Passwordless sudo (configure in sudoers)
# No additional flags needed

# Option 3: Pre-install packages manually
sudo yum install python3 python3-pip python3-devel git gcc
# Then run playbook without become
```

---

### Python Package Installation (No Sudo Required)

Tasks that don't require sudo:
- Installing Python packages with `pip3 --user`
- Verifying installations
- Running tests

**These run as regular user automatically.**

---

## 🎛️ Customization

### Skip Automatic Installation

If you want to skip automatic installation:

```yaml
# Add to playbook vars:
vars:
  skip_prerequisite_install: true

# Then add condition to install tasks:
when:
  - python3_check.rc != 0
  - not skip_prerequisite_install | default(false)
```

---

### Add Additional Packages

To add more packages:

1. **System packages:** Edit playbook
```yaml
- name: Install system packages (RHEL/CentOS/Rocky)
  yum:
    name:
      - python3
      - your_new_package  # Add here
```

2. **Python packages:** Edit `requirements.txt`
```
robotframework>=3.2.2
your_new_package>=1.0.0  # Add here
```

Then update playbook:
```yaml
- name: Install Robot Framework and required libraries
  pip:
    name:
      - robotframework>=3.2.2
      - your_new_package>=1.0.0  # Add here
```

---

## 🐛 Troubleshooting

### Installation Fails with "Permission Denied"

**Cause:** Need sudo for system packages

**Solution:**
```bash
ansible-playbook run_tests.yml -e TargetHostname=server01 --ask-become-pass
```

---

### Python Packages Install to Wrong Location

**Cause:** Using system pip instead of user pip

**Verify:** Check playbook uses `extra_args: --user`
```yaml
pip:
  extra_args: --user  # Installs to ~/.local
```

---

### Installation Succeeds but Robot Command Not Found

**Cause:** ~/.local/bin not in PATH

**Solution:**
```bash
export PATH=$PATH:~/.local/bin
python3 -m robot --version  # Use module syntax instead
```

---

## 📈 Benefits

### Before (Manual Setup):

1. ❌ Users had to manually install Python 3
2. ❌ Users had to manually install pip3
3. ❌ Users had to manually install Robot Framework
4. ❌ Users had to manually install 10+ Python libraries
5. ❌ Users had to troubleshoot dependency issues
6. ❌ Documentation out of date
7. ❌ Inconsistent environments across servers

---

### After (Automatic Setup):

1. ✅ Playbook checks prerequisites automatically
2. ✅ Playbook installs missing packages automatically
3. ✅ Playbook verifies installation success
4. ✅ Users just run one command
5. ✅ Consistent environment across all servers
6. ✅ Self-documenting (playbook shows what's installed)
7. ✅ Easy to maintain and update

---

## 📚 Related Files

- `run_tests.yml` - Main playbook with prerequisite installation
- `requirements.txt` - Python package requirements
- `INSTALLATION.md` - Complete installation guide
- `QUICKSTART.md` - Quick start guide

---

## 🎯 Summary

**The playbook now handles everything automatically!**

**What you need to do:**
```bash
# 1. Clone repo
git clone https://github.com/your-org/robotframework.git
cd robotframework

# 2. Set up credentials
cp credentials.env.example credentials.env
vim credentials.env
chmod 600 credentials.env

# 3. Run tests (everything else is automatic)
./run_tests.sh alhxvdvitap01
```

**What the playbook does automatically:**
- ✅ Check prerequisites
- ✅ Install missing system packages
- ✅ Install missing Python packages
- ✅ Verify installation
- ✅ Run tests
- ✅ Generate reports

**No manual installation required!** 🎉

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Feature:** Automatic prerequisite installation in Ansible playbook

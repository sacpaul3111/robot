# Robot Framework Test Execution Scripts

## Overview

This directory contains scripts to execute Robot Framework tests across different platforms.

## 📁 Files

### Main Execution Scripts

| File | Platform | Purpose | When to Use |
|------|----------|---------|-------------|
| `run_all_tests.ps1` | Windows | PowerShell script | Manual execution on Windows |
| `run_all_tests.sh` | Linux/macOS | Bash script | Manual execution on Linux/macOS |
| `ansible_playbooks/run_tests.yml` | Linux/macOS | Ansible playbook | CI/CD pipelines, automated execution |

### Supporting Files (in ansible_playbooks/ directory)

| File | Purpose |
|------|---------|
| `ansible_playbooks/execute_test_suite.yml` | Task file included by `run_tests.yml` (for individual test execution) |

## 🚀 Quick Start

### Windows
```powershell
.\run_all_tests.ps1 -TargetHostname "alhxvdvitap01"
```

### Linux/macOS (Bash)
```bash
./run_all_tests.sh --TargetHostname alhxvdvitap01
```

### Linux/macOS (Ansible)
```bash
ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=alhxvdvitap01
```

## 🔧 File Relationships

```
ansible_playbooks/
├── run_tests.yml (Main Ansible Playbook)
│   └── Includes: execute_test_suite.yml (for each test suite)
└── execute_test_suite.yml (Task file)

run_all_tests.sh (Standalone Bash Script)
    └── No dependencies (runs independently)

run_all_tests.ps1 (Standalone PowerShell Script)
    └── No dependencies (runs independently)
```

## ⚙️ Which Script Should I Use?

### Use PowerShell Script (`run_all_tests.ps1`) When:
- ✅ Running on Windows
- ✅ Manual testing
- ✅ Quick test execution
- ✅ No Ansible available

### Use Bash Script (`run_all_tests.sh`) When:
- ✅ Running on Linux/macOS
- ✅ Manual testing
- ✅ No Ansible available or needed
- ✅ Standalone execution

### Use Ansible Playbook (`run_tests.yml`) When:
- ✅ Running on Linux/macOS
- ✅ CI/CD pipeline integration
- ✅ Need detailed test statistics
- ✅ Want test summary files
- ✅ Advanced result parsing needed
- ✅ Part of larger automation workflow

## 📊 Feature Comparison

| Feature | PowerShell | Bash | Ansible |
|---------|-----------|------|---------|
| Auto test discovery | ✅ | ✅ | ✅ |
| Consolidated reports | ✅ | ✅ | ✅ |
| Pass/fail counts | Basic | Basic | Advanced |
| Individual test results | ❌ | ❌ | ✅ |
| Test summary file | ❌ | ❌ | ✅ |
| XML result parsing | ❌ | ❌ | ✅ |
| Fail on errors option | ❌ | ❌ | ✅ |

## 📚 Documentation

- **USAGE_COMPARISON.md** - Side-by-side comparison of all methods
- **ANSIBLE_USAGE.md** - Detailed Ansible playbook usage
- **ANSIBLE_README.md** - Ansible setup and configuration (legacy)

## 🔐 Credentials

All scripts support environment variables for credentials:

**Linux/macOS:**
```bash
export SSH_USERNAME="admin"
export SSH_PASSWORD="password123"
```

**Windows:**
```powershell
$env:SSH_USERNAME = "admin"
$env:SSH_PASSWORD = "password123"
```

## 📤 Output

All scripts create results in the same directory structure:

```
results/
├── test3_network_validation/
├── test5_disk_space_validation/
├── test7_time_configuration_validation/
├── test11_services_validation/
├── test17_mail_configuration/
├── test18_patch_management/
├── test21_tanium_agent/
├── test22_event_logs/
├── all_log.html          # All scripts create this
├── all_output.xml        # All scripts create this
├── all_report.html       # All scripts create this
└── TEST_SUMMARY.txt      # Only Ansible creates this
```

## 🎯 Common Parameters

All scripts use consistent parameter names:

| Parameter | PowerShell | Bash | Ansible |
|-----------|-----------|------|---------|
| **Target Hostname** | `-TargetHostname` | `--TargetHostname` or `-t` | `-e TargetHostname=...` |
| **Username** | `-Username` | `-u` or `--username` | `-e robot_username=...` |
| **Password** | `-Password` | `-p` or `--password` | `-e robot_password=...` |
| **Output Dir** | `-OutputDir` | `-o` or `--output` | `-e robot_output_dir=...` |

## 🔍 Dependencies

### PowerShell Script
- Python with Robot Framework
- SSH libraries installed
- Windows OS

### Bash Script
- Python3 with Robot Framework
- SSH libraries installed
- Linux/macOS OS

### Ansible Playbook
- Ansible installed
- Python3 with Robot Framework
- SSH libraries installed
- lxml library (for XML parsing)
- Linux/macOS OS

## 💡 Tips

1. **Use environment variables** for credentials instead of command line parameters
2. **Use Ansible playbook** for CI/CD pipelines (better reporting)
3. **Use bash/PowerShell scripts** for manual testing
4. **Never commit credentials** to version control
5. **Check TEST_SUMMARY.txt** (Ansible only) for detailed results

## 🐛 Troubleshooting

### All Scripts
```bash
# Verify credentials are set
echo $SSH_USERNAME  # Linux/macOS
echo $env:SSH_USERNAME  # Windows

# Check Python/Robot Framework
python --version
robot --version

# Verify EDS Excel file exists and has target hostname
```

### Ansible Specific
```bash
# Install lxml for XML parsing
pip install lxml

# Run with verbose output
ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=server01 -vv

# Check Ansible version
ansible --version
```

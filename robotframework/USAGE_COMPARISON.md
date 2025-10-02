# Robot Framework Test Execution - Usage Comparison

## Quick Reference: PowerShell vs Bash vs Ansible

All three methods use the **same variable name format** for consistency.

### Windows (PowerShell)

```powershell
# Set credentials as environment variables
$env:SSH_USERNAME = "admin"
$env:SSH_PASSWORD = "password123"

# Run tests
.\run_all_tests.ps1 -TargetHostname "alhxvdvitap01"

# OR with inline credentials
.\run_all_tests.ps1 -TargetHostname "alhxvdvitap01" -Username "admin" -Password "password123"

# Custom output directory
.\run_all_tests.ps1 -TargetHostname "alhxvdvitap01" -OutputDir "custom_results"
```

### Linux (Bash Script)

```bash
# Set credentials as environment variables
export SSH_USERNAME="admin"
export SSH_PASSWORD="password123"

# Run tests (supports all these formats)
./run_all_tests.sh --TargetHostname alhxvdvitap01
./run_all_tests.sh --target alhxvdvitap01
./run_all_tests.sh -t alhxvdvitap01

# OR with inline credentials
./run_all_tests.sh -t alhxvdvitap01 -u admin -p password123

# Custom output directory
./run_all_tests.sh -t alhxvdvitap01 -o custom_results
```

### Linux (Ansible Playbook)

```bash
# Set credentials as environment variables
export SSH_USERNAME="admin"
export SSH_PASSWORD="password123"

# Run tests (supports both PowerShell and Ansible style)
ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=alhxvdvitap01
# OR
ansible-playbook ansible_playbooks/run_tests.yml -e target_hostname=alhxvdvitap01

# OR with inline credentials
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e robot_username=admin \
  -e robot_password=password123

# Custom output directory
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e robot_output_dir=custom_results

# Fail on test errors
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e fail_on_test_errors=true
```

## Parameter/Variable Names

### Target Hostname
| Method | Accepted Formats |
|--------|-----------------|
| PowerShell | `-TargetHostname` |
| Bash | `-t`, `--target`, `--TargetHostname` |
| Ansible | `-e TargetHostname=...` or `-e target_hostname=...` |

### Username
| Method | Accepted Formats |
|--------|-----------------|
| PowerShell | `-Username` or `$env:SSH_USERNAME` |
| Bash | `-u`, `--username` or `$SSH_USERNAME` |
| Ansible | `-e robot_username=...` or `$SSH_USERNAME` |

### Password
| Method | Accepted Formats |
|--------|-----------------|
| PowerShell | `-Password` or `$env:SSH_PASSWORD` |
| Bash | `-p`, `--password` or `$SSH_PASSWORD` |
| Ansible | `-e robot_password=...` or `$SSH_PASSWORD` |

### Output Directory
| Method | Accepted Formats |
|--------|-----------------|
| PowerShell | `-OutputDir` (default: `results`) |
| Bash | `-o`, `--output` (default: `results`) |
| Ansible | `-e robot_output_dir=...` (default: `results`) |

## Feature Comparison

| Feature | PowerShell | Bash | Ansible |
|---------|-----------|------|---------|
| **Platform** | Windows | Linux/macOS | Linux/macOS |
| **Auto test discovery** | ✅ | ✅ | ✅ |
| **Consolidated reports** | ✅ | ✅ | ✅ |
| **Pass/fail summary** | ✅ | ✅ | ✅ Enhanced |
| **Individual test results** | ❌ | ❌ | ✅ |
| **Test summary file** | ❌ | ❌ | ✅ |
| **XML result parsing** | ❌ | ❌ | ✅ |
| **Fail on errors option** | ❌ | ❌ | ✅ |
| **CI/CD integration** | ✅ | ✅ | ✅ Best |
| **Verbose mode** | ✅ | ✅ | ✅ |
| **Environment variables** | ✅ | ✅ | ✅ |

## When to Use Which Method?

### Use PowerShell Script When:
- ✅ Running on **Windows** systems
- ✅ Manual test execution from Windows workstation
- ✅ Simple, straightforward test runs
- ✅ No need for advanced result parsing

### Use Bash Script When:
- ✅ Running on **Linux/macOS** systems
- ✅ Manual test execution from Linux terminal
- ✅ Standalone script without dependencies
- ✅ Quick test runs without Ansible

### Use Ansible Playbook When:
- ✅ Running on **Linux/macOS** systems
- ✅ Need **detailed pass/fail statistics**
- ✅ Want **individual test suite results**
- ✅ **CI/CD pipeline** integration (Jenkins, GitLab, GitHub Actions)
- ✅ Need **test summary files** for reporting
- ✅ Want to **fail pipeline** on test failures
- ✅ Advanced result parsing and analysis
- ✅ Part of larger automation workflow

## Environment Variables (All Methods)

Set these before running tests:

### Linux/macOS/Ansible
```bash
export SSH_USERNAME="your_username"
export SSH_PASSWORD="your_password"
```

### Windows PowerShell
```powershell
$env:SSH_USERNAME = "your_username"
$env:SSH_PASSWORD = "your_password"
```

### Making Variables Persistent

**Linux/macOS (.bashrc or .bash_profile):**
```bash
echo 'export SSH_USERNAME="admin"' >> ~/.bashrc
echo 'export SSH_PASSWORD="secret123"' >> ~/.bashrc
source ~/.bashrc
```

**Windows PowerShell (Profile):**
```powershell
# Edit profile
notepad $PROFILE

# Add these lines:
$env:SSH_USERNAME = "admin"
$env:SSH_PASSWORD = "secret123"
```

## Output Location (All Methods)

Default output directory: `results/`

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
├── all_log.html          # Consolidated log (all methods)
├── all_output.xml        # Consolidated output (all methods)
├── all_report.html       # Consolidated report (all methods)
└── TEST_SUMMARY.txt      # Summary file (Ansible only)
```

## Examples Side-by-Side

### Same Command, Different Platforms

**Goal:** Run all tests against server "alhxvdvitap01" with credentials

**Windows (PowerShell):**
```powershell
.\run_all_tests.ps1 -TargetHostname "alhxvdvitap01" -Username "admin" -Password "secret"
```

**Linux (Bash):**
```bash
./run_all_tests.sh --TargetHostname alhxvdvitap01 -u admin -p secret
```

**Linux (Ansible):**
```bash
ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=alhxvdvitap01 -e robot_username=admin -e robot_password=secret
```

## CI/CD Usage

### Jenkins (Windows)
```groovy
bat """
    .\\run_all_tests.ps1 -TargetHostname ${TARGET_HOST}
"""
```

### Jenkins (Linux - Bash)
```groovy
sh """
    ./run_all_tests.sh --TargetHostname ${TARGET_HOST}
"""
```

### Jenkins (Linux - Ansible)
```groovy
sh """
    ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=${TARGET_HOST}
"""
```

### GitLab CI
```yaml
test:
  script:
    - ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=${TARGET_HOST}
```

## Best Practices

1. **Always use environment variables** for credentials in CI/CD
2. **Never commit credentials** to version control
3. **Use Ansible playbook** for CI/CD pipelines (better reporting)
4. **Use bash script** for manual testing on Linux
5. **Use PowerShell script** for manual testing on Windows
6. **Set fail_on_test_errors=true** in CI/CD to fail pipeline on test failures

## Troubleshooting

### All Methods
- Verify credentials: `echo $SSH_USERNAME` (Linux) or `echo $env:SSH_USERNAME` (Windows)
- Check EDS Excel file has correct IP for hostname
- Verify network connectivity to target server
- Check Python and Robot Framework are installed

### Ansible-Specific
- Install lxml: `pip install lxml`
- Run with verbose: `-vv` or `-vvv`
- Check inventory.ini is accessible

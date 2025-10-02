# Ansible Playbook for Robot Framework Tests

## Overview

This is a unified Ansible playbook that executes all Robot Framework test suites **without requiring a separate bash script**. The playbook handles everything: test discovery, execution, result consolidation, and pass/fail reporting.

## Files

All Ansible files are located in the `ansible_playbooks/` directory:

- `ansible_playbooks/run_tests.yml` - Main Ansible playbook (unified approach)
- `ansible_playbooks/execute_test_suite.yml` - Task file for individual test execution (included by main playbook)

## Quick Start

### Prerequisites

```bash
# Install Ansible
pip3 install ansible

# Or using system package manager
sudo apt-get install ansible  # Debian/Ubuntu
sudo yum install ansible      # RHEL/CentOS

# Install Python XML library (required for result parsing)
pip3 install lxml
```

### Basic Usage

```bash
# Set credentials (required)
export SSH_USERNAME="your_username"
export SSH_PASSWORD="your_password"

# Run all tests (PowerShell-style variable name)
ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=alhxvdvitap01

# OR using Ansible-style variable name (both work)
ansible-playbook ansible_playbooks/run_tests.yml -e target_hostname=alhxvdvitap01
```

That's it! The playbook will:
1. ✅ Find all test suites automatically
2. ✅ Execute each test suite
3. ✅ Collect and parse results
4. ✅ Generate consolidated reports
5. ✅ Display pass/fail summary with results path
6. ✅ Save summary to `results/TEST_SUMMARY.txt`

## Usage Examples

### Example 1: Basic Execution (PowerShell-style)

```bash
export SSH_USERNAME="admin"
export SSH_PASSWORD="password123"

# Using PowerShell-style variable name (matches run_all_tests.ps1)
ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=alhxvdvitap01
```

### Example 2: Basic Execution (Ansible-style)

```bash
export SSH_USERNAME="admin"
export SSH_PASSWORD="password123"

# Using Ansible-style variable name
ansible-playbook ansible_playbooks/run_tests.yml -e target_hostname=alhxvdvitap01
```

### Example 3: Custom Output Directory

```bash
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e robot_output_dir=custom_results
```

### Example 4: Inline Credentials (Not Recommended)

```bash
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e robot_username=admin \
  -e robot_password=secret123
```

### Example 5: Fail on Test Errors

```bash
# Playbook will fail (exit code 1) if any tests fail
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e fail_on_test_errors=true
```

### Example 6: Verbose Output

```bash
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -vv
```

### Example 7: Using Custom Inventory

```bash
ansible-playbook -i custom_inventory.ini run_tests.yml \
  -e TargetHostname=alhxvdvitap01
```

## Playbook Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `TargetHostname` or `target_hostname` | Target server hostname (both formats accepted) | - | **Yes** |
| `robot_username` | SSH username | `$SSH_USERNAME` | **Yes** |
| `robot_password` | SSH password | `$SSH_PASSWORD` | **Yes** |
| `robot_output_dir` | Results directory | `results` | No |
| `robot_project_dir` | Project root | `{{ playbook_dir }}` | No |
| `robot_python_venv` | Python venv path | `{{ playbook_dir }}/venv` | No |
| `fail_on_test_errors` | Fail playbook on test errors | `false` | No |

## Output and Results

### Console Output

The playbook displays:

```
========================================================
   GSA Itential Robot Framework - Test Execution
========================================================
Project Directory: /path/to/robotframework
Target Hostname:   alhxvdvitap01
Output Directory:  results
========================================================

Found 8 test suite(s)

========================================================
Executing: test3_network_validation
Test ID:   test3
========================================================
[Test execution output...]

Test Suite: test3_network_validation
Status:     PASSED ✅
Passed:     5
Failed:     0
Total:      5

========================================================
           TEST EXECUTION SUMMARY
========================================================
Total Tests:    45
Passed Tests:   42
Failed Tests:   3
========================================================
Overall Status: FAILED ❌
========================================================

Results Location:
  Directory:    /path/to/robotframework/results
  Log:          /path/to/robotframework/results/all_log.html
  Report:       /path/to/robotframework/results/all_report.html
========================================================
```

### Results Directory Structure

```
results/
├── test3_network_validation/
│   ├── log.html
│   ├── output.xml
│   ├── report.html
│   └── data/
├── test5_disk_space_validation/
│   └── ...
├── test7_time_configuration_validation/
│   └── ...
├── test11_services_validation/
│   └── ...
├── test17_mail_configuration/
│   └── ...
├── test18_patch_management/
│   └── ...
├── test21_tanium_agent/
│   └── ...
├── test22_event_logs/
│   └── ...
├── all_log.html          # ⭐ Consolidated log
├── all_output.xml        # ⭐ Consolidated output
├── all_report.html       # ⭐ Consolidated report
└── TEST_SUMMARY.txt      # ⭐ Test summary file
```

### TEST_SUMMARY.txt

The playbook creates a summary file with:

```
========================================================
GSA Itential Robot Framework - Test Execution Summary
========================================================
Execution Date: 2025-10-01T19:30:45Z
Target Hostname: alhxvdvitap01

========================================================
RESULTS SUMMARY
========================================================
Total Tests:    45
Passed Tests:   42
Failed Tests:   3
Overall Status: FAILED

========================================================
INDIVIDUAL TEST SUITES
========================================================
[test3] test3_network_validation: PASSED ✅ (5/5 passed)
[test5] test5_disk_space_validation: PASSED ✅ (7/7 passed)
[test7] test7_time_configuration_validation: PASSED ✅ (6/6 passed)
[test11] test11_services_validation: FAILED ❌ (6/8 passed)
[test17] test17_mail_configuration: PASSED ✅ (10/10 passed)
[test18] test18_patch_management: FAILED ❌ (8/10 passed)
[test21] test21_tanium_agent: PASSED ✅ (8/8 passed)
[test22] test22_event_logs: FAILED ❌ (2/3 passed)

========================================================
RESULTS LOCATION
========================================================
Directory:  /path/to/robotframework/results
Log:        /path/to/robotframework/results/all_log.html
Report:     /path/to/robotframework/results/all_report.html
========================================================
```

## CI/CD Integration

### Jenkins Pipeline Example

```groovy
pipeline {
    agent any

    environment {
        SSH_USERNAME = credentials('robot-ssh-username')
        SSH_PASSWORD = credentials('robot-ssh-password')
    }

    stages {
        stage('Run Robot Tests') {
            steps {
                sh '''
                    ansible-playbook ansible_playbooks/run_tests.yml \
                        -e target_hostname=${TARGET_HOST} \
                        -e fail_on_test_errors=true
                '''
            }
        }
    }

    post {
        always {
            publishHTML([
                reportDir: 'results',
                reportFiles: 'all_report.html',
                reportName: 'Robot Framework Report'
            ])
            archiveArtifacts artifacts: 'results/**/*', fingerprint: true
        }
    }
}
```

### GitLab CI Example

```yaml
# .gitlab-ci.yml
test:
  stage: test
  image: python:3.9

  before_script:
    - pip install ansible lxml
    - pip install robotframework robotframework-sshlibrary openpyxl

  script:
    - export SSH_USERNAME="${ROBOT_SSH_USER}"
    - export SSH_PASSWORD="${ROBOT_SSH_PASS}"
    - ansible-playbook ansible_playbooks/run_tests.yml
        -e target_hostname="${TARGET_HOST}"
        -e fail_on_test_errors=true

  artifacts:
    when: always
    paths:
      - results/
    reports:
      junit: results/*/output.xml
```

### GitHub Actions Example

```yaml
# .github/workflows/robot-tests.yml
name: Robot Framework Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'

      - name: Install dependencies
        run: |
          pip install ansible lxml
          pip install robotframework robotframework-sshlibrary openpyxl

      - name: Run Robot tests
        env:
          SSH_USERNAME: ${{ secrets.ROBOT_SSH_USER }}
          SSH_PASSWORD: ${{ secrets.ROBOT_SSH_PASS }}
        run: |
          ansible-playbook ansible_playbooks/run_tests.yml \
            -e target_hostname=${{ secrets.TARGET_HOST }} \
            -e fail_on_test_errors=true

      - name: Upload results
        uses: actions/upload-artifact@v2
        if: always()
        with:
          name: robot-results
          path: results/
```

## Alternative: Standalone Bash Script

If you prefer not to use Ansible, you can use the standalone bash script:

```bash
# Make executable (first time only)
chmod +x run_all_tests.sh

# Run tests
./run_all_tests.sh -t alhxvdvitap01 -u admin -p password

# Or with environment variables
export SSH_USERNAME="admin"
export SSH_PASSWORD="password"
./run_all_tests.sh -t alhxvdvitap01
```

**Note:** The bash script doesn't have the advanced result parsing and summary features of the Ansible playbook.

## Troubleshooting

### Error: "lxml not found"

```bash
pip3 install lxml
```

### Error: "No module named robot"

```bash
# Activate venv or install Robot Framework
source venv/bin/activate
pip install robotframework robotframework-sshlibrary openpyxl
```

### Error: "SSH connection failed"

- Verify credentials: `echo $SSH_USERNAME $SSH_PASSWORD`
- Check EDS Excel file has correct IP for hostname
- Verify network connectivity to target
- Check firewall allows SSH (port 22)

### Error: "Target hostname is required"

```bash
# Make sure to pass target_hostname
ansible-playbook ansible_playbooks/run_tests.yml -e target_hostname=your_hostname
```

### Verbose debugging

```bash
ansible-playbook ansible_playbooks/run_tests.yml \
  -e target_hostname=alhxvdvitap01 \
  -vvv
```

## Security Best Practices

### 1. Use Ansible Vault for Credentials

```bash
# Create encrypted file
ansible-vault create vault.yml

# Add to vault.yml:
vault_ssh_username: admin
vault_ssh_password: secret123

# Run playbook with vault
ansible-playbook ansible_playbooks/run_tests.yml \
  -e target_hostname=server01 \
  -e robot_username="{{ vault_ssh_username }}" \
  -e robot_password="{{ vault_ssh_password }}" \
  --vault-password-file ~/.vault_pass
```

### 2. Use Environment Variables in CI/CD

Always store credentials as CI/CD secrets, never in code.

### 3. Restrict File Permissions

```bash
chmod 600 inventory.ini
chmod 644 run_tests.yml
```

### 4. Use SSH Keys (Future Enhancement)

Consider modifying tests to use SSH key authentication instead of passwords.

## Advanced Usage

### Run Specific Test Suite Only

Modify the playbook or use tags (future enhancement), or use Robot Framework directly:

```bash
source venv/bin/activate
python -m robot \
  --variable SSH_USERNAME:admin \
  --variable SSH_PASSWORD:secret \
  --variable TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test3_network_validation \
  tests/test3_network_validation/network_validation.robot
```

### Custom Results Processing

The playbook stores results in variables that you can use for custom processing:

- `all_tests_passed` - Boolean: true if all tests passed
- `total_count` - Total number of tests
- `passed_count` - Number of passed tests
- `failed_count` - Number of failed tests
- `results_directory` - Path to results directory
- `test_results` - List of individual test suite results

## Support

For issues:
1. Check the TEST_SUMMARY.txt file in results directory
2. Review consolidated report at results/all_report.html
3. Check individual test logs in results/<test_name>/log.html
4. Run with verbose mode: `-vv` or `-vvv`

# Robot Framework Ansible Playbooks

This directory contains Ansible playbooks for executing Robot Framework tests.

## Available Playbooks

### 1. run_tests.yml (Full Output)
**Use when:** You want detailed output and logs during test execution

**Features:**
- Displays full test execution output
- Shows individual test suite results
- Creates comprehensive HTML reports
- Displays pass/fail summary at the end

**Usage:**
```bash
# Method 1: With extra variables
ansible-playbook run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e SSH_USERNAME=robotuser \
  -e SSH_PASSWORD='YourPassword'

# Method 2: With environment variables
export SSH_USERNAME=robotuser
export SSH_PASSWORD='YourPassword'
ansible-playbook run_tests.yml -e TargetHostname=alhxvdvitap01
```

---

### 2. run_tests_silent.yml (Silent Mode)
**Use when:** You only need the final status and artifacts URL (e.g., for CI/CD integration, Itential, or Ansible Tower)

**Features:**
- Suppresses all verbose output
- Returns only 2 variables:
  - `overall_status`: PASSED or FAILED
  - `nexus_artifacts_url`: URL to artifacts
- Logs detailed output to `/tmp/ansible_robot_output_<hostname>.log`
- Uses `set_stats` for Tower/AWX integration

**Usage:**
```bash
# Method 1: With extra variables
ansible-playbook run_tests_silent.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e SSH_USERNAME=robotuser \
  -e SSH_PASSWORD='YourPassword'

# Method 2: Using wrapper script
./run_tests_silent.sh alhxvdvitap01

# Method 3: With environment variables
export SSH_USERNAME=robotuser
export SSH_PASSWORD='YourPassword'
ansible-playbook run_tests_silent.yml -e TargetHostname=alhxvdvitap01
```

**Output Example:**
```
========================================================
ROBOT FRAMEWORK TEST RESULTS
========================================================
Overall Status:      PASSED
Nexus Artifacts URL: https://nexus.company.com/repository/robot-framework-artifacts/alhxvdvitap01/2025-10-17T14-30-15
Detailed Log:        /tmp/ansible_robot_output_alhxvdvitap01.log
========================================================
```

---

## Credential Management

Both playbooks support three methods of providing credentials (in priority order):

1. **Extra Variables** (Highest Priority)
   ```bash
   -e SSH_USERNAME=user -e SSH_PASSWORD=pass
   ```

2. **Environment Variables** (Fallback)
   ```bash
   export SSH_USERNAME=user
   export SSH_PASSWORD=pass
   ```

3. **Ansible Vault** (Production - for run_tests.yml only)
   ```bash
   ansible-playbook run_tests.yml \
     -e TargetHostname=hostname \
     -e @/etc/ansible/vault/robot_credentials.yml \
     --vault-password-file=/etc/ansible/vault/.vault_pass
   ```

---

## Integration with Itential/Ansible Tower

For Itential or Ansible Tower/AWX integration, use **run_tests_silent.yml**:

1. The playbook uses `set_stats` to expose variables to Tower/AWX
2. Access variables in subsequent workflow steps:
   - `overall_status`: Test execution result (PASSED/FAILED)
   - `nexus_artifacts_url`: URL to test artifacts
   - `detailed_log`: Path to detailed execution log

### Tower/AWX Workflow Example:
```yaml
- name: Run Robot Framework Tests
  job_template: "Robot Framework - Silent Mode"
  register: robot_tests

- name: Check if tests passed
  assert:
    that:
      - robot_tests.artifacts.overall_status == "PASSED"
    fail_msg: "Robot Framework tests failed. Artifacts: {{ robot_tests.artifacts.nexus_artifacts_url }}"
```

---

## Output Locations

### run_tests.yml
- **Results Directory:** `robotframework/results/`
- **Consolidated Report:** `robotframework/results/all_report.html`
- **Consolidated Log:** `robotframework/results/all_log.html`
- **Summary File:** `robotframework/results/TEST_SUMMARY.txt`

### run_tests_silent.yml
- **Results Directory:** `robotframework/results/` (same as above)
- **Detailed Execution Log:** `/tmp/ansible_robot_output_<hostname>.log`
- **Summary File:** `robotframework/results/TEST_SUMMARY.txt`

---

## Troubleshooting

### Issue: "SSH credentials required" error with environment variables

**Solution:** Pass credentials as extra variables instead:
```bash
ansible-playbook run_tests.yml \
  -e TargetHostname=hostname \
  -e SSH_USERNAME=user \
  -e SSH_PASSWORD='password'
```

### Issue: Need to see detailed logs from silent mode

**Solution:** Check the detailed log file:
```bash
tail -f /tmp/ansible_robot_output_<hostname>.log
```

### Issue: Tests fail but need more information

**Solution:** Run with full output playbook:
```bash
ansible-playbook run_tests.yml -e TargetHostname=hostname -e SSH_USERNAME=user -e SSH_PASSWORD='pass'
```

---

## Files in this Directory

- `run_tests.yml` - Main playbook with full output
- `run_tests_silent.yml` - Silent mode playbook
- `execute_test_suite.yml` - Included task file (used by run_tests.yml)
- `run_tests_silent.sh` - Wrapper script for silent mode
- `README_PLAYBOOKS.md` - This file

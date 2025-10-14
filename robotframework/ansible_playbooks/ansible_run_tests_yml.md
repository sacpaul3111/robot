# Ansible Playbook: run_tests.yml - Working Explanation

## Playbook Information
- **Playbook File**: `ansible_playbooks/run_tests.yml`
- **Purpose**: Execute all Robot Framework tests with comprehensive pass/fail tracking and reporting
- **Integration**: Designed for Itential automation platform integration
- **Execution**: Runs on localhost, executes tests against remote targets

---

## Overview

The `run_tests.yml` Ansible playbook orchestrates Robot Framework test execution by:
1. Discovering all test suites in the `tests/` directory
2. Executing each test suite sequentially
3. Collecting individual test results
4. Generating consolidated reports using Robot Framework's `rebot` tool
5. Providing pass/fail summary with boolean `all_tests_passed` variable for Itential

---

## Playbook Structure

```yaml
Playbook: run_tests.yml
├─> Pre-tasks: Validation and Setup
│   ├─ Display banner
│   ├─ Validate target hostname provided
│   ├─ Validate SSH credentials provided
│   └─ Create project directory
├─> Tasks: Test Discovery and Execution
│   ├─ Find all test suite directories
│   ├─ Initialize test results tracking
│   ├─ Execute each test suite (loop)
│   ├─ Create consolidated reports (rebot)
│   ├─ Parse consolidated results
│   └─ Set final test status (all_tests_passed)
└─> Post-tasks: Reporting
    ├─ Display test execution summary
    ├─ Display individual test results
    ├─ Save test summary to file
    └─ Optional: Fail playbook if tests failed
```

---

## Key Variables

### Input Variables (Command Line)
```yaml
# Required Variables
TargetHostname: <hostname>     # Target server to test (from Itential)

# Optional Variables (defaults from environment)
ssh_username: $SSH_USERNAME    # SSH username for target
ssh_password: $SSH_PASSWORD    # SSH password for target

# vCenter Credentials (for VM/datastore tests)
vcenter_username: $VCENTER_USERNAME
vcenter_password: $VCENTER_PASSWORD

# Service Credentials (for various tests)
splunk_username: $SPLUNK_USERNAME
cyberark_username: $CYBERARK_USERNAME
tanium_username: $TANIUM_USERNAME
ansible_tower_username: $ANSIBLE_TOWER_USERNAME

# Execution Settings
fail_on_test_errors: false     # Don't fail playbook if tests fail (default)
```

### Internal Variables
```yaml
robot_project_dir: "{{ playbook_dir }}/.."    # Robot Framework project root
robot_output_dir: "results"                    # Test results directory
python_executable: "python3"                   # Python interpreter

# Test Tracking Variables
test_results: []              # List of test results
all_output_files: []          # List of output.xml files for rebot
total_tests: 0                # Total test count
passed_tests: 0               # Passed test count
failed_tests: 0               # Failed test count
```

---

## Detailed Playbook Flow

### **Pre-task 1: Display Banner**
**Purpose**: Show execution information

**Output**:
```
========================================================
   GSA Itential Robot Framework - Test Execution
========================================================
Project Directory: /path/to/robotframework
Target Hostname:   alhxvdvitap01
Output Directory:  results
========================================================
```

---

### **Pre-task 2: Validate Target Hostname**
**Purpose**: Ensure `TargetHostname` is provided

**Logic**:
```yaml
when: target_hostname == ''
fail: ERROR: Target hostname is required!
```

**Why**: Prevents running tests without specifying target server

**Example**:
```bash
# Correct usage
ansible-playbook run_tests.yml -e TargetHostname=alhxvdvitap01

# Incorrect - will fail
ansible-playbook run_tests.yml
```

---

### **Pre-task 3: Validate SSH Credentials**
**Purpose**: Ensure SSH credentials are provided

**Logic**:
```yaml
when: ssh_username == '' or ssh_password == ''
fail: ERROR: SSH credentials required!
```

**Why**: Tests require SSH access to target server

**Credential Sources**:
1. Environment variables: `$SSH_USERNAME`, `$SSH_PASSWORD`
2. Command line: `-e ssh_username=user -e ssh_password=pass`

---

### **Task 1: Find All Test Suite Directories**
**Purpose**: Auto-discover test suites in `tests/` directory

**Logic**:
```yaml
find:
  paths: "{{ robot_project_dir }}/tests"
  file_type: directory
  patterns: 'test*_*'
register: test_directories
```

**Discovers**: test3_network_validation, test5_disk_space_validation, test7_time_configuration_validation, etc.

**Output**: List of test directories sorted alphabetically

---

### **Task 2: Initialize Test Results Tracking**
**Purpose**: Set up variables to track test execution

**Variables Initialized**:
```yaml
test_results: []       # Empty list for test results
all_output_files: []   # Empty list for output.xml files
total_tests: 0         # Counter for total tests
passed_tests: 0        # Counter for passed tests
failed_tests: 0        # Counter for failed tests
```

---

### **Task 3: Execute Each Test Suite**
**Purpose**: Run each discovered test suite using Robot Framework

**Logic**:
```yaml
include_tasks: execute_test_suite.yml
loop: "{{ test_directories.files | sort(attribute='path') }}"
loop_var: test_dir
```

**For Each Test Suite**:
1. Extract test suite name (e.g., "test3_network_validation")
2. Build robot command with proper arguments:
   ```bash
   python3 -m robot \
     --variable TARGET_HOSTNAME:alhxvdvitap01 \
     --variable SSH_USERNAME:admin \
     --variable SSH_PASSWORD:*** \
     --outputdir results/test3_network_validation \
     --output output.xml \
     --log log.html \
     --report report.html \
     tests/test3_network_validation/
   ```
3. Execute robot command
4. Capture exit code and results
5. Parse output.xml for pass/fail statistics
6. Append to `test_results` list
7. Append output.xml path to `all_output_files`

**Test Suite Execution File**: `execute_test_suite.yml` (separate task file)

---

### **Task 4: Create Consolidated Reports**
**Purpose**: Merge all individual test results into single report using `rebot`

**Logic**:
```yaml
command: >
  python3 -m robot.rebot
    --outputdir results
    --output all_output.xml
    --log all_log.html
    --report all_report.html
    {{ all_output_files | join(' ') }}
```

**Input**: All individual `output.xml` files from each test suite

**Output**:
- `results/all_output.xml` - Consolidated test results (machine-readable)
- `results/all_log.html` - Consolidated test log (human-readable)
- `results/all_report.html` - Consolidated test report (summary)

**Why**: Provides single source of truth for all test results

---

### **Task 5: Parse Consolidated Results**
**Purpose**: Extract pass/fail statistics from consolidated output.xml

**Logic**:
```yaml
xml:
  path: "{{ robot_project_dir }}/results/all_output.xml"
  xpath: /robot/statistics/total/stat
  content: attribute
register: final_statistics
```

**Extracts**:
- `pass` attribute - Number of passed tests
- `fail` attribute - Number of failed tests

**Example XML**:
```xml
<statistics>
  <total>
    <stat pass="45" fail="2">All Tests</stat>
  </total>
</statistics>
```

---

### **Task 6: Set Final Test Status**
**Purpose**: Calculate `all_tests_passed` boolean for Itential

**Logic**:
```yaml
all_tests_passed: "{{ (failed_tests_final | int) == 0 and (total_tests_final | int) > 0 }}"
```

**Boolean Calculation**:
- `true` if: 0 failures AND at least 1 test ran
- `false` if: any failures OR no tests ran

**Why This Logic**:
1. `failed_tests == 0` - No test failures
2. `total_tests > 0` - Prevents false positive if no tests executed
3. Combined with AND - Both conditions must be true

**Itential Integration**:
```python
# Itential can check this variable after playbook completes
if ansible_result['all_tests_passed'] == true:
    # All tests passed - proceed with deployment
else:
    # Tests failed - block deployment
```

---

### **Task 7: Set Nexus Artifacts URL**
**Purpose**: Generate Nexus OSS URL for test artifacts

**Logic**:
```yaml
nexus_artifacts_url: "https://nexus.company.com/repository/robot-framework-artifacts/{{ target_hostname }}/{{ ansible_date_time.iso8601 | regex_replace('[:]', '-') }}"
```

**URL Format**:
```
https://nexus.company.com/repository/robot-framework-artifacts/<hostname>/<timestamp>

Example:
https://nexus.company.com/repository/robot-framework-artifacts/alhxvdvitap01/2025-10-14T15-30-00Z
```

**Why**: Provides unique URL for Itential to access test artifacts after upload to Nexus

---

### **Post-task 1: Display Test Execution Summary**
**Purpose**: Show comprehensive test results to console

**Output**:
```
========================================================
           TEST EXECUTION SUMMARY
========================================================
Total Tests:    47
Passed Tests:   45
Failed Tests:   2
========================================================
Overall Status: FAILED ❌
========================================================

Results Location:
  Directory:    /path/to/results
  Log:          /path/to/results/all_log.html
  Report:       /path/to/results/all_report.html

Artifacts URL (Nexus OSS):
  https://nexus.company.com/repository/robot-framework-artifacts/alhxvdvitap01/2025-10-14T15-30-00Z
========================================================
```

---

### **Post-task 2: Save Test Summary to File**
**Purpose**: Save summary to `TEST_SUMMARY.txt` for Itential parsing

**File**: `results/TEST_SUMMARY.txt`

**Content**:
```
========================================================
GSA Itential Robot Framework - Test Execution Summary
========================================================
Execution Date: 2025-10-14T15:30:00Z
Target Hostname: alhxvdvitap01

========================================================
RESULTS SUMMARY
========================================================
Total Tests:    47
Passed Tests:   45
Failed Tests:   2
Overall Status: FAILED

========================================================
INDIVIDUAL TEST SUITES
========================================================
test3_network_validation: PASSED (6/6 tests)
test5_disk_space_validation: PASSED (8/8 tests)
test7_time_configuration_validation: PASSED (7/7 tests)
test11_services_validation: PASSED (6/6 tests)
test17_mail_configuration: FAILED (7/8 tests)
...

========================================================
RESULTS LOCATION
========================================================
Directory:  /path/to/results
Log:        /path/to/results/all_log.html
Report:     /path/to/results/all_report.html

========================================================
ARTIFACTS URL (NEXUS OSS)
========================================================
https://nexus.company.com/repository/robot-framework-artifacts/alhxvdvitap01/2025-10-14T15-30-00Z
========================================================
```

**Why**: Itential can parse this file for test results and artifact URLs

---

### **Post-task 3: Optional Playbook Failure**
**Purpose**: Fail playbook if tests failed (when `fail_on_test_errors: true`)

**Logic**:
```yaml
when:
  - not all_tests_passed
  - fail_on_test_errors | bool
fail:
  msg: |
    ❌ TEST EXECUTION FAILED ❌
    {{ failed_count }} test(s) failed
    Check reports at: {{ results_directory }}
```

**Default**: `fail_on_test_errors: false` (playbook succeeds even if tests fail)

**Why**: Allows Itential to decide how to handle test failures based on `all_tests_passed` variable

---

## Execution Examples

### Basic Execution
```bash
ansible-playbook run_tests.yml \
  -e TargetHostname=alhxvdvitap01
```

### With Explicit Credentials
```bash
ansible-playbook run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e ssh_username=admin \
  -e ssh_password=SecurePass123
```

### Fail Playbook on Test Failures
```bash
ansible-playbook run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  -e fail_on_test_errors=true
```

### From Itential
```python
# Itential workflow calls Ansible
ansible_job = {
    'playbook': 'run_tests.yml',
    'extra_vars': {
        'TargetHostname': 'alhxvdvitap01',
        'ssh_username': '{{ vault.ssh_user }}',
        'ssh_password': '{{ vault.ssh_pass }}'
    }
}

# After execution, check result
if ansible_job.result['all_tests_passed']:
    workflow.proceed_to_deployment()
else:
    workflow.block_deployment()
    workflow.create_ticket(failed_tests=ansible_job.result['failed_count'])
```

---

## Key Output Variables for Itential

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `all_tests_passed` | Boolean | True if all tests passed | `true` / `false` |
| `total_count` | Integer | Total number of tests executed | `47` |
| `passed_count` | Integer | Number of tests that passed | `45` |
| `failed_count` | Integer | Number of tests that failed | `2` |
| `results_directory` | String | Path to results directory | `/path/to/results` |
| `consolidated_log` | String | Path to consolidated log HTML | `results/all_log.html` |
| `consolidated_report` | String | Path to consolidated report HTML | `results/all_report.html` |
| `nexus_artifacts_url` | String | Nexus OSS URL for artifacts | `https://nexus.company.com/...` |

---

## File Structure After Execution

```
robotframework/
├── ansible_playbooks/
│   ├── run_tests.yml          # Main playbook
│   └── execute_test_suite.yml # Test suite execution tasks
├── results/
│   ├── all_output.xml         # Consolidated results (XML)
│   ├── all_log.html           # Consolidated log (HTML)
│   ├── all_report.html        # Consolidated report (HTML)
│   ├── TEST_SUMMARY.txt       # Summary for Itential parsing
│   ├── test3_network_validation/
│   │   ├── output.xml
│   │   ├── log.html
│   │   ├── report.html
│   │   └── data/              # Test data files
│   ├── test5_disk_space_validation/
│   │   └── ...
│   └── test7_time_configuration_validation/
│       └── ...
└── tests/
    ├── test3_network_validation/
    ├── test5_disk_space_validation/
    └── test7_time_configuration_validation/
```

---

## Common Issues

### Issue 1: No Tests Found
**Symptom**: "Found 0 test suite(s)"
**Cause**: Tests directory not found or empty
**Resolution**: Verify tests/ directory exists with test suites

### Issue 2: SSH Connection Fails
**Symptom**: All tests fail with connection timeout
**Cause**: Invalid credentials or target not reachable
**Resolution**: Verify SSH credentials and network connectivity

### Issue 3: Credentials Not Provided
**Symptom**: Playbook fails in pre-tasks validation
**Cause**: SSH_USERNAME or SSH_PASSWORD not set
**Resolution**: Set environment variables or pass via `-e`

### Issue 4: rebot Fails
**Symptom**: Consolidated report not created
**Cause**: No output.xml files or invalid XML
**Resolution**: Check individual test execution logs

---

## Integration with Itential

### Workflow Example

1. **Itential Trigger**: User requests server build validation
2. **Itential Calls Ansible**: Execute `run_tests.yml` with `TargetHostname`
3. **Ansible Executes Tests**: Runs all Robot Framework tests
4. **Ansible Returns Results**: Includes `all_tests_passed` boolean
5. **Itential Decision**:
   - If `all_tests_passed == true`: Approve server for production
   - If `all_tests_passed == false`: Block server, create incident ticket
6. **Itential Artifact Storage**: Upload results to Nexus using `nexus_artifacts_url`

### Parsing Results in Itential

```python
# Parse TEST_SUMMARY.txt
summary_file = f"{results_dir}/TEST_SUMMARY.txt"
with open(summary_file, 'r') as f:
    summary = f.read()

# Extract key information
import re
overall_status = re.search(r'Overall Status: (\w+)', summary).group(1)
total_tests = re.search(r'Total Tests:\s+(\d+)', summary).group(1)
failed_tests = re.search(r'Failed Tests:\s+(\d+)', summary).group(1)
nexus_url = re.search(r'ARTIFACTS URL.*\n.*\n(https://.*)', summary).group(1)

# Use in workflow
if overall_status == "PASSED":
    itential.approve_server(hostname, nexus_url)
else:
    itential.create_ticket(hostname, failed_tests, nexus_url)
```

---

## Related Documentation
- Individual Test Explanations: `docs/test_explanations/`
- Robot Framework User Guide: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html
- Ansible Documentation: https://docs.ansible.com/

---

**Document Version**: 1.0 | **Date**: 2025-10-14

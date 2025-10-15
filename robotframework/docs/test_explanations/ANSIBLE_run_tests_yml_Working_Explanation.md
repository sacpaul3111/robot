# Ansible Playbook: run_tests.yml - Working Explanation

## Playbook Information

**File:** `ansible_playbooks/run_tests.yml`
**Purpose:** Execute all Robot Framework tests with automatic prerequisite installation and comprehensive pass/fail summary
**Usage:** `ansible-playbook run_tests.yml -e TargetHostname=<hostname>`
**Itential Integration:** Returns `all_tests_passed` boolean and `nexus_artifacts_url`

---

## Overview

This Ansible playbook orchestrates the execution of all Robot Framework tests on a target server. It includes automatic prerequisite checking and installation (Python, Robot Framework, system packages), executes all test suites sequentially, generates consolidated reports using `rebot`, and provides a comprehensive pass/fail summary for Itential automation integration.

---

## Playbook Structure

```
run_tests.yml
├── Pre-Tasks (Prerequisite Installation)
│   ├── Display Banner
│   ├── Check Prerequisites (Python 3, pip3, git)
│   ├── Install System Packages (yum/apt)
│   ├── Upgrade pip
│   ├── Install Robot Framework and Libraries
│   └── Verify Installation
│
├── Tasks (Test Execution)
│   ├── Set Python Executable
│   ├── Check Tests Directory Exists
│   ├── Create Output Directory
│   ├── Find All Test Suite Directories
│   ├── Execute Each Test Suite (via execute_test_suite.yml)
│   └── Create Consolidated Reports (rebot)
│
└── Post-Tasks (Summary and Results)
    ├── Display Test Execution Summary
    ├── Display Individual Test Results
    └── Save Test Summary to File
```

---

## Detailed Working

### Variables

```yaml
vars:
  # Default values - can be overridden with -e flag
  robot_project_dir: "{{ playbook_dir }}/.."
  robot_output_dir: "results"

  # TARGET_HOSTNAME - Primary variable used by Robot Framework tests
  target_hostname: "{{ TargetHostname | default('') }}"

  # Itential integration
  fail_on_test_errors: false
```

**Key Variables:**
- `TargetHostname` - Provided by Itential or command line (required)
- `target_hostname` - Internal variable mapped from TargetHostname
- `fail_on_test_errors` - Default false (playbook doesn't fail on test failures)

**Environment Variables (Credentials):**
- All credentials (SSH, vCenter, Splunk, etc.) are provided via environment variables
- No credentials passed as playbook parameters
- See `credentials.env.example` for complete list

---

## Pre-Tasks: Prerequisite Installation

### Display Banner

**What it does:**
- Displays project information banner with key details

**Output:**
```
========================================================
   GSA Itential Robot Framework - Test Execution
========================================================
Project Directory: /path/to/robotframework
Target Hostname:   alhxvdvitap01
Output Directory:  results
Operating System:  RedHat 8.5
========================================================
```

---

### Check Prerequisites

**What it does:**
- Checks if Python 3, pip3, and git are already installed
- Does not fail if missing - will install next

**Commands:**
```yaml
- name: Check if Python 3 is installed
  command: python3 --version
  register: python3_check
  ignore_errors: yes

- name: Check if pip3 is installed
  command: pip3 --version
  register: pip3_check
  ignore_errors: yes

- name: Check if git is installed
  command: git --version
  register: git_check
  ignore_errors: yes
```

**Output:**
```
Prerequisite Check Results:
  Python 3: Installed
  pip3:     Installed
  git:      Installed
```

---

### Install System Packages

**What it does:**
- Installs system packages based on OS family (RedHat or Debian)
- Only installs if prerequisites are missing
- Requires sudo/become privileges

#### RHEL/CentOS/Rocky Linux:

```yaml
- name: Install system packages (RHEL/CentOS/Rocky)
  become: yes
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
    state: present
  when:
    - ansible_os_family == 'RedHat'
    - python3_check.rc != 0 or pip3_check.rc != 0 or git_check.rc != 0
```

#### Ubuntu/Debian:

```yaml
- name: Install system packages (Ubuntu/Debian)
  become: yes
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
    state: present
    update_cache: yes
  when:
    - ansible_os_family == 'Debian'
    - python3_check.rc != 0 or pip3_check.rc != 0 or git_check.rc != 0
```

---

### Install Robot Framework and Libraries

**What it does:**
- Checks if Robot Framework and SSHLibrary are installed
- Installs all required Python packages with specific versions
- Uses `--user` flag (no sudo required)

```yaml
- name: Check if Robot Framework is installed
  command: python3 -m robot --version
  register: robot_check
  ignore_errors: yes

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
    executable: pip3
    state: present
    extra_args: --user
  when: robot_check.rc != 0 or sshlibrary_check.rc != 0
```

---

### Verify Installation

**What it does:**
- Verifies Python 3 and Robot Framework are working
- Fails playbook if verification fails
- Displays installed versions

```yaml
- name: Verify Python 3 is available after installation
  command: python3 --version
  register: python3_verify
  failed_when: python3_verify.rc != 0

- name: Verify Robot Framework is available after installation
  command: python3 -m robot --version
  register: robot_verify
  failed_when: robot_verify.rc != 0
```

**Output:**
```
Installed Software Versions:
  Python 3.9.7
  Robot Framework 4.1.3 (Python 3.9.7 on linux)
```

---

### Validation

**What it does:**
- Validates target hostname is provided
- Validates SSH credentials are in environment variables

```yaml
- name: Validate target hostname is provided
  fail:
    msg: |
      ERROR: Target hostname is required!
      Usage: ansible-playbook run_tests.yml -e TargetHostname=<hostname>
  when: target_hostname == ''

- name: Validate SSH credentials are provided via environment
  fail:
    msg: |
      ERROR: SSH credentials required!
      Please ensure environment variables are set:
        export SSH_USERNAME=<user>
        export SSH_PASSWORD=<pass>
  when: lookup('env', 'SSH_USERNAME') == '' or lookup('env', 'SSH_PASSWORD') == ''
```

---

## Tasks: Test Execution

### Set Python Executable

```yaml
- name: Set Python executable to system python
  set_fact:
    python_executable: "python3"
```

---

### Find All Test Suite Directories

**What it does:**
- Searches for all test directories matching pattern `test*_*`
- Sorts directories for consistent execution order

```yaml
- name: Find all test suite directories
  find:
    paths: "{{ robot_project_dir }}/tests"
    file_type: directory
    patterns: 'test*_*'
  register: test_directories
```

**Example result:**
```
Found 20 test suite(s)
tests/test3_network_validation/
tests/test5_disk_space_validation/
tests/test7_time_configuration_validation/
...
```

---

### Execute Each Test Suite

**What it does:**
- Loops through all found test directories
- Includes `execute_test_suite.yml` for each test
- Tracks results in `test_results` list

```yaml
- name: Execute each test suite
  include_tasks: execute_test_suite.yml
  loop: "{{ test_directories.files | sort(attribute='path') }}"
  loop_control:
    loop_var: test_dir
```

**Key included playbook:** `execute_test_suite.yml`
- Executes Robot Framework test for each directory
- Passes environment variables (credentials)
- Collects pass/fail statistics

---

### Create Consolidated Reports

**What it does:**
- Uses Robot Framework's `rebot` tool to merge all test outputs
- Creates unified log, report, and output files

```yaml
- name: Create consolidated reports using rebot
  command: >
    {{ python_executable }} -m robot.rebot
    --outputdir {{ robot_project_dir }}/{{ robot_output_dir }}
    --output all_output.xml
    --log all_log.html
    --report all_report.html
    {{ all_output_files | join(' ') }}
```

**Files generated:**
- `results/all_output.xml` - Combined test data (XML)
- `results/all_log.html` - Combined detailed log (HTML)
- `results/all_report.html` - Combined test report (HTML)

---

### Parse Consolidated Results

**What it does:**
- Parses all_output.xml to extract final pass/fail counts
- Sets critical variables for Itential integration

```yaml
- name: Parse consolidated output.xml for final results
  xml:
    path: "{{ robot_project_dir }}/{{ robot_output_dir }}/all_output.xml"
    xpath: /robot/statistics/total/stat
    content: attribute
  register: final_statistics

- name: Extract pass/fail counts from consolidated results
  set_fact:
    total_tests_final: "{{ final_statistics.matches[0].stat.pass | int + final_statistics.matches[0].stat.fail | int }}"
    passed_tests_final: "{{ final_statistics.matches[0].stat.pass | int }}"
    failed_tests_final: "{{ final_statistics.matches[0].stat.fail | int }}"
```

---

### Set Final Test Status

**What it does:**
- Sets `all_tests_passed` boolean (Itential integration)
- Sets `nexus_artifacts_url` for artifact storage

```yaml
- name: Set final test status
  set_fact:
    all_tests_passed: "{{ (failed_tests_final | int) == 0 and (total_tests_final | int) > 0 }}"
    nexus_artifacts_url: "https://nexus.company.com/repository/robot-framework-artifacts/{{ target_hostname }}/{{ ansible_date_time.iso8601 | regex_replace('[:]', '-') }}"
```

**Critical variables for Itential:**
- `all_tests_passed` - Boolean: true if all tests passed, false if any failed
- `nexus_artifacts_url` - URL where test artifacts can be stored/retrieved

**Logic:**
- `all_tests_passed = true` if:
  - `failed_tests_final == 0` AND
  - `total_tests_final > 0` (at least one test ran)

---

## Post-Tasks: Summary and Results

### Display Test Execution Summary

**What it does:**
- Displays comprehensive test summary to console

**Output:**
```
========================================================
           TEST EXECUTION SUMMARY
========================================================
Total Tests:    45
Passed Tests:   43
Failed Tests:   2
========================================================
Overall Status: FAILED ❌
========================================================

Results Location:
  Directory:    /path/to/robotframework/results
  Log:          /path/to/robotframework/results/all_log.html
  Report:       /path/to/robotframework/results/all_report.html

Artifacts URL (Nexus OSS):
  https://nexus.company.com/repository/robot-framework-artifacts/alhxvdvitap01/2025-10-14T10-30-00
========================================================
```

---

### Display Individual Test Suite Results

**What it does:**
- Shows pass/fail status for each individual test suite

**Example output:**
```
test3_network_validation: PASSED ✅ (6 passed, 0 failed)
test5_disk_space_validation: PASSED ✅ (8 passed, 0 failed)
test7_time_configuration_validation: FAILED ❌ (3 passed, 1 failed)
...
```

---

### Save Test Summary to File

**What it does:**
- Saves complete test summary to `TEST_SUMMARY.txt`
- Includes all test results, timestamps, and report locations

**File:** `results/TEST_SUMMARY.txt`

**Content:**
```
========================================================
GSA Itential Robot Framework - Test Execution Summary
========================================================
Execution Date: 2025-10-14T10:30:00
Target Hostname: alhxvdvitap01

========================================================
RESULTS SUMMARY
========================================================
Total Tests:    45
Passed Tests:   43
Failed Tests:   2
Overall Status: FAILED

========================================================
INDIVIDUAL TEST SUITES
========================================================
test3_network_validation: PASSED ✅
test5_disk_space_validation: PASSED ✅
test7_time_configuration_validation: FAILED ❌
...

========================================================
RESULTS LOCATION
========================================================
Directory:  /path/to/robotframework/results
Log:        /path/to/robotframework/results/all_log.html
Report:     /path/to/robotframework/results/all_report.html

========================================================
ARTIFACTS URL (NEXUS OSS)
========================================================
https://nexus.company.com/repository/robot-framework-artifacts/alhxvdvitap01/2025-10-14T10-30-00
========================================================
```

---

## Itential Integration

### Variables Provided to Itential

**1. `all_tests_passed` (Boolean)**
- Value: `true` or `false`
- Logic: `true` if 0 failures AND at least 1 test ran
- Usage: Itential workflow decision point

**Example Itential workflow:**
```python
if ansible_result['all_tests_passed']:
    # All tests passed - proceed with deployment
    proceed_to_deployment()
else:
    # Tests failed - send alert
    send_alert_to_team()
```

**2. `nexus_artifacts_url` (String)**
- Value: URL to Nexus OSS artifact location
- Format: `https://nexus.company.com/repository/robot-framework-artifacts/{hostname}/{timestamp}`
- Usage: Itential can upload test artifacts (HTML reports, logs) to this URL

**Example:**
```
https://nexus.company.com/repository/robot-framework-artifacts/alhxvdvitap01/2025-10-14T10-30-00
```

---

## Execution Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    ANSIBLE PLAYBOOK FLOW                        │
└─────────────────────────────────────────────────────────────────┘

1. Pre-Tasks (Prerequisite Installation)
   ├─> Display banner
   ├─> Check Python 3, pip3, git
   ├─> Install system packages (if needed)
   ├─> Install Robot Framework + libraries (if needed)
   ├─> Verify installation
   └─> Validate target hostname and credentials

2. Tasks (Test Execution)
   ├─> Find all test directories (test*_*)
   ├─> For each test directory:
   │   ├─> Include execute_test_suite.yml
   │   ├─> Execute Robot Framework test
   │   ├─> Collect pass/fail statistics
   │   └─> Save individual output.xml
   │
   └─> Consolidate all results with rebot
       ├─> Create all_output.xml
       ├─> Create all_log.html
       └─> Create all_report.html

3. Post-Tasks (Summary)
   ├─> Parse consolidated results
   ├─> Calculate final statistics
   ├─> Set all_tests_passed = (failed == 0 && total > 0)
   ├─> Set nexus_artifacts_url
   ├─> Display summary to console
   ├─> Save TEST_SUMMARY.txt
   └─> Return results to Itential

4. Itential Receives:
   ├─> all_tests_passed: true/false
   ├─> nexus_artifacts_url: https://...
   ├─> results_directory: path to HTML reports
   └─> total_count, passed_count, failed_count
```

---

## Usage Examples

### Basic Execution:

```bash
# Source credentials first
source credentials.env

# Execute playbook
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01
```

### With Sudo (First Run):

```bash
# For prerequisite installation
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01 \
  --ask-become-pass
```

### Using Wrapper Script:

```bash
# Wrapper script handles credentials automatically
./run_tests.sh alhxvdvitap01
```

### From Itential:

```python
# Itential Automation Platform job
ansible_job = {
    'playbook': 'run_tests.yml',
    'extra_vars': {
        'TargetHostname': 'alhxvdvitap01'
    },
    'environment': itential.get_credentials('robot_framework')
}

result = ansible.run(ansible_job)

if result['all_tests_passed']:
    log.info(f"Tests passed! Artifacts: {result['nexus_artifacts_url']}")
else:
    log.error(f"Tests failed! {result['failed_count']} failures")
```

---

## Key Files and Outputs

### Input Files:
- `tests/test*/` - Test suite directories
- `credentials.env` - Environment variables (not in repo)
- `requirements.txt` - Python dependencies

### Output Files:
- `results/all_output.xml` - Consolidated test data
- `results/all_log.html` - Detailed test log (viewable in browser)
- `results/all_report.html` - Test report summary (viewable in browser)
- `results/TEST_SUMMARY.txt` - Text summary
- `results/test*/output.xml` - Individual test outputs

---

## Error Handling

### Playbook does NOT fail if:
- Tests fail (`fail_on_test_errors: false`)
- Individual test suites fail (continues with next test)

### Playbook FAILS if:
- Target hostname not provided
- SSH credentials not in environment
- Cannot find tests directory
- Prerequisites installation fails and cannot be skipped
- Python 3 or Robot Framework verification fails

---

## Troubleshooting

### Issue: "Target hostname is required"
**Solution:**
```bash
ansible-playbook run_tests.yml -e TargetHostname=alhxvdvitap01
```

### Issue: "SSH credentials required"
**Solution:**
```bash
source credentials.env
# or
export SSH_USERNAME=admin
export SSH_PASSWORD=password
```

### Issue: Prerequisite installation fails
**Solution:**
```bash
# Run with sudo
ansible-playbook run_tests.yml -e TargetHostname=server01 --ask-become-pass
```

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Playbook Features:** Automatic prerequisite installation, comprehensive test execution, Itential integration
**Critical Variables:** `all_tests_passed`, `nexus_artifacts_url`

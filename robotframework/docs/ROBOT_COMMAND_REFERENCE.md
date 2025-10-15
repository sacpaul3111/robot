# Robot Framework - Individual Test Execution Commands Reference

## Overview

This document provides complete `robot` command examples for executing each test individually. Use these commands when you need to run a single test suite instead of the full test suite via Ansible.

---

## Prerequisites

Before running any test, ensure:
1. Robot Framework and required libraries are installed (`pip install -r requirements.txt`)
2. You have SSH credentials for the target server
3. Target server is accessible from your machine

---

## Common Variables (Used by Most Tests)

All tests require these basic variables:

| Variable | Description | Example | Source |
|----------|-------------|---------|--------|
| `SSH_USERNAME` | SSH username for target server | `robotuser` | Command line / Environment |
| `SSH_PASSWORD` | SSH password for target server | `R0botuserwashere!` | Command line / Environment |
| `TARGET_HOSTNAME` | Target server hostname (from Itential) | `alhxvdvitap01` | Command line / Environment |

**IMPORTANT:** The IP address (`TARGET_IP`) is **automatically looked up from the EDS sheet** based on the `TARGET_HOSTNAME`. You do **NOT** need to pass it as a variable. The `EDSLookup.py` library reads the Excel file and extracts the IP address and all other configuration details.

---

## Test Execution Commands

### Test 3: Network Validation

**Purpose:** Validate network configuration (hostname, IP, subnet, gateway, DNS, NTP)

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test3_network_validation \
  tests/test3_network_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 4: VM Validation

**Purpose:** Validate virtual machine configuration against vCenter

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v VCENTER_USERNAME:vcenter_admin@vsphere.local \
  -v VCENTER_PASSWORD:vCenterPass456 \
  -v VCENTER_SERVER:vcenter.domain.com \
  --outputdir results/test4_vm_validation \
  tests/test4_vm_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `VCENTER_USERNAME` - vCenter username
- `VCENTER_PASSWORD` - vCenter password
- `VCENTER_SERVER` - vCenter server hostname/IP

---

### Test 5: Disk Space Validation

**Purpose:** Validate system resources (CPU, RAM, disk space, storage type)

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test5_disk_space_validation \
  tests/test5_disk_space_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 6: OS Package Validation

**Purpose:** Validate installed OS packages against requirements

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test6_os_package_validation \
  tests/test6_os_package_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 7: Time Configuration Validation

**Purpose:** Validate timezone (Pacific/Los Angeles) and NTP synchronization

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v NTP_SERVER:ntpx.domain.com \
  --outputdir results/test7_time_configuration_validation \
  tests/test7_time_configuration_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `NTP_SERVER` - Expected NTP server (optional, default: ntpx.domain.com)

---

### Test 8: SSH Key Authentication

**Purpose:** Validate SSH key-based authentication configuration

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test8_ssh_key_authentication \
  tests/test8_ssh_key_authentication
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 9: Datastore Configuration

**Purpose:** Validate datastore configuration in vCenter

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v VCENTER_USERNAME:vcenter_admin@vsphere.local \
  -v VCENTER_PASSWORD:vCenterPass456 \
  -v VCENTER_SERVER:vcenter.domain.com \
  --outputdir results/test9_datastore_configuration \
  tests/test9_datastore_configuration
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `VCENTER_USERNAME` - vCenter username
- `VCENTER_PASSWORD` - vCenter password
- `VCENTER_SERVER` - vCenter server hostname/IP

---

### Test 10: Port Validation

**Purpose:** Validate required network ports are open/listening

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test10_port_validation \
  tests/test10_port_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 11: Services Validation

**Purpose:** Collect and document all system services (informational)

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test11_services_validation \
  tests/test11_services_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 12: ID Agent Validation

**Purpose:** Validate identity management agent configuration

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test12_id_agent_validation \
  tests/test12_id_agent_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 13: Password Policy Validation

**Purpose:** Validate password policy configuration (PAM settings)

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test13_password_policy_validation \
  tests/test13_password_policy_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 14: Logging Validation

**Purpose:** Validate logging configuration and Splunk integration

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v SPLUNK_USERNAME:splunk_admin \
  -v SPLUNK_PASSWORD:SplunkPass789 \
  -v SPLUNK_SERVER:splunk.domain.com \
  -v SPLUNK_PORT:8089 \
  --outputdir results/test14_logging_validation \
  tests/test14_logging_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `SPLUNK_USERNAME` - Splunk admin username
- `SPLUNK_PASSWORD` - Splunk admin password
- `SPLUNK_SERVER` - Splunk server hostname/IP
- `SPLUNK_PORT` - Splunk API port (default: 8089)

---

### Test 15: Backup Validation

**Purpose:** Validate backup configuration and vCenter snapshots

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v VCENTER_USERNAME:vcenter_admin@vsphere.local \
  -v VCENTER_PASSWORD:vCenterPass456 \
  -v VCENTER_SERVER:vcenter.domain.com \
  --outputdir results/test15_backup_validation \
  tests/test15_backup_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `VCENTER_USERNAME` - vCenter username
- `VCENTER_PASSWORD` - vCenter password
- `VCENTER_SERVER` - vCenter server hostname/IP

---

### Test 16: Password Vault Validation

**Purpose:** Validate CyberArk password vault integration

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v CYBERARK_USERNAME:vault_admin \
  -v CYBERARK_PASSWORD:CyberArkPass012 \
  -v CYBERARK_SERVER:cyberark.domain.com \
  -v CYBERARK_SAFE:BES_Cyber_Assets \
  --outputdir results/test16_password_vault_validation \
  tests/test16_password_vault_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `CYBERARK_USERNAME` - CyberArk username
- `CYBERARK_PASSWORD` - CyberArk password
- `CYBERARK_SERVER` - CyberArk server hostname/IP
- `CYBERARK_SAFE` - CyberArk safe name

---

### Test 17: Mail Configuration

**Purpose:** Validate mail/SMTP relay configuration

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v SMTP_SERVER:mail.domain.com \
  -v SMTP_PORT:25 \
  -v TEST_EMAIL_RECIPIENT:admin@domain.com \
  --outputdir results/test17_mail_configuration \
  tests/test17_mail_configuration
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `SMTP_SERVER` - SMTP relay server (default: mail.domain.com)
- `SMTP_PORT` - SMTP port (default: 25)
- `TEST_EMAIL_RECIPIENT` - Test email recipient address

---

### Test 18: Patch Management & RSA

**Purpose:** Validate RSA SecurID authentication and patch management

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v RSA_SERVER:rsa.domain.com \
  -v RSA_PORT:5500 \
  --outputdir results/test18_patch_management \
  tests/test18_patch_management
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `RSA_SERVER` - RSA authentication server (default: rsa.domain.com)
- `RSA_PORT` - RSA port (default: 5500)

---

### Test 19: Antivirus Validation

**Purpose:** Validate antivirus agent configuration (legacy test - use Test 20)

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test19_antivirus_validation \
  tests/test19_antivirus_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 20: AV Agent Validation

**Purpose:** Validate antivirus agent (CIP-007 R3.1 compliance)

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test20_av_agent_validation \
  tests/test20_av_agent_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

**Optional Variables:**
- `AV_TYPE` - Antivirus product type (McAfee or SentinelOne)
- `MAX_SIGNATURE_AGE_DAYS` - Maximum signature age in days (default: 7)

---

### Test 21: Tanium Agent

**Purpose:** Validate Tanium agent installation and configuration

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v TANIUM_USERNAME:tanium_admin \
  -v TANIUM_PASSWORD:TaniumPass345 \
  -v TANIUM_SERVER:tanium.domain.com \
  -v TANIUM_PORT:443 \
  --outputdir results/test21_tanium_agent \
  tests/test21_tanium_agent
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `TANIUM_USERNAME` - Tanium server username
- `TANIUM_PASSWORD` - Tanium server password
- `TANIUM_SERVER` - Tanium server hostname/IP
- `TANIUM_PORT` - Tanium server port (default: 443)

---

### Test 22: Event Logs Validation

**Purpose:** Validate system health through log analysis

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test22_event_logs \
  tests/test22_event_logs
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)

---

### Test 23: Change Management Validation

**Purpose:** Validate change management process compliance (CIP-010 R1) using BMC Helix

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v BMC_HELIX_URL:https://helix.company.com \
  -v BMC_HELIX_USERNAME:helix_admin \
  -v BMC_HELIX_PASSWORD:HelixPassword123 \
  -v CHANGE_REQUEST_NUMBER:CHG0012345 \
  -v CHANGE_FORM_ID:CHGFORM001 \
  --outputdir results/test23_change_management_validation \
  tests/test23_change_management_validation
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `BMC_HELIX_URL` - BMC Helix ITSM URL (e.g., https://helix.company.com)
- `BMC_HELIX_USERNAME` - BMC Helix username
- `BMC_HELIX_PASSWORD` - BMC Helix password
- `CHANGE_REQUEST_NUMBER` - Change request number (e.g., CHG0012345)
- `CHANGE_FORM_ID` - Asset change form ID

**Note:** This test validates change management compliance by verifying CRQ completion, approvals, documentation, and handoff to operations in BMC Helix ITSM. Asset management is integrated within BMC Helix (same credentials).

---

### Test 24: Ansible Playbook

**Purpose:** Validate Ansible playbook execution by checking job status in Tower/AWX

**Command:**
```bash
robot \
  -v SSH_USERNAME:robotuser \
  -v SSH_PASSWORD:R0botuserwashere! \
  -v TARGET_HOSTNAME:alhxvdvitap01 \
  -v ANSIBLE_TOWER_URL:https://tower.domain.com \
  -v ANSIBLE_USERNAME:tower_admin \
  -v ANSIBLE_PASSWORD:TowerPass678 \
  -v ANSIBLE_JOB_ID:12345 \
  --outputdir results/test24_ansible_playbook \
  tests/test24_ansible_playbook
```

**Required Variables:**
- `SSH_USERNAME` - SSH username
- `SSH_PASSWORD` - SSH password
- `TARGET_HOSTNAME` - Server hostname (IP automatically looked up from EDS)
- `ANSIBLE_TOWER_URL` - Ansible Tower/AWX URL (e.g., https://tower.domain.com)
- `ANSIBLE_USERNAME` - Ansible Tower username
- `ANSIBLE_PASSWORD` - Ansible Tower password
- `ANSIBLE_JOB_ID` - **Job ID to validate** (obtained from Tower/AWX after job execution)

**Note:** This test validates an **existing** Ansible Tower/AWX job by its ID. You must run the Ansible playbook job in Tower/AWX first, then use the job ID to validate it with this test.

---

## Environment Variable Alternative

Instead of passing variables via `-v` flags, you can use environment variables (recommended for security):

```bash
# Set environment variables (IP automatically looked up from EDS)
export SSH_USERNAME=robotuser
export SSH_PASSWORD=R0botuserwashere!
export TARGET_HOSTNAME=alhxvdvitap01

# Run test (Robot Framework automatically reads environment variables)
robot --outputdir results/test3_network_validation \
      tests/test3_network_validation
```

**Note:** Robot Framework can access environment variables using `%{VAR_NAME}` syntax in test files.

**How EDS Lookup Works:**
1. You provide only the `TARGET_HOSTNAME` (e.g., "alhxvdvitap01")
2. The `EDSLookup.py` library reads the EDS Excel file (`EDS_Itential_DRAFT_v0.01.xlsx`)
3. It searches for the hostname in the "Server Requirements" sheet
4. It extracts ALL configuration details: IP, subnet, gateway, CPU, RAM, storage, etc.
5. These values become available as `${TARGET_IP}`, `${TARGET_SUBNET}`, `${TARGET_CPU_CORES}`, etc. in tests

---

## Using credentials.env File

For better security and convenience, use the `credentials.env` file:

```bash
# 1. Copy example file
cp credentials.env.example credentials.env

# 2. Edit with your credentials
vim credentials.env

# 3. Source credentials
source credentials.env

# 4. Run any test (credentials automatically available)
robot --outputdir results/test20_av_agent_validation \
      tests/test20_av_agent_validation
```

---

## Batch Execution Script

To run multiple specific tests, create a script:

```bash
#!/bin/bash
# run_selected_tests.sh

# Source credentials
source credentials.env

# Define tests to run
TESTS=(
    "test3_network_validation"
    "test5_disk_space_validation"
    "test7_time_configuration_validation"
    "test20_av_agent_validation"
)

# Execute each test
for test in "${TESTS[@]}"; do
    echo "=========================================="
    echo "Running: $test"
    echo "=========================================="

    robot \
      -v SSH_USERNAME:${SSH_USERNAME} \
      -v SSH_PASSWORD:${SSH_PASSWORD} \
      -v TARGET_HOSTNAME:${TARGET_HOSTNAME} \
      --outputdir results/${test} \
      tests/${test}

    echo ""
done

echo "All selected tests completed!"
```

---

## Additional Robot Framework Options

### Useful Options:

```bash
# Run with specific log level
robot --loglevel DEBUG ...

# Run specific test cases by tag
robot --include critical ...

# Run and exclude certain tags
robot --exclude informational ...

# Set variables from file
robot --variablefile variables.py ...

# Generate XUnit output for CI/CD
robot --xunit xunit.xml ...

# Rerun failed tests only
robot --rerunfailed output.xml ...

# Run tests in parallel (requires pabot)
pabot --processes 4 tests/
```

---

## Viewing Results

After test execution, view results in browser:

```bash
# Open test report
firefox results/test20_av_agent_validation/report.html

# Open detailed log
firefox results/test20_av_agent_validation/log.html
```

Or use Python's built-in web server:

```bash
cd results/test20_av_agent_validation
python3 -m http.server 8000
# Open browser to: http://localhost:8000/report.html
```

---

## Complete Variable Reference Table

**Note:** The IP address is automatically looked up from the EDS Excel sheet based on `TARGET_HOSTNAME`. All other server configuration details (subnet, gateway, CPU, RAM, storage, etc.) are also retrieved from the EDS sheet.

| Variable | Used By Tests | Description |
|----------|---------------|-------------|
| `SSH_USERNAME` | All | SSH username for target server |
| `SSH_PASSWORD` | All | SSH password for target server |
| `TARGET_HOSTNAME` | All | Target server hostname (from Itential) - triggers EDS lookup |
| `VCENTER_USERNAME` | 4, 9, 15 | vCenter administrator username |
| `VCENTER_PASSWORD` | 4, 9, 15 | vCenter administrator password |
| `VCENTER_SERVER` | 4, 9, 15 | vCenter server hostname/IP |
| `SPLUNK_USERNAME` | 14 | Splunk admin username |
| `SPLUNK_PASSWORD` | 14 | Splunk admin password |
| `SPLUNK_SERVER` | 14 | Splunk server hostname/IP |
| `SPLUNK_PORT` | 14 | Splunk API port (default: 8089) |
| `CYBERARK_USERNAME` | 16 | CyberArk username |
| `CYBERARK_PASSWORD` | 16 | CyberArk password |
| `CYBERARK_SERVER` | 16 | CyberArk server hostname/IP |
| `CYBERARK_SAFE` | 16 | CyberArk safe name |
| `TANIUM_USERNAME` | 21 | Tanium server username |
| `TANIUM_PASSWORD` | 21 | Tanium server password |
| `TANIUM_SERVER` | 21 | Tanium server hostname/IP |
| `TANIUM_PORT` | 21 | Tanium server port |
| `BMC_HELIX_URL` | 23 | BMC Helix ITSM URL (https://helix.company.com) |
| `BMC_HELIX_USERNAME` | 23 | BMC Helix username |
| `BMC_HELIX_PASSWORD` | 23 | BMC Helix password |
| `CHANGE_REQUEST_NUMBER` | 23 | Change request number (e.g., CHG0012345) |
| `CHANGE_FORM_ID` | 23 | Asset change form ID |
| `ANSIBLE_TOWER_URL` | 24 | Ansible Tower/AWX URL (https://tower.domain.com) |
| `ANSIBLE_USERNAME` | 24 | Ansible Tower username |
| `ANSIBLE_PASSWORD` | 24 | Ansible Tower password |
| `ANSIBLE_JOB_ID` | 24 | **Job ID to validate** (from Tower/AWX) |
| `RSA_SERVER` | 18 | RSA authentication server |
| `RSA_PORT` | 18 | RSA server port (default: 5500) |
| `SMTP_SERVER` | 17 | SMTP relay server |
| `SMTP_PORT` | 17 | SMTP port (default: 25) |
| `TEST_EMAIL_RECIPIENT` | 17 | Test email recipient address |
| `NTP_SERVER` | 7 | NTP server hostname (default: ntpx.domain.com) |
| `AV_TYPE` | 20 | Antivirus product type (McAfee/SentinelOne) |
| `MAX_SIGNATURE_AGE_DAYS` | 20 | Maximum signature age (default: 7) |

---

## Quick Copy-Paste Commands

### For Development/Testing (Single Server):

```bash
# Set once (IP automatically looked up from EDS sheet)
export SSH_USERNAME=robotuser
export SSH_PASSWORD=R0botuserwashere!
export TARGET_HOSTNAME=alhxvdvitap01

# Run any test quickly
robot --outputdir results/test3_network_validation tests/test3_network_validation
robot --outputdir results/test5_disk_space_validation tests/test5_disk_space_validation
robot --outputdir results/test20_av_agent_validation tests/test20_av_agent_validation
```

---

## Troubleshooting

### Issue: "Variable not found"
**Solution:** Ensure all required variables are set via `-v` flag or environment variables

### Issue: "Connection timeout"
**Solution:** Verify the IP address looked up from EDS sheet is correct and server is reachable. Check that `TARGET_HOSTNAME` exists in the EDS Excel file.

### Issue: "Authentication failed"
**Solution:** Verify `SSH_USERNAME` and `SSH_PASSWORD` are correct

### Issue: Test fails immediately
**Solution:** Check `--outputdir` directory exists or Robot Framework can create it

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Maintained By:** Robot Framework Test Suite Team
**Related Documents:**
- `CREDENTIALS_SETUP.md` - Credentials configuration guide
- `QUICKSTART.md` - Quick start guide
- `docs/test_explanations/` - Individual test working explanations

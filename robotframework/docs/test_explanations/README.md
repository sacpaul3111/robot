# Robot Framework Test Suite - Working Explanations

## Overview
This directory contains comprehensive working explanations for each Robot Framework test and the Ansible orchestration playbook.

**Purpose**: Help users understand what each test does, how it works, and how to interpret results.

---

## Document Index

### Test Documentation

1. **[TEST3_Network_Validation_Working_Explanation.md](TEST3_Network_Validation_Working_Explanation.md)**
   - **Test ID**: Test-3
   - **Purpose**: Validate network configuration (hostname, IP, subnet, gateway, DNS, NTP) against EDS standards
   - **Key Validations**: Hostname, IP address, subnet, gateway, DNS, NTP service
   - **File Location**: `tests/test3_network_validation/network_validation.robot`

2. **[TEST5_Disk_Space_Validation_Working_Explanation.md](TEST5_Disk_Space_Validation_Working_Explanation.md)**
   - **Test ID**: Test-5
   - **Purpose**: Validate system resources (CPU, memory, disk space, storage type, filesystem)
   - **Key Validations**: CPU cores, RAM, disk space, storage type, filesystem type, OS
   - **File Location**: `tests/test5_disk_space_validation/disk_space_validation.robot`

3. **[TEST7_Time_Configuration_Validation_Working_Explanation.md](TEST7_Time_Configuration_Validation_Working_Explanation.md)**
   - **Test ID**: Test-7
   - **Purpose**: Validate time configuration (timezone, chrony service, NTP server, synchronization)
   - **Key Validations**: Pacific/Los Angeles timezone, chrony service, ntpx.domain.com NTP server, time sync
   - **File Location**: `tests/test7_time_configuration_validation/time_configuration_validation.robot`

4. **[TEST11_Services_Validation_Working_Explanation.md](TEST11_Services_Validation_Working_Explanation.md)**
   - **Test ID**: Test-11
   - **Purpose**: Collect and document all running services for manual review
   - **Key Actions**: List all services, document status, check required services (informational)
   - **File Location**: `tests/test11_services_validation/services_validation.robot`

5. **[TEST17_Mail_Configuration_Working_Explanation.md](TEST17_Mail_Configuration_Working_Explanation.md)**
   - **Test ID**: Test-17
   - **Purpose**: Validate mail/SMTP configuration and relay settings
   - **Key Validations**: MX records, mail.rc configuration, SMTP relay (mail.domain.com), port 25 connectivity
   - **File Location**: `tests/test17_mail_configuration/mail_configuration.robot`

6. **[TEST18_Patch_Management_RSA_Working_Explanation.md](TEST18_Patch_Management_RSA_Working_Explanation.md)**
   - **Test ID**: Test-18
   - **Purpose**: Validate RSA SecurID two-factor authentication and patch management registration
   - **Key Validations**: RSA agent installed, RSA config files, RSA server connectivity, Satellite/Ansible registration
   - **File Location**: `tests/test18_patch_management/patch_management.robot`

7. **[TEST20_AV_Agent_Validation_Working_Explanation.md](TEST20_AV_Agent_Validation_Working_Explanation.md)**
   - **Test ID**: Test-20
   - **Purpose**: Validate antivirus agent configuration (CIP-007 R3.1 compliance)
   - **Key Validations**: AV agent installed, real-time protection enabled, signatures current (<7 days), scheduled scans
   - **Compliance**: CIP-007 R3.1 - Malware Prevention
   - **Supported AV**: McAfee VirusScan Enterprise, SentinelOne
   - **File Location**: `tests/test20_av_agent_validation/av_agent_validation.robot`

8. **[TEST22_Event_Logs_Validation_Working_Explanation.md](TEST22_Event_Logs_Validation_Working_Explanation.md)**
   - **Test ID**: Test-22
   - **Purpose**: Validate system health through comprehensive log analysis
   - **Key Validations**: Critical errors in logs, clean boot sequence, service startups, log rotation
   - **File Location**: `tests/test22_event_logs/event_logs.robot`

---

### Ansible Playbook Documentation

9. **[ANSIBLE_run_tests_yml_Working_Explanation.md](ANSIBLE_run_tests_yml_Working_Explanation.md)**
   - **File**: `ansible_playbooks/run_tests.yml`
   - **Purpose**: Orchestrate all Robot Framework tests with comprehensive reporting
   - **Key Features**:
     - Auto-discovers all test suites
     - Executes tests sequentially
     - Generates consolidated reports
     - Provides `all_tests_passed` boolean for Itential integration
     - Generates Nexus OSS artifacts URL
   - **Integration**: Designed for Itential automation platform

---

## Quick Reference Guide

### Common Test Steps Pattern
Most tests follow the "Step Model" pattern:

```
Step 1: Connect to Target
  └─> Establish SSH connection

Step 2: Collect Data (Data Collection)
  ├─> Step 2.1: Collect [Parameter 1]
  ├─> Step 2.2: Collect [Parameter 2]
  ├─> Step 2.3: Collect [Parameter 3]
  └─> ...

Step 3: Validate Against Standards (Validation)
  ├─> Step 3.1: Validate [Parameter 1]
  ├─> Step 3.2: Validate [Parameter 2]
  └─> ...
```

### Test Priority Tags
- **Critical** - Must pass for test success
- **Normal** - Informational or supplementary checks

---

## Data File Locations

Each test saves data files to its own directory:
```
results/
├── test3_network_validation/
│   ├── data/                    # Collected data files
│   ├── output.xml               # Test results (XML)
│   ├── log.html                 # Test log (HTML)
│   └── report.html              # Test report (HTML)
├── test5_disk_space_validation/
│   └── ...
└── test7_time_configuration_validation/
    └── ...
```

---

## Compliance Standards Referenced

- **CIP-007 R3.1** - Malware Prevention (Test 20)
- **CIP-007 R4.1** - Logging (Test 14 - not documented here)
- **CIP-010 R1** - Configuration Change Management (Test 23 - not documented here)
- **Enterprise Design Standards (EDS)** - All tests validate against EDS

---

## Execution Examples

### Execute Single Test
```bash
robot --variable TARGET_HOSTNAME:alhxvdvitap01 \
      --variable SSH_USERNAME:admin \
      --variable SSH_PASSWORD:password \
      --outputdir results/test3_network_validation \
      tests/test3_network_validation/network_validation.robot
```

### Execute All Tests via Ansible
```bash
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01
```

### Execute All Tests via Ansible (with credentials)
```bash
export SSH_USERNAME=admin
export SSH_PASSWORD=SecurePassword123

ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=alhxvdvitap01
```

---

## Key Technologies Used

- **Robot Framework** - Test automation framework (Python-based)
- **SSHLibrary** - Robot Framework library for SSH operations
- **Ansible** - IT automation for test orchestration
- **systemd/systemctl** - Linux service management
- **chrony** - NTP time synchronization
- **journalctl** - systemd journal log viewer
- **McAfee / SentinelOne** - Antivirus solutions

---

## Common Commands Reference

### SSH and Network
```bash
hostname                          # Get hostname
ip addr                           # Get IP configuration
ip route                          # Get gateway
hostname -f                       # Get FQDN
systemctl status chronyd          # Check NTP service
```

### System Resources
```bash
nproc                            # Get CPU core count
free -g                          # Get memory in GB
df -h /                          # Get disk space
lsblk                            # List block devices
cat /etc/os-release              # Get OS information
```

### Time Configuration
```bash
timedatectl                      # Show time configuration
chronyc sources                  # Show NTP sources
chronyc tracking                 # Show time synchronization status
```

### Services
```bash
systemctl list-units --type=service    # List all services
systemctl --failed                     # Show failed services
systemctl status <service>             # Check service status
```

### Logs
```bash
journalctl -n 1000               # Last 1000 journal entries
journalctl -p 0..3               # Critical/error logs
dmesg                            # Kernel boot messages
tail -f /var/log/messages        # Follow system log
```

### Antivirus (McAfee)
```bash
/opt/McAfee/cma/bin/cmdagent -v       # Get version
/opt/McAfee/cma/bin/cmdagent -c       # Get status
/opt/McAfee/cma/bin/cmdagent -i       # Get DAT info
systemctl status ma                    # Check service
```

---

## Understanding Test Results

### Pass/Fail Criteria
- **Test Passes**: All critical validations succeed
- **Test Fails**: One or more critical validations fail
- **Informational**: Some checks are informational only (don't cause failure)

### Result Files
- **output.xml** - Machine-readable test results
- **log.html** - Detailed test execution log with keywords
- **report.html** - Summary report with statistics
- **data/** - Raw data collected during test execution

---

## Troubleshooting Guide

### Common Issues

1. **SSH Connection Fails**
   - Check firewall rules
   - Verify credentials
   - Test manual SSH: `ssh user@hostname`

2. **Test Fails with "Not Found"**
   - Component not installed on target (e.g., AV agent, RSA)
   - Check if component is required for this server type

3. **Validation Fails with Mismatch**
   - Server configuration doesn't match EDS
   - Update server configuration OR correct EDS file

4. **Cannot Read EDS File**
   - EDS file path incorrect
   - EDS file doesn't contain target hostname
   - Check `library/EDSLookup.py` configuration

---

## Document Information

- **Created**: 2025-10-14
- **Version**: 1.0
- **Location**: `docs/test_explanations/`
- **Maintained By**: Robot Framework Test Suite Team

---

## Additional Resources

- **Robot Framework User Guide**: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html
- **SSHLibrary Documentation**: https://robotframework.org/SSHLibrary/latest/SSHLibrary.html
- **Ansible Documentation**: https://docs.ansible.com/
- **systemd Documentation**: https://www.freedesktop.org/wiki/Software/systemd/
- **CIP Standards**: https://www.nerc.com/pa/Stand/Pages/CIPStandards.aspx

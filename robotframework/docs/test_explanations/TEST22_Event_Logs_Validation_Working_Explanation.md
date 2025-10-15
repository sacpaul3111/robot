# Test 22: Event Logs & Critical Error Validation - Working Explanation

## Test Information

**Test ID:** test22_event_logs
**Test File:** `tests/test22_event_logs/event_logs.robot`
**Purpose:** Validate system health through comprehensive log analysis (no critical errors)
**Compliance:** CIP-010 R1 - Baseline Configuration, System Health Monitoring

---

## Overview

This test validates system health by collecting and analyzing system logs for critical errors, boot sequence issues, and service startup problems. It uses journalctl, dmesg, and /var/log files to ensure the system is operating cleanly without critical errors.

---

## Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│         TEST 22: EVENT LOGS & CRITICAL ERROR VALIDATION     │
└─────────────────────────────────────────────────────────────┘

Step 1: Connect to Target Server
   └─> Establish SSH connection

Step 2: Collect Event Log Data
   ├─> Step 2.1: Collect System Journal Logs (journalctl)
   │   └─> Execute: journalctl -p 0..3 (emergency, alert, critical, error)
   │   └─> Save journal logs to file
   │
   ├─> Step 2.2: Collect Boot Messages (dmesg)
   │   └─> Execute: dmesg
   │   └─> Save dmesg output to file
   │
   └─> Step 2.3: Collect System Log Files
       └─> Execute: tail /var/log/messages, /var/log/syslog
       └─> Save system logs to file

Step 3: Validate Against Standards
   ├─> Step 3.1: Check for Critical Errors in Journalctl
   │   └─> Search for emergency/alert/critical level errors
   │   └─> Count and analyze critical errors
   │   └─> Result: PASS/FAIL
   │
   ├─> Step 3.2: Validate Clean Boot Sequence
   │   └─> Analyze boot messages for errors
   │   └─> Result: PASS/FAIL
   │
   ├─> Step 3.3: Validate Service Startup Status
   │   └─> Check all services started successfully
   │   └─> Result: PASS/FAIL
   │
   └─> Step 3.4: Check Log Rotation Configuration
       └─> Validate logrotate is configured
       └─> Result: PASS/FAIL

Step 4: Additional Analysis (Informational)
   ├─> Analyze Repeating Error Patterns
   ├─> Check Authentication Logs
   ├─> Check Kernel Messages for Errors
   ├─> Validate Disk Space for Logs
   ├─> Check Log File Permissions
   ├─> Check SELinux Denial Logs
   ├─> Check Application Specific Logs
   ├─> Validate Rsyslog Configuration
   ├─> Check Log Size and Growth Rate
   ├─> Check System Uptime and Reboot History
   └─> Comprehensive Log Health Summary

Final Result: PASS if no critical errors found
```

---

## Detailed Working

### Step 2.1: Collect System Journal Logs (journalctl)

**What it does:**
- Collects systemd journal logs with priority 0-3 (emergency, alert, critical, error)
- Saves journal logs to file for analysis

**Commands executed:**
```bash
journalctl -p 0..3 --no-pager -n 500
journalctl --since "24 hours ago" -p 0..3 --no-pager
```

**Priority levels:**
- 0 = emergency
- 1 = alert
- 2 = critical
- 3 = error

**Robot Framework keyword:**
```robot
Collect Journalctl Logs
Save Journal Logs to File    ${journal_logs}
```

**File created:**
- `${DATA_DIR}/journal_logs_YYYYMMDD_HHMMSS.txt`

**Expected output (clean system):**
```
-- No entries --
```

**Expected output (with errors):**
```
Oct 14 10:30:00 server systemd[1]: Failed to start httpd.service
Oct 14 10:30:01 server kernel: Out of memory: Kill process 1234
```

---

### Step 2.2: Collect Boot Messages (dmesg)

**What it does:**
- Collects kernel ring buffer messages (boot and runtime)
- Captures hardware initialization and driver loading

**Commands executed:**
```bash
dmesg
dmesg -l err,crit,alert,emerg
```

**Robot Framework keyword:**
```robot
Collect Dmesg Output
Save Dmesg to File    ${dmesg_output}
```

**File created:**
- `${DATA_DIR}/dmesg_output_YYYYMMDD_HHMMSS.txt`

**Example output:**
```
[    0.000000] Linux version 4.18.0-348.el8.x86_64
[    0.000000] Command line: BOOT_IMAGE=/vmlinuz...
[    1.234567] PCI: Using ACPI for IRQ routing
[    2.345678] EXT4-fs (dm-0): mounted filesystem with ordered data mode
```

---

### Step 2.3: Collect System Log Files

**What it does:**
- Collects recent entries from /var/log files
- Focuses on messages, syslog, and audit logs

**Commands executed:**
```bash
tail -500 /var/log/messages
tail -500 /var/log/syslog  # Debian/Ubuntu
tail -100 /var/log/secure
tail -100 /var/log/audit/audit.log
```

**Robot Framework keyword:**
```robot
Collect System Log Files
Save System Logs to File    ${system_logs}
```

**File created:**
- `${DATA_DIR}/system_logs_YYYYMMDD_HHMMSS.txt`

---

### Step 3.1: Check for Critical Errors in Journalctl

**What it does:**
- Searches journal logs for emergency/alert/critical level errors
- Counts critical errors
- Analyzes error patterns

**Commands executed:**
```bash
journalctl -p 0..2 --no-pager | wc -l  # Count emergency/alert/critical
```

**Robot Framework keyword:**
```robot
Search Critical Errors in Journal
Count Critical Errors    ${critical_errors}
Save Critical Errors to File    ${critical_errors}
```

**File created:**
- `${DATA_DIR}/critical_errors_YYYYMMDD_HHMMSS.txt`

**Pass criteria:**
- Critical error count = 0 or acceptable errors only
- Known false positives filtered out

**Example (passing):**
```
⚠️ Critical error count: 0
✅ No critical errors detected
```

**Example (with errors):**
```
⚠️ Critical error count: 3
📄 Critical errors saved to: test22_data/critical_errors_20251014_103000.txt

Errors found:
Oct 14 10:30:00 server systemd[1]: Failed to start application.service
Oct 14 10:30:05 server kernel: segfault at 0000000000000000
Oct 14 10:30:10 server systemd[1]: Unit entered failed state
```

---

### Step 3.2: Validate Clean Boot Sequence

**What it does:**
- Analyzes boot sequence for errors and warnings
- Checks for successful hardware initialization
- Validates filesystems mounted correctly

**Commands executed:**
```bash
dmesg | grep -i "error\|fail\|warn"
journalctl -b 0 | grep -i "failed"
```

**Robot Framework keyword:**
```robot
Analyze Boot Sequence
Save Boot Analysis to File    ${boot_analysis}
```

**File created:**
- `${DATA_DIR}/boot_analysis_YYYYMMDD_HHMMSS.txt`

**Pass criteria:**
- No critical boot failures
- All required filesystems mounted
- Essential hardware initialized

---

### Step 3.3: Validate Service Startup Status

**What it does:**
- Verifies all critical services started successfully
- Checks for failed service units

**Commands executed:**
```bash
systemctl --failed --no-pager
systemctl list-units --state=failed --no-pager
```

**Robot Framework keyword:**
```robot
Validate Service Startup Status
Save Service Startup Analysis to File    ${service_startup}
```

**File created:**
- `${DATA_DIR}/service_startup_YYYYMMDD_HHMMSS.txt`

**Pass criteria:**
- 0 failed services or only non-critical services failed

**Example (passing):**
```
UNIT              LOAD   ACTIVE SUB    DESCRIPTION
0 loaded units listed.
✅ All services started successfully
```

---

### Step 3.4: Check Log Rotation Configuration

**What it does:**
- Validates logrotate is configured to prevent disk space issues
- Checks log rotation policies

**Commands executed:**
```bash
cat /etc/logrotate.conf
ls -la /etc/logrotate.d/
logrotate --debug /etc/logrotate.conf
```

**Robot Framework keyword:**
```robot
Check Logrotate Configuration
Save Logrotate Config to File    ${logrotate_config}
```

**File created:**
- `${DATA_DIR}/logrotate_config_YYYYMMDD_HHMMSS.txt`

**Pass criteria:**
- logrotate.conf exists
- Log rotation configured for system logs

---

### Step 4: Additional Analysis (Informational)

#### Analyze Repeating Error Patterns

**What it does:**
- Searches for repeating error messages
- Identifies recurring issues

**Commands executed:**
```bash
journalctl -p 3 | sort | uniq -c | sort -rn | head -20
```

**Robot Framework keyword:**
```robot
Analyze Repeating Error Patterns
Save Pattern Analysis to File    ${pattern_analysis}
```

---

#### Check Authentication Logs

**What it does:**
- Reviews authentication logs for failed login attempts
- Security monitoring

**Commands executed:**
```bash
tail -200 /var/log/secure
journalctl -u sshd | grep -i "failed\|invalid"
```

**Robot Framework keyword:**
```robot
Collect Authentication Logs
Save Authentication Logs to File    ${auth_logs}
```

**File created:**
- `${DATA_DIR}/auth_logs_YYYYMMDD_HHMMSS.txt`

---

#### Check Kernel Messages for Errors

**What it does:**
- Searches kernel messages for hardware or driver errors

**Commands executed:**
```bash
dmesg -l err,crit,alert,emerg
dmesg | grep -i "error\|fail"
```

**Robot Framework keyword:**
```robot
Search Kernel Errors
Save Kernel Errors to File    ${kernel_errors}
```

---

#### Validate Disk Space for Logs

**What it does:**
- Checks if sufficient disk space available for logging
- Prevents log truncation due to disk full

**Commands executed:**
```bash
df -h /var/log
df -h /var
```

**Robot Framework keyword:**
```robot
Check Log Disk Space
```

**Example output:**
```
💾 Log partition disk space:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   10G   40G  20% /var
✅ Sufficient disk space for logs (80% available)
```

---

#### Check Log File Permissions

**What it does:**
- Verifies log files have correct permissions
- Security validation

**Commands executed:**
```bash
ls -la /var/log/messages /var/log/secure /var/log/audit/audit.log
```

**Robot Framework keyword:**
```robot
Check Log File Permissions
Save Log Permissions to File    ${log_permissions}
```

**Expected permissions:**
- /var/log/messages: 644 (rw-r--r--)
- /var/log/secure: 600 (rw-------)
- /var/log/audit/audit.log: 600 (rw-------)

---

#### Check SELinux Denial Logs

**What it does:**
- Checks for SELinux access denials
- Security policy violations

**Commands executed:**
```bash
ausearch -m avc,user_avc -ts recent
grep "avc: denied" /var/log/audit/audit.log | tail -50
```

**Robot Framework keyword:**
```robot
Check SELinux Denials
Save SELinux Denials to File    ${selinux_denials}
```

---

#### Check Application Specific Logs

**What it does:**
- Collects application-specific log files

**Commands executed:**
```bash
ls -lh /var/log/*.log
tail -100 /var/log/httpd/error_log
tail -100 /var/log/mysql/error.log
```

**Robot Framework keyword:**
```robot
Collect Application Logs
Save Application Logs to File    ${app_logs}
```

---

#### Validate Rsyslog Configuration

**What it does:**
- Verifies rsyslog is properly configured
- Checks remote logging if configured

**Commands executed:**
```bash
cat /etc/rsyslog.conf
systemctl status rsyslog
```

**Robot Framework keyword:**
```robot
Check Rsyslog Configuration
Save Rsyslog Config to File    ${rsyslog_config}
```

---

#### Check Log Size and Growth Rate

**What it does:**
- Analyzes log file sizes
- Estimates growth rate

**Commands executed:**
```bash
du -sh /var/log/*
ls -lh /var/log/messages*
```

**Robot Framework keyword:**
```robot
Analyze Log Sizes and Growth
Save Log Size Analysis to File    ${log_size_analysis}
```

---

#### Check System Uptime and Reboot History

**What it does:**
- Checks system uptime
- Reviews reboot history

**Commands executed:**
```bash
uptime
last reboot | head -10
journalctl --list-boots
```

**Robot Framework keyword:**
```robot
Check Uptime and Reboot History
Save Uptime Analysis to File    ${uptime_analysis}
```

---

#### Comprehensive Log Health Summary

**Example output:**
```
📊 Comprehensive log health summary:
📊 - Journal Logs: Collected ✅
📊 - Boot Messages: Collected ✅
📊 - System Logs: Collected ✅
📊 - Critical Errors: Validated ✅
📊 - Boot Sequence: Validated ✅
📊 - Service Startup: Validated ✅
📊 - Log Rotation: Validated ✅
📊 - Error Patterns: Analyzed ✅
✅ Comprehensive log health validation: COMPLETED
```

---

## Data Sources

### Output Data:
- Journal logs (priority 0-3)
- Kernel boot messages (dmesg)
- System log files (/var/log/*)
- Critical error analysis
- Boot sequence analysis
- Service startup analysis

### Files Created:
All files saved to `${DATA_DIR}`:
- `journal_logs_YYYYMMDD_HHMMSS.txt`
- `dmesg_output_YYYYMMDD_HHMMSS.txt`
- `system_logs_YYYYMMDD_HHMMSS.txt`
- `critical_errors_YYYYMMDD_HHMMSS.txt`
- `boot_analysis_YYYYMMDD_HHMMSS.txt`
- `service_startup_YYYYMMDD_HHMMSS.txt`
- `logrotate_config_YYYYMMDD_HHMMSS.txt`
- Plus additional analysis files

---

## Success/Failure Criteria

### Test PASSES if:
- ✅ SSH connection successful
- ✅ Logs collected successfully (Critical)
- ✅ No critical errors or acceptable errors only (Critical)
- ✅ Clean boot sequence (Critical)
- ✅ All critical services started (Critical)
- ✅ Log rotation configured (Critical)
- ℹ️ Additional analysis (Informational)

### Test FAILS if:
- ❌ Cannot collect logs
- ❌ Critical unresolved errors found
- ❌ Boot sequence failures
- ❌ Critical services failed to start
- ❌ Log rotation not configured

---

## Key Technologies and Commands

| Technology | Purpose | Commands Used |
|------------|---------|---------------|
| journalctl | Systemd journal | `journalctl -p 0..3`, `-b`, `-u` |
| dmesg | Kernel messages | `dmesg`, `dmesg -l err` |
| tail | Log files | `tail /var/log/messages` |
| systemctl | Service status | `systemctl --failed` |
| logrotate | Log rotation | `logrotate --debug` |
| ausearch | SELinux audit | `ausearch -m avc` |
| uptime | System uptime | `uptime`, `last reboot` |

---

## Example Execution

```
🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH
📋 Target: alhxvdvitap01 (10.10.10.100)
✅ SSH connection verified and active

🔍 STEP 2.1: COLLECT SYSTEM JOURNAL LOGS (JOURNALCTL)
📄 Journal logs saved to: test22_data/journal_logs_20251014_103000.txt
✅ System journal logs collected successfully

🔍 STEP 2.2: COLLECT BOOT MESSAGES (DMESG)
📄 dmesg output saved to: test22_data/dmesg_output_20251014_103000.txt
✅ Kernel boot messages collected successfully

🔍 STEP 3.1: CHECK FOR CRITICAL ERRORS IN JOURNALCTL
⚠️ Critical error count: 0
📄 Critical errors saved to: test22_data/critical_errors_20251014_103000.txt
✅ No critical errors detected

🔍 STEP 3.2: VALIDATE CLEAN BOOT SEQUENCE
📄 Boot analysis saved to: test22_data/boot_analysis_20251014_103000.txt
✅ Boot sequence validation completed - Clean boot

🔍 STEP 3.3: VALIDATE SERVICE STARTUP STATUS
📄 Service startup analysis saved to: test22_data/service_startup_20251014_103000.txt
✅ All services started successfully

📊 Comprehensive log health summary:
📊 - Journal Logs: Collected ✅
📊 - Critical Errors: 0 ✅
📊 - Boot Sequence: Clean ✅
📊 - Services: All Started ✅
✅ Comprehensive log health validation: COMPLETED

Overall Status: PASSED ✅
```

---

## Troubleshooting

### Issue: Critical errors found in logs
**Solution:**
- Review specific errors in saved files
- Address root cause of errors
- Retest after remediation

### Issue: Service startup failures
**Solution:**
```bash
# Check failed services
systemctl --failed

# Check service status
systemctl status <service>

# Review service logs
journalctl -u <service>

# Fix and restart
systemctl restart <service>
```

### Issue: Log rotation not configured
**Solution:**
```bash
# Check logrotate configuration
vi /etc/logrotate.conf

# Test logrotate
logrotate --debug /etc/logrotate.conf

# Force rotation test
logrotate -f /etc/logrotate.conf
```

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Test Coverage:** System log analysis and critical error validation (CIP-010 R1)
**Focus:** System health monitoring through comprehensive log analysis

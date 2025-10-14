# Test 22: Event Logs & Critical Error Validation - Working Explanation

## Test Information
- **Test Suite**: `test22_event_logs`
- **Robot File**: `event_logs.robot`
- **Test ID**: Test-22
- **Purpose**: Validate system health through comprehensive log analysis - ensure no critical errors in system logs

---

## Overview

Test 22 validates system health by:
1. Collecting system logs (journalctl, dmesg, /var/log files)
2. Searching for critical errors and failures
3. Validating clean boot sequence
4. Verifying successful service starts
5. Checking log rotation configuration
6. Documenting all findings for system health assessment

**Focus**: System health validation through comprehensive log analysis to identify potential issues.

---

## Process Flow

```
Step 1: Connect to Target → SSH connection

Step 2: Collect Event Log Data
  ├─> Step 2.1: Collect System Journal Logs (journalctl)
  ├─> Step 2.2: Collect Boot Messages (dmesg)
  └─> Step 2.3: Collect System Log Files (/var/log)

Step 3: Validate Against Standards
  ├─> Step 3.1: Check for Critical Errors in Journalctl
  ├─> Step 3.2: Validate Clean Boot Sequence
  ├─> Step 3.3: Validate Service Startup Status
  └─> Step 3.4: Check Log Rotation Configuration

Normal Tests (Analysis):
  ├─> Analyze Repeating Error Patterns
  ├─> Check Authentication Logs (failed logins)
  ├─> Check Kernel Messages for Errors
  ├─> Validate Disk Space for Logs
  ├─> Check Log File Permissions
  ├─> Check SELinux Denial Logs
  ├─> Check Application Specific Logs
  ├─> Validate Rsyslog Configuration
  ├─> Check Log Size and Growth Rate
  ├─> Check System Uptime and Reboot History
  └─> Comprehensive Log Health Summary
```

---

## Key Steps Explained

### Step 2.1: Collect System Journal Logs (journalctl)
**Purpose**: Collect systemd journal logs for analysis

**Actions**:
1. Execute multiple journalctl queries:
   ```bash
   # Last 1000 lines of journal
   journalctl -n 1000 --no-pager

   # Priority 0-3 (emergency, alert, critical, error)
   journalctl -p 0..3 -n 500 --no-pager

   # Since last boot
   journalctl -b --no-pager

   # Failed services
   journalctl -p err -b --no-pager
   ```
2. Combine all journal data
3. Save to file: `journal_logs_<timestamp>.txt`

**Data Collected**: System journal entries including errors, warnings, service starts/stops

---

### Step 2.2: Collect Boot Messages (dmesg)
**Purpose**: Collect kernel boot messages for hardware/driver errors

**Actions**:
1. Execute `dmesg` or `dmesg -T` (with timestamps)
2. Capture kernel ring buffer contents
3. Save to file: `dmesg_output_<timestamp>.txt`

**Data Collected**: Kernel boot messages, hardware detection, driver loading, kernel errors

---

### Step 2.3: Collect System Log Files
**Purpose**: Collect important system log files from /var/log

**Actions**:
1. Collect key log files:
   ```bash
   tail -1000 /var/log/messages
   tail -1000 /var/log/syslog
   tail -1000 /var/log/secure
   tail -1000 /var/log/audit/audit.log
   ```
2. Combine log data
3. Save to file: `system_logs_<timestamp>.txt`

**Data Collected**: System messages, security logs, audit logs

---

### Step 3.1: Check for Critical Errors in Journalctl
**Purpose**: Search for emergency, alert, and critical level errors

**Actions**:
1. Execute `Search Critical Errors in Journal` keyword
2. Search for priority levels:
   - **Priority 0** - Emergency (system unusable)
   - **Priority 1** - Alert (immediate action required)
   - **Priority 2** - Critical (critical conditions)
   - **Priority 3** - Error (error conditions)
3. Parse errors and categorize
4. Count critical error occurrences
5. Save to file: `critical_errors_<timestamp>.txt`

**Validation**:
```robot
Count critical errors
Log error count
Acceptable errors: Some errors may be expected (e.g., failed mounts that retry)
```

**Command**:
```bash
journalctl -p 0..3 --no-pager | grep -iE "(error|critical|emergency|alert|fail)"
```

---

### Step 3.2: Validate Clean Boot Sequence
**Purpose**: Analyze boot sequence for errors

**Actions**:
1. Execute `Analyze Boot Sequence` keyword
2. Check boot journal: `journalctl -b 0 --no-pager`
3. Search for boot errors:
   - Failed service starts
   - Mount failures
   - Hardware errors
   - Timeout errors
4. Analyze systemd boot targets
5. Save to file: `boot_analysis_<timestamp>.txt`

**Command**:
```bash
# Show current boot messages
journalctl -b 0 --no-pager

# Show boot errors
journalctl -b 0 -p err --no-pager
```

---

### Step 3.3: Validate Service Startup Status
**Purpose**: Verify all critical services started successfully

**Actions**:
1. Execute `Validate Service Startup Status` keyword
2. Search journal for service startup messages
3. Identify services that:
   - Started successfully
   - Failed to start
   - Took long time to start
   - Had warnings during startup
4. Save to file: `service_startup_analysis_<timestamp>.txt`

**Command**:
```bash
# Check service startup messages
journalctl -b | grep -i "started\|starting\|failed"

# List failed services
systemctl --failed
```

---

### Step 3.4: Check Log Rotation Configuration
**Purpose**: Validate log rotation is properly configured

**Actions**:
1. Check logrotate configuration files:
   - `/etc/logrotate.conf`
   - `/etc/logrotate.d/*`
2. Verify rotation policies for key logs
3. Check logrotate status: `/var/lib/logrotate/logrotate.status`
4. Save to file: `logrotate_config_<timestamp>.txt`

**Command**:
```bash
# View logrotate configuration
cat /etc/logrotate.conf
ls -la /etc/logrotate.d/

# Test logrotate (dry run)
logrotate -d /etc/logrotate.conf
```

**Why Important**: Prevents log files from filling disk space

---

### Normal Test: Analyze Repeating Error Patterns
**Purpose**: Identify errors that occur repeatedly (may indicate systemic issues)

**Actions**:
1. Parse all collected logs
2. Count error message occurrences
3. Identify patterns that repeat > 10 times
4. Flag potential issues
5. Save to file: `error_patterns_<timestamp>.txt`

---

### Normal Test: Check Authentication Logs
**Purpose**: Review failed login attempts and authentication issues

**Actions**:
1. Parse `/var/log/secure` or `/var/log/auth.log`
2. Search for:
   - Failed password attempts
   - Invalid users
   - Successful logins
   - sudo usage
3. Save to file: `authentication_logs_<timestamp>.txt`

**Command**:
```bash
# Failed SSH attempts
grep "Failed password" /var/log/secure

# Successful logins
grep "Accepted" /var/log/secure

# sudo usage
grep "sudo" /var/log/secure
```

---

### Normal Test: Check Kernel Messages for Errors
**Purpose**: Search dmesg for hardware/driver errors

**Actions**:
1. Parse dmesg output
2. Search for error keywords:
   - "error", "fail", "warning"
   - "I/O error", "timeout"
   - "out of memory", "segfault"
3. Identify hardware issues
4. Save to file: `kernel_errors_<timestamp>.txt`

---

### Normal Test: Validate Disk Space for Logs
**Purpose**: Ensure sufficient disk space for logging

**Actions**:
1. Check /var/log disk usage: `df -h /var/log`
2. Check individual log file sizes: `du -sh /var/log/*`
3. Alert if disk usage > 80%
4. Log disk space information

---

### Normal Test: Check Log File Permissions
**Purpose**: Verify log files have correct permissions for security

**Actions**:
1. Check permissions on key log files:
   ```bash
   ls -la /var/log/messages
   ls -la /var/log/secure
   ls -la /var/log/audit/audit.log
   ```
2. Verify:
   - Readable by root/syslog
   - Not world-readable (especially secure logs)
3. Save to file: `log_permissions_<timestamp>.txt`

**Expected Permissions**:
- `/var/log/messages` - 0644 (rw-r--r--)
- `/var/log/secure` - 0600 (rw-------)
- `/var/log/audit/audit.log` - 0600 (rw-------)

---

### Normal Test: Check System Uptime and Reboot History
**Purpose**: Check system stability and reboot history

**Actions**:
1. Get system uptime: `uptime`
2. Get last reboot: `last reboot | head -10`
3. Check reboot reasons in journal
4. Analyze reboot frequency
5. Save to file: `uptime_analysis_<timestamp>.txt`

---

## Data Files Saved

Files saved to `results/test22_event_logs/data/`:
- `journal_logs_<timestamp>.txt` - System journal logs
- `dmesg_output_<timestamp>.txt` - Kernel boot messages
- `system_logs_<timestamp>.txt` - /var/log files
- `critical_errors_<timestamp>.txt` - Critical/emergency errors found
- `boot_analysis_<timestamp>.txt` - Boot sequence analysis
- `service_startup_analysis_<timestamp>.txt` - Service startup validation
- `logrotate_config_<timestamp>.txt` - Log rotation configuration
- `error_patterns_<timestamp>.txt` - Repeating error patterns
- `authentication_logs_<timestamp>.txt` - Auth and security logs
- `kernel_errors_<timestamp>.txt` - Kernel-level errors
- `log_permissions_<timestamp>.txt` - Log file permission audit
- `selinux_denials_<timestamp>.txt` - SELinux denial logs
- `uptime_analysis_<timestamp>.txt` - System uptime and reboot history

---

## Key Technologies

- **systemd-journald** - System logging service
- **journalctl** - Query systemd journal
- **dmesg** - Kernel ring buffer (boot messages)
- **logrotate** - Log rotation utility
- **rsyslog** - System logging daemon

**Commands Used**:
- `journalctl -n 1000` - Last 1000 journal entries
- `journalctl -p 0..3` - Critical/error priority logs
- `journalctl -b` - Current boot logs
- `dmesg` / `dmesg -T` - Kernel messages
- `systemctl --failed` - Failed services
- `last reboot` - Reboot history
- `uptime` - System uptime
- `df -h /var/log` - Log disk space
- `logrotate -d` - Test log rotation

---

## Success Criteria

**Passes When**:
- All log data collected successfully
- Critical error count documented (may have some acceptable errors)
- Boot sequence validated (clean or acceptable errors documented)
- Services started successfully
- Log rotation configured properly

**Fails When**:
- Cannot collect log data
- Cannot access log files
- Critical failures in log collection process

**Note**: This test primarily DOCUMENTS log health. Finding errors does not automatically fail the test - errors are documented for manual review and investigation.

---

## Common Issues

### Issue 1: Too Many Critical Errors
**Cause**: System has experienced failures or misconfigurations
**Resolution**: Investigate specific errors in detailed log files

### Issue 2: Boot Sequence Errors
**Cause**: Failed mounts, service failures during boot
**Resolution**: Review boot analysis file and fix underlying issues

### Issue 3: Log Disk Space Full
**Cause**: Log files filling disk partition
**Resolution**:
- Configure/fix logrotate
- Manually clean old logs
- Increase /var/log partition size

### Issue 4: Failed Services on Startup
**Cause**: Services configured to start but failing
**Resolution**: Disable unnecessary services or fix service configurations

---

## Execution Example

```bash
robot --variable TARGET_HOSTNAME:alhxvdvitap01 \
      --variable SSH_USERNAME:admin \
      --variable SSH_PASSWORD:password \
      --outputdir results/test22_event_logs \
      tests/test22_event_logs/event_logs.robot
```

---

## Related Tests
- **Test 11** - Services Validation (validates service status)
- **Test 14** - Logging Validation (validates remote logging configuration - CIP-007 R4.1)

---

**Document Version**: 1.0 | **Date**: 2025-10-14

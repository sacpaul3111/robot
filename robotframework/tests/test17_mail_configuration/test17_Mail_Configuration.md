# Test 17: Mail Configuration Validation - Working Explanation

## Test Information
- **Test Suite**: `test17_mail_configuration`
- **Robot File**: `mail_configuration.robot`
- **Test ID**: Test-17
- **Purpose**: Validate mail/SMTP configuration and relay settings for email delivery

---

## Overview

Test 17 validates mail configuration by:
1. Collecting DNS MX records for the mail domain
2. Reading and validating `/etc/mail.rc` configuration
3. Validating SMTP relay server is set to `mail.domain.com`
4. Testing SMTP port 25 connectivity
5. Optionally sending test email and checking mail queue

---

## Process Flow

```
Step 1: Connect to Target → SSH connection

Step 2: Collect Mail Configuration Data
  ├─> Step 2.1: Collect DNS MX Records
  └─> Step 2.2: Collect Mail.rc Configuration

Step 3: Validate Against Standards
  ├─> Step 3.1: Validate SMTP Relay Configuration (mail.domain.com)
  └─> Step 3.2: Test SMTP Port Connectivity (port 25)

Normal Tests:
  ├─> Send Test Email
  ├─> Check Mail Queue Status
  ├─> Validate Mail Subsystem Services (postfix/sendmail)
  ├─> Collect Mail Logs
  ├─> Validate Firewall Rules for SMTP
  ├─> Test SMTP Authentication
  ├─> Validate Mail Aliases Configuration
  └─> Comprehensive Mail Configuration Summary
```

---

## Key Steps Explained

### Step 2.1: Collect DNS MX Records
**Purpose**: Query DNS for MX (Mail eXchange) records

**Actions**:
1. Execute `nslookup -type=mx domain.com` or `dig MX domain.com`
2. Parse output to find mail servers
3. Verify expected SMTP relay is listed

**Expected**: mail.domain.com

---

### Step 2.2: Collect Mail.rc Configuration
**Purpose**: Read `/etc/mail.rc` file containing mail configuration

**Actions**:
1. Execute `cat /etc/mail.rc` via SSH
2. Save configuration to file
3. Parse for SMTP relay settings

**Key Settings in mail.rc**:
```bash
set smtp=mail.domain.com:25
set from="user@domain.com"
```

---

### Step 3.1: Validate SMTP Relay Configuration
**Purpose**: Ensure mail.rc has correct SMTP relay server

**Validation**:
```robot
Expected SMTP Relay: mail.domain.com
Check mail.rc contains: smtp=mail.domain.com
```

---

### Step 3.2: Test SMTP Port Connectivity
**Purpose**: Test network connectivity to SMTP server on port 25

**Actions**:
1. Execute `nc -zv mail.domain.com 25` or `telnet mail.domain.com 25`
2. Verify connection succeeds
3. Test basic SMTP commands (EHLO, QUIT)

**Commands**:
```bash
# Test connectivity with netcat
nc -zv mail.domain.com 25

# OR test with telnet
timeout 5 bash -c "</dev/tcp/mail.domain.com/25" && echo "Connected"
```

---

### Normal Test: Send Test Email
**Purpose**: Send actual test email to verify mail functionality

**Actions**:
1. Use `echo "Test" | mail -s "Test from ${TARGET_HOSTNAME}" recipient@domain.com`
2. Check mail command exit status
3. Log success/failure

---

### Normal Test: Check Mail Queue
**Purpose**: Check for stuck messages in mail queue

**Actions**:
1. Execute `mailq` or `postqueue -p` to view queue
2. Verify queue is empty or has acceptable messages
3. Save queue status to file

---

## Data Files Saved

Files saved to `results/test17_mail_configuration/data/`:
- `mail_rc_config_<timestamp>.txt` - /etc/mail.rc configuration
- `mx_records_<timestamp>.txt` - DNS MX records
- `smtp_connectivity_<timestamp>.txt` - SMTP connectivity test results
- `mail_queue_status_<timestamp>.txt` - Mail queue status
- `mail_logs_<timestamp>.txt` - Recent mail log entries
- `mail_aliases_<timestamp>.txt` - Mail aliases configuration

---

## Key Technologies

- **MX Records** - DNS mail exchange records
- **SMTP** - Simple Mail Transfer Protocol (port 25)
- **mail.rc** - Mail configuration file
- **Postfix/Sendmail** - Mail transfer agents
- **mail command** - Send email from command line

**Commands Used**:
- `nslookup -type=mx` - DNS MX lookup
- `nc` / `telnet` - Test SMTP connectivity
- `mail` - Send email
- `mailq` / `postqueue` - Check mail queue
- `systemctl status postfix` - Check mail service

---

## Success Criteria

**Passes When**:
- MX records collected successfully
- mail.rc configuration read successfully
- SMTP relay is mail.domain.com
- SMTP port 25 connectivity successful

**Fails When**:
- Cannot collect MX records
- Cannot read mail.rc
- SMTP relay incorrect
- Cannot connect to SMTP port 25

---

## Common Issues

### Issue 1: SMTP Connection Timeout
**Cause**: Firewall blocking port 25
**Resolution**: Open port 25 in firewall rules

### Issue 2: mail.rc Not Found
**Cause**: File doesn't exist on system
**Resolution**: Create mail.rc with proper SMTP settings

### Issue 3: Mail Queue Stuck
**Cause**: Messages cannot be delivered
**Resolution**: Check mail logs, verify relay configuration

---

## Related Tests
- **Test 11** - Services Validation (checks postfix/sendmail services)

---

## Execution Example

```bash
robot --variable TARGET_HOSTNAME:alhxvdvitap01 \
      --variable SSH_USERNAME:admin \
      --variable SSH_PASSWORD:password \
      --outputdir results/test17_mail_configuration \
      tests/test17_mail_configuration/mail_configuration.robot
```

---

**Document Version**: 1.0 | **Date**: 2025-10-14

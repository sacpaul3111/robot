# Test 17: Mail Configuration Validation - Working Explanation

## Test Information

**Test ID:** test17_mail_configuration
**Test File:** `tests/test17_mail_configuration/mail_configuration.robot`
**Purpose:** Validate SMTP relay configuration (mail.domain.com) and mail subsystem
**Compliance:** CIP-010 R1 - Baseline Configuration Management

---

## Overview

This test validates that the target server's mail configuration is properly set up to use the corporate SMTP relay server (mail.domain.com) for sending system emails. It checks DNS MX records, mail.rc configuration, SMTP connectivity, and optionally sends a test email.

---

## Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│           TEST 17: MAIL CONFIGURATION VALIDATION            │
└─────────────────────────────────────────────────────────────┘

Step 1: Connect to Target Server
   └─> Establish SSH connection

Step 2: Collect Mail Configuration Data
   ├─> Step 2.1: Collect DNS MX Records
   │   └─> Execute: nslookup -type=mx domain.com
   │   └─> Save MX records
   │
   └─> Step 2.2: Collect Mail.rc Configuration
       └─> Execute: cat /etc/mail.rc
       └─> Save mail.rc to file

Step 3: Validate Against Standards
   ├─> Step 3.1: Validate SMTP Relay Configuration
   │   └─> Check mail.rc contains mail.domain.com
   │   └─> Result: PASS/FAIL
   │
   └─> Step 3.2: Test SMTP Port Connectivity
       └─> Execute: nc -zv mail.domain.com 25
       └─> Result: PASS/FAIL

Step 4: Additional Validation (Normal/Informational)
   ├─> Send Test Email
   ├─> Check Mail Queue Status
   ├─> Validate Mail Subsystem Services
   ├─> Collect Mail Logs
   ├─> Validate Firewall Rules for SMTP
   ├─> Test SMTP Authentication
   ├─> Validate Mail Aliases Configuration
   └─> Comprehensive Mail Configuration Summary

Final Result: PASS if SMTP relay configured and reachable
```

---

## Detailed Working

### Step 1: Connect to Target Server

**What it does:**
- Establishes SSH connection
- Verifies connection active

---

### Step 2: Collect Mail Configuration Data

#### Step 2.1: Collect DNS MX Records

**What it does:**
- Queries DNS for MX (mail exchange) records
- Validates domain has proper mail routing

**Commands executed:**
```bash
nslookup -type=mx domain.com
```

**Expected output:**
```
Server:         10.10.10.1
Address:        10.10.10.1#53

domain.com      mail exchanger = 10 mail.domain.com.
```

**Robot Framework keyword:**
```robot
Collect MX Records
```

**Variables set:**
- `${mx_records}` - MX record data

**Variable used:**
- `${EXPECTED_SMTP_RELAY}` - mail.domain.com

---

#### Step 2.2: Collect Mail.rc Configuration

**What it does:**
- Reads /etc/mail.rc configuration file
- Saves configuration to file for review

**Commands executed:**
```bash
cat /etc/mail.rc
```

**Expected content:**
```
# System-wide mail configuration
set smtp=mail.domain.com:25
set smtp-auth=none
set from="noreply@domain.com"
```

**Robot Framework keyword:**
```robot
Collect Mail RC Configuration
Save Mail RC to File    ${mail_rc_content}
```

**File created:**
- `${DATA_DIR}/mail_rc_config_YYYYMMDD_HHMMSS.txt`

---

### Step 3: Validate Against Standards

#### Step 3.1: Validate SMTP Relay Configuration

**What it does:**
- Validates mail.rc file contains correct SMTP relay server
- Checks for "mail.domain.com" in configuration

**Validation logic:**
```robot
Validate SMTP Relay Configuration
```

**Expected:**
- mail.rc contains "set smtp=mail.domain.com"
- Or contains "smtp://mail.domain.com"

**Pass criteria:**
- SMTP relay server matches expected value (mail.domain.com)

**Example:**
```
📋 Expected SMTP Relay: mail.domain.com
📧 mail.rc contains: set smtp=mail.domain.com:25
✅ SMTP relay configuration validated
```

**Fail message:**
```
❌ SMTP RELAY MISMATCH: mail.rc does not contain mail.domain.com
```

---

#### Step 3.2: Test SMTP Port Connectivity

**What it does:**
- Tests TCP connectivity to SMTP server on port 25
- Uses netcat (nc) or telnet to verify reachability

**Commands executed:**
```bash
nc -zv mail.domain.com 25
```

**Alternative commands:**
```bash
timeout 5 bash -c "</dev/tcp/mail.domain.com/25" 2>/dev/null
telnet mail.domain.com 25
```

**Expected output:**
```
Connection to mail.domain.com 25 port [tcp/smtp] succeeded!
```

**Robot Framework keyword:**
```robot
Test SMTP Port Connectivity
```

**Variables:**
- `${SMTP_PORT}` - 25 (default SMTP port)

**Pass criteria:**
- Connection to port 25 successful
- No timeout or connection refused

**Example:**
```
📋 SMTP Server: mail.domain.com
📋 SMTP Port: 25
🔌 Testing connectivity...
✅ Connection successful
✅ SMTP port connectivity test completed
```

---

### Step 4: Additional Validation

#### Send Test Email

**What it does:**
- Sends a test email through the mail subsystem
- Verifies end-to-end mail functionality

**Commands executed:**
```bash
echo "Test email from ${TARGET_HOSTNAME}" | mail -s "Test Email" ${TEST_EMAIL_RECIPIENT}
```

**Variables:**
- `${TEST_EMAIL_RECIPIENT}` - From environment variable

**Robot Framework keyword:**
```robot
Send Test Email
```

**Example:**
```
📋 Test Recipient: admin@domain.com
📨 Sending test email...
✅ Test email sent successfully
ℹ️ Check recipient mailbox for delivery
```

**Result:** Informational - logs whether email was sent

---

#### Check Mail Queue Status

**What it does:**
- Checks mail queue for stuck messages
- Uses mailq or postqueue commands

**Commands executed:**
```bash
mailq
# or
postqueue -p
```

**Expected output - empty queue:**
```
Mail queue is empty
```

**Expected output - with messages:**
```
-Queue ID- --Size-- ----Arrival Time---- -Sender/Recipient-------
ABC123DEF*    1234 Mon Oct 14 10:30:00  root@server.com
                                         admin@domain.com
```

**Robot Framework keyword:**
```robot
Check Mail Queue Status
Save Mail Queue Status to File    ${queue_status}
```

**File created:**
- `${DATA_DIR}/mail_queue_YYYYMMDD_HHMMSS.txt`

---

#### Validate Mail Subsystem Services

**What it does:**
- Checks if mail service (postfix/sendmail) is running
- Validates service is enabled

**Commands executed:**
```bash
systemctl is-active postfix
systemctl is-active sendmail
```

**Robot Framework keyword:**
```robot
Check Mail Service Status
```

**Example output:**
```
🔧 Postfix service: active
🔧 Sendmail service: inactive
✅ Mail service validation: INFORMATIONAL
```

---

#### Collect Mail Logs

**What it does:**
- Collects recent mail log entries from /var/log/maillog
- Saves logs for troubleshooting

**Commands executed:**
```bash
tail -100 /var/log/maillog
# or
journalctl -u postfix -n 100
```

**Robot Framework keyword:**
```robot
Collect Mail Logs
Save Mail Logs to File    ${mail_logs}
```

**File created:**
- `${DATA_DIR}/mail_logs_YYYYMMDD_HHMMSS.txt`

---

#### Validate Firewall Rules for SMTP

**What it does:**
- Checks firewall allows outbound SMTP traffic on port 25
- Reviews iptables or firewalld rules

**Commands executed:**
```bash
iptables -L OUTPUT -n | grep 25
firewall-cmd --list-all
```

**Robot Framework keyword:**
```robot
Check Firewall Rules for SMTP
```

**Result:** Informational - firewall rules documented

---

#### Test SMTP Authentication

**What it does:**
- Checks if SMTP authentication is configured
- Reviews mail.rc for auth settings

**Robot Framework keyword:**
```robot
Check SMTP Authentication Config
```

**Example output:**
```
🔐 SMTP Auth Configuration: none (relay-only)
ℹ️ SMTP authentication settings documented
```

---

#### Validate Mail Aliases Configuration

**What it does:**
- Collects /etc/aliases file
- Reviews mail forwarding rules

**Commands executed:**
```bash
cat /etc/aliases
```

**Expected content:**
```
root: admin@domain.com
postmaster: root
```

**Robot Framework keyword:**
```robot
Collect Mail Aliases Configuration
Save Mail Aliases to File    ${aliases_content}
```

**File created:**
- `${DATA_DIR}/mail_aliases_YYYYMMDD_HHMMSS.txt`

---

#### Comprehensive Mail Configuration Summary

**What it does:**
- Validates all mail settings together
- Generates comprehensive summary

**Robot Framework keyword:**
```robot
Validate All Mail Settings
```

**Example output:**
```
📊 Comprehensive mail configuration summary:
📊 - MX Records: Collected ✅
📊 - Mail.rc Config: Validated ✅
📊 - SMTP Connectivity: Tested ✅
📊 - Test Email: Sent ✅
📊 - Mail Queue: Monitored ✅
📊 - Services: Validated ✅
✅ Comprehensive mail validation: COMPLETED
```

---

## Data Sources

### Input Data (Environment Variables):
- `${EXPECTED_SMTP_RELAY}` - mail.domain.com
- `${SMTP_PORT}` - 25
- `${TEST_EMAIL_RECIPIENT}` - From environment variable

### Output Data:
- MX records
- mail.rc configuration
- SMTP connectivity test results
- Mail queue status
- Mail service status
- Mail logs

### Files Created:
- `mail_rc_config_YYYYMMDD_HHMMSS.txt` - Mail.rc file content
- `mail_queue_YYYYMMDD_HHMMSS.txt` - Mail queue status
- `mail_logs_YYYYMMDD_HHMMSS.txt` - Mail log entries
- `mail_aliases_YYYYMMDD_HHMMSS.txt` - Mail aliases configuration

---

## Success/Failure Criteria

### Test PASSES if:
- ✅ SSH connection successful
- ✅ MX records collected (Critical)
- ✅ Mail.rc contains mail.domain.com (Critical)
- ✅ SMTP port 25 connectivity successful (Critical)
- ℹ️ Test email sent (Informational)
- ℹ️ Mail queue checked (Informational)

### Test FAILS if:
- ❌ SSH connection fails
- ❌ mail.rc not found or doesn't contain correct relay
- ❌ SMTP port 25 not reachable
- ❌ MX record collection fails

---

## Key Technologies and Commands

| Technology | Purpose | Commands Used |
|------------|---------|---------------|
| nslookup | DNS queries | `nslookup -type=mx domain.com` |
| mail.rc | Mail configuration | `cat /etc/mail.rc` |
| nc (netcat) | Port connectivity | `nc -zv mail.domain.com 25` |
| mail/mailx | Send email | `echo "..." \| mail -s "Subject" recipient` |
| mailq | Mail queue | `mailq`, `postqueue -p` |
| postfix | Mail service | `systemctl status postfix` |
| journalctl | Mail logs | `journalctl -u postfix` |

---

## Example Execution

### Successful execution:
```
🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH
📋 Target: alhxvdvitap01 (10.10.10.100)
✅ SSH connection verified and active

🔍 STEP 2.1: COLLECT DNS MX RECORDS
📋 Expected SMTP Relay: mail.domain.com
🌐 MX Records: domain.com mail exchanger = 10 mail.domain.com
✅ DNS MX records collected successfully

🔍 STEP 2.2: COLLECT MAIL.RC CONFIGURATION
📄 Mail.rc configuration saved to: test17_data/mail_rc_config_20251014_103000.txt
✅ Mail.rc configuration collected

🔍 STEP 3.1: VALIDATE SMTP RELAY CONFIGURATION
📋 Expected SMTP Relay: mail.domain.com
📧 mail.rc contains: set smtp=mail.domain.com:25
✅ SMTP relay configuration validated

🔍 STEP 3.2: TEST SMTP PORT CONNECTIVITY
📋 SMTP Server: mail.domain.com
📋 SMTP Port: 25
🔌 Connection successful
✅ SMTP port connectivity test completed

Overall Status: PASSED ✅
```

---

## Troubleshooting

### Issue: SMTP relay not in mail.rc
**Solution:**
```bash
# Edit /etc/mail.rc
echo "set smtp=mail.domain.com:25" >> /etc/mail.rc
```

### Issue: Port 25 connectivity fails
**Solution:**
- Check network connectivity: `ping mail.domain.com`
- Check firewall rules allow outbound port 25
- Verify SMTP server is listening: Contact network team

### Issue: Test email not received
**Solution:**
- Check mail queue: `mailq`
- Review mail logs: `tail -f /var/log/maillog`
- Verify recipient address is valid
- Check spam filters

### Issue: Mail service not running
**Solution:**
```bash
# Start postfix
systemctl start postfix
systemctl enable postfix

# Verify
systemctl status postfix
```

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Test Coverage:** Mail configuration and SMTP relay validation (CIP-010 R1)

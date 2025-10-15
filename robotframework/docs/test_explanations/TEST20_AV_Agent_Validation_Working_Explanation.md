# Test 20: AV Agent Validation - Working Explanation

## Test Information

**Test ID:** test20_av_agent_validation
**Test File:** `tests/test20_av_agent_validation/av_agent_validation.robot`
**Purpose:** Validate antivirus agent configuration meets CIP-007 R3.1 malware protection requirements
**Compliance:** CIP-007 R3.1 - Malware Prevention

---

## Overview

This test validates that the target server has an antivirus agent properly installed and configured to meet NERC CIP-007 R3.1 requirements for malware prevention. It checks agent installation, real-time protection, signature currency, scan schedules, and exclusion policies.

---

## Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│            TEST 20: AV AGENT VALIDATION                     │
│            (CIP-007 R3.1 Malware Prevention)                │
└─────────────────────────────────────────────────────────────┘

Step 1: Connect to Target Machine
   └─> Establish SSH connection
   └─> Check AV installation status

Step 2: Collect AV Agent Data
   ├─> Step 2.1: Collect Agent Installation Status
   │   └─> Get agent version and status
   │
   ├─> Step 2.2: Collect Real-Time Protection Settings
   │   └─> Check RTP enabled status
   │
   ├─> Step 2.3: Collect Signature Update Information
   │   └─> Get last signature update date
   │
   ├─> Step 2.4: Collect Scan Schedule Configuration
   │   └─> Get scheduled scan settings
   │
   ├─> Step 2.5: Collect Exclusion Configurations
   │   └─> Get exclusion paths and policies
   │
   └─> Step 2.6: Document AV Agent Data to Files
       └─> Save all AV data to files

Step 3: Validate Against CIP-007 R3.1 Standards
   ├─> Step 3.1: Validate Agent Installation
   │   └─> Agent installed and operational
   │
   ├─> Step 3.2: Validate Real-Time Protection
   │   └─> RTP is enabled
   │
   ├─> Step 3.3: Validate Signature Currency
   │   └─> Signatures updated within 7 days
   │
   ├─> Step 3.4: Validate Scheduled Scans
   │   └─> Scans configured and scheduled
   │
   └─> Step 3.5: Validate Exclusion Policies
       └─> Exclusions appropriate and documented

Final Result: PASS if AV meets CIP-007 R3.1 requirements
```

---

## Detailed Working

### Step 1: Connect to Target Machine

**What it does:**
- Establishes SSH connection to target server
- Checks if AV agent is installed

**Commands executed (McAfee example):**
```bash
/opt/McAfee/cma/bin/cmdagent -v
```

**Commands executed (SentinelOne example):**
```bash
/opt/sentinelone/bin/sentinelctl version
```

**Variables:**
- `${AV_TYPE}` - "McAfee" or "SentinelOne" (from environment)

**Robot Framework keyword:**
```robot
Check AV Installation Status
```

**Pass criteria:**
- AV agent binary exists and responds to version query

---

### Step 2.1: Collect Agent Installation Status

**What it does:**
- Collects agent version, installation date, and operational status
- Verifies agent is properly installed

**Commands executed (McAfee):**
```bash
/opt/McAfee/cma/bin/cmdagent -i
rpm -qa | grep McAfee
```

**Commands executed (SentinelOne):**
```bash
/opt/sentinelone/bin/sentinelctl status
/opt/sentinelone/bin/sentinelctl version
```

**Expected output structure:**
```python
${AGENT_STATUS} = {
    'version': '5.7.4',
    'status': 'active',
    'installation_date': '2024-01-15',
    'agent_type': 'McAfee Endpoint Security'
}
```

**Robot Framework keyword:**
```robot
Collect Agent Installation Status
```

---

### Step 2.2: Collect Real-Time Protection Settings

**What it does:**
- Checks if real-time protection (RTP) is enabled
- Validates on-access scanning is active

**Commands executed (McAfee):**
```bash
/opt/McAfee/cma/bin/cmdagent -c
```

**Commands executed (SentinelOne):**
```bash
/opt/sentinelone/bin/sentinelctl status | grep "Agent is"
```

**Expected output structure:**
```python
${RTP_SETTINGS} = {
    'enabled': True,
    'scan_on_read': True,
    'scan_on_write': True,
    'scan_on_execute': True
}
```

**Robot Framework keyword:**
```robot
Collect Real Time Protection Settings
```

**CIP-007 R3.1 Requirement:**
- Real-time protection MUST be enabled

---

### Step 2.3: Collect Signature Update Information

**What it does:**
- Retrieves last signature/definition update date
- Checks signature version

**Commands executed (McAfee):**
```bash
/opt/McAfee/cma/bin/cmdagent -p | grep "DAT Version"
```

**Commands executed (SentinelOne):**
```bash
/opt/sentinelone/bin/sentinelctl version | grep "Content Version"
```

**Expected output structure:**
```python
${SIGNATURE_INFO} = {
    'last_update': '2025-10-14',
    'version': '4523.0',
    'age_days': 0
}
```

**Robot Framework keyword:**
```robot
Collect Signature Update Information
```

**CIP-007 R3.1 Requirement:**
- Signatures updated within 7 days (MAX_SIGNATURE_AGE_DAYS = 7)

---

### Step 2.4: Collect Scan Schedule Configuration

**What it does:**
- Retrieves scheduled scan configuration
- Checks scan frequency and scope

**Commands executed (McAfee):**
```bash
/opt/McAfee/cma/bin/cmdagent -s | grep "Schedule"
```

**Commands executed (SentinelOne):**
```bash
/opt/sentinelone/bin/sentinelctl config --get scan.schedule
```

**Expected output structure:**
```python
${SCAN_SCHEDULE} = {
    'frequency': 'weekly',
    'day': 'Sunday',
    'time': '02:00',
    'scan_type': 'full'
}
```

**Robot Framework keyword:**
```robot
Collect Scan Schedule Configuration
```

**CIP-007 R3.1 Requirement:**
- Regular scans must be configured (weekly or monthly minimum)

---

### Step 2.5: Collect Exclusion Configurations

**What it does:**
- Collects list of exclusion paths and policies
- Documents why exclusions are needed

**Commands executed (McAfee):**
```bash
/opt/McAfee/cma/bin/cmdagent -p | grep -A 20 "Exclusions"
```

**Commands executed (SentinelOne):**
```bash
/opt/sentinelone/bin/sentinelctl config --get exclusions
```

**Expected output structure:**
```python
${EXCLUSIONS} = {
    'paths': [
        '/var/lib/mysql',
        '/opt/application/temp',
        '/var/log'
    ],
    'processes': ['oracle', 'postgres'],
    'extensions': ['.tmp']
}
```

**Robot Framework keyword:**
```robot
Collect Exclusion Configurations
```

**CIP-007 R3.1 Note:**
- Exclusions must be documented and justified

---

### Step 2.6: Document AV Agent Data to Files

**What it does:**
- Saves all collected AV data to multiple files
- Creates comprehensive AV summary report

**Robot Framework keyword:**
```robot
Save AV Agent Data to Files
```

**Files created:**
- `av_agent_status_YYYYMMDD_HHMMSS.txt` - Agent installation status
- `av_rtp_settings_YYYYMMDD_HHMMSS.txt` - Real-time protection settings
- `av_signature_info_YYYYMMDD_HHMMSS.txt` - Signature update information
- `av_scan_schedule_YYYYMMDD_HHMMSS.txt` - Scan schedule configuration
- `av_exclusions_YYYYMMDD_HHMMSS.txt` - Exclusion configurations
- `av_comprehensive_report_YYYYMMDD_HHMMSS.txt` - Complete summary

**File verification:**
```robot
OperatingSystem.File Should Exist    ${summary_file}
${file_size}=    OperatingSystem.Get File Size    ${summary_file}
Should Be True    ${file_size} > 0
```

---

### Step 3: Validate Against CIP-007 R3.1 Standards

#### Step 3.1: Validate Agent Installation

**What it does:**
- Validates agent is properly installed and operational
- Checks agent version is current

**Robot Framework keyword:**
```robot
Validate Agent Installation    ${AGENT_STATUS}
```

**Pass criteria:**
- Agent status = "active" or "running"
- Agent version not empty

---

#### Step 3.2: Validate Real-Time Protection

**What it does:**
- Validates RTP is enabled
- Critical CIP-007 R3.1 requirement

**Validation logic:**
```robot
${rtp_enabled}=    Get From Dictionary    ${RTP_SETTINGS}    enabled
Should Be True    ${rtp_enabled}    msg=Real-time protection is not enabled
```

**Pass criteria:**
- RTP enabled = True

**Fail message:**
```
❌ Real-time protection is not enabled - CIP-007 R3.1 VIOLATION
```

---

#### Step 3.3: Validate Signature Currency

**What it does:**
- Validates signatures are current (< 7 days old)
- Critical CIP-007 R3.1 requirement

**Validation logic:**
```robot
Validate Signature Currency    ${SIGNATURE_INFO}
```

**Pass criteria:**
- Signature age <= 7 days

**Variables:**
- `${MAX_SIGNATURE_AGE_DAYS}` = 7

**Example:**
```
📋 Maximum signature age: 7 days
📅 Last signature update: 2025-10-14 (0 days ago)
✅ Signature currency validated (Current)
```

**Fail message:**
```
❌ Signatures are 10 days old - exceeds 7 day maximum (CIP-007 R3.1)
```

---

#### Step 3.4: Validate Scheduled Scans

**What it does:**
- Validates scheduled scans are configured
- Checks scan frequency is appropriate

**Robot Framework keyword:**
```robot
Validate Scheduled Scans    ${SCAN_SCHEDULE}
```

**Pass criteria:**
- Scan frequency configured (daily, weekly, or monthly)
- Scan type defined

---

#### Step 3.5: Validate Exclusion Policies

**What it does:**
- Validates exclusions are appropriate
- Ensures exclusions don't compromise security

**Robot Framework keyword:**
```robot
Validate Exclusion Policies    ${EXCLUSIONS}
```

**Pass criteria:**
- Exclusions documented
- Exclusion count reasonable (not excessive)

---

### Comprehensive AV Validation Summary

**Example output:**
```
📊 COMPREHENSIVE AV VALIDATION SUMMARY (CIP-007 R3.1)
📊 AV protection validation summary:
📊 - Agent installation: ✅
📊 - Real-time protection: ✅
📊 - Signature currency: ✅
📊 - Scheduled scans: ✅
📊 - Exclusion policies: ✅
✅ AV protection validation: PASSED - Meets CIP-007 R3.1 requirements
```

---

## Data Sources

### Input Data:
- `${AV_TYPE}` - "McAfee" or "SentinelOne" (from environment)
- `${MAX_SIGNATURE_AGE_DAYS}` - 7 days (CIP-007 R3.1 requirement)

### Output Data:
- `${AGENT_STATUS}` - Agent installation status
- `${RTP_SETTINGS}` - Real-time protection settings
- `${SIGNATURE_INFO}` - Signature update information
- `${SCAN_SCHEDULE}` - Scan schedule configuration
- `${EXCLUSIONS}` - Exclusion configurations

### Files Created:
All files saved to `${TEST20_DATA_DIR}`:
- Agent status
- RTP settings
- Signature info
- Scan schedule
- Exclusions
- Comprehensive report

---

## Success/Failure Criteria

### Test PASSES if (CIP-007 R3.1):
- ✅ AV agent installed and operational (Critical)
- ✅ Real-time protection enabled (Critical)
- ✅ Signatures current (< 7 days) (Critical)
- ✅ Scheduled scans configured (Critical)
- ✅ Exclusions documented (Critical)

### Test FAILS if:
- ❌ AV agent not installed
- ❌ Real-time protection disabled
- ❌ Signatures outdated (>= 7 days)
- ❌ No scheduled scans configured
- ❌ Excessive or unjustified exclusions

---

## Key Technologies and Commands

| AV Product | Purpose | Commands Used |
|------------|---------|---------------|
| McAfee | Agent status | `/opt/McAfee/cma/bin/cmdagent -v`, `-i`, `-c`, `-p`, `-s` |
| SentinelOne | Agent status | `/opt/sentinelone/bin/sentinelctl status`, `version`, `config` |
| rpm | Package check | `rpm -qa \| grep McAfee` |

---

## Example Execution

```
🔍 STEP 1: CONNECT TO TARGET MACHINE VIA SSH
📋 Target Machine: alhxvdvitap01
📋 Expected AV Type: McAfee
✅ SSH connection established and AV installation confirmed

🔍 STEP 2.1: COLLECT AGENT INSTALLATION STATUS
✅ Agent installation status: McAfee Endpoint Security 5.7.4 - active

🔍 STEP 2.2: COLLECT REAL-TIME PROTECTION SETTINGS
✅ Real-time protection status: Enabled

🔍 STEP 2.3: COLLECT SIGNATURE UPDATE INFORMATION
✅ Signature last updated: 2025-10-14 (0 days ago)

🔍 STEP 2.6: DOCUMENT AV AGENT DATA TO FILES
📄 AV agent data saved to: test20_data/
✅ AV agent documentation saved

🔍 STEP 3.2: VALIDATE REAL-TIME PROTECTION
✅ Real-time protection status validated (Enabled)

🔍 STEP 3.3: VALIDATE SIGNATURE CURRENCY
📋 Maximum signature age: 7 days
📅 Signature age: 0 days
✅ Signature currency validated (Current)

📊 COMPREHENSIVE AV VALIDATION SUMMARY (CIP-007 R3.1)
✅ AV protection validation: PASSED - Meets CIP-007 R3.1 requirements
```

---

## Troubleshooting

### Issue: AV agent not installed
**Solution:**
- Contact security team to install approved AV agent
- McAfee or SentinelOne are typical enterprise solutions

### Issue: Real-time protection disabled
**Solution (McAfee):**
```bash
/opt/McAfee/cma/bin/cmdagent -e
# Enable real-time scanning
```

**Solution (SentinelOne):**
```bash
/opt/sentinelone/bin/sentinelctl config --set agent.enabled=true
```

### Issue: Signatures outdated
**Solution (McAfee):**
```bash
# Force signature update
/opt/McAfee/cma/bin/cmdagent -u

# Verify
/opt/McAfee/cma/bin/cmdagent -p | grep "DAT Version"
```

**Solution (SentinelOne):**
```bash
# Force content update
/opt/sentinelone/bin/sentinelctl update
```

### Issue: No scheduled scans configured
**Solution:**
- Configure via central management console (ePO for McAfee, Management Console for SentinelOne)
- Or configure locally per vendor documentation

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Test Coverage:** Antivirus agent validation (CIP-007 R3.1 Malware Prevention)
**Critical:** This test validates NERC CIP compliance for malware protection

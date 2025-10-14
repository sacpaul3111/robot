# Test 20: Antivirus Agent Validation - Working Explanation

## Test Information
- **Test Suite**: `test20_av_agent_validation`
- **Robot File**: `av_agent_validation.robot`
- **Test ID**: Test-20
- **Purpose**: Validate antivirus agent configuration meets CIP-007 R3.1 requirements for malware protection
- **Compliance**: CIP-007 R3.1 - Malware Prevention

---

## Overview

Test 20 validates antivirus protection by:
1. Verifying AV agent is installed and running
2. Collecting AV configuration (real-time protection, signatures, scans, exclusions)
3. Validating agent meets CIP-007 R3.1 malware prevention requirements
4. Documenting all AV settings to files for compliance review

**CIP-007 R3.1**: Each Responsible Entity shall deploy method(s) to deter, detect, or prevent malicious code.

---

## Process Flow

```
Step 1: Connect to Target Machine → SSH + verify AV installed

Step 2: Collect AV Agent Data
  ├─> Step 2.1: Collect Agent Installation Status
  ├─> Step 2.2: Collect Real-Time Protection Settings
  ├─> Step 2.3: Collect Signature Update Information
  ├─> Step 2.4: Collect Scan Schedule Configuration
  ├─> Step 2.5: Collect Exclusion Configurations
  └─> Step 2.6: Document AV Agent Data to Files

Step 3: Validate Against CIP-007 R3.1 Standards
  ├─> Step 3.1: Validate Agent Installation
  ├─> Step 3.2: Validate Real-Time Protection (MUST be enabled)
  ├─> Step 3.3: Validate Signature Currency (max 7 days old)
  ├─> Step 3.4: Validate Scheduled Scans (configured)
  └─> Step 3.5: Validate Exclusion Policies (appropriate)

Normal Test:
  └─> Comprehensive AV Validation Summary
```

---

## Supported Antivirus Products

- **McAfee VirusScan Enterprise** (ma/nailsd service)
- **SentinelOne** (sentinelone service)

---

## Key Steps Explained

### Step 1: Connect and Verify AV Installation
**Purpose**: SSH to target and confirm AV agent is installed

**Actions**:
1. Establish SSH connection
2. Execute `Check AV Installation Status`
3. Search for AV processes and packages:
   - McAfee: `ps -ef | grep -i mcafee`, `rpm -qa | grep McAfee`
   - SentinelOne: `ps -ef | grep sentinelone`, `rpm -qa | grep sentinelone`
4. Fail if no AV agent found

**Expected**: AV agent (McAfee or SentinelOne) must be installed

---

### Step 2.1: Collect Agent Installation Status
**Purpose**: Get AV agent version and installation details

**Actions**:
1. Execute agent-specific version command:
   - McAfee: `/opt/McAfee/cma/bin/cmdagent -v`
   - SentinelOne: `/opt/sentinelone/bin/sentinelctl version`
2. Parse output for version number
3. Check installation directories
4. Store in `${AGENT_STATUS}` dictionary:
   ```python
   {
       'version': '5.7.8',
       'status': 'installed',
       'type': 'McAfee'
   }
   ```

---

### Step 2.2: Collect Real-Time Protection Settings
**Purpose**: Verify real-time (on-access) protection is enabled

**Actions**:
1. Query AV agent for RTP status:
   - McAfee: `/opt/McAfee/cma/bin/cmdagent -c` (check status)
   - SentinelOne: `/opt/sentinelone/bin/sentinelctl status`
2. Parse output for real-time protection state
3. Store in `${RTP_SETTINGS}` dictionary:
   ```python
   {
       'enabled': True,
       'mode': 'on-access',
       'status': 'active'
   }
   ```

**CIP-007 R3.1 Requirement**: Real-time protection MUST be enabled

---

### Step 2.3: Collect Signature Update Information
**Purpose**: Check when AV signatures were last updated

**Actions**:
1. Query AV agent for DAT version and update date:
   - McAfee: `/opt/McAfee/cma/bin/cmdagent -i` (DAT info)
   - SentinelOne: `/opt/sentinelone/bin/sentinelctl info`
2. Extract last update timestamp
3. Store in `${SIGNATURE_INFO}` dictionary:
   ```python
   {
       'version': '9876',
       'last_update': '2025-10-13',
       'age_days': 1
   }
   ```

**CIP-007 R3.1 Requirement**: Signatures must be current (max 7 days old)

---

### Step 2.4: Collect Scan Schedule Configuration
**Purpose**: Verify scheduled scans are configured

**Actions**:
1. Check for scan schedule configuration:
   - McAfee: Check scan task in McAfee console or crontab
   - SentinelOne: Check scan policy
2. Extract scan frequency (daily, weekly, etc.)
3. Store in `${SCAN_SCHEDULE}` dictionary:
   ```python
   {
       'enabled': True,
       'frequency': 'Weekly',
       'day': 'Sunday',
       'time': '02:00'
   }
   ```

---

### Step 2.5: Collect Exclusion Configurations
**Purpose**: Document AV exclusion paths and policies

**Actions**:
1. Query AV agent for exclusions:
   - McAfee: Check exclusion list from agent
   - SentinelOne: `/opt/sentinelone/bin/sentinelctl config get`
2. Extract excluded paths, file types, processes
3. Store in `${EXCLUSIONS}` dictionary:
   ```python
   {
       'paths': ['/opt/app/temp', '/var/log'],
       'extensions': ['.tmp', '.log'],
       'count': 2
   }
   ```

**Note**: Exclusions should be documented and approved for compliance

---

### Step 2.6: Document AV Agent Data to Files
**Purpose**: Save all collected AV data to files for compliance audit

**Actions**:
1. Call `Save AV Agent Data to Files` keyword
2. Generate 6 files:
   - `av_agent_status_<timestamp>.txt` - Agent installation details
   - `av_rtp_settings_<timestamp>.txt` - Real-time protection config
   - `av_signature_info_<timestamp>.txt` - Signature update details
   - `av_scan_schedule_<timestamp>.txt` - Scan schedule configuration
   - `av_exclusions_<timestamp>.txt` - Exclusion list
   - `av_validation_report_<timestamp>.txt` - Comprehensive validation report
3. Verify all files created successfully

---

### Step 3.1: Validate Agent Installation
**Purpose**: Ensure AV agent is properly installed

**Validation**:
```robot
Check: ${AGENT_STATUS}['status'] == 'installed'
Check: ${AGENT_STATUS}['version'] is not empty
```

**Pass**: Agent installed with valid version

---

### Step 3.2: Validate Real-Time Protection
**Purpose**: Ensure RTP is enabled (CIP-007 R3.1 requirement)

**Validation**:
```robot
Check: ${RTP_SETTINGS}['enabled'] == True
Assertion: Should Be True ${rtp_enabled}
```

**Pass**: Real-time protection is enabled
**Fail**: RTP is disabled (violates CIP-007 R3.1)

---

### Step 3.3: Validate Signature Currency
**Purpose**: Ensure signatures are current (max 7 days old)

**Validation**:
```robot
MAX_SIGNATURE_AGE_DAYS: 7
Check: ${SIGNATURE_INFO}['age_days'] <= 7
```

**Pass**: Signatures updated within 7 days
**Fail**: Signatures older than 7 days (violates CIP-007 R3.1)

---

### Step 3.4: Validate Scheduled Scans
**Purpose**: Ensure scheduled scans are configured

**Validation**:
```robot
Check: ${SCAN_SCHEDULE}['enabled'] == True
Check: Scan frequency is defined
```

**Pass**: Scheduled scans configured
**Fail**: No scan schedule configured

---

### Step 3.5: Validate Exclusion Policies
**Purpose**: Ensure exclusions are appropriate and documented

**Validation**:
```robot
Check: Exclusions are documented
Check: Exclusion count is reasonable
Warning: Review exclusions for security risks
```

**Pass**: Exclusions documented and reasonable

---

## Data Files Saved

Files saved to `results/test20_av_agent_validation/data/`:
- `av_agent_status_<timestamp>.txt` - Agent installation and version
- `av_rtp_settings_<timestamp>.txt` - Real-time protection configuration
- `av_signature_info_<timestamp>.txt` - Signature version and update date
- `av_scan_schedule_<timestamp>.txt` - Scheduled scan configuration
- `av_exclusions_<timestamp>.txt` - Exclusion paths and policies
- `av_validation_report_<timestamp>.txt` - Comprehensive validation summary

---

## Key Technologies

- **McAfee VirusScan Enterprise**
  - Service: `ma` or `nailsd`
  - Command: `/opt/McAfee/cma/bin/cmdagent`
  - Ports: 8081 (management)

- **SentinelOne**
  - Service: `sentinelone`
  - Command: `/opt/sentinelone/bin/sentinelctl`
  - Ports: 443 (management)

**Commands Used**:
- `ps -ef | grep mcafee` - Check McAfee processes
- `systemctl status ma` - Check McAfee service
- `/opt/McAfee/cma/bin/cmdagent -v` - Get McAfee version
- `/opt/McAfee/cma/bin/cmdagent -c` - Get McAfee status
- `/opt/McAfee/cma/bin/cmdagent -i` - Get DAT info
- `/opt/sentinelone/bin/sentinelctl version` - Get SentinelOne version
- `/opt/sentinelone/bin/sentinelctl status` - Get SentinelOne status

---

## Success Criteria (CIP-007 R3.1 Compliance)

**Passes When**:
- AV agent is installed and running ✅
- Real-time protection is ENABLED ✅
- Signatures updated within 7 days ✅
- Scheduled scans configured ✅
- Exclusions documented ✅
- All data saved to files ✅

**Fails When**:
- No AV agent installed ❌
- Real-time protection DISABLED ❌ (CIP-007 R3.1 violation)
- Signatures older than 7 days ❌ (CIP-007 R3.1 violation)
- No scheduled scans ❌
- Excessive/undocumented exclusions ⚠️

---

## Common Issues

### Issue 1: AV Agent Not Found
**Cause**: No McAfee or SentinelOne installed
**Resolution**: Install approved AV agent

### Issue 2: Real-Time Protection Disabled
**Cause**: RTP manually disabled or service stopped
**Resolution**: Enable RTP immediately (CIP-007 R3.1 compliance)
```bash
systemctl start ma  # McAfee
systemctl start sentinelone  # SentinelOne
```

### Issue 3: Outdated Signatures
**Cause**: Cannot connect to update server or updates disabled
**Resolution**:
- Enable automatic updates
- Check network connectivity to update server
- Manually trigger update

### Issue 4: No Scan Schedule
**Cause**: Scheduled scans not configured
**Resolution**: Configure weekly full scan via AV console

---

## CIP-007 R3.1 Compliance

**Requirement**: Deploy methods to deter, detect, or prevent malicious code

**Test Validates**:
1. ✅ Malware detection capability (AV agent installed)
2. ✅ Real-time protection (on-access scanning)
3. ✅ Current malware definitions (signature updates)
4. ✅ Regular scanning (scheduled scans)
5. ✅ Exclusion management (documented exceptions)

---

## Execution Example

```bash
robot --variable TARGET_HOSTNAME:alhxvdvitap01 \
      --variable AV_TYPE:McAfee \
      --variable SSH_USERNAME:admin \
      --variable SSH_PASSWORD:password \
      --outputdir results/test20_av_agent_validation \
      tests/test20_av_agent_validation/av_agent_validation.robot
```

---

**Document Version**: 1.0 | **Date**: 2025-10-14 | **Compliance**: CIP-007 R3.1

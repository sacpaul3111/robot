# Test 11: Services Validation - Working Explanation

## Test Information

**Test ID:** test11_services_validation
**Test File:** `tests/test11_services_validation/services_validation.robot`
**Purpose:** Collect and document all system services for compliance review (Informational)
**Compliance:** CIP-010 R1 - Baseline Configuration Management

---

## Overview

This test collects a complete inventory of all system services running on the target server. It documents service statuses, checks required services, and saves comprehensive service information to files for compliance and security review. **This is an informational test** - it does not fail based on service status but documents everything for manual review.

---

## Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│              TEST 11: SERVICES VALIDATION                   │
└─────────────────────────────────────────────────────────────┘

Step 1: Connect to Target Server
   └─> Establish SSH connection
   └─> Verify connection active

Step 2: Collect Service Data
   ├─> Step 2.1: Collect All Services Status
   │   └─> Execute: systemctl list-units --type=service
   │   └─> Execute: systemctl list-unit-files --type=service --state=enabled
   │   └─> Save: ${ALL_SERVICES_OUTPUT}, ${ENABLED_SERVICES_OUTPUT}
   │
   └─> Step 2.2: Document Service Status to File
       └─> Save complete service list to file
       └─> File: ${DATA_DIR}/services_status_YYYYMMDD_HHMMSS.txt

Step 3: Document Service Status (Informational)
   ├─> Step 3.1: Review Required Services Status
   │   └─> Check: autofs, sshd, sssd, chronyd, syslog
   │   └─> Result: INFORMATIONAL (documented)
   │
   └─> Step 3.2: Review Unnecessary Services Status
       └─> Check: iptables, selinux status
       └─> Result: INFORMATIONAL (documented)

Step 4: Additional Analysis (Informational)
   ├─> Service Dependency Analysis
   ├─> Failed Services Report
   ├─> Service Startup Time Analysis
   └─> Security Services Status

Final Result: INFORMATIONAL - All service data documented
```

---

## Detailed Working

### Step 1: Connect to Target Server

**What it does:**
- Establishes SSH connection to target server
- Verifies connection is active

**Commands executed:**
```bash
echo "Connection active"
```

---

### Step 2: Collect Service Data

#### Step 2.1: Collect All Services Status

**What it does:**
- Lists all systemd services and their current status
- Lists all enabled services (auto-start)
- Collects comprehensive service inventory

**Commands executed:**
```bash
systemctl list-units --type=service --all --no-pager
systemctl list-unit-files --type=service --state=enabled --no-pager
```

**Expected output - list-units:**
```
UNIT                          LOAD   ACTIVE SUB     DESCRIPTION
sshd.service                  loaded active running OpenSSH server daemon
chronyd.service               loaded active running NTP client/server
sssd.service                  loaded active running System Security Services Daemon
autofs.service                loaded active running Automounts filesystems on demand
rsyslog.service               loaded active running System Logging Service
```

**Expected output - enabled services:**
```
UNIT FILE          STATE
sshd.service       enabled
chronyd.service    enabled
sssd.service       enabled
autofs.service     enabled
rsyslog.service    enabled
```

**Variables set:**
- `${ALL_SERVICES_OUTPUT}` - Complete service list with status
- `${ENABLED_SERVICES_OUTPUT}` - List of enabled services
- `${SERVICES_DATA_COLLECTED}` - Boolean flag (True)

**Robot Framework keyword:**
```robot
Collect All Services Status
```

**Count services:**
```robot
${ALL_SERVICES_OUTPUT.count('●')} entries
```

---

#### Step 2.2: Document Service Status to File

**What it does:**
- Saves complete service inventory to text file
- Creates timestamped file in DATA_DIR
- Includes all service statuses for compliance review

**Robot Framework keyword:**
```robot
Save Services Status to File
```

**File created:**
- Path: `${DATA_DIR}/services_status_YYYYMMDD_HHMMSS.txt`
- Example: `test11_data/services_status_20251014_103000.txt`

**File content format:**
```
=== SERVICES STATUS REPORT ===
Timestamp: 2025-10-14 10:30:00
Target Server: alhxvdvitap01 (10.10.10.100)

=== ALL SERVICES ===
[systemctl list-units --type=service output]

=== ENABLED SERVICES ===
[systemctl list-unit-files --state=enabled output]

=== END REPORT ===
```

**File verification:**
```robot
OperatingSystem.File Should Exist    ${service_file}
${file_size}=    Get File Size    ${service_file}
Should Be True    ${file_size} > 0
```

---

### Step 3: Document Service Status (Informational)

#### Step 3.1: Review Required Services Status

**What it does:**
- Checks status of required services for proper operation
- Documents whether each service is enabled/active
- **Does NOT fail test** - informational only

**Required services checked:**
- `autofs.service` - Automount filesystems
- `sshd.service` - SSH server
- `sssd.service` - System Security Services Daemon
- `chronyd.service` - NTP time synchronization
- `ntpd.service` - Alternative NTP service
- `rsyslog.service` - System logging

**Variable:**
```robot
${REQUIRED_SERVICES_ENABLED} = ['autofs', 'sshd', 'sssd', 'chronyd', 'ntpd', 'rsyslog']
```

**Robot Framework keyword:**
```robot
Validate Required Services Are Enabled
```

**Output format:**
```robot
FOR    ${service}    IN    @{REQUIRED_SERVICES_ENABLED}
    ${status}=    Get From Dictionary    ${validation_results}    ${service}
    Log    📊 - ${service}: ${status}    console=yes
END
```

**Example output:**
```
📊 Required services status:
📊 - autofs: active (enabled)
📊 - sshd: active (enabled)
📊 - sssd: active (enabled)
📊 - chronyd: active (enabled)
📊 - ntpd: inactive (not found)
📊 - rsyslog: active (enabled)
```

**Result:** Informational - documented in logs

---

#### Step 3.2: Review Unnecessary Services Status

**What it does:**
- Checks status of services that should typically be disabled
- Documents security-related service statuses
- **Does NOT fail test** - informational only

**Services checked:**
- `iptables.service` - Firewall (often disabled in favor of firewalld)
- SELinux status (getenforce)

**Variable:**
```robot
${REQUIRED_SERVICES_DISABLED} = ['iptables']
```

**Robot Framework keyword:**
```robot
Validate Unnecessary Services Are Disabled
```

**Example output:**
```
📊 Security services status:
📊 - iptables: inactive (disabled) ✅
📊 - SELinux: Enforcing
```

**Result:** Informational - documented in logs

---

### Step 4: Additional Analysis (Informational)

#### Service Dependency Analysis

**What it does:**
- Analyzes service dependencies for critical services
- Shows what services depend on others

**Commands executed:**
```bash
systemctl list-dependencies sshd.service | head -20
systemctl list-dependencies chronyd.service | head -20
systemctl list-dependencies sssd.service | head -20
```

**Example output:**
```
📊 SSHD Dependencies:
sshd.service
├─system.slice
├─sshd-keygen.target
│ ├─sshd-keygen@rsa.service
│ └─sshd-keygen@ecdsa.service
└─network.target
  └─network.service
```

---

#### Failed Services Report

**What it does:**
- Identifies any services that failed to start
- Reports failed services for troubleshooting

**Commands executed:**
```bash
systemctl --failed --no-pager --no-legend
```

**Example output - no failures:**
```
✅ No failed services detected
```

**Example output - with failures:**
```
⚠️ Failed services detected:
bluetooth.service  loaded failed failed  Bluetooth service
postfix.service    loaded failed failed  Postfix Mail Transport Agent
```

**File saved (if failures exist):**
```robot
Save Failed Services Report    ${failed_services}
```

---

#### Service Startup Time Analysis

**What it does:**
- Analyzes system boot time
- Identifies slowest-starting services

**Commands executed:**
```bash
systemd-analyze time
systemd-analyze blame | head -20
```

**Example output:**
```
⏱️ Boot Time Analysis:
Startup finished in 3.521s (kernel) + 8.456s (initrd) + 25.789s (userspace) = 37.766s

📊 Slowest Services:
     12.456s sssd.service
      8.234s chronyd.service
      5.678s NetworkManager.service
      3.421s firewalld.service
```

---

#### Security Services Status

**What it does:**
- Checks security-related services and configurations
- Documents SELinux, iptables, firewalld status

**Commands executed:**
```bash
getenforce
systemctl is-active iptables
systemctl is-active firewalld
```

**Example output:**
```
🔒 SELinux Status: Enforcing
🔒 iptables Status: inactive
🔒 firewalld Status: active
```

**Result:** Informational - security configuration documented

---

## Data Sources

### Input Data:
- List of required services (hardcoded in test)
- List of services to check as disabled (hardcoded)

### Output Data:
- `${ALL_SERVICES_OUTPUT}` - All services with status
- `${ENABLED_SERVICES_OUTPUT}` - Enabled services only
- `${SERVICE_STATUS_FILE}` - File path for saved data

### Files Created:
- `services_status_YYYYMMDD_HHMMSS.txt` - Complete service inventory
- `failed_services_YYYYMMDD_HHMMSS.txt` - Failed services (if any)

---

## Success/Failure Criteria

### Test ALWAYS PASSES:
- ✅ SSH connection successful
- ✅ Service data collected
- ✅ Service status documented to file
- ✅ All validations are informational only

**This test does NOT fail based on service status** - it documents all services for manual compliance review.

### Test would only FAIL if:
- ❌ SSH connection fails
- ❌ Service data collection fails
- ❌ File creation fails

---

## Key Technologies and Commands

| Technology | Purpose | Commands Used |
|------------|---------|---------------|
| systemctl | Service management | `list-units`, `list-unit-files`, `--failed`, `is-active`, `list-dependencies` |
| systemd-analyze | Boot analysis | `systemd-analyze time`, `systemd-analyze blame` |
| getenforce | SELinux status | `getenforce` |
| SSHLibrary | Remote execution | Robot Framework SSH connection |

---

## File Output

### Files Created:

**1. Services Status Report:**
- Location: `test11_data/services_status_YYYYMMDD_HHMMSS.txt`
- Contains: Complete service inventory with status

**2. Failed Services Report (if any):**
- Location: `test11_data/failed_services_YYYYMMDD_HHMMSS.txt`
- Contains: List of failed services for troubleshooting

---

## Example Execution

### Successful execution:
```
🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH
📋 Target: alhxvdvitap01 (10.10.10.100)
✅ SSH connection verified and active

🔍 STEP 2.1: COLLECT ALL SERVICES STATUS
📋 Total services collected: 125 entries
✅ Service list collected

🔍 STEP 2.2: DOCUMENT SERVICE STATUS TO FILE
📄 Service status saved to: test11_data/services_status_20251014_103000.txt
📄 File size: 15234 bytes
✅ Service documentation saved

🔍 STEP 3.1: REQUIRED SERVICES STATUS REVIEW (INFORMATIONAL)
📋 Required services: ['autofs', 'sshd', 'sssd', 'chronyd', 'rsyslog']
📊 Required services status:
📊 - autofs: active (enabled)
📊 - sshd: active (enabled)
📊 - sssd: active (enabled)
📊 - chronyd: active (enabled)
📊 - rsyslog: active (enabled)

🔍 Failed Services Report
✅ No failed services detected

Overall Status: INFORMATIONAL ✅
All service data documented for review
```

---

## Troubleshooting

### Issue: Many services shown as "failed"
**Solution:**
- Review actual failure reasons: `systemctl status <service>`
- Some failed services may be expected (e.g., bluetooth on servers)
- Focus on critical services (sshd, chronyd, rsyslog)

### Issue: Required service not enabled
**Solution:**
```bash
# Enable and start service
systemctl enable --now <service>

# Verify
systemctl status <service>
```

### Issue: SELinux in permissive or disabled mode
**Solution:**
```bash
# Check current status
getenforce

# Set to enforcing (if required)
setenforce 1

# Make permanent
vi /etc/selinux/config
SELINUX=enforcing
```

### Issue: File creation fails
**Solution:**
- Check DATA_DIR exists and is writable
- Verify disk space available
- Check file permissions

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Test Coverage:** System services inventory and documentation (CIP-010 R1)
**Note:** This is an INFORMATIONAL test - all checks document status for manual review

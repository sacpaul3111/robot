# Test 18: Patch Management & RSA Authentication - Working Explanation

## Test Information

**Test ID:** test18_patch_management
**Test File:** `tests/test18_patch_management/patch_management.robot`
**Purpose:** Validate RSA SecurID agent configuration and patch management registration
**Compliance:** CIP-007 R2 - Security Patch Management, CIP-005 - Two-Factor Authentication

---

## Overview

This test validates that the target server has RSA SecurID two-factor authentication properly configured and is registered with the patch management system (Red Hat Satellite/Ansible Tower). RSA authentication is critical for secure patch management access.

---

## Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│        TEST 18: PATCH MANAGEMENT & RSA VALIDATION           │
└─────────────────────────────────────────────────────────────┘

Step 1: Connect to Target Server
   └─> Establish SSH connection

Step 2: Collect Patch Management Data
   ├─> Step 2.1: Check RSA Agent Installation
   │   └─> Execute: rpm -qa | grep rsa
   │   └─> Save RSA agent status to file
   │
   ├─> Step 2.2: Validate RSA Configuration Files
   │   └─> Check: /etc/pam.d/system-auth contains RSA config
   │   └─> Check: /var/ace/config/ exists
   │   └─> Save RSA config to file
   │
   ├─> Step 2.3: Check RSA Authentication Settings
   │   └─> Validate RSA PAM configuration
   │   └─> Check RSA agent configuration
   │
   └─> Step 2.4: Test RSA Server Connectivity
       └─> Execute: nc -zv rsa.domain.com 5500
       └─> Save connectivity test results

Step 3: Validate Against Standards
   ├─> Step 3.1: Validate RSA Agent Status
   │   └─> Check RSA agent service running
   │   └─> Result: PASS/FAIL
   │
   └─> Step 3.2: Check Patch Management Registration
       └─> Execute: subscription-manager status
       └─> Check Satellite/Ansible registration
       └─> Result: PASS/FAIL

Step 4: Additional Validation (Normal/Informational)
   ├─> Validate Two-Factor Authentication Flow
   ├─> Check RSA Token Configuration
   ├─> Validate Satellite Subscription Status
   ├─> Check Available Patches
   ├─> Validate Ansible Control Node Access
   ├─> Check Patch Management Schedule
   ├─> Validate Security Updates Status
   └─> Comprehensive Patch Management Summary

Final Result: PASS if RSA configured and patch system registered
```

---

## Detailed Working

### Step 2.1: Check RSA Agent Installation

**What it does:**
- Checks if RSA SecurID agent is installed
- Verifies agent package and version

**Commands executed:**
```bash
rpm -qa | grep -i rsa
rpm -qa | grep -i securid
```

**Expected output:**
```
rsa-authentication-manager-7.1.0-1.x86_64
rsa-securid-pam-agent-8.0.1-1.x86_64
```

**Robot Framework keyword:**
```robot
Check RSA Agent Installation
Save RSA Agent Status to File    ${agent_status}
```

**File created:**
- `${DATA_DIR}/rsa_agent_status_YYYYMMDD_HHMMSS.txt`

---

### Step 2.2: Validate RSA Configuration Files

**What it does:**
- Checks for RSA configuration files in expected locations
- Validates PAM (Pluggable Authentication Modules) integration

**Files checked:**
- `/etc/pam.d/system-auth` - PAM configuration
- `/var/ace/config/` - RSA agent configuration directory
- `/var/ace/config/sdconf.rec` - RSA server configuration

**Commands executed:**
```bash
cat /etc/pam.d/system-auth | grep rsa
ls -la /var/ace/config/
```

**Expected in system-auth:**
```
auth sufficient pam_rsa_auth.so
```

**Robot Framework keyword:**
```robot
Collect RSA Configuration Files
Save RSA Config to File    ${config_status}
```

**File created:**
- `${DATA_DIR}/rsa_config_YYYYMMDD_HHMMSS.txt`

---

### Step 2.3: Check RSA Authentication Settings

**What it does:**
- Validates RSA authentication is properly configured
- Checks PAM configuration includes RSA module

**Robot Framework keyword:**
```robot
Validate RSA Authentication Settings
```

**Validation checks:**
- PAM system-auth contains RSA references
- RSA configuration directory exists and is readable
- RSA agent configuration file exists

---

### Step 2.4: Test RSA Server Connectivity

**What it does:**
- Tests connectivity to RSA authentication server
- Default RSA port: 5500 (UDP/TCP)

**Commands executed:**
```bash
nc -zv rsa.domain.com 5500
```

**Variables:**
- `${EXPECTED_RSA_SERVER}` - rsa.domain.com
- `${RSA_PORT}` - 5500

**Robot Framework keyword:**
```robot
Test RSA Server Connectivity
Save RSA Connectivity Test to File    ${connectivity_result}
```

**File created:**
- `${DATA_DIR}/rsa_connectivity_YYYYMMDD_HHMMSS.txt`

---

### Step 3.1: Validate RSA Agent Status

**What it does:**
- Checks if RSA agent service is running
- Validates agent is actively communicating with RSA server

**Commands executed:**
```bash
systemctl status rsa-agent
ps aux | grep rsa
```

**Robot Framework keyword:**
```robot
Check RSA Agent Service Status
```

**Pass criteria:**
- RSA agent service active
- RSA processes running

---

### Step 3.2: Check Patch Management Registration

**What it does:**
- Validates system is registered with Red Hat Satellite or Ansible Tower
- Checks subscription status

**Commands executed:**
```bash
subscription-manager status
subscription-manager identity
```

**Expected output - Satellite:**
```
+-------------------------------------------+
   System Status Details
+-------------------------------------------+
Overall Status: Current
System Purpose Status: Matched

System Identity:
org name: domain.com
org ID: 12345678
```

**Robot Framework keyword:**
```robot
Check Patch Management Registration
Save Registration Status to File    ${registration_status}
```

**File created:**
- `${DATA_DIR}/patch_registration_YYYYMMDD_HHMMSS.txt`

---

### Step 4: Additional Validation

#### Validate Two-Factor Authentication Flow

**What it does:**
- Validates complete 2FA readiness for patch management access
- Checks RSA + password authentication flow

**Robot Framework keyword:**
```robot
Validate Two Factor Authentication Flow
```

---

#### Check RSA Token Configuration

**What it does:**
- Verifies RSA token assignment
- Checks token serial number association

**Commands executed:**
```bash
cat /var/ace/config/sdconf.rec
```

---

#### Validate Satellite Subscription Status

**What it does:**
- Validates Red Hat Satellite subscription is current
- Checks content view and lifecycle environment

**Commands executed:**
```bash
subscription-manager list --consumed
subscription-manager repos --list-enabled
```

**Robot Framework keyword:**
```robot
Check Satellite Subscription Status
Save Subscription Status to File    ${subscription_status}
```

---

#### Check Available Patches

**What it does:**
- Lists available patches and updates
- Identifies security patches

**Commands executed:**
```bash
yum check-update
yum list updates
yum updateinfo list security
```

**Robot Framework keyword:**
```robot
Check Available Patches
Save Available Patches to File    ${patch_status}
```

**File created:**
- `${DATA_DIR}/available_patches_YYYYMMDD_HHMMSS.txt`

---

#### Validate Ansible Control Node Access

**What it does:**
- Checks connectivity to Ansible Tower/AWX
- Validates server is in Ansible inventory

**Robot Framework keyword:**
```robot
Check Ansible Control Node Access
```

---

#### Validate Security Updates Status

**What it does:**
- Checks status of security patches
- Identifies critical updates

**Commands executed:**
```bash
yum updateinfo list security --security
yum updateinfo info security
```

**Robot Framework keyword:**
```robot
Check Security Updates Status
Save Security Updates to File    ${security_status}
```

---

## Data Sources

### Input Data (Environment Variables):
- `${EXPECTED_RSA_SERVER}` - rsa.domain.com
- `${RSA_PORT}` - 5500

### Output Data:
- RSA agent installation status
- RSA configuration files
- RSA connectivity test results
- Patch management registration status
- Available patches list
- Security updates list

### Files Created:
- `rsa_agent_status_YYYYMMDD_HHMMSS.txt`
- `rsa_config_YYYYMMDD_HHMMSS.txt`
- `rsa_connectivity_YYYYMMDD_HHMMSS.txt`
- `patch_registration_YYYYMMDD_HHMMSS.txt`
- `subscription_status_YYYYMMDD_HHMMSS.txt`
- `available_patches_YYYYMMDD_HHMMSS.txt`
- `security_updates_YYYYMMDD_HHMMSS.txt`

---

## Success/Failure Criteria

### Test PASSES if:
- ✅ SSH connection successful
- ✅ RSA agent installed (Critical)
- ✅ RSA configuration files exist (Critical)
- ✅ RSA server connectivity successful (Critical)
- ✅ RSA agent service running (Critical)
- ✅ Patch management system registered (Critical)
- ℹ️ Additional validations (Informational)

### Test FAILS if:
- ❌ RSA agent not installed
- ❌ RSA configuration missing
- ❌ RSA server unreachable
- ❌ RSA agent service not running
- ❌ Not registered with patch management system

---

## Key Technologies and Commands

| Technology | Purpose | Commands Used |
|------------|---------|---------------|
| RPM | Package management | `rpm -qa \| grep rsa` |
| PAM | Authentication | `cat /etc/pam.d/system-auth` |
| RSA Agent | Two-factor auth | `systemctl status rsa-agent` |
| subscription-manager | Satellite registration | `subscription-manager status` |
| yum | Patch management | `yum check-update`, `yum updateinfo` |
| nc (netcat) | RSA connectivity | `nc -zv rsa.domain.com 5500` |

---

## Example Execution

```
🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH
✅ SSH connection verified

🔍 STEP 2.1: CHECK RSA AGENT INSTALLATION
📄 RSA agent status saved to: test18_data/rsa_agent_status_20251014_103000.txt
✅ RSA agent: rsa-securid-pam-agent-8.0.1 installed

🔍 STEP 2.2: VALIDATE RSA CONFIGURATION FILES
📄 RSA configuration saved to: test18_data/rsa_config_20251014_103000.txt
✅ RSA configuration files validated

🔍 STEP 3.1: VALIDATE RSA AGENT STATUS
🔧 RSA Agent Service: active (running)
✅ RSA agent service status validated

🔍 STEP 3.2: CHECK PATCH MANAGEMENT REGISTRATION
📄 Registration status saved to: test18_data/patch_registration_20251014_103000.txt
✅ System registered with Red Hat Satellite
✅ Overall Status: Current

Overall Status: PASSED ✅
```

---

## Troubleshooting

### Issue: RSA agent not installed
**Solution:**
```bash
# Install RSA agent (contact security team for package)
rpm -ivh rsa-securid-pam-agent-8.0.1-1.x86_64.rpm
```

### Issue: RSA server unreachable
**Solution:**
- Verify network connectivity to RSA server
- Check firewall allows port 5500
- Contact security team to verify RSA server status

### Issue: Not registered with Satellite
**Solution:**
```bash
# Register with Satellite
subscription-manager register --org="domain.com" --activationkey="key"

# Verify
subscription-manager status
```

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Test Coverage:** RSA authentication and patch management validation (CIP-007 R2, CIP-005)

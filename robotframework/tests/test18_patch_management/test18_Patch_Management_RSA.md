# Test 18: Patch Management & RSA Authentication - Working Explanation

## Test Information
- **Test Suite**: `test18_patch_management`
- **Robot File**: `patch_management.robot`
- **Test ID**: Test-18
- **Purpose**: Validate RSA SecurID two-factor authentication setup and patch management registration (Ansible/Satellite)

---

## Overview

Test 18 validates RSA authentication and patch management by:
1. Checking RSA SecurID agent installation
2. Validating RSA configuration files
3. Testing RSA server connectivity
4. Verifying patch management system registration (Red Hat Satellite or Ansible Tower)

**Focus**: This test ensures two-factor authentication (RSA) is properly configured for secure patch management access.

---

## Process Flow

```
Step 1: Connect to Target → SSH connection

Step 2: Collect Patch Management Data
  ├─> Step 2.1: Check RSA Agent Installation
  ├─> Step 2.2: Validate RSA Configuration Files
  ├─> Step 2.3: Check RSA Authentication Settings
  └─> Step 2.4: Test RSA Server Connectivity

Step 3: Validate Against Standards
  ├─> Step 3.1: Validate RSA Agent Status (service running)
  └─> Step 3.2: Check Patch Management Registration (Satellite/Ansible)

Normal Tests:
  ├─> Validate Two-Factor Authentication Flow
  ├─> Check RSA Token Configuration
  ├─> Validate Satellite Subscription Status
  ├─> Check Available Patches
  ├─> Validate Ansible Control Node Access
  ├─> Check Patch Management Schedule
  ├─> Validate Security Updates Status
  └─> Comprehensive Patch Management Summary
```

---

## Key Steps Explained

### Step 2.1: Check RSA Agent Installation
**Purpose**: Verify RSA SecurID agent is installed

**Actions**:
1. Check for RSA agent files in `/opt/rsa` or `/etc/rsa`
2. Check for RSA agent packages: `rpm -qa | grep -i rsa`
3. Document agent version and installation status
4. Save to file: `rsa_agent_status_<timestamp>.txt`

**Expected**: RSA Authentication Agent installed

---

### Step 2.2: Validate RSA Configuration Files
**Purpose**: Verify RSA configuration files exist and are valid

**Actions**:
1. Check for configuration files:
   - `/var/ace/sdconf.rec` - RSA configuration database
   - `/etc/pam.d/rsa` - PAM configuration for RSA
2. Verify file permissions
3. Save configuration details to file

**Key Files**:
- `sdconf.rec` - RSA server configuration
- PAM integration files for authentication

---

### Step 2.3: Check RSA Authentication Settings
**Purpose**: Validate RSA authentication is properly configured

**Actions**:
1. Check PAM configuration for RSA module
2. Verify RSA is integrated into authentication stack
3. Check SSH configuration for RSA challenge-response
4. Document authentication settings

---

### Step 2.4: Test RSA Server Connectivity
**Purpose**: Test network connectivity to RSA authentication server

**Actions**:
1. Get RSA server address from configuration
2. Test connectivity on RSA ports (typically 5500/UDP)
3. Execute: `nc -uzv <rsa_server> 5500`
4. Save connectivity test results

**Expected RSA Server**: As configured in variables

---

### Step 3.1: Validate RSA Agent Status
**Purpose**: Verify RSA agent service is running

**Actions**:
1. Execute: `systemctl status rsaauthmgr` or similar
2. Verify service is active
3. Check service logs for errors

---

### Step 3.2: Check Patch Management Registration
**Purpose**: Verify system is registered with Satellite or Ansible

**Actions**:
1. **For Red Hat Satellite**:
   - Execute: `subscription-manager status`
   - Check: `subscription-manager list`
   - Verify system is registered and subscribed
2. **For Ansible Tower**:
   - Check for Ansible agent/configuration
   - Verify connectivity to Ansible controller
3. Save registration status to file

**Commands**:
```bash
# Check Satellite registration
subscription-manager status
subscription-manager identity

# Check available patches
yum check-update --quiet | wc -l
```

---

### Normal Test: Validate Satellite Subscription
**Purpose**: Check Red Hat Satellite subscription details

**Actions**:
1. Execute `subscription-manager status`
2. Execute `subscription-manager list`
3. Verify subscriptions are current
4. Check subscription pool usage
5. Save to file: `subscription_status_<timestamp>.txt`

---

### Normal Test: Check Available Patches
**Purpose**: Check for available system updates

**Actions**:
1. Execute: `yum check-update` or `dnf check-update`
2. Count available patches
3. Identify security patches
4. Save to file: `available_patches_<timestamp>.txt`

---

### Normal Test: Check Security Updates
**Purpose**: Identify critical security patches

**Actions**:
1. Execute: `yum updateinfo list security`
2. Identify critical/important updates
3. Check if security patches are pending
4. Save to file: `security_updates_<timestamp>.txt`

---

## Data Files Saved

Files saved to `results/test18_patch_management/data/`:
- `rsa_agent_status_<timestamp>.txt` - RSA agent installation details
- `rsa_config_<timestamp>.txt` - RSA configuration files
- `rsa_connectivity_test_<timestamp>.txt` - RSA server connectivity results
- `registration_status_<timestamp>.txt` - Patch management registration
- `subscription_status_<timestamp>.txt` - Satellite subscription details
- `available_patches_<timestamp>.txt` - List of available patches
- `security_updates_<timestamp>.txt` - Security patches pending

---

## Key Technologies

- **RSA SecurID** - Two-factor authentication system
- **Red Hat Satellite** - Patch management and system registration
- **Ansible Tower/AWX** - Automation and patch deployment
- **subscription-manager** - RHEL subscription management tool
- **PAM** - Pluggable Authentication Modules

**Commands Used**:
- `rpm -qa | grep rsa` - Check RSA packages
- `systemctl status rsaauthmgr` - Check RSA service
- `subscription-manager status` - Check Satellite registration
- `yum check-update` - List available patches
- `yum updateinfo list security` - List security patches

---

## Success Criteria

**Passes When**:
- RSA agent is installed
- RSA configuration files exist and valid
- RSA authentication settings configured
- RSA server connectivity successful
- RSA agent service is running
- System is registered with patch management (Satellite/Ansible)

**Fails When**:
- RSA agent not installed
- RSA configuration files missing
- Cannot connect to RSA server
- RSA agent service not running
- System not registered with patch management

---

## Common Issues

### Issue 1: RSA Agent Not Found
**Cause**: RSA SecurID agent not installed
**Resolution**: Install RSA Authentication Agent package

### Issue 2: Cannot Connect to RSA Server
**Cause**: Firewall blocking RSA ports (5500/UDP)
**Resolution**: Open firewall for RSA server communication

### Issue 3: Not Registered with Satellite
**Cause**: System not registered with Red Hat Satellite
**Resolution**:
```bash
subscription-manager register --org=<org_id> --activationkey=<key>
```

### Issue 4: Subscription Expired
**Cause**: Red Hat subscription has expired
**Resolution**: Renew subscription through Red Hat portal

---

## Related Tests
- **Test 11** - Services Validation (checks rsaauthmgr service)

---

## Execution Example

```bash
robot --variable TARGET_HOSTNAME:alhxvdvitap01 \
      --variable SSH_USERNAME:admin \
      --variable SSH_PASSWORD:password \
      --outputdir results/test18_patch_management \
      tests/test18_patch_management/patch_management.robot
```

---

**Document Version**: 1.0 | **Date**: 2025-10-14

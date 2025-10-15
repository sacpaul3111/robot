# Test 3: Network Validation - Working Explanation

## Test Information

**Test ID:** test3_network_validation
**Test File:** `tests/test3_network_validation/network_validation.robot`
**Purpose:** Validate network configuration (hostname, IP, subnet, gateway, DNS, NTP) against EDS standards
**Compliance:** CIP-010 R1 - Baseline Configuration Management

---

## Overview

This test validates that the target server's network configuration matches the Enterprise Design Standards (EDS) specification. It connects via SSH, collects network configuration data from the running system, and compares it against expected values from the EDS database.

---

## Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    TEST 3: NETWORK VALIDATION               │
└─────────────────────────────────────────────────────────────┘

Step 1: Connect to Target Server
   └─> Establish SSH connection to target machine
   └─> Verify connection is active

Step 2: Collect Network Configuration Data
   ├─> Step 2.1: Collect Hostname Configuration
   │   └─> Execute: hostname
   │   └─> Save: ${SERVER_HOSTNAME}
   │
   ├─> Step 2.2: Collect IP Configuration
   │   └─> Execute: ip addr show
   │   └─> Parse IP address
   │   └─> Save: ${SERVER_IP}
   │
   ├─> Step 2.3: Collect Subnet Configuration
   │   └─> Execute: ip addr show
   │   └─> Parse subnet mask (CIDR notation)
   │   └─> Save: ${SERVER_SUBNET}
   │
   ├─> Step 2.4: Collect Gateway Configuration
   │   └─> Execute: ip route show default
   │   └─> Parse default gateway
   │   └─> Save: ${SERVER_GATEWAY}
   │
   ├─> Step 2.5: Collect DNS Configuration
   │   └─> Execute: hostname -f
   │   └─> Get Fully Qualified Domain Name
   │   └─> Save: ${SERVER_FQDN}
   │
   └─> Step 2.6: Collect NTP Configuration
       └─> Execute: systemctl status chronyd
       └─> Check NTP service status
       └─> Save: ${SERVER_NTP_STATUS}

Step 3: Validate Against EDS Standards
   ├─> Step 3.1: Validate Hostname
   │   └─> Compare: ${SERVER_HOSTNAME} == ${TARGET_HOSTNAME}
   │   └─> Result: PASS/FAIL
   │
   ├─> Step 3.2: Validate IP Address
   │   └─> Compare: ${SERVER_IP} == ${TARGET_IP}
   │   └─> Result: PASS/FAIL
   │
   ├─> Step 3.3: Validate Subnet
   │   └─> Compare: ${SERVER_SUBNET} == ${TARGET_SUBNET}
   │   └─> Result: PASS/FAIL
   │
   ├─> Step 3.4: Validate Gateway
   │   └─> Compare: ${SERVER_GATEWAY} == ${TARGET_GATEWAY}
   │   └─> Result: PASS/FAIL
   │
   ├─> Step 3.5: Validate DNS Configuration
   │   └─> Validate CNAME matches hostname
   │   └─> Validate FQDN format correct
   │   └─> Result: PASS/FAIL
   │
   └─> Step 3.6: Validate NTP Service (Informational)
       └─> Check: NTP service contains "active" or "running"
       └─> Result: PASS/FAIL (Informational)

Final Result: PASS if all critical validations pass
```

---

## Detailed Working

### Step 1: Connect to Target Server

**What it does:**
- Establishes SSH connection using credentials from environment variables
- Tests connection by verifying it's active
- Sets up session for command execution

**Commands executed:**
- SSH connection establishment (handled by Robot Framework SSHLibrary)

**Output:**
- `${SSH_CONNECTION_ACTIVE}` = True/False

---

### Step 2: Collect Network Configuration Data

#### Step 2.1: Collect Hostname Configuration

**What it does:**
- Executes `hostname` command on target server
- Retrieves short hostname

**Commands executed:**
```bash
hostname
```

**Expected output example:**
```
alhxvdvitap01
```

**Variables set:**
- `${SERVER_HOSTNAME}` - The actual hostname from server

---

#### Step 2.2: Collect IP Configuration

**What it does:**
- Executes `ip addr show` to get network interface configuration
- Parses output to extract primary IP address
- Identifies the correct network interface (typically ens192, eth0, etc.)

**Commands executed:**
```bash
ip addr show
```

**Expected output example:**
```
2: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 10.10.10.100/24 brd 10.10.10.255 scope global ens192
```

**Variables set:**
- `${SERVER_IP}` - Extracted IP address (e.g., "10.10.10.100")

---

#### Step 2.3: Collect Subnet Configuration

**What it does:**
- Uses same `ip addr show` output as Step 2.2
- Extracts subnet mask in CIDR notation

**Expected output example:**
```
inet 10.10.10.100/24
```

**Variables set:**
- `${SERVER_SUBNET}` - Subnet mask (e.g., "255.255.255.0" or "/24")

---

#### Step 2.4: Collect Gateway Configuration

**What it does:**
- Executes `ip route show default` to get default gateway
- Parses routing table for default route

**Commands executed:**
```bash
ip route show default
```

**Expected output example:**
```
default via 10.10.10.1 dev ens192 proto static metric 100
```

**Variables set:**
- `${SERVER_GATEWAY}` - Default gateway IP (e.g., "10.10.10.1")

---

#### Step 2.5: Collect DNS Configuration

**What it does:**
- Executes `hostname -f` to get Fully Qualified Domain Name
- Validates DNS resolution is working

**Commands executed:**
```bash
hostname -f
```

**Expected output example:**
```
alhxvdvitap01.domain.com
```

**Variables set:**
- `${SERVER_FQDN}` - Full domain name

---

#### Step 2.6: Collect NTP Configuration

**What it does:**
- Checks NTP/Chrony service status
- Verifies time synchronization service is running

**Commands executed:**
```bash
systemctl status chronyd
```

**Expected output example:**
```
● chronyd.service - NTP client/server
   Loaded: loaded
   Active: active (running) since Mon 2025-10-14
```

**Variables set:**
- `${SERVER_NTP_STATUS}` - Service status string

---

### Step 3: Validate Against EDS Standards

#### Step 3.1: Validate Hostname Against EDS

**What it does:**
- Compares collected hostname with EDS expected value
- Uses exact string matching

**Validation logic:**
```robot
Should Be Equal As Strings    ${SERVER_HOSTNAME}    ${TARGET_HOSTNAME}
```

**Pass criteria:**
- Server hostname exactly matches EDS hostname

**Fail message:**
```
❌ HOSTNAME MISMATCH: EDS expects 'alhxvdvitap01' but server shows 'wrong-hostname'
```

---

#### Step 3.2: Validate IP Address Against EDS

**What it does:**
- Compares collected IP address with EDS expected value
- Validates IP address format and value

**Validation logic:**
```robot
Should Be Equal As Strings    ${SERVER_IP}    ${TARGET_IP}
```

**Pass criteria:**
- Server IP exactly matches EDS IP address

**Fail message:**
```
❌ IP MISMATCH: EDS expects '10.10.10.100' but server shows '10.10.10.200'
```

---

#### Step 3.3: Validate Subnet Against EDS

**What it does:**
- Compares collected subnet mask with EDS expected value
- Validates network segmentation

**Validation logic:**
```robot
Should Be Equal As Strings    ${SERVER_SUBNET}    ${TARGET_SUBNET}
```

**Pass criteria:**
- Server subnet exactly matches EDS subnet

---

#### Step 3.4: Validate Gateway Against EDS

**What it does:**
- Compares collected default gateway with EDS expected value
- Validates routing configuration

**Validation logic:**
```robot
Should Be Equal As Strings    ${SERVER_GATEWAY}    ${TARGET_GATEWAY}
```

**Pass criteria:**
- Server gateway exactly matches EDS gateway

---

#### Step 3.5: Validate DNS Configuration Against EDS

**What it does:**
- Validates CNAME matches hostname
- Validates FQDN format is correct
- Checks DNS domain matches EDS domain

**Validation logic:**
```robot
Should Be Equal As Strings    ${TARGET_HOSTNAME}    ${expected_cname}
```

**Pass criteria:**
- CNAME matches hostname
- FQDN is properly formed

---

#### Step 3.6: Validate NTP Service Status (Informational)

**What it does:**
- Validates NTP/Chrony service is active
- Tagged as "normal" (not critical)

**Validation logic:**
```robot
Should Contain Any    ${SERVER_NTP_STATUS}    active    running    synchronized
```

**Pass criteria:**
- NTP service status contains "active", "running", or "synchronized"

---

## Data Sources

### Input Data (EDS Lookup):
- `${TARGET_HOSTNAME}` - Expected hostname from EDS
- `${TARGET_IP}` - Expected IP address from EDS
- `${TARGET_SUBNET}` - Expected subnet mask from EDS
- `${TARGET_GATEWAY}` - Expected gateway from EDS
- `${TARGET_CNAME}` - Expected CNAME from EDS
- `${TARGET_DOMAIN}` - Expected DNS domain from EDS

### Output Data (Collected from Server):
- `${SERVER_HOSTNAME}` - Actual hostname
- `${SERVER_IP}` - Actual IP address
- `${SERVER_SUBNET}` - Actual subnet mask
- `${SERVER_GATEWAY}` - Actual default gateway
- `${SERVER_FQDN}` - Actual fully qualified domain name
- `${SERVER_NTP_STATUS}` - Actual NTP service status

---

## Success/Failure Criteria

### Test PASSES if:
- ✅ SSH connection successful
- ✅ Hostname matches EDS (Critical)
- ✅ IP address matches EDS (Critical)
- ✅ Subnet matches EDS (Critical)
- ✅ Gateway matches EDS (Critical)
- ✅ DNS configuration matches EDS (Critical)
- ✅ NTP service active (Normal - Informational)

### Test FAILS if:
- ❌ SSH connection fails
- ❌ Hostname mismatch
- ❌ IP address mismatch
- ❌ Subnet mismatch
- ❌ Gateway mismatch
- ❌ DNS configuration invalid

---

## Key Technologies and Commands

| Technology | Purpose | Commands Used |
|------------|---------|---------------|
| SSH | Remote connection | SSHLibrary connection |
| hostname | Get system hostname | `hostname` |
| ip | Network configuration | `ip addr show`, `ip route show default` |
| DNS | Domain resolution | `hostname -f` |
| Chrony/NTP | Time synchronization | `systemctl status chronyd` |

---

## File Output

This test does NOT save files to disk. All validation is done in-memory and reported in Robot Framework logs and reports.

**Report locations:**
- `results/test3_network_validation/output.xml` - Raw test data
- `results/test3_network_validation/log.html` - Detailed test log
- `results/test3_network_validation/report.html` - Test report

---

## Example Execution

### Successful execution:
```
🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH
📋 Target: alhxvdvitap01 (10.10.10.100)
✅ SSH connection verified and active

🔍 STEP 2.1: COLLECT HOSTNAME CONFIGURATION
🖥️ Server Hostname: alhxvdvitap01
✅ Hostname collected

🔍 STEP 2.2: COLLECT IP CONFIGURATION
🖥️ Server IP Address: 10.10.10.100
✅ IP address collected

🔍 STEP 3.1: VALIDATE HOSTNAME AGAINST EDS
📋 EDS Expected: alhxvdvitap01
🖥️ Server Actual: alhxvdvitap01
✅ Hostname validation: PASSED

Overall Status: PASSED ✅
```

---

## Troubleshooting

### Issue: SSH connection fails
**Solution:**
- Verify SSH credentials in environment variables
- Check network connectivity to target
- Verify SSH service running on target

### Issue: Hostname mismatch
**Solution:**
- Check EDS database has correct hostname
- Verify hostname was set correctly on server
- Run `hostnamectl set-hostname <name>` to fix

### Issue: IP address mismatch
**Solution:**
- Check network interface configuration
- Verify correct interface is being queried
- Check DHCP vs static configuration

### Issue: NTP service not active
**Solution:**
- Check chronyd service: `systemctl status chronyd`
- Start service: `systemctl start chronyd`
- Enable service: `systemctl enable chronyd`

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Test Coverage:** Network configuration validation (CIP-010 R1)

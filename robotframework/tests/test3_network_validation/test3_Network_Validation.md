# Test 3: Network Validation - Working Explanation

## Test Information
- **Test Suite**: `test3_network_validation`
- **Robot File**: `network_validation.robot`
- **Test ID**: Test-3
- **Purpose**: Validate network configuration (hostname, IP, subnet, gateway, DNS, NTP) against EDS standards

---

## Overview

Test 3 performs comprehensive network configuration validation by:
1. SSH directly to the target server
2. Collecting network configuration data from the running system
3. Comparing collected data against EDS (Enterprise Design Standards) expected values
4. Validating NTP service is active for time synchronization

---

## Process Flow

### Step Model Structure
The test follows a 3-step validation model:

```
Step 1: Connect to Target
  └─> Establish SSH connection to target server

Step 2: Collect Network Configuration Data (Data Collection)
  ├─> Step 2.1: Collect Hostname Configuration
  ├─> Step 2.2: Collect IP Configuration
  ├─> Step 2.3: Collect Subnet Configuration
  ├─> Step 2.4: Collect Gateway Configuration
  ├─> Step 2.5: Collect DNS Configuration
  └─> Step 2.6: Collect NTP Configuration

Step 3: Validate Against EDS Standards (Validation)
  ├─> Step 3.1: Validate Hostname Against EDS
  ├─> Step 3.2: Validate IP Address Against EDS
  ├─> Step 3.3: Validate Subnet Against EDS
  ├─> Step 3.4: Validate Gateway Against EDS
  ├─> Step 3.5: Validate DNS Configuration Against EDS
  └─> Step 3.6: Validate NTP Service Status
```

---

## Detailed Step-by-Step Working

### **STEP 1: Connect to Target Server** (Critical)
**Purpose**: Establish SSH connection to the target machine

**Actions**:
1. The `Initialize Test Environment And Lookup Configuration` Suite Setup:
   - Looks up target hostname in EDS file
   - Retrieves expected values: IP, subnet, gateway, CNAME, domain
   - Establishes SSH session to target server
2. Test verifies SSH connection is active

**Keywords Used**:
- `Establish SSH Session` - Opens SSH connection using SSHLibrary
- Connection verification with echo command

**Success Criteria**: SSH connection is established and active

---

### **STEP 2: Collect Network Configuration Data**

These steps execute commands on the target server to gather actual network configuration.

#### **Step 2.1: Collect Hostname Configuration** (Critical)
**Purpose**: Get the server's configured hostname

**Actions**:
1. Execute SSH command: `hostname` on target server
2. Store result in suite variable `${SERVER_HOSTNAME}`

**Keywords Used**: `Get Hostname From Server`

**Data Collected**: Server hostname (e.g., "alhxvdvitap01")

---

#### **Step 2.2: Collect IP Configuration** (Critical)
**Purpose**: Get the server's IP address

**Actions**:
1. Execute SSH commands to extract IP address from `ip addr` or `ifconfig`
2. Parse output to identify primary IP address
3. Store result in suite variable `${SERVER_IP}`

**Keywords Used**: `Get IP Address From Server`

**Data Collected**: Server IP address (e.g., "10.120.30.45")

---

#### **Step 2.3: Collect Subnet Configuration** (Critical)
**Purpose**: Get the server's subnet mask

**Actions**:
1. Execute SSH commands to extract subnet mask from network configuration
2. Parse output to identify subnet (CIDR notation or dotted decimal)
3. Store result in suite variable `${SERVER_SUBNET}`

**Keywords Used**: `Get Subnet From Server`

**Data Collected**: Server subnet (e.g., "255.255.255.0" or "/24")

---

#### **Step 2.4: Collect Gateway Configuration** (Critical)
**Purpose**: Get the server's default gateway

**Actions**:
1. Execute SSH command: `ip route` or `route -n`
2. Parse output to extract default gateway IP
3. Store result in suite variable `${SERVER_GATEWAY}`

**Keywords Used**: `Get Gateway From Server`

**Data Collected**: Default gateway IP (e.g., "10.120.30.1")

---

#### **Step 2.5: Collect DNS Configuration** (Critical)
**Purpose**: Get the server's FQDN (Fully Qualified Domain Name)

**Actions**:
1. Execute SSH commands: `hostname -f` or check `/etc/hosts`
2. Extract FQDN from output
3. Store result in suite variable `${SERVER_FQDN}`

**Keywords Used**: `Get FQDN From Server`

**Data Collected**: Server FQDN (e.g., "alhxvdvitap01.domain.com")

---

#### **Step 2.6: Collect NTP Configuration** (Critical)
**Purpose**: Check NTP/chrony service status

**Actions**:
1. Execute SSH command: `systemctl status chronyd` or `systemctl status ntpd`
2. Check if service is active/running
3. Store result in suite variable `${SERVER_NTP_STATUS}`

**Keywords Used**: `Get NTP Status From Server`

**Data Collected**: NTP service status (e.g., "active (running)")

---

### **STEP 3: Validate Against EDS Standards**

These steps compare collected data against EDS expected values.

#### **Step 3.1: Validate Hostname Against EDS** (Critical)
**Purpose**: Ensure server hostname matches EDS specification

**Validation Logic**:
```robot
Expected: ${TARGET_HOSTNAME}  (from EDS)
Actual:   ${SERVER_HOSTNAME}  (from server)

Assertion: Should Be Equal As Strings ${SERVER_HOSTNAME} ${TARGET_HOSTNAME}
```

**Pass Condition**: Server hostname exactly matches EDS hostname

**Fail Condition**: Mismatch between server and EDS hostname

---

#### **Step 3.2: Validate IP Address Against EDS** (Critical)
**Purpose**: Ensure server IP address matches EDS specification

**Validation Logic**:
```robot
Expected: ${TARGET_IP}  (from EDS)
Actual:   ${SERVER_IP}  (from server)

Assertion: Should Be Equal As Strings ${SERVER_IP} ${TARGET_IP}
```

**Pass Condition**: Server IP exactly matches EDS IP

**Fail Condition**: Mismatch between server and EDS IP address

---

#### **Step 3.3: Validate Subnet Against EDS** (Critical)
**Purpose**: Ensure server subnet matches EDS specification

**Validation Logic**:
```robot
Expected: ${TARGET_SUBNET}  (from EDS)
Actual:   ${SERVER_SUBNET}  (from server)

Assertion: Should Be Equal As Strings ${SERVER_SUBNET} ${TARGET_SUBNET}
```

**Pass Condition**: Server subnet exactly matches EDS subnet

**Fail Condition**: Mismatch between server and EDS subnet

---

#### **Step 3.4: Validate Gateway Against EDS** (Critical)
**Purpose**: Ensure server gateway matches EDS specification

**Validation Logic**:
```robot
Expected: ${TARGET_GATEWAY}  (from EDS)
Actual:   ${SERVER_GATEWAY}  (from server)

Assertion: Should Be Equal As Strings ${SERVER_GATEWAY} ${TARGET_GATEWAY}
```

**Pass Condition**: Server gateway exactly matches EDS gateway

**Fail Condition**: Mismatch between server and EDS gateway

---

#### **Step 3.5: Validate DNS Configuration Against EDS** (Critical)
**Purpose**: Ensure DNS CNAME matches hostname

**Validation Logic**:
```robot
Expected CNAME: ${TARGET_CNAME}      (from EDS)
Expected Domain: ${TARGET_DOMAIN}     (from EDS)
Expected FQDN: ${TARGET_CNAME}.${TARGET_DOMAIN}
Actual FQDN: ${SERVER_FQDN}           (from server)

Assertion: Should Be Equal As Strings ${TARGET_HOSTNAME} ${TARGET_CNAME}
```

**Pass Condition**: CNAME matches hostname structure

**Fail Condition**: CNAME doesn't match hostname

---

#### **Step 3.6: Validate NTP Service Status** (Normal)
**Purpose**: Ensure time synchronization service is running

**Validation Logic**:
```robot
Should Contain Any ${SERVER_NTP_STATUS} active running synchronized
```

**Pass Condition**: NTP/chrony service is active/running/synchronized

**Fail Condition**: Time sync service is not active

---

## Data Sources

### Input Data (EDS Lookup)
The test reads expected values from the EDS (Enterprise Design Standards) file:
- `Hostname` → `${TARGET_HOSTNAME}`
- `IP Address` → `${TARGET_IP}`
- `Subnet` → `${TARGET_SUBNET}`
- `Gateway` → `${TARGET_GATEWAY}`
- `CNAME` → `${TARGET_CNAME}`
- `Domain` → `${TARGET_DOMAIN}`

### Output Data (Files Saved)
The test saves collected data to files in `results/test3_network_validation/data/`:
- `network_configuration_<timestamp>.txt` - All collected network data
- `network_validation_report_<timestamp>.txt` - Validation results
- `executive_summary.txt` - Overall test summary

---

## Success/Failure Criteria

### Test Passes When:
- SSH connection successful
- All 6 network parameters collected successfully
- Hostname matches EDS
- IP address matches EDS
- Subnet matches EDS
- Gateway matches EDS
- DNS configuration valid
- NTP service is active

### Test Fails When:
- Cannot establish SSH connection
- Cannot collect network data from server
- Hostname mismatch between server and EDS
- IP address mismatch between server and EDS
- Subnet mismatch between server and EDS
- Gateway mismatch between server and EDS
- DNS configuration invalid
- NTP service not active

---

## Key Technologies Used

1. **Robot Framework** - Test automation framework
2. **SSHLibrary** - SSH connection and command execution
3. **EDSLookup.py** - Python library for reading EDS file
4. **Linux Commands**:
   - `hostname` - Get hostname
   - `ip addr` / `ifconfig` - Get IP configuration
   - `ip route` / `route -n` - Get gateway
   - `hostname -f` - Get FQDN
   - `systemctl status chronyd/ntpd` - Check NTP service

---

## Variables Used

### Input Variables (Set via command line or EDS):
- `${TARGET_HOSTNAME}` - Expected hostname from EDS
- `${TARGET_IP}` - Expected IP from EDS
- `${TARGET_SUBNET}` - Expected subnet from EDS
- `${TARGET_GATEWAY}` - Expected gateway from EDS
- `${TARGET_CNAME}` - Expected CNAME from EDS
- `${TARGET_DOMAIN}` - Expected domain from EDS
- `${SSH_USERNAME}` - SSH username
- `${SSH_PASSWORD}` - SSH password

### Suite Variables (Collected during execution):
- `${SERVER_HOSTNAME}` - Actual hostname from server
- `${SERVER_IP}` - Actual IP from server
- `${SERVER_SUBNET}` - Actual subnet from server
- `${SERVER_GATEWAY}` - Actual gateway from server
- `${SERVER_FQDN}` - Actual FQDN from server
- `${SERVER_NTP_STATUS}` - NTP service status

---

## Compliance Standards

This test validates compliance with enterprise network standards:
- **Network Configuration Standards** - Ensures servers have correct network settings
- **DNS Standards** - Validates proper DNS naming conventions
- **Time Synchronization** - Ensures NTP is configured for accurate timekeeping

---

## Execution Example

```bash
# Run Test 3 from command line
robot --variable TARGET_HOSTNAME:alhxvdvitap01 \
      --variable SSH_USERNAME:admin \
      --variable SSH_PASSWORD:password \
      --outputdir results/test3_network_validation \
      tests/test3_network_validation/network_validation.robot
```

---

## Common Issues and Troubleshooting

### Issue 1: SSH Connection Fails
**Symptom**: Step 1 fails with connection timeout
**Cause**: Firewall blocking SSH or incorrect credentials
**Resolution**: Check SSH access, credentials, and firewall rules

### Issue 2: Hostname Mismatch
**Symptom**: Step 3.1 fails with hostname mismatch
**Cause**: Server hostname doesn't match EDS specification
**Resolution**: Update server hostname or correct EDS file

### Issue 3: IP Address Mismatch
**Symptom**: Step 3.2 fails with IP mismatch
**Cause**: Server has different IP than EDS specifies
**Resolution**: Update server network config or correct EDS file

### Issue 4: NTP Service Not Running
**Symptom**: Step 3.6 fails with NTP inactive
**Cause**: chronyd/ntpd service not started
**Resolution**: Start and enable NTP service on server

---

## Related Tests
- **Test 7** - Time Configuration Validation (detailed NTP validation)
- **Test 11** - Services Validation (validates NTP service)

---

## Document Version
- **Version**: 1.0
- **Date**: 2025-10-14
- **Author**: Robot Framework Test Suite Documentation

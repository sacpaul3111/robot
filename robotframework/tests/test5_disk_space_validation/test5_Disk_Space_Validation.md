# Test 5: Disk Space & System Resource Validation - Working Explanation

## Test Information
- **Test Suite**: `test5_disk_space_validation`
- **Robot File**: `disk_space_validation.robot`
- **Test ID**: Test-5
- **Purpose**: Validate system resources (CPU, memory, disk space, storage type, filesystem) against EDS standards

---

## Overview

Test 5 performs comprehensive system resource validation by:
1. SSH directly to the target server
2. Collecting hardware and storage configuration data
3. Comparing collected data against EDS (Enterprise Design Standards) specifications
4. Analyzing storage capacity, volume groups, and operating system configuration

---

## Process Flow

### Step Model Structure
The test follows a 3-step validation model:

```
Step 1: Connect to Target
  └─> Establish SSH connection to target server

Step 2: Collect System Resource Data (Data Collection)
  ├─> Step 2.1: Collect CPU Information
  ├─> Step 2.2: Collect Memory Information
  ├─> Step 2.3: Collect Disk Space Information
  ├─> Step 2.4: Collect Storage Type Information
  ├─> Step 2.5: Collect Filesystem Information
  └─> Step 2.6: Collect Operating System Information

Step 3: Validate Against EDS Standards (Validation)
  ├─> Step 3.1: Validate CPU Cores Against EDS
  ├─> Step 3.2: Validate Memory Against EDS
  ├─> Step 3.3: Validate Disk Space Against EDS
  ├─> Step 3.4: Validate Storage Type Against EDS
  └─> Step 3.5: Validate Filesystem Against EDS

Additional Analysis (Normal):
  ├─> Storage Capacity Analysis
  ├─> Volume Group Analysis
  └─> Operating System Validation
```

---

## Detailed Step-by-Step Working

### **STEP 1: Connect to Target Server** (Critical)
**Purpose**: Establish SSH connection to the target machine

**Actions**:
1. The `Initialize Storage Test Environment And Lookup Configuration` Suite Setup:
   - Looks up target hostname in EDS file
   - Retrieves expected values: CPU cores, RAM, storage allocation, OS type
   - Establishes SSH session to target server
2. Test verifies SSH connection is active by executing echo command

**Success Criteria**: SSH connection is established and active

---

### **STEP 2: Collect System Resource Data**

These steps execute commands on the target server to gather hardware and storage configuration.

#### **Step 2.1: Collect CPU Information** (Critical)
**Purpose**: Get the server's CPU core count

**Actions**:
1. Execute SSH command: `lscpu` or `nproc` to get CPU core count
2. Parse output to extract total CPU cores
3. Store result in suite variable `${SERVER_CPU_CORES}`

**Keywords Used**: `Get CPU Information From Server`

**Data Collected**: Number of CPU cores (e.g., "4", "8", "16")

**Command Example**:
```bash
# Count CPU cores
nproc
# OR
lscpu | grep "^CPU(s):" | awk '{print $2}'
```

---

#### **Step 2.2: Collect Memory Information** (Critical)
**Purpose**: Get the server's RAM allocation

**Actions**:
1. Execute SSH command: `free -g` to get memory in GB
2. Parse output to extract total RAM
3. Convert to GB and store in suite variable `${SERVER_MEMORY_GB}`

**Keywords Used**: `Get Memory Information From Server`

**Data Collected**: Total RAM in GB (e.g., "16", "32", "64")

**Command Example**:
```bash
# Get memory in GB
free -g | grep Mem | awk '{print $2}'
# OR
grep MemTotal /proc/meminfo | awk '{print int($2/1024/1024)}'
```

---

#### **Step 2.3: Collect Disk Space Information** (Critical)
**Purpose**: Get the server's root filesystem size

**Actions**:
1. Execute SSH command: `df -h /` to get root filesystem size
2. Parse output to extract total size of root partition
3. Store result in suite variable `${SERVER_ROOT_SIZE}`

**Keywords Used**: `Get Disk Space Information From Server`

**Data Collected**: Root filesystem size (e.g., "50G", "100G", "200G")

**Command Example**:
```bash
# Get root filesystem size
df -h / | tail -1 | awk '{print $2}'
# OR
lsblk -o SIZE,MOUNTPOINT | grep "/$" | awk '{print $1}'
```

---

#### **Step 2.4: Collect Storage Type Information** (Critical)
**Purpose**: Identify the storage infrastructure type (SAN, local disk, etc.)

**Actions**:
1. Execute SSH commands to detect storage type:
   - Check for multipath devices (SAN storage)
   - Check for local disks (SATA, SSD, NVMe)
   - Examine `/sys/block/` for storage controllers
2. Determine storage type based on findings
3. Store result in suite variable `${SERVER_STORAGE_TYPE}`

**Keywords Used**: `Get Storage Type From Server`

**Data Collected**: Storage type (e.g., "SAN", "Local Disk", "NFS", "iSCSI")

**Command Example**:
```bash
# Check for multipath (SAN)
multipath -ll 2>/dev/null && echo "SAN" || echo "Local"
# OR check disk type
lsblk -d -o name,rota | grep "^sd" | awk '{if ($2==0) print "SSD"; else print "HDD"}'
```

---

#### **Step 2.5: Collect Filesystem Information** (Critical)
**Purpose**: Get the filesystem type of root partition

**Actions**:
1. Execute SSH command: `df -T /` to get filesystem type
2. Parse output to extract filesystem type (ext4, xfs, etc.)
3. Store result in suite variable `${SERVER_FS_TYPE}`

**Keywords Used**: `Get Filesystem Information From Server`

**Data Collected**: Filesystem type (e.g., "ext4", "xfs", "ext3")

**Command Example**:
```bash
# Get filesystem type
df -T / | tail -1 | awk '{print $2}'
# OR
findmnt -n -o FSTYPE /
```

---

#### **Step 2.6: Collect Operating System Information** (Critical)
**Purpose**: Get OS details and kernel version

**Actions**:
1. Execute SSH commands:
   - Read `/etc/os-release` for OS name and version
   - Execute `uname -r` for kernel version
2. Store results in suite variables:
   - `${SERVER_OS_INFO}` - OS name (e.g., "Red Hat Enterprise Linux 8.5")
   - `${SERVER_KERNEL_INFO}` - Kernel version (e.g., "4.18.0-348.el8.x86_64")

**Data Collected**: Operating system information

**Command Example**:
```bash
# Get OS information
cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2

# Get kernel version
uname -r
```

---

### **STEP 3: Validate Against EDS Standards**

#### **Step 3.1: Validate CPU Cores Against EDS** (Critical)
**Purpose**: Ensure server has expected number of CPU cores

**Validation Logic**:
```robot
Expected: ${TARGET_CPU_CORES}  (from EDS)
Actual:   ${SERVER_CPU_CORES}  (from server)

Keyword: Validate CPU Cores Against EDS ${SERVER_CPU_CORES}
```

**Pass Condition**: Server CPU cores match or exceed EDS specification

**Fail Condition**: Server has fewer CPU cores than EDS specifies

---

#### **Step 3.2: Validate Memory Against EDS** (Critical)
**Purpose**: Ensure server has expected amount of RAM

**Validation Logic**:
```robot
Expected: ${TARGET_RAM} GB  (from EDS)
Actual:   ${SERVER_MEMORY_GB} GB  (from server)

Keyword: Validate Memory Against EDS ${SERVER_MEMORY_GB}
```

**Pass Condition**: Server RAM matches or exceeds EDS specification (±1GB tolerance)

**Fail Condition**: Server RAM is significantly less than EDS specifies

---

#### **Step 3.3: Validate Disk Space Against EDS** (Critical)
**Purpose**: Document disk space allocation for compliance review

**Validation Logic**:
```robot
Expected Storage Allocation: ${TARGET_STORAGE_ALLOC_GB} GB
Recommended Storage: ${TARGET_RECOMMENDED_GB} GB
Actual Root Filesystem: ${SERVER_ROOT_SIZE}

Action: Log disk space information (Informational)
```

**Pass Condition**: Disk space is logged for review

**Fail Condition**: N/A (informational only)

---

#### **Step 3.4: Validate Storage Type Against EDS** (Critical)
**Purpose**: Validate storage infrastructure type

**Validation Logic**:
```robot
Expected: ${TARGET_STORAGE_TYPE}  (from EDS)
Actual:   ${SERVER_STORAGE_TYPE}  (from server)

Keyword: Validate Storage Type Against EDS ${SERVER_STORAGE_TYPE}
```

**Pass Condition**: Storage type matches EDS or is acceptable alternative

**Fail Condition**: Informational only (detection may vary)

---

#### **Step 3.5: Validate Filesystem Against EDS** (Critical)
**Purpose**: Validate root filesystem configuration

**Validation Logic**:
```robot
Expected Mount Point: ${TARGET_LOGICAL_VOLUME}
Expected File System: ${TARGET_FILE_SYSTEM}
Actual FS Type: ${SERVER_FS_TYPE}
Actual Root Size: ${SERVER_ROOT_SIZE}

Keyword: Validate Root Filesystem Against EDS ${SERVER_FS_TYPE} ${SERVER_ROOT_SIZE}
```

**Pass Condition**: Filesystem type and size are logged for review

**Fail Condition**: N/A (logged for review)

---

### **Additional Analysis Tests** (Normal)

#### **Storage Capacity Analysis**
**Purpose**: Analyze overall storage capacity and utilization

**Actions**:
1. Collect detailed storage information (root size, storage type)
2. Compare with EDS total storage allocation
3. Log storage capacity analysis

**Data Logged**:
- Storage Type
- Root Partition Size
- EDS Total Storage (TB)
- Drive Purpose

---

#### **Volume Group Analysis**
**Purpose**: Analyze LVM volume group and logical volume configuration

**Actions**:
1. Review EDS volume group information
2. Check actual filesystem type on server
3. Log volume configuration for analysis

**Data Logged**:
- EDS Volume Group Info
- EDS Logical Volume
- EDS File System
- Server Filesystem Type

---

#### **Operating System Validation**
**Purpose**: Validate OS type matches EDS specification

**Actions**:
1. Get OS information from `/etc/os-release`
2. Get kernel version from `uname -r`
3. Compare with EDS expected OS type
4. Log OS validation results

**Data Logged**:
- EDS Expected OS Type
- Server Actual OS
- Server Kernel Version

---

## Data Sources

### Input Data (EDS Lookup)
The test reads expected values from the EDS file:
- `CPU Cores` → `${TARGET_CPU_CORES}` (e.g., 4, 8, 16)
- `RAM (GB)` → `${TARGET_RAM}` (e.g., 16, 32, 64)
- `Storage Allocation (GB)` → `${TARGET_STORAGE_ALLOC_GB}`
- `Recommended Storage (GB)` → `${TARGET_RECOMMENDED_GB}`
- `Storage Type` → `${TARGET_STORAGE_TYPE}` (e.g., "SAN", "Local")
- `Total Storage (TB)` → `${TARGET_STORAGE_TOTAL_TB}`
- `OS Type` → `${TARGET_OS_TYPE}` (e.g., "RHEL 8")
- `Volume Group` → `${TARGET_DRIVE_VOLUME_GROUP}`
- `Logical Volume` → `${TARGET_LOGICAL_VOLUME}`
- `File System` → `${TARGET_FILE_SYSTEM}` (e.g., "xfs", "ext4")
- `Drive Purpose` → `${TARGET_DRIVE_PURPOSE}`

### Output Data (Files Saved)
The test saves collected data to files in `results/test5_disk_space_validation/data/`:
- `system_resources_<timestamp>.txt` - CPU, memory, disk space data
- `storage_configuration_<timestamp>.txt` - Storage type and filesystem info
- `storage_validation_report_<timestamp>.txt` - Validation results
- `executive_summary.txt` - Overall test summary

---

## Success/Failure Criteria

### Test Passes When:
- SSH connection successful
- All 6 resource parameters collected successfully
- CPU cores meet or exceed EDS specification
- Memory meets or exceeds EDS specification (with tolerance)
- Disk space is documented (informational)
- Storage type is documented (informational)
- Filesystem configuration is documented

### Test Fails When:
- Cannot establish SSH connection
- Cannot collect system resource data
- CPU cores below EDS specification
- Memory significantly below EDS specification

---

## Key Technologies Used

1. **Robot Framework** - Test automation framework
2. **SSHLibrary** - SSH connection and command execution
3. **EDSLookup.py** - Python library for reading EDS file
4. **Linux Commands**:
   - `lscpu` / `nproc` - Get CPU information
   - `free -g` - Get memory information
   - `df -h /` - Get disk space
   - `df -T /` - Get filesystem type
   - `lsblk` - List block devices
   - `multipath -ll` - Check SAN storage
   - `cat /etc/os-release` - Get OS information
   - `uname -r` - Get kernel version

---

## Variables Used

### Input Variables (Set via command line or EDS):
- `${TARGET_HOSTNAME}` - Server hostname
- `${TARGET_IP}` - Server IP address
- `${TARGET_CPU_CORES}` - Expected CPU cores
- `${TARGET_RAM}` - Expected RAM (GB)
- `${TARGET_STORAGE_ALLOC_GB}` - Storage allocation
- `${TARGET_STORAGE_TYPE}` - Expected storage type
- `${TARGET_FILE_SYSTEM}` - Expected filesystem type
- `${TARGET_OS_TYPE}` - Expected OS type
- `${SSH_USERNAME}` - SSH username
- `${SSH_PASSWORD}` - SSH password

### Suite Variables (Collected during execution):
- `${SERVER_CPU_CORES}` - Actual CPU cores
- `${SERVER_MEMORY_GB}` - Actual RAM (GB)
- `${SERVER_ROOT_SIZE}` - Root filesystem size
- `${SERVER_STORAGE_TYPE}` - Actual storage type
- `${SERVER_FS_TYPE}` - Actual filesystem type
- `${SERVER_OS_INFO}` - OS information
- `${SERVER_KERNEL_INFO}` - Kernel version

---

## Compliance Standards

This test validates compliance with:
- **Hardware Sizing Standards** - Ensures servers meet minimum hardware requirements
- **Storage Standards** - Validates proper storage configuration
- **OS Standards** - Ensures correct operating system is installed

---

## Execution Example

```bash
# Run Test 5 from command line
robot --variable TARGET_HOSTNAME:alhxvdvitap01 \
      --variable SSH_USERNAME:admin \
      --variable SSH_PASSWORD:password \
      --outputdir results/test5_disk_space_validation \
      tests/test5_disk_space_validation/disk_space_validation.robot
```

---

## Common Issues and Troubleshooting

### Issue 1: CPU Core Count Mismatch
**Symptom**: Step 3.1 fails with insufficient CPU cores
**Cause**: Server has fewer cores than EDS specifies
**Resolution**: Add CPU cores to VM or correct EDS specification

### Issue 2: Memory Allocation Insufficient
**Symptom**: Step 3.2 fails with memory below threshold
**Cause**: Server RAM below EDS requirement
**Resolution**: Increase server RAM or correct EDS specification

### Issue 3: Storage Type Detection Incorrect
**Symptom**: Storage type shows as "Unknown"
**Cause**: Cannot determine SAN vs Local storage
**Resolution**: Check multipath configuration or disk controllers

### Issue 4: Filesystem Type Not Standard
**Symptom**: Filesystem type unexpected (e.g., ext3 instead of xfs)
**Cause**: Server uses different filesystem than EDS standard
**Resolution**: Document finding; may be acceptable variation

---

## Related Tests
- **Test 9** - Datastore Configuration (validates vCenter datastore allocation for VMs)
- **Test 11** - Services Validation (validates system services)

---

## Document Version
- **Version**: 1.0
- **Date**: 2025-10-14
- **Author**: Robot Framework Test Suite Documentation

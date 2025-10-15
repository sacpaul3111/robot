# Test 5: Disk Space & System Resources Validation - Working Explanation

## Test Information

**Test ID:** test5_disk_space_validation
**Test File:** `tests/test5_disk_space_validation/disk_space_validation.robot`
**Purpose:** Validate system resources (CPU, RAM, disk space, storage type, filesystem) against EDS standards
**Compliance:** CIP-010 R1 - Baseline Configuration Management

---

## Overview

This test validates that the target server's system resources and storage configuration match the Enterprise Design Standards (EDS) specification. It collects hardware information (CPU cores, RAM), disk space allocation, storage infrastructure type, and filesystem configuration, then compares against EDS requirements.

---

## Process Flow

```
┌─────────────────────────────────────────────────────────────┐
│          TEST 5: DISK SPACE & RESOURCES VALIDATION          │
└─────────────────────────────────────────────────────────────┘

Step 1: Connect to Target Server
   └─> Establish SSH connection
   └─> Verify connection active

Step 2: Collect System Resource Data
   ├─> Step 2.1: Collect CPU Information
   │   └─> Execute: nproc
   │   └─> Save: ${SERVER_CPU_CORES}
   │
   ├─> Step 2.2: Collect Memory Information
   │   └─> Execute: free -g
   │   └─> Parse RAM in GB
   │   └─> Save: ${SERVER_MEMORY_GB}
   │
   ├─> Step 2.3: Collect Disk Space Information
   │   └─> Execute: df -h /
   │   └─> Parse root filesystem size
   │   └─> Save: ${SERVER_ROOT_SIZE}
   │
   ├─> Step 2.4: Collect Storage Type Information
   │   └─> Execute: lsblk
   │   └─> Identify storage type (SSD/HDD/SAN)
   │   └─> Save: ${SERVER_STORAGE_TYPE}
   │
   ├─> Step 2.5: Collect Filesystem Information
   │   └─> Execute: df -T /
   │   └─> Get filesystem type
   │   └─> Save: ${SERVER_FS_TYPE}
   │
   └─> Step 2.6: Collect Operating System Information
       └─> Execute: cat /etc/os-release, uname -r
       └─> Save: ${SERVER_OS_INFO}, ${SERVER_KERNEL_INFO}

Step 3: Validate Against EDS Standards
   ├─> Step 3.1: Validate CPU Cores
   │   └─> Compare: ${SERVER_CPU_CORES} >= ${TARGET_CPU_CORES}
   │   └─> Result: PASS/FAIL
   │
   ├─> Step 3.2: Validate Memory
   │   └─> Compare: ${SERVER_MEMORY_GB} >= ${TARGET_RAM}
   │   └─> Result: PASS/FAIL
   │
   ├─> Step 3.3: Validate Disk Space
   │   └─> Log disk space information
   │   └─> Result: INFORMATIONAL
   │
   ├─> Step 3.4: Validate Storage Type
   │   └─> Compare storage type
   │   └─> Result: INFORMATIONAL
   │
   └─> Step 3.5: Validate Filesystem
       └─> Validate root filesystem configuration
       └─> Result: INFORMATIONAL

Step 4: Additional Analysis
   ├─> Storage Capacity Analysis
   ├─> Volume Group Analysis
   └─> Operating System Validation

Final Result: PASS if all critical validations pass
```

---

## Detailed Working

### Step 1: Connect to Target Server

**What it does:**
- Establishes SSH connection to target server
- Verifies connection is active

**Commands executed:**
```bash
echo "SSH connection active"
```

**Output:**
- Connection status verified

---

### Step 2: Collect System Resource Data

#### Step 2.1: Collect CPU Information

**What it does:**
- Counts the number of CPU cores/processors available
- Uses `nproc` command for accurate count

**Commands executed:**
```bash
nproc
```

**Expected output example:**
```
4
```

**Variables set:**
- `${SERVER_CPU_CORES}` - Number of CPU cores (e.g., "4")

**Robot Framework keyword:**
```robot
Get CPU Information From Server
```

---

#### Step 2.2: Collect Memory Information

**What it does:**
- Retrieves total system memory in gigabytes
- Uses `free -g` command to get memory stats

**Commands executed:**
```bash
free -g
```

**Expected output example:**
```
              total        used        free      shared  buff/cache   available
Mem:             16           2          10           0           3          13
Swap:             8           0           8
```

**Variables set:**
- `${SERVER_MEMORY_GB}` - Total RAM in GB (e.g., "16")

**Robot Framework keyword:**
```robot
Get Memory Information From Server
```

---

#### Step 2.3: Collect Disk Space Information

**What it does:**
- Retrieves root filesystem size and usage
- Uses `df -h /` for human-readable output

**Commands executed:**
```bash
df -h /
```

**Expected output example:**
```
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/rootvg-root   50G   10G   40G  20% /
```

**Variables set:**
- `${SERVER_ROOT_SIZE}` - Root filesystem size (e.g., "50G")

**Robot Framework keyword:**
```robot
Get Disk Space Information From Server
```

---

#### Step 2.4: Collect Storage Type Information

**What it does:**
- Identifies underlying storage infrastructure type
- Checks for SSD, HDD, SAN, or virtual disk

**Commands executed:**
```bash
lsblk -d -o NAME,ROTA
```

**Expected output example:**
```
NAME ROTA
sda     0     (0 = SSD, 1 = HDD)
```

**Variables set:**
- `${SERVER_STORAGE_TYPE}` - Storage type (e.g., "SSD", "SAN", "HDD")

**Robot Framework keyword:**
```robot
Get Storage Type From Server
```

**Detection logic:**
- ROTA=0 → SSD/NVMe
- ROTA=1 → Traditional HDD
- VMware virtual disk → SAN (typically)

---

#### Step 2.5: Collect Filesystem Information

**What it does:**
- Retrieves filesystem type of root partition
- Common types: xfs, ext4, ext3

**Commands executed:**
```bash
df -T /
```

**Expected output example:**
```
Filesystem              Type  Size  Used Avail Use% Mounted on
/dev/mapper/rootvg-root xfs    50G   10G   40G  20% /
```

**Variables set:**
- `${SERVER_FS_TYPE}` - Filesystem type (e.g., "xfs", "ext4")

**Robot Framework keyword:**
```robot
Get Filesystem Information From Server
```

---

#### Step 2.6: Collect Operating System Information

**What it does:**
- Retrieves OS distribution and version
- Gets kernel version

**Commands executed:**
```bash
cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2
uname -r
```

**Expected output example:**
```
Red Hat Enterprise Linux 8.5 (Ootpa)
4.18.0-348.el8.x86_64
```

**Variables set:**
- `${SERVER_OS_INFO}` - OS name and version
- `${SERVER_KERNEL_INFO}` - Kernel version

---

### Step 3: Validate Against EDS Standards

#### Step 3.1: Validate CPU Cores Against EDS

**What it does:**
- Compares actual CPU core count with EDS requirement
- Uses threshold validation (actual >= expected)

**Validation logic:**
```robot
Validate CPU Cores Against EDS    ${SERVER_CPU_CORES}
```

**Pass criteria:**
- Server CPU cores >= EDS required CPU cores

**Example:**
```
📋 EDS Expected: 4 cores
💻 Server Actual: 4 cores
✅ CPU cores validation: PASSED
```

**Fail message:**
```
❌ CPU MISMATCH: EDS requires 4 cores but server has 2 cores
```

---

#### Step 3.2: Validate Memory Against EDS

**What it does:**
- Compares actual RAM with EDS requirement
- Uses threshold validation (actual >= expected)
- Allows minor variance due to reserved memory

**Validation logic:**
```robot
Validate Memory Against EDS    ${SERVER_MEMORY_GB}
```

**Pass criteria:**
- Server RAM >= EDS required RAM (within tolerance)

**Example:**
```
📋 EDS Expected: 16 GB
🧠 Server Actual: 16 GB
✅ Memory allocation validation: PASSED
```

**Note:** System may show slightly less due to reserved memory (e.g., 15.6 GB actual vs 16 GB spec is acceptable)

---

#### Step 3.3: Validate Disk Space Against EDS

**What it does:**
- Logs disk space information for review
- Does not fail test on mismatch
- Informational validation only

**Validation logic:**
```robot
Log    💾 Server Root Filesystem Size: ${SERVER_ROOT_SIZE}    console=yes
```

**Pass criteria:**
- Informational - logs data for compliance review

**Example:**
```
📋 EDS Expected Storage Allocation: 100 GB
📋 EDS Recommended Storage: 150 GB
💾 Server Root Filesystem Size: 50G
ℹ️ Disk space validation logged for review
```

---

#### Step 3.4: Validate Storage Type Against EDS

**What it does:**
- Compares storage infrastructure type
- Informational due to detection variations

**Validation logic:**
```robot
Validate Storage Type Against EDS    ${SERVER_STORAGE_TYPE}
```

**Pass criteria:**
- Logs comparison for review
- Does not fail test (informational)

**Example:**
```
📋 EDS Expected: SAN
📡 Server Actual: SAN
✅ Storage type validation: INFORMATIONAL
```

---

#### Step 3.5: Validate Filesystem Against EDS

**What it does:**
- Validates root filesystem type and configuration
- Checks mount points and logical volumes

**Validation logic:**
```robot
Validate Root Filesystem Against EDS    ${SERVER_FS_TYPE}    ${SERVER_ROOT_SIZE}
```

**Pass criteria:**
- Logs filesystem configuration for review

**Example:**
```
📋 EDS Expected Mount Point: /dev/mapper/rootvg-root
📋 EDS Expected File System: xfs
🗂️ Server Filesystem Type: xfs
✅ Filesystem validation: LOGGED for review
```

---

### Step 4: Additional Analysis

#### Storage Capacity Analysis

**What it does:**
- Analyzes overall storage capacity
- Reviews storage type and allocation
- Logs against EDS total storage spec

**Commands executed:**
```bash
df -h /
lsblk
```

**Output logged:**
```
📊 Storage Analysis Summary:
📊 - Storage Type: SAN
📊 - Root Size: 50G
📊 - EDS Total Storage: 500 TB
📊 - EDS Drive Purpose: Operating System
```

---

#### Volume Group Analysis

**What it does:**
- Analyzes LVM volume group configuration
- Checks logical volume setup
- Compares with EDS volume specifications

**Example output:**
```
📋 EDS Volume Group Info: rootvg
📋 EDS Logical Volume: /dev/mapper/rootvg-root
📋 EDS File System: xfs
🏗️ Server Filesystem Type: xfs
✅ Volume group analysis: INFORMATIONAL
```

---

#### Operating System Validation

**What it does:**
- Validates OS type matches EDS specification
- Logs OS and kernel versions

**Example output:**
```
📋 EDS Expected OS Type: Red Hat Enterprise Linux
🖥️ Server OS: Red Hat Enterprise Linux 8.5 (Ootpa)
🖥️ Server Kernel: 4.18.0-348.el8.x86_64
✅ Operating system validation: LOGGED for compliance review
```

---

## Data Sources

### Input Data (EDS Lookup):
- `${TARGET_CPU_CORES}` - Expected CPU core count
- `${TARGET_RAM}` - Expected RAM in GB
- `${TARGET_STORAGE_ALLOC_GB}` - Expected storage allocation
- `${TARGET_RECOMMENDED_GB}` - Recommended storage
- `${TARGET_STORAGE_TYPE}` - Expected storage type (SAN/SSD/HDD)
- `${TARGET_STORAGE_TOTAL_TB}` - Total storage capacity
- `${TARGET_FILE_SYSTEM}` - Expected filesystem type
- `${TARGET_LOGICAL_VOLUME}` - Expected LVM path
- `${TARGET_OS_TYPE}` - Expected operating system

### Output Data (Collected from Server):
- `${SERVER_CPU_CORES}` - Actual CPU cores
- `${SERVER_MEMORY_GB}` - Actual RAM in GB
- `${SERVER_ROOT_SIZE}` - Actual root filesystem size
- `${SERVER_STORAGE_TYPE}` - Actual storage type
- `${SERVER_FS_TYPE}` - Actual filesystem type
- `${SERVER_OS_INFO}` - Actual OS distribution
- `${SERVER_KERNEL_INFO}` - Actual kernel version

---

## Success/Failure Criteria

### Test PASSES if:
- ✅ SSH connection successful
- ✅ CPU cores >= EDS requirement (Critical)
- ✅ RAM >= EDS requirement (Critical)
- ℹ️ Disk space logged (Informational)
- ℹ️ Storage type logged (Informational)
- ℹ️ Filesystem validated (Informational)

### Test FAILS if:
- ❌ SSH connection fails
- ❌ CPU cores < EDS requirement
- ❌ RAM < EDS requirement
- ❌ Data collection fails

---

## Key Technologies and Commands

| Technology | Purpose | Commands Used |
|------------|---------|---------------|
| SSH | Remote connection | SSHLibrary |
| nproc | CPU count | `nproc` |
| free | Memory stats | `free -g` |
| df | Disk usage | `df -h /`, `df -T /` |
| lsblk | Block devices | `lsblk -d -o NAME,ROTA` |
| LVM | Volume management | `/dev/mapper/*` detection |
| os-release | OS information | `cat /etc/os-release` |
| uname | Kernel info | `uname -r` |

---

## File Output

This test does NOT save data to separate files. All information is captured in Robot Framework logs.

**Report locations:**
- `results/test5_disk_space_validation/output.xml`
- `results/test5_disk_space_validation/log.html`
- `results/test5_disk_space_validation/report.html`

---

## Example Execution

### Successful execution:
```
🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH
✅ SSH connection verified and active

🔍 STEP 2.1: COLLECT CPU INFORMATION
💻 Server CPU Cores: 4
✅ CPU information collected

🔍 STEP 2.2: COLLECT MEMORY INFORMATION
🧠 Server RAM: 16 GB
✅ Memory information collected

🔍 STEP 2.3: COLLECT DISK SPACE INFORMATION
💾 Server Root Filesystem Size: 50G
✅ Disk space information collected

🔍 STEP 3.1: VALIDATE CPU CORES AGAINST EDS
📋 EDS Expected: 4
💻 Server Actual: 4
✅ CPU cores validation: PASSED

🔍 STEP 3.2: VALIDATE MEMORY AGAINST EDS
📋 EDS Expected: 16 GB
🧠 Server Actual: 16 GB
✅ Memory allocation validation: PASSED

Overall Status: PASSED ✅
```

---

## Troubleshooting

### Issue: CPU core count mismatch
**Solution:**
- Verify EDS has correct CPU specification
- Check virtualization CPU allocation
- Use `lscpu` for detailed CPU information

### Issue: Memory shows less than expected
**Solution:**
- Check if using GB vs GiB (binary vs decimal)
- Verify memory reservation settings
- Allow 5-10% tolerance for system reserved memory

### Issue: Disk space mismatch
**Solution:**
- Check correct filesystem is being measured
- Verify LVM configuration
- Check if using GB vs GiB units

### Issue: Storage type detection fails
**Solution:**
- Use `lsblk` manually to inspect
- Check for virtual disk types
- Review hardware specifications

---

**Document Version:** 1.0
**Last Updated:** 2025-10-14
**Test Coverage:** System resources and storage validation (CIP-010 R1)

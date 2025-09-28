# Test 5: Disk Space Allocation Information

## Test Case Overview
**Test Name:** Disk space allocation information from EDS/Build sheet, make visible Compute, Storage capacities, also separate disks for root, application and cyber tools, Also CPU information

## Test Description
This test suite validates system resources against EDS/Build sheet requirements, focusing on:
- **Disk Space Allocation**: Validates total disk space, partition sizes, and allocation for different purposes
- **Compute Capacity**: Verifies CPU specifications including core count and model information
- **Storage Validation**: Ensures proper separation of disks for root, application, and cyber tools
- **Build Compliance**: Comprehensive verification against build sheet requirements

## Implementation Steps
1. **Connect to Citrix** - (depending on environment - QA or Production)
2. **Open terminal application** - (Putty or Secure CRT)
3. **Connect to codeserver**
4. **Connect via SSH to target machine**
5. **Execute command df -h**
6. **Save outcome of command to a file**

## Robot Framework Validations
1. **Connect to Target** - Establish direct connection to the target machine via SSH for Linux systems
2. **Collect System Resources** - Execute disk space commands (df -h, lsblk, fdisk), gather CPU information, and capture all compute and storage capacity data while saving outputs to files
3. **Validate Against Build Requirements** - Compare all collected data (total disk allocation, partition structure, root/application/cyber tools disk sizes, CPU specifications, filesystem types) against the EDS/Build sheet requirements to ensure proper resource allocation and configuration

## Test Cases Implemented

### Critical Tests
- **SSH Connection to Target Machine**: Establishes secure connection for system analysis
- **Disk Space Information Collection**: Executes df -h and collects comprehensive disk data
- **CPU Information and Validation**: Gathers CPU specifications and validates against requirements
- **Storage Capacity and Allocation Analysis**: Validates disk separation and sizing for different purposes

### Normal Tests
- **Build Sheet Compliance Verification**: Comprehensive validation against EDS/Build sheet
- **System Resource Documentation**: Generates detailed reports for audit purposes

## Configuration Variables
Key configuration settings in `variables.resource`:
- **Environment Settings**: Citrix environment (QA/Production), terminal application
- **Connection Settings**: Codeserver and target machine hostnames
- **Validation Thresholds**: Minimum disk space, partition sizes, CPU requirements
- **Output Settings**: File locations and naming conventions

## Output Files Generated
- `disk_space_info.txt` - df -h command output
- `cpu_info.txt` - CPU specification details
- `storage_capacity.txt` - Storage capacity information
- `block_devices.txt` - Block device information
- `partition_info.txt` - Partition table details
- `storage_summary_report.txt` - Comprehensive summary report

## Usage
```bash
cd robotframework/tests/test5
robot disk_space_validation.robot
```

## Dependencies
- SSHLibrary for remote connections
- OperatingSystem library for file operations
- Target machine with SSH access configured
- Appropriate permissions for system information commands

## Expected Results
- All disk space requirements validated against build sheet
- CPU specifications meet minimum requirements
- Proper disk allocation for root, application, and cyber tools
- Comprehensive documentation of system resources
- Build sheet compliance verification passed
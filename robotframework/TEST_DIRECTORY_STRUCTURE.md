# Robot Framework Test Directory Structure

## Overview

This document defines the standardized directory structure for all Robot Framework test outputs and evidence files.

## Directory Structure

```
results/
├── test3_network_validation/
│   ├── log.html              # Robot Framework log (auto-generated)
│   ├── output.xml            # Robot Framework XML output (auto-generated)
│   ├── report.html           # Robot Framework report (auto-generated)
│   └── data/                 # Evidence files (test-generated)
│       ├── network_status_20231005_123456.txt
│       ├── ping_results_20231005_123456.txt
│       └── dns_lookup_20231005_123456.json
├── test4_vm_validation/
│   ├── log.html
│   ├── output.xml
│   ├── report.html
│   └── data/
│       ├── vm_config_20231005_123456.txt
│       └── vcenter_api_response_20231005_123456.json
└── all_output.xml            # Consolidated output from all tests
    all_log.html              # Consolidated log from all tests
    all_report.html           # Consolidated report from all tests
```

## File Placement Rules

### 1. Robot Framework Auto-Generated Files (Root of Test Directory)
These files are automatically created by Robot Framework using `--outputdir`:
- **log.html** - Detailed test execution log
- **output.xml** - Machine-readable test results
- **report.html** - Summary report with pass/fail statistics

**Location**: `results/{test_suite_name}/`
**Set by**: Ansible playbook or PowerShell script via `--outputdir` flag

### 2. Evidence Files (data Subdirectory)
All test-generated evidence files (txt, json, csv, xml) must go to the `data/` subdirectory:
- Raw command outputs (.txt)
- API responses (.json)
- Configuration files (.txt, .conf)
- Data exports (.csv, .json)
- Screenshots (.png) - if applicable
- Any other test artifacts

**Location**: `results/{test_suite_name}/data/`
**Set by**: Tests using `${OUTPUT_DIR}/data/`

## Implementation in Tests

### In Keyword Files

All tests should define DATA_DIR as:

```robot
*** Variables ***
${DATA_DIR}    ${OUTPUT_DIR}/data
```

### Creating the Data Directory

In the Suite Setup keyword, create the data directory:

```robot
*** Keywords ***
Initialize Test Environment
    [Documentation]    Setup test environment

    # Create data directory for evidence files
    Create Directory    ${DATA_DIR}

    # Rest of initialization...
```

### Saving Evidence Files

When saving evidence files, always use `${DATA_DIR}`:

```robot
Save Service Status
    [Documentation]    Save service status to file

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${filename}=    Set Variable    ${DATA_DIR}/service_status_${timestamp}.txt

    ${output}=    Execute Command    systemctl status --all
    Create File    ${filename}    ${output}

    Log    Evidence saved to: ${filename}    console=yes
```

### Executive Summary Files

Executive summary files can go in either location:
- **Root**: If it's a high-level summary meant to be visible alongside HTML reports
- **Data folder**: If it's detailed evidence data

**Recommendation**: Save executive summaries to root for easy access:

```robot
Generate Executive Summary
    [Documentation]    Generate high-level test summary

    ${summary_file}=    Set Variable    ${OUTPUT_DIR}/Test11_Services_Executive_Summary.txt
    Create File    ${summary_file}    ${summary_content}
```

## Test Suite ID and Naming

### Auto-Detection

Tests should auto-detect their suite ID from the directory name:

```robot
Auto Detect Test Suite Name
    [Documentation]    Auto-detect full test suite directory name

    ${suite_source}=    Get Variable Value    ${SUITE_SOURCE}    ${EMPTY}
    ${path_parts}=    Split String    ${suite_source}    ${/}

    FOR    ${part}    IN    @{path_parts}
        ${is_test_dir}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${part}    ^test\\d+_

        Run Keyword If    ${is_test_dir}
        ...    Return From Keyword    ${part}
    END

    # Fallback
    RETURN    test_unknown
```

### Using OUTPUT_DIR

Robot Framework provides `${OUTPUT_DIR}` automatically based on `--outputdir` flag.

**Example**: If executed with `--outputdir results/test11_services_validation`
- `${OUTPUT_DIR}` = `results/test11_services_validation`
- `${DATA_DIR}` = `${OUTPUT_DIR}/data` = `results/test11_services_validation/data`

## Execution Examples

### Via Ansible Playbook

```bash
ansible-playbook ansible_playbooks/run_tests.yml -e TargetHostname=server01
```

**Result**:
```
results/
├── test3_network_validation/
│   ├── log.html
│   ├── output.xml
│   ├── report.html
│   └── data/
│       └── *.txt, *.json files
├── test4_vm_validation/
│   ├── log.html
│   ├── output.xml
│   ├── report.html
│   └── data/
│       └── *.txt, *.json files
...
```

### Via PowerShell Script

```powershell
.\run_all_tests.ps1 -TargetHostname server01
```

**Result**: Same as above

### Via Direct Robot Command

```bash
python -m robot \
  --variable TARGET_HOSTNAME:server01 \
  --outputdir results/test11_services_validation \
  tests/test11_services_validation/services_validation.robot
```

**Result**:
```
results/test11_services_validation/
├── log.html
├── output.xml
├── report.html
└── data/
    └── services_status_20231005_123456.txt
```

## Benefits of This Structure

1. **Clean Separation**: HTML reports separate from evidence files
2. **Easy Navigation**: Evidence files organized in dedicated data folder
3. **Standardized**: All tests follow the same pattern
4. **Automation-Friendly**: Ansible and PowerShell can easily consolidate results
5. **Audit-Ready**: All evidence files in predictable locations

## Migration Checklist for Existing Tests

- [ ] Add `${DATA_DIR} = ${OUTPUT_DIR}/data` to keywords file
- [ ] Add `Create Directory ${DATA_DIR}` to Suite Setup
- [ ] Update all `Create File` calls to use `${DATA_DIR}/filename.txt`
- [ ] Update all evidence file paths to use `${DATA_DIR}`
- [ ] Test execution to verify files go to correct locations
- [ ] Verify HTML reports stay in root, evidence goes to data/

## Current Implementation Status

### ✅ Implemented Correctly
- test3_network_validation
- test11_services_validation (updated)

### ⚠️ Needs Update
- test4_vm_validation
- test9_datastore_configuration
- test15_backup_validation
- All other tests

### 🔍 To Verify
- Check each test's Suite Setup creates `${DATA_DIR}`
- Check each test's evidence files use `${DATA_DIR}`
- Verify no hardcoded paths like `results/testX/data/`

## Support

For questions or issues with directory structure:
- Review this document
- Check test3 or test11 as reference implementations
- Ensure `${OUTPUT_DIR}` is used, not hardcoded paths

---

**Last Updated**: 2025-10-12
**Version**: 1.0

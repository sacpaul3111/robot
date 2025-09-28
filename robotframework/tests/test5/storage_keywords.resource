*** Settings ***
Documentation    💾 Storage and System Resource Keywords for Test-5
...              Comprehensive keywords for disk space, storage, and compute validation

Library          SSHLibrary
Library          OperatingSystem
Library          String
Library          Collections

*** Keywords ***
Initialize Test Environment
    [Documentation]    🚀 Initialize test environment and create output directories
    Log    🔧 Initializing Test-5: Disk Space Allocation Information    console=yes

    # Initialize test counters
    Set Test Variable    ${TOTAL_TESTS}        0
    Set Test Variable    ${PASSED_TESTS}       0
    Set Test Variable    @{TEST_RESULTS}
    Set Test Variable    @{PERFORMANCE_METRICS}
    Set Test Variable    @{VALIDATION_ERRORS}

    # Create output directory
    Create Directory    ${OUTPUT_DIR}
    Log    📁 Created output directory: ${OUTPUT_DIR}    console=yes

Connect To Target Machine
    [Documentation]    🌐 Establish SSH connection to target machine
    [Arguments]    ${host}=${TARGET_MACHINE}    ${username}=root

    Log    🔗 Connecting to target machine: ${host}    console=yes

    TRY
        Open Connection    ${host}    timeout=${SSH_TIMEOUT}
        Login    ${username}    # Assumes key-based authentication
        Log    ✅ Successfully connected to ${host}    console=yes
        RETURN    ${True}
    EXCEPT
        Log    ❌ Failed to connect to ${host}    console=yes
        RETURN    ${False}
    END

Execute Storage Command
    [Documentation]    💻 Execute storage-related command and save output
    [Arguments]    ${command}    ${description}    ${output_file}=${EMPTY}

    Log    🔍 Executing: ${command} (${description})    console=yes

    TRY
        ${result}=    Execute Command    ${command}    timeout=${COMMAND_TIMEOUT}
        Log    📋 Command output:\n${result}    console=yes

        # Save to file if specified
        IF    "${output_file}" != "${EMPTY}"
            ${file_path}=    Set Variable    ${OUTPUT_DIR}/${output_file}
            Create File    ${file_path}    ${result}
            Log    💾 Output saved to: ${file_path}    console=yes
        END

        RETURN    ${result}
    EXCEPT    AS    ${error}
        Log    ❌ Command failed: ${error}    console=yes
        Append To List    ${VALIDATION_ERRORS}    Command failed: ${command} - ${error}
        RETURN    ${EMPTY}
    END

Collect Disk Space Information
    [Documentation]    💿 Collect comprehensive disk space information using df -h

    Log    📊 Collecting disk space information...    console=yes

    # Execute df -h command
    ${df_output}=    Execute Storage Command    df -h    Disk space usage    ${DISK_INFO_FILE}
    Should Not Be Empty    ${df_output}    df command returned no output

    # Execute lsblk for block device information
    ${lsblk_output}=    Execute Storage Command    lsblk -f    Block device info    block_devices.txt

    # Execute fdisk for partition information
    ${fdisk_output}=    Execute Storage Command    fdisk -l    Partition table info    partition_info.txt

    RETURN    ${df_output}

Collect CPU Information
    [Documentation]    🖥️ Collect CPU information and specifications

    Log    🔍 Collecting CPU information...    console=yes

    # Get CPU info from /proc/cpuinfo
    ${cpu_info}=    Execute Storage Command    cat /proc/cpuinfo    CPU information    ${CPU_INFO_FILE}
    Should Not Be Empty    ${cpu_info}    CPU information not available

    # Get CPU count
    ${cpu_count}=    Execute Storage Command    nproc    CPU core count    cpu_count.txt

    # Get CPU model
    ${cpu_model}=    Execute Command    grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs

    Log    💻 CPU Model: ${cpu_model}    console=yes
    Log    🔢 CPU Cores: ${cpu_count}    console=yes

    RETURN    ${cpu_info}

Collect Storage Capacity Information
    [Documentation]    📦 Collect detailed storage capacity and allocation information

    Log    📊 Collecting storage capacity information...    console=yes

    # Get detailed filesystem information
    ${filesystem_info}=    Execute Storage Command    df -T    Filesystem types    ${STORAGE_INFO_FILE}

    # Get mount point information
    ${mount_info}=    Execute Storage Command    mount | grep -E "^/dev"    Mount points    mount_points.txt

    # Get disk usage by directory
    ${du_info}=    Execute Storage Command    du -sh /* 2>/dev/null | sort -hr    Directory usage    directory_usage.txt

    RETURN    ${filesystem_info}

Validate Disk Space Requirements
    [Documentation]    ✅ Validate disk space against build sheet requirements
    [Arguments]    ${df_output}

    Log    🔍 Validating disk space requirements...    console=yes

    # Parse df output to extract disk information
    @{df_lines}=    Split To Lines    ${df_output}

    ${root_found}=    Set Variable    ${False}
    ${total_space_gb}=    Set Variable    0

    FOR    ${line}    IN    @{df_lines}
        ${line}=    Strip String    ${line}
        Continue For Loop If    "${line}" == ""
        Continue For Loop If    "Filesystem" in "${line}"

        # Parse filesystem line
        @{parts}=    Split String    ${line}
        ${filesystem}=    Get From List    ${parts}    0
        ${size}=    Get From List    ${parts}    1
        ${used}=    Get From List    ${parts}    2
        ${available}=    Get From List    ${parts}    3
        ${use_percent}=    Get From List    ${parts}    4
        ${mount_point}=    Get From List    ${parts}    5

        # Check root partition
        IF    "${mount_point}" == "/"
            ${root_found}=    Set Variable    ${True}
            ${root_size_gb}=    Convert Size To GB    ${size}
            Should Be True    ${root_size_gb} >= ${MIN_ROOT_PARTITION}
            ...    Root partition too small: ${root_size_gb}GB < ${MIN_ROOT_PARTITION}GB
            Log    ✅ Root partition size: ${root_size_gb}GB    console=yes
        END

        # Extract and sum total space
        ${size_gb}=    Convert Size To GB    ${size}
        ${total_space_gb}=    Evaluate    ${total_space_gb} + ${size_gb}

        # Check disk usage percentage
        ${usage_num}=    Get Regexp Matches    ${use_percent}    (\\d+)    1
        IF    ${usage_num}
            ${usage_percent}=    Convert To Integer    ${usage_num}[0]
            Should Be True    ${usage_percent} <= ${MAX_DISK_USAGE_PERCENT}
            ...    Disk usage too high on ${mount_point}: ${usage_percent}% > ${MAX_DISK_USAGE_PERCENT}%
        END
    END

    Should Be True    ${root_found}    Root partition not found
    Should Be True    ${total_space_gb} >= ${MIN_TOTAL_DISK_SPACE}
    ...    Total disk space insufficient: ${total_space_gb}GB < ${MIN_TOTAL_DISK_SPACE}GB

    Log    ✅ Total disk space: ${total_space_gb}GB    console=yes
    RETURN    ${total_space_gb}

Validate CPU Requirements
    [Documentation]    🖥️ Validate CPU specifications against build requirements
    [Arguments]    ${cpu_info}

    Log    🔍 Validating CPU requirements...    console=yes

    # Count CPU cores
    ${core_count}=    Get Regexp Matches    ${cpu_info}    processor\\s*:\\s*(\\d+)
    ${cpu_cores}=    Get Length    ${core_count}
    ${cpu_cores}=    Evaluate    ${cpu_cores} + 1    # processor numbers start from 0

    Should Be True    ${cpu_cores} >= ${MIN_CPU_CORES}
    ...    Insufficient CPU cores: ${cpu_cores} < ${MIN_CPU_CORES}

    # Get CPU model information
    ${cpu_model_lines}=    Get Regexp Matches    ${cpu_info}    model name\\s*:\\s*(.+)    1
    ${cpu_model}=    Set Variable If    ${cpu_model_lines}    ${cpu_model_lines}[0]    Unknown

    Log    ✅ CPU cores: ${cpu_cores}    console=yes
    Log    💻 CPU model: ${cpu_model}    console=yes

    Append To List    ${PERFORMANCE_METRICS}    CPU Cores: ${cpu_cores}
    Append To List    ${PERFORMANCE_METRICS}    CPU Model: ${cpu_model}

    RETURN    ${cpu_cores}

Validate Storage Allocation
    [Documentation]    📦 Validate storage allocation for root, application, and cyber tools
    [Arguments]    ${filesystem_info}

    Log    🔍 Validating storage allocation...    console=yes

    @{fs_lines}=    Split To Lines    ${filesystem_info}

    ${allocation_valid}=    Set Variable    ${True}
    @{found_partitions}=    Create List

    FOR    ${line}    IN    @{fs_lines}
        ${line}=    Strip String    ${line}
        Continue For Loop If    "${line}" == ""
        Continue For Loop If    "Filesystem" in "${line}"

        @{parts}=    Split String    ${line}
        ${filesystem}=    Get From List    ${parts}    0
        ${fs_type}=    Get From List    ${parts}    1
        ${mount_point}=    Get From List    ${parts}    6

        Append To List    ${found_partitions}    ${mount_point}

        # Validate filesystem types
        IF    "${fs_type}" not in ${EXPECTED_FILESYSTEMS}
            Log    ⚠️ Unexpected filesystem type: ${fs_type} on ${mount_point}    console=yes
        END
    END

    # Check for required mount points
    FOR    ${required_mount}    IN    @{REQUIRED_MOUNT_POINTS}
        IF    "${required_mount}" not in ${found_partitions}
            Log    ❌ Required mount point missing: ${required_mount}    console=yes
            ${allocation_valid}=    Set Variable    ${False}
        ELSE
            Log    ✅ Found required mount point: ${required_mount}    console=yes
        END
    END

    Should Be True    ${allocation_valid}    Storage allocation validation failed
    RETURN    ${allocation_valid}

Convert Size To GB
    [Documentation]    🔄 Convert disk size string to GB (handles K, M, G, T suffixes)
    [Arguments]    ${size_str}

    ${size_str}=    Strip String    ${size_str}
    ${size_str}=    Convert To Upper Case    ${size_str}

    # Extract number and unit
    ${matches}=    Get Regexp Matches    ${size_str}    (\\d+(?:\\.\\d+)?)([KMGT]?)    1    2

    IF    not ${matches}
        RETURN    0
    END

    ${number}=    Convert To Number    ${matches}[0][0]
    ${unit}=    Set Variable    ${matches}[0][1]

    # Convert to GB
    IF    "${unit}" == "K"
        ${gb_size}=    Evaluate    ${number} / 1024 / 1024
    ELSE IF    "${unit}" == "M"
        ${gb_size}=    Evaluate    ${number} / 1024
    ELSE IF    "${unit}" == "G" or "${unit}" == ""
        ${gb_size}=    Set Variable    ${number}
    ELSE IF    "${unit}" == "T"
        ${gb_size}=    Evaluate    ${number} * 1024
    ELSE
        ${gb_size}=    Set Variable    0
    END

    RETURN    ${gb_size}

Generate Storage Summary Report
    [Documentation]    📊 Generate comprehensive storage and system summary report

    Log    📋 Generating storage summary report...    console=yes

    # Create summary report
    ${report_content}=    Set Variable
    ...    =====================================\n
    ...    🗂️ DISK SPACE ALLOCATION REPORT\n
    ...    =====================================\n\n
    ...    📊 Test Summary:\n
    ...    - Total Tests: ${TOTAL_TESTS}\n
    ...    - Passed Tests: ${PASSED_TESTS}\n
    ...    - Success Rate: ${PASSED_TESTS}/${TOTAL_TESTS}\n\n
    ...    💾 Storage Information:\n

    FOR    ${result}    IN    @{TEST_RESULTS}
        ${report_content}=    Set Variable    ${report_content}- ${result}\n
    END

    ${report_content}=    Set Variable    ${report_content}\n🖥️ Performance Metrics:\n

    FOR    ${metric}    IN    @{PERFORMANCE_METRICS}
        ${report_content}=    Set Variable    ${report_content}- ${metric}\n
    END

    IF    ${VALIDATION_ERRORS}
        ${report_content}=    Set Variable    ${report_content}\n❌ Validation Errors:\n
        FOR    ${error}    IN    @{VALIDATION_ERRORS}
            ${report_content}=    Set Variable    ${report_content}- ${error}\n
        END
    END

    ${report_content}=    Set Variable    ${report_content}\n=====================================\n

    # Save report to file
    ${report_file}=    Set Variable    ${OUTPUT_DIR}/storage_summary_report.txt
    Create File    ${report_file}    ${report_content}

    Log    📊 Storage summary report generated: ${report_file}    console=yes
    Log    ${report_content}    console=yes

Log Test Start
    [Documentation]    🚀 Log the start of a test case
    [Arguments]    ${test_name}
    Log    🚀 Starting: ${test_name}    console=yes

Log Test End
    [Documentation]    🏁 Log the end of a test case
    [Arguments]    ${test_name}    ${status}
    Log    🏁 Finished: ${test_name} - Status: ${status}    console=yes

Close Target Connection
    [Documentation]    🔒 Close SSH connection to target machine

    Log    🔒 Closing connection to target machine    console=yes
    Close All Connections
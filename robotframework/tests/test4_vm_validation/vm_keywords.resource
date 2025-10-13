*** Settings ***
Documentation    VM Validation Keywords - vCenter API interactions and VM data collection
Library          ../../library/VCenterAPI.py
Library          Collections
Library          String
Library          BuiltIn
Library          DateTime
Library          OperatingSystem

*** Keywords ***
Connect To vCenter And Get VM Details
    [Documentation]    Connect to vCenter API and retrieve comprehensive VM configuration
    [Arguments]    ${vm_name}    ${vcenter_host}    ${vcenter_user}    ${vcenter_pass}

    Log    🔌 Connecting to vCenter: ${vcenter_host}    console=yes

    # Establish vCenter API connection
    ${session_id}=    Connect To VCenter    ${vcenter_host}    ${vcenter_user}    ${vcenter_pass}
    Log    ✅ Connected to vCenter API (Session: ${session_id})    console=yes

    # Get comprehensive VM details
    ${vm_details}=    Get VM Comprehensive Details    ${vm_name}

    Log    📦 Retrieved comprehensive VM details for: ${vm_name}    console=yes

    RETURN    ${vm_details}

Get VM Cluster Placement
    [Documentation]    Extract cluster placement from VM details - prefers cluster name over ID
    [Arguments]    ${vm_details}

    ${cluster_info}=    Get From Dictionary    ${vm_details}    cluster_placement

    # Try to get cluster_name first, fallback to cluster_id, then host_name
    ${cluster_name}=    Get From Dictionary    ${cluster_info}    cluster_name    default=N/A
    ${cluster_id}=      Get From Dictionary    ${cluster_info}    cluster_id      default=N/A
    ${host_name}=       Get From Dictionary    ${cluster_info}    host_name       default=N/A

    Log    🏢 VM Cluster Name: ${cluster_name}    console=yes
    Log    🏢 VM Cluster ID: ${cluster_id}    console=yes
    Log    🖥️ VM Host: ${host_name}    console=yes

    # Determine best identifier: cluster_name > cluster_id > host_name
    ${cluster_identifier}=    Set Variable If
    ...    '${cluster_name}' != 'N/A'    ${cluster_name}
    ...    '${cluster_id}' != 'N/A'      ${cluster_id}
    ...    ${host_name}

    RETURN    ${cluster_identifier}

Get VM CPU Configuration
    [Documentation]    Extract CPU configuration from VM details
    [Arguments]    ${vm_details}

    ${config}=        Get From Dictionary    ${vm_details}    configuration
    ${cpu_count}=     Get From Dictionary    ${config}        cpu_count
    ${cores_per_socket}=    Get From Dictionary    ${config}    cores_per_socket

    Log    💻 VM CPU Count: ${cpu_count}    console=yes
    Log    💻 VM Cores per Socket: ${cores_per_socket}    console=yes

    RETURN    ${cpu_count}

Get VM Memory Configuration
    [Documentation]    Extract memory configuration from VM details
    [Arguments]    ${vm_details}

    ${config}=        Get From Dictionary    ${vm_details}    configuration
    ${memory_gb}=     Get From Dictionary    ${config}        memory_size_gb

    Log    🧠 VM Memory: ${memory_gb} GB    console=yes

    RETURN    ${memory_gb}

Get VM Hardware Version
    [Documentation]    Extract hardware version from VM details
    [Arguments]    ${vm_details}

    ${config}=        Get From Dictionary    ${vm_details}    configuration
    ${hw_version}=    Get From Dictionary    ${config}        hardware_version

    Log    ⚙️ VM Hardware Version: ${hw_version}    console=yes

    RETURN    ${hw_version}

Get VM Network Adapter Configuration
    [Documentation]    Extract network adapter configuration from VM details
    [Arguments]    ${vm_details}

    ${adapters}=    Get From Dictionary    ${vm_details}    network_adapters
    ${adapter_count}=    Get Length    ${adapters}

    Log    🌐 VM Network Adapters: ${adapter_count}    console=yes

    FOR    ${adapter}    IN    @{adapters}
        ${label}=    Get From Dictionary    ${adapter}    label
        ${type}=     Get From Dictionary    ${adapter}    type
        ${network}=  Get From Dictionary    ${adapter}    network_name
        Log    🔌 Adapter: ${label}, Type: ${type}, Network: ${network}    console=yes
    END

    RETURN    ${adapters}

Get VM Disk Configuration
    [Documentation]    Extract disk configuration from VM details
    [Arguments]    ${vm_details}

    ${disks}=    Get From Dictionary    ${vm_details}    disk_configuration
    ${disk_count}=    Get Length    ${disks}
    ${total_capacity}=    Set Variable    ${0}

    Log    💾 VM Disks: ${disk_count}    console=yes

    FOR    ${disk}    IN    @{disks}
        ${label}=      Get From Dictionary    ${disk}    label
        ${capacity}=   Get From Dictionary    ${disk}    capacity_gb
        ${type}=       Get From Dictionary    ${disk}    type
        Log    💿 Disk: ${label}, Capacity: ${capacity} GB, Type: ${type}    console=yes
        ${total_capacity}=    Evaluate    ${total_capacity} + ${capacity}
    END

    Log    📊 Total Disk Capacity: ${total_capacity} GB    console=yes

    RETURN    ${total_capacity}

Validate VM Cluster Placement Against EDS
    [Documentation]    Validate that VM is in the expected VxRail cluster
    [Arguments]    ${actual_cluster}    ${expected_cluster}

    Log    🔍 Validating cluster placement...    console=yes
    Log    📋 Expected VxRail Cluster (from EDS): ${expected_cluster}    console=yes
    Log    🏢 Actual Cluster (from vCenter): ${actual_cluster}    console=yes

    # If EDS has specific cluster name, validate it matches or is contained in actual cluster
    Run Keyword If    '${expected_cluster}' != 'N/A'
    ...    Should Contain    ${actual_cluster}    ${expected_cluster}    ignore_case=True
    ...    msg=❌ CLUSTER MISMATCH: Expected cluster name '${expected_cluster}' but VM is in '${actual_cluster}'

    Log    ✅ Cluster placement validated    console=yes

Validate VM CPU Against EDS
    [Documentation]    Validate VM CPU configuration matches EDS specification
    [Arguments]    ${actual_cpu}    ${expected_cpu}

    Log    🔍 Validating CPU configuration...    console=yes
    Log    📋 EDS Expected CPU: ${expected_cpu}    console=yes
    Log    💻 vCenter Actual CPU: ${actual_cpu}    console=yes

    # Convert to integers for comparison
    ${actual_cpu_int}=    Convert To Integer    ${actual_cpu}
    ${expected_cpu_int}=  Convert To Integer    ${expected_cpu}

    Should Be Equal As Integers    ${actual_cpu_int}    ${expected_cpu_int}
    ...    ❌ CPU MISMATCH: EDS expects ${expected_cpu} cores but vCenter shows ${actual_cpu} cores

    Log    ✅ CPU configuration validated    console=yes

Validate VM Memory Against EDS
    [Documentation]    Validate VM memory configuration matches EDS specification
    [Arguments]    ${actual_memory_gb}    ${expected_ram}

    Log    🔍 Validating memory configuration...    console=yes
    Log    📋 EDS Expected RAM: ${expected_ram} GB    console=yes
    Log    🧠 vCenter Actual Memory: ${actual_memory_gb} GB    console=yes

    # Convert expected RAM (may have "GB" suffix) to number
    ${expected_ram_cleaned}=    Remove String    ${expected_ram}    GB    gb    ${SPACE}
    ${expected_ram_float}=      Convert To Number    ${expected_ram_cleaned}
    ${actual_memory_float}=     Convert To Number    ${actual_memory_gb}

    Should Be Equal As Numbers    ${actual_memory_float}    ${expected_ram_float}    precision=2
    ...    ❌ MEMORY MISMATCH: EDS expects ${expected_ram} GB but vCenter shows ${actual_memory_gb} GB

    Log    ✅ Memory configuration validated    console=yes

Validate VM Hardware Version Against EDS
    [Documentation]    Validate VM hardware version matches EDS specification
    [Arguments]    ${actual_hw_version}    ${expected_hw_version}

    Log    🔍 Validating hardware version...    console=yes
    Log    📋 EDS Expected HW Version: ${expected_hw_version}    console=yes
    Log    ⚙️ vCenter Actual HW Version: ${actual_hw_version}    console=yes

    Run Keyword If    '${expected_hw_version}' != 'N/A'
    ...    Should Contain    ${actual_hw_version}    ${expected_hw_version}    ignore_case=True
    ...    msg=❌ HARDWARE VERSION MISMATCH: EDS expects '${expected_hw_version}' but vCenter shows '${actual_hw_version}'

    Log    ✅ Hardware version validated    console=yes

Validate VM Network Configuration
    [Documentation]    Validate VM has network adapters configured
    [Arguments]    ${network_adapters}

    Log    🔍 Validating network configuration...    console=yes

    ${adapter_count}=    Get Length    ${network_adapters}
    Should Be True    ${adapter_count} > 0
    ...    ❌ NETWORK ERROR: VM has no network adapters configured

    Log    ✅ Network configuration validated (${adapter_count} adapter(s))    console=yes

Validate VM Disk Configuration
    [Documentation]    Validate VM disk configuration
    [Arguments]    ${total_disk_capacity_gb}

    Log    🔍 Validating disk configuration...    console=yes
    Log    💾 Total Disk Capacity: ${total_disk_capacity_gb} GB    console=yes

    ${capacity_float}=    Convert To Number    ${total_disk_capacity_gb}
    Should Be True    ${capacity_float} > 0
    ...    ❌ DISK ERROR: VM has no disk capacity configured

    Log    ✅ Disk configuration validated    console=yes

Save VM Data to Files
    [Documentation]    💾 Save complete VM configuration data to files for compliance review
    Log    💾 Saving VM configuration data to files...    console=yes

    # Generate timestamp for unique filenames
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S

    # Build network adapter details
    ${network_details}=    Set Variable    ${EMPTY}
    FOR    ${adapter}    IN    @{VM_NETWORK_ADAPTERS}
        ${label}=    Get From Dictionary    ${adapter}    label
        ${type}=     Get From Dictionary    ${adapter}    type
        ${network}=  Get From Dictionary    ${adapter}    network_name
        ${network_details}=    Catenate    SEPARATOR=\n    ${network_details}
        ...    - ${label}: Type=${type}, Network=${network}
    END

    # Save VM configuration summary
    ${vm_config_file}=    Set Variable    ${TEST4_DATA_DIR}/vm_configuration_${timestamp}.txt
    ${vm_config_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === VM CONFIGURATION SUMMARY ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target VM: ${TARGET_HOSTNAME}
    ...    vCenter Host: ${TARGET_VCENTER_HOST}
    ...
    ...    CLUSTER PLACEMENT:
    ...    - Cluster: ${VM_CLUSTER_ID}
    ...
    ...    COMPUTE RESOURCES:
    ...    - CPU Cores: ${VM_CPU_COUNT}
    ...    - Memory: ${VM_MEMORY_GB} GB
    ...
    ...    HARDWARE:
    ...    - Hardware Version: ${VM_HW_VERSION}
    ...
    ...    NETWORK CONFIGURATION:
    ...    ${network_details}
    ...
    ...    STORAGE:
    ...    - Total Disk Capacity: ${VM_DISK_CAPACITY} GB
    ...    =========================================
    Create File    ${vm_config_file}    ${vm_config_report}
    Log    📄 VM configuration saved to: ${vm_config_file}    console=yes

    # Save EDS comparison report
    ${comparison_file}=    Set Variable    ${TEST4_DATA_DIR}/eds_comparison_${timestamp}.txt
    ${comparison_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === VM vs EDS COMPARISON REPORT ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target VM: ${TARGET_HOSTNAME}
    ...
    ...    CLUSTER PLACEMENT:
    ...    - EDS Expected: ${TARGET_VXRAIL_CLUSTER}
    ...    - vCenter Actual: ${VM_CLUSTER_ID}
    ...
    ...    CPU CONFIGURATION:
    ...    - EDS Expected: ${TARGET_VM_CPU_CORES} cores
    ...    - vCenter Actual: ${VM_CPU_COUNT} cores
    ...
    ...    MEMORY CONFIGURATION:
    ...    - EDS Expected: ${TARGET_VM_RAM} GB
    ...    - vCenter Actual: ${VM_MEMORY_GB} GB
    ...
    ...    HARDWARE VERSION:
    ...    - EDS Expected: ${TARGET_VM_HARDWARE_VERSION}
    ...    - vCenter Actual: ${VM_HW_VERSION}
    ...
    ...    NETWORK ADAPTERS:
    ...    ${network_details}
    ...
    ...    DISK CONFIGURATION:
    ...    - Total Capacity: ${VM_DISK_CAPACITY} GB
    ...
    ...    MEMORY RESERVATION:
    ...    - EDS Setting: ${TARGET_VM_MEMORY_RESERVATION}
    ...
    ...    CPU RESERVATION:
    ...    - EDS Setting: ${TARGET_VM_CPU_RESERVATION}
    ...    =========================================
    Create File    ${comparison_file}    ${comparison_report}
    Log    📄 EDS comparison saved to: ${comparison_file}    console=yes

    # Save comprehensive validation report
    ${validation_file}=    Set Variable    ${TEST4_DATA_DIR}/vm_validation_report_${timestamp}.txt
    ${validation_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === VM VALIDATION COMPREHENSIVE REPORT ===
    ...    =========================================
    ...    Timestamp: ${timestamp}
    ...    Target VM: ${TARGET_HOSTNAME}
    ...    vCenter: ${TARGET_VCENTER_HOST}
    ...
    ...    TEST SUITE: Test-4 VM Configuration Validation
    ...    PURPOSE: Validate VM configuration matches EDS specifications
    ...
    ...    =========================================
    ...    === COLLECTED DATA ===
    ...    =========================================
    ...    Cluster: ${VM_CLUSTER_ID}
    ...    CPU Cores: ${VM_CPU_COUNT}
    ...    Memory: ${VM_MEMORY_GB} GB
    ...    Hardware Version: ${VM_HW_VERSION}
    ...    Network Adapters: ${network_details}
    ...    Disk Capacity: ${VM_DISK_CAPACITY} GB
    ...
    ...    =========================================
    ...    === EDS REQUIREMENTS ===
    ...    =========================================
    ...    Required Cluster: ${TARGET_VXRAIL_CLUSTER}
    ...    Required CPU: ${TARGET_VM_CPU_CORES} cores
    ...    Required Memory: ${TARGET_VM_RAM} GB
    ...    Required HW Version: ${TARGET_VM_HARDWARE_VERSION}
    ...    Memory Reservation: ${TARGET_VM_MEMORY_RESERVATION}
    ...    CPU Reservation: ${TARGET_VM_CPU_RESERVATION}
    ...
    ...    =========================================
    ...    === VALIDATION RESULTS ===
    ...    =========================================
    ...    See test report for detailed validation results
    ...    =========================================
    Create File    ${validation_file}    ${validation_report}
    Log    📄 Validation report saved to: ${validation_file}    console=yes

    Log    ✅ All VM configuration data saved to ${TEST4_DATA_DIR}    console=yes
    RETURN    ${validation_file}

Disconnect From vCenter
    [Documentation]    Disconnect from vCenter API session

    Disconnect From VCenter
    Log    🔌 Disconnected from vCenter API    console=yes
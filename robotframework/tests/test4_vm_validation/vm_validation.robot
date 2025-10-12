*** Settings ***
Documentation    🖥️ VM Configuration Validation Test Suite - Test-4
...              🔍 Process: Connect to vCenter API → Query VM details → Compare vCenter vs EDS
...              ✅ Pass if VM configuration matches EDS requirements, ❌ Fail if mismatch
...              📊 Validates: Cluster placement, CPU cores, memory, hardware version, network, disks
...
Resource         ../../settings.resource
Resource         vm_keywords.resource
Resource         variables.resource

Suite Setup      Initialize VM Test Environment And Lookup Configuration
Suite Teardown   Generate VM Executive Summary And Disconnect

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Variables ***
${VM_DETAILS}    ${EMPTY}

*** Test Cases ***
Critical - Step 1: Connect to vCenter API
    [Documentation]    🔌 Establish API connection to vCenter to retrieve VM details
    ...                Step 1 of validation process: Connect to vCenter
    [Tags]             critical    vcenter    api    connection    step1

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO VCENTER API    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target VM: ${TARGET_HOSTNAME}    console=yes
    Log    📋 vCenter Host: ${TARGET_VCENTER_HOST}    console=yes

    # Validate vCenter connection details are available
    Should Not Be Equal    ${TARGET_VCENTER_HOST}    N/A
    ...    ❌ CONFIGURATION ERROR: vCenter host not specified in EDS

    Should Not Be Empty    ${VCENTER_USERNAME}
    ...    ❌ CONFIGURATION ERROR: vCenter username not provided

    Should Not Be Empty    ${VCENTER_PASSWORD}
    ...    ❌ CONFIGURATION ERROR: vCenter password not provided

    # Connect to vCenter and retrieve VM details
    ${vm_details}=    Connect To vCenter And Get VM Details
    ...    ${TARGET_HOSTNAME}
    ...    ${TARGET_VCENTER_HOST}
    ...    ${VCENTER_USERNAME}
    ...    ${VCENTER_PASSWORD}

    Set Suite Variable    ${VM_DETAILS}    ${vm_details}

    Log    ✅ vCenter API connection successful    console=yes
    Log    ✅ STEP 1: COMPLETED - VM details retrieved from vCenter    console=yes

Critical - Step 2.1: Collect VM Cluster Placement
    [Documentation]    🏢 Query VM cluster placement information from vCenter
    ...                Step 2 of validation process: Collect VM Configuration Data (Part 1)
    [Tags]             critical    cluster    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT VM CLUSTER PLACEMENT    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get cluster placement from VM details
    ${actual_cluster_id}=    Get VM Cluster Placement    ${VM_DETAILS}

    Set Suite Variable    ${VM_CLUSTER_ID}    ${actual_cluster_id}

    Log    🖥️ VM Cluster: ${actual_cluster_id}    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Cluster placement collected    console=yes

Critical - Step 2.2: Collect VM CPU Configuration
    [Documentation]    💻 Query VM CPU allocation from vCenter
    ...                Step 2 of validation process: Collect VM Configuration Data (Part 2)
    [Tags]             critical    cpu    hardware    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT VM CPU CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get CPU configuration from VM details
    ${actual_cpu_count}=    Get VM CPU Configuration    ${VM_DETAILS}

    Set Suite Variable    ${VM_CPU_COUNT}    ${actual_cpu_count}

    Log    🖥️ VM CPU Cores: ${actual_cpu_count}    console=yes
    Log    ✅ STEP 2.2: COMPLETED - CPU configuration collected    console=yes

Critical - Step 2.3: Collect VM Memory Configuration
    [Documentation]    🧠 Query VM memory allocation from vCenter
    ...                Step 2 of validation process: Collect VM Configuration Data (Part 3)
    [Tags]             critical    memory    hardware    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT VM MEMORY CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get memory configuration from VM details
    ${actual_memory_gb}=    Get VM Memory Configuration    ${VM_DETAILS}

    Set Suite Variable    ${VM_MEMORY_GB}    ${actual_memory_gb}

    Log    🖥️ VM Memory: ${actual_memory_gb} GB    console=yes
    Log    ✅ STEP 2.3: COMPLETED - Memory configuration collected    console=yes

Critical - Step 2.4: Collect VM Hardware Version
    [Documentation]    ⚙️ Query VM hardware version from vCenter
    ...                Step 2 of validation process: Collect VM Configuration Data (Part 4)
    [Tags]             critical    hardware    version    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: COLLECT VM HARDWARE VERSION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get hardware version from VM details
    ${actual_hw_version}=    Get VM Hardware Version    ${VM_DETAILS}

    Set Suite Variable    ${VM_HW_VERSION}    ${actual_hw_version}

    Log    🖥️ VM Hardware Version: ${actual_hw_version}    console=yes
    Log    ✅ STEP 2.4: COMPLETED - Hardware version collected    console=yes

Critical - Step 2.5: Collect VM Network Configuration
    [Documentation]    🌐 Query VM network adapter configuration from vCenter
    ...                Step 2 of validation process: Collect VM Configuration Data (Part 5)
    [Tags]             critical    network    adapters    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.5: COLLECT VM NETWORK CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get network adapter configuration
    ${network_adapters}=    Get VM Network Adapter Configuration    ${VM_DETAILS}

    Set Suite Variable    ${VM_NETWORK_ADAPTERS}    ${network_adapters}

    ${adapter_count}=    Get Length    ${network_adapters}
    Log    🖥️ VM Network Adapters: ${adapter_count}    console=yes
    Log    ✅ STEP 2.5: COMPLETED - Network configuration collected    console=yes

Critical - Step 2.6: Collect VM Disk Configuration
    [Documentation]    💾 Query VM disk configuration and capacity from vCenter
    ...                Step 2 of validation process: Collect VM Configuration Data (Part 6)
    [Tags]             critical    disk    storage    step2    data_collection

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.6: COLLECT VM DISK CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get disk configuration
    ${total_disk_capacity}=    Get VM Disk Configuration    ${VM_DETAILS}

    Set Suite Variable    ${VM_DISK_CAPACITY}    ${total_disk_capacity}

    Log    🖥️ VM Total Disk Capacity: ${total_disk_capacity} GB    console=yes
    Log    ✅ STEP 2.6: COMPLETED - Disk configuration collected    console=yes

Critical - Step 3.1: Validate Cluster Placement Against EDS
    [Documentation]    ✅ Compare collected cluster placement with EDS expected value
    ...                Step 3 of validation process: Validate Against EDS Standards (Part 1)
    [Tags]             critical    validation    step3    compliance    cluster

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE CLUSTER PLACEMENT AGAINST EDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    Log    📋 EDS Expected: ${TARGET_VXRAIL_CLUSTER}    console=yes
    Log    🖥️ vCenter Actual: ${VM_CLUSTER_ID}    console=yes

    # Validate against EDS
    Validate VM Cluster Placement Against EDS    ${VM_CLUSTER_ID}    ${TARGET_VXRAIL_CLUSTER}

    Log    ✅ Cluster placement validation: PASSED    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Cluster validated    console=yes

Critical - Step 3.2: Validate CPU Configuration Against EDS
    [Documentation]    ✅ Compare collected CPU allocation with EDS expected value
    ...                Step 3 of validation process: Validate Against EDS Standards (Part 2)
    [Tags]             critical    validation    step3    compliance    cpu    hardware

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE CPU CONFIGURATION AGAINST EDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    Log    📋 EDS Expected: ${TARGET_VM_CPU_CORES}    console=yes
    Log    🖥️ vCenter Actual: ${VM_CPU_COUNT}    console=yes

    # Validate against EDS
    Validate VM CPU Against EDS    ${VM_CPU_COUNT}    ${TARGET_VM_CPU_CORES}

    Log    ✅ CPU configuration validation: PASSED    console=yes
    Log    ✅ STEP 3.2: COMPLETED - CPU validated    console=yes

Critical - Step 3.3: Validate Memory Configuration Against EDS
    [Documentation]    ✅ Compare collected memory allocation with EDS expected value
    ...                Step 3 of validation process: Validate Against EDS Standards (Part 3)
    [Tags]             critical    validation    step3    compliance    memory    hardware

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE MEMORY CONFIGURATION AGAINST EDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    Log    📋 EDS Expected: ${TARGET_VM_RAM}    console=yes
    Log    🖥️ vCenter Actual: ${VM_MEMORY_GB} GB    console=yes

    # Validate against EDS
    Validate VM Memory Against EDS    ${VM_MEMORY_GB}    ${TARGET_VM_RAM}

    Log    ✅ Memory configuration validation: PASSED    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Memory validated    console=yes

Critical - Step 3.4: Validate Hardware Version Against EDS
    [Documentation]    ✅ Compare collected hardware version with EDS expected value
    ...                Step 3 of validation process: Validate Against EDS Standards (Part 4)
    [Tags]             critical    validation    step3    compliance    hardware    version

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: VALIDATE HARDWARE VERSION AGAINST EDS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    Log    📋 EDS Expected: ${TARGET_VM_HARDWARE_VERSION}    console=yes
    Log    🖥️ vCenter Actual: ${VM_HW_VERSION}    console=yes

    # Validate against EDS
    Validate VM Hardware Version Against EDS    ${VM_HW_VERSION}    ${TARGET_VM_HARDWARE_VERSION}

    Log    ✅ Hardware version validation: PASSED    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Hardware version validated    console=yes

Critical - Step 3.5: Validate Network Configuration
    [Documentation]    ✅ Validate collected network adapter configuration meets requirements
    ...                Step 3 of validation process: Validate Against Standards (Part 5)
    [Tags]             critical    validation    step3    compliance    network    adapters

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.5: VALIDATE NETWORK CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate network configuration
    Validate VM Network Configuration    ${VM_NETWORK_ADAPTERS}

    Log    ✅ Network adapter validation: PASSED    console=yes
    Log    ✅ STEP 3.5: COMPLETED - Network adapters validated    console=yes

Critical - Step 3.6: Validate Disk Configuration
    [Documentation]    ✅ Validate collected disk configuration meets requirements
    ...                Step 3 of validation process: Validate Against Standards (Part 6)
    [Tags]             critical    validation    step3    compliance    disk    storage

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.6: VALIDATE DISK CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate disk configuration
    Validate VM Disk Configuration    ${VM_DISK_CAPACITY}

    Log    ✅ Disk configuration validation: PASSED    console=yes
    Log    ✅ STEP 3.6: COMPLETED - Disk configuration validated    console=yes

Normal - VM Properties Comprehensive Review
    [Documentation]    📋 Review all VM properties and configuration details
    [Tags]             normal    analysis    review    properties

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📊 VM COMPREHENSIVE PROPERTIES REVIEW    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Log comprehensive VM configuration
    ${config}=    Get From Dictionary    ${VM_DETAILS}    configuration

    Log    📊 VM Configuration Summary:    console=yes
    Log    📊 - Name: ${config['name']}    console=yes
    Log    📊 - Power State: ${config['power_state']}    console=yes
    Log    📊 - CPU Count: ${config['cpu_count']}    console=yes
    Log    📊 - Cores per Socket: ${config['cores_per_socket']}    console=yes
    Log    📊 - Memory: ${config['memory_size_gb']} GB    console=yes
    Log    📊 - Hardware Version: ${config['hardware_version']}    console=yes
    Log    📊 - Guest OS: ${config['guest_os']}    console=yes

    Log    ℹ️ Comprehensive VM properties documented    console=yes
    Log    ✅ VM properties review: INFORMATIONAL    console=yes

*** Keywords ***
Generate VM Executive Summary And Disconnect
    [Documentation]    Generate executive summary and disconnect from vCenter

    Generate VM Executive Summary
    Disconnect From vCenter
*** Settings ***
Documentation    🤖 Ansible Playbook Validation Keywords for Test-24
...              📋 Provides Ansible Tower/AWX API connection and job validation capabilities
...
Library          SSHLibrary
Library          Collections
Library          String
Library          OperatingSystem
Library          DateTime
Library          RequestsLibrary
Library          JSONLibrary
Resource         ../../settings.resource

*** Variables ***
${DATA_DIR}                results/test24_ansible_playbook/data

# Suite-level variables for Ansible job data
${ANSIBLE_API_SESSION}     ${EMPTY}
${JOB_INFO}                ${EMPTY}
${JOB_STATUS}              ${EMPTY}

*** Keywords ***
Initialize Ansible Test Environment
    [Documentation]    🏗️ Set up test environment for Ansible playbook validation
    Log    🚀 Initializing Test-24: Ansible Playbook Validation Environment...    console=yes

    # Create directories for data collection
    Create Directory    ${DATA_DIR}

    # Lookup EDS configuration to get target IP
    ${eds_config}=    EDSLookup.Lookup Server Config    ${TARGET_HOSTNAME}
    Set Suite Variable    ${TARGET_IP}    ${eds_config['ip']}

    Log    📋 Target Server: ${TARGET_HOSTNAME}    console=yes
    Log    📋 Target IP: ${TARGET_IP}    console=yes

    # Establish SSH connection to target server
    Log    🔗 Connecting to target server: ${TARGET_IP}...    console=yes
    Open Connection    ${TARGET_IP}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}

    Log    ✅ SSH connection established successfully    console=yes

    # Initialize Ansible API session
    Log    🔗 Initializing Ansible Tower/AWX API session...    console=yes
    Initialize Ansible API Session

    Log    ✅ Test-24 environment initialized    console=yes

Initialize Ansible API Session
    [Documentation]    🔗 Create authenticated session with Ansible Tower/AWX API
    Log    🔗 Creating Ansible Tower/AWX API session...    console=yes

    # Create RequestsLibrary session with authentication
    ${auth}=    Create List    ${ANSIBLE_USERNAME}    ${ANSIBLE_PASSWORD}

    # Create session with basic auth and SSL verification settings
    Create Session    ansible
    ...    ${ANSIBLE_TOWER_URL}/api/v2
    ...    auth=${auth}
    ...    verify=${ANSIBLE_SSL_VERIFY}
    ...    disable_warnings=1

    Set Suite Variable    ${ANSIBLE_API_SESSION}    ansible

    Log    ✅ Ansible API session created    console=yes

Connect To Ansible Tower API
    [Documentation]    🔗 Test connectivity to Ansible Tower/AWX API
    Log    🔍 Testing Ansible Tower/AWX API connectivity...    console=yes

    # Test API connection by pinging the API endpoint
    ${response}=    GET On Session    ${ANSIBLE_API_SESSION}    /ping/
    ...    expected_status=200

    # Verify response
    ${status_code}=    Convert To Integer    ${response.status_code}
    ${api_connected}=    Evaluate    ${status_code} == 200

    Run Keyword If    ${api_connected}
    ...    Log    ✅ Ansible Tower/AWX API is reachable    console=yes
    ...    ELSE
    ...    Log    ❌ Failed to connect to Ansible Tower/AWX API    console=yes

    RETURN    ${api_connected}

Get Ansible Job Info
    [Documentation]    📋 Retrieve job information from Ansible Tower/AWX by job ID
    [Arguments]    ${job_id}
    Log    📋 Retrieving job information for Job ID: ${job_id}...    console=yes

    # Call the jobs API endpoint
    ${response}=    GET On Session    ${ANSIBLE_API_SESSION}    /jobs/${job_id}/
    ...    expected_status=200

    # Parse JSON response
    ${job_info}=    Set Variable    ${response.json()}

    Log    ✅ Job information retrieved for Job ID: ${job_id}    console=yes

    RETURN    ${job_info}

Get Ansible Job Status
    [Documentation]    📊 Retrieve detailed job status and execution details
    [Arguments]    ${job_id}
    Log    📊 Retrieving detailed job status for Job ID: ${job_id}...    console=yes

    # Get job details
    ${response}=    GET On Session    ${ANSIBLE_API_SESSION}    /jobs/${job_id}/
    ...    expected_status=200

    ${job_status}=    Set Variable    ${response.json()}

    # Extract key status fields
    ${status}=       Get From Dictionary    ${job_status}    status      default=unknown
    ${failed}=       Get From Dictionary    ${job_status}    failed      default=True
    ${finished}=     Get From Dictionary    ${job_status}    finished    default=${EMPTY}

    Log    📊 Job Status: ${status}    console=yes
    Log    📊 Failed: ${failed}    console=yes
    Log    📊 Finished: ${finished}    console=yes

    RETURN    ${job_status}

Get Ansible Job Task Summary
    [Documentation]    📊 Retrieve task summary for a specific job
    [Arguments]    ${job_id}
    Log    📊 Retrieving task summary for Job ID: ${job_id}...    console=yes

    # Get job details which includes task summary
    ${job_info}=    Get Ansible Job Info    ${job_id}

    # Extract task summary counts
    ${ok}=         Get From Dictionary    ${job_info}    ok         default=0
    ${changed}=    Get From Dictionary    ${job_info}    changed    default=0
    ${failures}=   Get From Dictionary    ${job_info}    failures   default=0
    ${skipped}=    Get From Dictionary    ${job_info}    skipped    default=0

    # Create summary dictionary
    ${task_summary}=    Create Dictionary
    ...    ok=${ok}
    ...    changed=${changed}
    ...    failures=${failures}
    ...    skipped=${skipped}

    Log    ✅ Task summary retrieved    console=yes

    RETURN    ${task_summary}

Get Ansible Tower Version
    [Documentation]    📋 Retrieve Ansible Tower/AWX version information
    Log    📋 Retrieving Ansible Tower/AWX version...    console=yes

    # Call the config API endpoint to get version info
    ${response}=    GET On Session    ${ANSIBLE_API_SESSION}    /config/
    ...    expected_status=200

    ${config}=    Set Variable    ${response.json()}

    # Extract version information
    ${version}=         Get From Dictionary    ${config}    version         default=unknown
    ${ansible_version}= Get From Dictionary    ${config}    ansible_version default=unknown

    ${version_info}=    Create Dictionary
    ...    version=${version}
    ...    ansible_version=${ansible_version}

    Log    ✅ Version information retrieved    console=yes

    RETURN    ${version_info}

Save Ansible Job Report
    [Documentation]    💾 Save complete Ansible job report to file for audit trail
    [Arguments]    ${job_id}    ${job_status}
    Log    💾 Saving Ansible job report to file...    console=yes

    # Generate timestamp for unique filename
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${report_file}=    Set Variable    ${DATA_DIR}/ansible_job_${job_id}_${timestamp}.txt

    # Extract job details
    ${status}=          Get From Dictionary    ${job_status}    status          default=unknown
    ${name}=            Get From Dictionary    ${job_status}    name            default=unknown
    ${playbook}=        Get From Dictionary    ${job_status}    playbook        default=unknown
    ${started}=         Get From Dictionary    ${job_status}    started         default=${EMPTY}
    ${finished}=        Get From Dictionary    ${job_status}    finished        default=${EMPTY}
    ${elapsed}=         Get From Dictionary    ${job_status}    elapsed         default=0
    ${failed}=          Get From Dictionary    ${job_status}    failed          default=True
    ${warnings}=        Get From Dictionary    ${job_status}    warnings        default=0
    ${skipped}=         Get From Dictionary    ${job_status}    skipped         default=0
    ${ok}=              Get From Dictionary    ${job_status}    ok              default=0
    ${changed}=         Get From Dictionary    ${job_status}    changed         default=0
    ${failures}=        Get From Dictionary    ${job_status}    failures        default=0
    ${job_template}=    Get From Dictionary    ${job_status}    job_template    default=unknown
    ${inventory}=       Get From Dictionary    ${job_status}    inventory       default=unknown

    # Build comprehensive job report
    ${job_report}=    Catenate    SEPARATOR=\n
    ...    =========================================
    ...    === Ansible Playbook Job Report ===
    ...    =========================================
    ...    Report Timestamp: ${timestamp}
    ...    Target Server: ${TARGET_HOSTNAME} (${TARGET_IP})
    ...
    ...    =========================================
    ...    === JOB IDENTIFICATION ===
    ...    =========================================
    ...    Job ID: ${job_id}
    ...    Job Name: ${name}
    ...    Job Template: ${job_template}
    ...    Playbook: ${playbook}
    ...    Inventory: ${inventory}
    ...
    ...    =========================================
    ...    === JOB STATUS ===
    ...    =========================================
    ...    Status: ${status}
    ...    Failed: ${failed}
    ...    Started: ${started}
    ...    Finished: ${finished}
    ...    Elapsed Time: ${elapsed} seconds
    ...
    ...    =========================================
    ...    === TASK SUMMARY ===
    ...    =========================================
    ...    Tasks OK: ${ok}
    ...    Tasks Changed: ${changed}
    ...    Tasks Failed: ${failures}
    ...    Tasks Skipped: ${skipped}
    ...    Warnings: ${warnings}
    ...
    ...    =========================================
    ...    === COMPLIANCE VALIDATION ===
    ...    =========================================
    ...    Job Status: ${status}
    ...    Expected: successful
    ...    Result: ${'PASS' if '${status}' == 'successful' else 'FAIL'}
    ...
    ...    Failed Flag: ${failed}
    ...    Expected: False
    ...    Result: ${'PASS' if ${failed} == ${False} else 'FAIL'}
    ...
    ...    Job Completed: ${finished}
    ...    Expected: Timestamp present
    ...    Result: ${'PASS' if '${finished}' != '' else 'FAIL'}
    ...
    ...    =========================================
    ...    === OVERALL COMPLIANCE ===
    ...    =========================================
    ...    Build Status: ${'COMPLIANT - Asset built with Ansible playbook successfully' if '${status}' == 'successful' and ${failed} == ${False} else 'NON-COMPLIANT - Issues detected'}
    ...
    ...    =========================================

    # Save report to file
    Create File    ${report_file}    ${job_report}

    Log    📄 Ansible job report saved to: ${report_file}    console=yes
    RETURN    ${report_file}

Close All SSH Connections
    [Documentation]    🔌 Close all SSH connections
    Log    🔌 Closing SSH connections...    console=yes
    Close All Connections
    Log    ✅ SSH connections closed    console=yes

Execute Command
    [Documentation]    🔧 Execute a command on the remote server via SSH
    [Arguments]    ${command}
    ${output}=    SSHLibrary.Execute Command    ${command}
    RETURN    ${output}

Get File Size
    [Documentation]    📏 Get size of a file in bytes
    [Arguments]    ${file_path}
    ${size}=    OperatingSystem.Get File Size    ${file_path}
    RETURN    ${size}

Log Test Start
    [Documentation]    📝 Log the start of a test case
    [Arguments]    ${test_name}
    Log    \n================================================================================    console=yes
    Log    🏁 Starting Test: ${test_name}    console=yes
    Log    ================================================================================    console=yes

Log Test End
    [Documentation]    📝 Log the end of a test case with status
    [Arguments]    ${test_name}    ${status}
    Log    ================================================================================    console=yes
    Log    🏁 Completed Test: ${test_name} | Status: ${status}    console=yes
    Log    ================================================================================\n    console=yes

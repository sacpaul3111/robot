*** Settings ***
Documentation    🤖 Ansible Playbook Validation Test Suite - Test-24
...              🔍 Process: Connect to Ansible Tower/AWX → Pull job status via API → Validate build compliance
...              ✅ Validates: Asset built with Ansible playbook successfully
...              📊 Verifies job completion, playbook details, and execution status
...
Resource         ../../settings.resource
Resource         ansible_keywords.resource
Resource         variables.resource
Library          ../../library/EDSLookup.py

Suite Setup      Initialize Ansible Test Environment
Suite Teardown   Close All SSH Connections

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to Target Server
    [Documentation]    🔗 Establish direct connection to target machine via SSH
    ...                Step 1 of validation process: Connect to Target
    [Tags]             critical    connection    step1    ssh    infrastructure

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO TARGET SERVER VIA SSH    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target: ${TARGET_HOSTNAME} (${TARGET_IP})    console=yes

    # Connection already established in Suite Setup
    ${connection_status}=    Execute Command    echo "Connection active"
    Should Contain    ${connection_status}    Connection active

    Log    ✅ SSH connection verified and active    console=yes
    Log    ✅ STEP 1: COMPLETED - SSH connection established    console=yes

Critical - Step 2.1: Connect to Ansible Tower/AWX API
    [Documentation]    🔗 Establish connection to Ansible Tower/AWX API endpoint
    ...                Step 2 of validation process: Collect Ansible Job Data (Part 1)
    [Tags]             critical    ansible    step2    data_collection    api

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: CONNECT TO ANSIBLE TOWER/AWX API    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Ansible Tower URL: ${ANSIBLE_TOWER_URL}    console=yes

    # Verify API connectivity
    ${api_status}=    Connect To Ansible Tower API
    Should Be True    ${api_status}    msg=Failed to connect to Ansible Tower/AWX API

    Log    ✅ Ansible Tower/AWX API connection successful    console=yes
    Log    ✅ STEP 2.1: COMPLETED - API connection established    console=yes

Critical - Step 2.2: Retrieve Job Information by Job ID
    [Documentation]    📋 Pull job details from Ansible Tower/AWX using specific job ID
    ...                Step 2 of validation process: Collect Ansible Job Data (Part 2)
    [Tags]             critical    ansible    step2    data_collection    job_retrieval

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: RETRIEVE JOB INFORMATION BY JOB ID    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Job ID: ${ANSIBLE_JOB_ID}    console=yes

    # Get job information from Ansible Tower/AWX
    ${job_info}=    Get Ansible Job Info    ${ANSIBLE_JOB_ID}

    # Verify job information was retrieved
    Should Not Be Empty    ${job_info}
    Dictionary Should Contain Key    ${job_info}    id
    Dictionary Should Contain Key    ${job_info}    status

    # Log job details
    ${job_name}=    Get From Dictionary    ${job_info}    name    default=Unknown
    ${job_status}=    Get From Dictionary    ${job_info}    status    default=Unknown

    Log    📋 Job ID: ${ANSIBLE_JOB_ID}    console=yes
    Log    📋 Job Name: ${job_name}    console=yes
    Log    📋 Job Status: ${job_status}    console=yes

    # Save job info for later tests
    Set Suite Variable    ${JOB_INFO}    ${job_info}

    Log    ✅ Job information retrieved successfully    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Job information retrieved    console=yes

Critical - Step 2.3: Query Job Status and Execution Details
    [Documentation]    📊 Query job status endpoint to retrieve execution status and playbook details
    ...                Step 2 of validation process: Collect Ansible Job Data (Part 3)
    [Tags]             critical    ansible    step2    data_collection    status

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: QUERY JOB STATUS AND EXECUTION DETAILS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get detailed job status
    ${job_status}=    Get Ansible Job Status    ${ANSIBLE_JOB_ID}

    # Verify status fields are present
    Dictionary Should Contain Key    ${job_status}    status
    Dictionary Should Contain Key    ${job_status}    finished
    Dictionary Should Contain Key    ${job_status}    playbook

    # Extract status details
    ${status}=           Get From Dictionary    ${job_status}    status         default=unknown
    ${finished}=         Get From Dictionary    ${job_status}    finished       default=${EMPTY}
    ${playbook}=         Get From Dictionary    ${job_status}    playbook       default=unknown
    ${failed}=           Get From Dictionary    ${job_status}    failed         default=False
    ${job_template}=     Get From Dictionary    ${job_status}    job_template   default=unknown

    Log    📊 Status: ${status}    console=yes
    Log    📊 Finished: ${finished}    console=yes
    Log    📊 Playbook: ${playbook}    console=yes
    Log    📊 Failed: ${failed}    console=yes
    Log    📊 Job Template: ${job_template}    console=yes

    # Save status for validation
    Set Suite Variable    ${JOB_STATUS}    ${job_status}

    Log    ✅ Job status and execution details retrieved    console=yes
    Log    ✅ STEP 2.3: COMPLETED - Job status retrieved    console=yes

Critical - Step 3.1: Validate Job Completed Successfully
    [Documentation]    ✅ Verify job completed successfully by checking status field
    ...                Step 3 of validation process: Validate Against Standards (Part 1)
    [Tags]             critical    ansible    step3    validation    compliance

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE JOB COMPLETED SUCCESSFULLY    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get job status
    ${status}=    Get From Dictionary    ${JOB_STATUS}    status    default=unknown

    Log    📊 Job Status: ${status}    console=yes

    # Validate job completed successfully
    Should Be Equal As Strings    ${status}    successful
    ...    msg=Job did not complete successfully. Status: ${status}

    Log    ✅ Job completed successfully    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Job completion validated    console=yes

Critical - Step 3.2: Validate No Job Failures
    [Documentation]    ✅ Verify playbook executed without failures
    ...                Step 3 of validation process: Validate Against Standards (Part 2)
    [Tags]             critical    ansible    step3    validation    failures

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE NO JOB FAILURES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Check failed flag
    ${failed}=    Get From Dictionary    ${JOB_STATUS}    failed    default=True

    # Should be False (no failures)
    Should Be Equal    ${failed}    ${False}
    ...    msg=Job has failures: ${failed}

    Log    ✅ No job failures detected    console=yes
    Log    ✅ STEP 3.2: COMPLETED - No failures validated    console=yes

Critical - Step 3.3: Review Warnings and Skipped Tasks
    [Documentation]    📋 Review any warnings or skipped tasks in the job execution
    ...                Step 3 of validation process: Validate Against Standards (Part 3)
    [Tags]             critical    ansible    step3    validation    warnings

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: REVIEW WARNINGS AND SKIPPED TASKS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get warnings and skipped counts
    ${warnings}=    Get From Dictionary    ${JOB_STATUS}    warnings    default=0
    ${skipped}=     Get From Dictionary    ${JOB_STATUS}    skipped     default=0

    Log    📊 Warnings: ${warnings}    console=yes
    Log    📊 Skipped Tasks: ${skipped}    console=yes

    # If warnings exist, log them for review
    Run Keyword If    ${warnings} > 0
    ...    Log    ⚠️ Job has ${warnings} warning(s) - review recommended    console=yes
    ...    ELSE
    ...    Log    ✅ No warnings detected    console=yes

    # If tasks were skipped, log for review
    Run Keyword If    ${skipped} > 0
    ...    Log    ℹ️ Job has ${skipped} skipped task(s) - review recommended    console=yes
    ...    ELSE
    ...    Log    ✅ No skipped tasks    console=yes

    Log    ✅ Warnings and skipped tasks review completed    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Warnings and skipped tasks reviewed    console=yes

Critical - Step 3.4: Confirm Playbook Executed Without Failures
    [Documentation]    ✅ Final validation that playbook executed without failures
    ...                Step 3 of validation process: Validate Against Standards (Part 4)
    [Tags]             critical    ansible    step3    validation    compliance

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: CONFIRM PLAYBOOK EXECUTED WITHOUT FAILURES    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Get comprehensive job results
    ${status}=      Get From Dictionary    ${JOB_STATUS}    status      default=unknown
    ${failed}=      Get From Dictionary    ${JOB_STATUS}    failed      default=True
    ${finished}=    Get From Dictionary    ${JOB_STATUS}    finished    default=${EMPTY}

    Log    📊 Final Status: ${status}    console=yes
    Log    📊 Failed Flag: ${failed}    console=yes
    Log    📊 Finished Timestamp: ${finished}    console=yes

    # All conditions must pass for compliance
    Should Be Equal As Strings    ${status}    successful    msg=Job status is not 'successful'
    Should Be Equal               ${failed}    ${False}      msg=Job has failed flag set to True
    Should Not Be Empty           ${finished}               msg=Job has not finished

    Log    ✅ COMPLIANCE VALIDATED: Playbook executed successfully without failures    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Playbook execution validated    console=yes

Normal - Document Complete Job Details
    [Documentation]    📄 Save complete job information to file for audit trail
    [Tags]             normal    documentation    audit    compliance

    Log    🔍 Documenting complete job details...    console=yes

    # Save comprehensive job report
    ${report_file}=    Save Ansible Job Report    ${ANSIBLE_JOB_ID}    ${JOB_STATUS}

    # Verify file was created
    File Should Exist    ${report_file}
    ${file_size}=    Get File Size    ${report_file}
    Should Be True    ${file_size} > 0

    Log    📄 Job report saved to: ${report_file}    console=yes
    Log    📄 File size: ${file_size} bytes    console=yes
    Log    ✅ Job documentation completed    console=yes

Normal - Playbook Task Details Analysis
    [Documentation]    📊 Analyze individual playbook tasks and their execution
    [Tags]             normal    analysis    tasks    playbook

    Log    🔍 Analyzing playbook task execution details...    console=yes

    # Get task summary from job
    ${task_summary}=    Get Ansible Job Task Summary    ${ANSIBLE_JOB_ID}

    # Extract task counts
    ${ok_count}=        Get From Dictionary    ${task_summary}    ok        default=0
    ${changed_count}=   Get From Dictionary    ${task_summary}    changed   default=0
    ${failed_count}=    Get From Dictionary    ${task_summary}    failures  default=0
    ${skipped_count}=   Get From Dictionary    ${task_summary}    skipped   default=0

    Log    📊 Tasks OK: ${ok_count}    console=yes
    Log    📊 Tasks Changed: ${changed_count}    console=yes
    Log    📊 Tasks Failed: ${failed_count}    console=yes
    Log    📊 Tasks Skipped: ${skipped_count}    console=yes

    Log    ℹ️ Playbook task analysis completed    console=yes
    Log    ✅ Task details analysis: INFORMATIONAL    console=yes

Normal - Job Execution Time Analysis
    [Documentation]    ⏱️ Analyze job execution time and performance metrics
    [Tags]             normal    performance    timing    analysis

    Log    🔍 Analyzing job execution time...    console=yes

    # Get timing information
    ${started}=     Get From Dictionary    ${JOB_STATUS}    started     default=${EMPTY}
    ${finished}=    Get From Dictionary    ${JOB_STATUS}    finished    default=${EMPTY}
    ${elapsed}=     Get From Dictionary    ${JOB_STATUS}    elapsed     default=0

    Log    ⏱️ Started: ${started}    console=yes
    Log    ⏱️ Finished: ${finished}    console=yes
    Log    ⏱️ Elapsed Time: ${elapsed} seconds    console=yes

    # Performance assessment
    Run Keyword If    ${elapsed} < 300
    ...    Log    ✅ Good performance: Job completed in under 5 minutes    console=yes
    ...    ELSE IF    ${elapsed} < 900
    ...    Log    ℹ️ Moderate performance: Job completed in under 15 minutes    console=yes
    ...    ELSE
    ...    Log    ⚠️ Slow performance: Job took over 15 minutes    console=yes

    Log    ℹ️ Job execution time analysis completed    console=yes
    Log    ✅ Execution time analysis: INFORMATIONAL    console=yes

Normal - Ansible Tower/AWX Version Information
    [Documentation]    📋 Retrieve and document Ansible Tower/AWX version information
    [Tags]             normal    informational    version    ansible

    Log    🔍 Retrieving Ansible Tower/AWX version information...    console=yes

    # Get version information from API
    ${version_info}=    Get Ansible Tower Version

    # Extract version details
    ${version}=         Get From Dictionary    ${version_info}    version         default=unknown
    ${ansible_version}= Get From Dictionary    ${version_info}    ansible_version default=unknown

    Log    📋 Ansible Tower/AWX Version: ${version}    console=yes
    Log    📋 Ansible Engine Version: ${ansible_version}    console=yes

    Log    ℹ️ Version information retrieved    console=yes
    Log    ✅ Version information: INFORMATIONAL    console=yes

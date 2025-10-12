*** Settings ***
Documentation    💾 Backup Configuration Validation Test Suite - Test-15
...              🔍 Process: Connect to vCenter API → Collect Backup Configuration → Validate Backup Compliance
...              ✅ Pass if backup configuration meets data criticality requirements and compliance standards
...              📊 Validates: Backup policies, schedules, retention, job status, offsite replication
...
Resource         ../../settings.resource
Resource         backup_keywords.resource
Resource         variables.resource

Suite Setup      Initialize Backup Validation Test Environment
Suite Teardown   Generate Backup Validation Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Step 1: Connect to vCenter API
    [Documentation]    🔗 Establish API connection to VMware vCenter to query VM backup policy configuration and status
    ...                Step 1 of validation process: Connect to vCenter API
    [Tags]             critical    connection    step1    vcenter_api    infrastructure

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 1: CONNECT TO VCENTER API    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 vCenter Server: ${VCENTER_SERVER}    console=yes
    Log    📋 API Endpoint: ${VCENTER_API_ENDPOINT}    console=yes

    # Establish vCenter API connection
    Connect To vCenter API

    # Verify API connection is active
    ${connection_status}=    Verify vCenter API Connection
    Should Be True    ${connection_status}    msg=Failed to establish vCenter API connection

    Log    ✅ vCenter API connection established    console=yes
    Log    ✅ STEP 1: COMPLETED - Connected to vCenter API    console=yes

Critical - Step 2.1: Collect Backup Policy Details
    [Documentation]    📊 Retrieve VM backup policy details via vCenter REST API
    ...                Step 2 of validation process: Collect Backup Configuration Data (Part 1)
    [Tags]             critical    backup_collection    step2    data_collection    api

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.1: COLLECT BACKUP POLICY DETAILS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Target VMs: ${TARGET_VMS}    console=yes

    # Collect backup policy details
    Log    📊 Retrieving VM backup policy details...    console=yes
    ${policy_data}=    Collect Backup Policy Configuration
    Set Suite Variable    ${POLICY_DATA}    ${policy_data}
    ${vm_count}=    Get Length    ${policy_data}
    Should Be True    ${vm_count} > 0    msg=No backup policies found for target VMs
    FOR    ${policy}    IN    @{policy_data}
        Log    📊 VM: ${policy['vm_name']} - Policy: ${policy['policy_name']}    console=yes
    END
    Log    ✅ Backup policy details collected for ${vm_count} VMs    console=yes
    Log    ✅ STEP 2.1: COMPLETED - Backup policy details collected    console=yes

Critical - Step 2.2: Collect Backup Schedule Settings
    [Documentation]    📊 Retrieve backup schedule settings via vCenter REST API
    ...                Step 2 of validation process: Collect Backup Configuration Data (Part 2)
    [Tags]             critical    backup_collection    step2    data_collection    schedule

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.2: COLLECT BACKUP SCHEDULE SETTINGS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect schedule settings
    Log    📊 Retrieving backup schedule settings...    console=yes
    ${schedule_data}=    Collect Backup Schedule Settings
    Set Suite Variable    ${SCHEDULE_DATA}    ${schedule_data}
    ${schedule_count}=    Get Length    ${schedule_data}
    Should Be True    ${schedule_count} > 0    msg=No backup schedules found
    FOR    ${schedule}    IN    @{schedule_data}
        Log    📊 VM: ${schedule['vm_name']} - Frequency: ${schedule['frequency']}, RPO: ${schedule['rpo_hours']}h    console=yes
    END
    Log    ✅ Schedule settings collected for ${schedule_count} VMs    console=yes
    Log    ✅ STEP 2.2: COMPLETED - Schedule settings collected    console=yes

Critical - Step 2.3: Collect Recent Backup Job Status
    [Documentation]    📊 Retrieve recent backup job status via vCenter REST API
    ...                Step 2 of validation process: Collect Backup Configuration Data (Part 3)
    [Tags]             critical    backup_collection    step2    data_collection    job_status

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.3: COLLECT RECENT BACKUP JOB STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect recent job status
    Log    📊 Retrieving recent backup job status...    console=yes
    Log    📋 Looking back ${BACKUP_LOOKBACK_DAYS} days    console=yes
    ${job_status}=    Collect Recent Backup Job Status
    Set Suite Variable    ${JOB_STATUS}    ${job_status}
    ${job_count}=    Get Length    ${job_status}
    Should Be True    ${job_count} > 0    msg=No recent backup jobs found
    FOR    ${job}    IN    @{job_status}
        Log    📊 VM: ${job['vm_name']} - Status: ${job['status']}, Completion: ${job['end_time']}    console=yes
    END
    Log    ✅ Recent job status collected: ${job_count} jobs    console=yes
    Log    ✅ STEP 2.3: COMPLETED - Recent job status collected    console=yes

Critical - Step 2.4: Collect Retention Policy Settings
    [Documentation]    📊 Retrieve retention policy settings via vCenter REST API
    ...                Step 2 of validation process: Collect Backup Configuration Data (Part 4)
    [Tags]             critical    backup_collection    step2    data_collection    retention

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.4: COLLECT RETENTION POLICY SETTINGS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect retention policies
    Log    📊 Retrieving retention policy settings...    console=yes
    ${retention_data}=    Collect Retention Policy Settings
    Set Suite Variable    ${RETENTION_DATA}    ${retention_data}
    ${retention_count}=    Get Length    ${retention_data}
    Should Be True    ${retention_count} > 0    msg=No retention policies found
    FOR    ${retention}    IN    @{retention_data}
        Log    📊 VM: ${retention['vm_name']} - Daily: ${retention['daily_retention']}d, Weekly: ${retention['weekly_retention']}w    console=yes
    END
    Log    ✅ Retention policies collected for ${retention_count} VMs    console=yes
    Log    ✅ STEP 2.4: COMPLETED - Retention policy settings collected    console=yes

Critical - Step 2.5: Collect Latest Backup Timestamps
    [Documentation]    📊 Retrieve latest backup timestamps via vCenter REST API
    ...                Step 2 of validation process: Collect Backup Configuration Data (Part 5)
    [Tags]             critical    backup_collection    step2    data_collection    timestamps

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.5: COLLECT LATEST BACKUP TIMESTAMPS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect latest backup timestamps
    Log    📊 Retrieving latest backup timestamps...    console=yes
    ${timestamp_data}=    Collect Latest Backup Timestamps
    Set Suite Variable    ${TIMESTAMP_DATA}    ${timestamp_data}
    ${timestamp_count}=    Get Length    ${timestamp_data}
    Should Be True    ${timestamp_count} > 0    msg=No backup timestamps found
    FOR    ${timestamp}    IN    @{timestamp_data}
        Log    📊 VM: ${timestamp['vm_name']} - Last Backup: ${timestamp['last_backup_time']}    console=yes
    END
    Log    ✅ Latest timestamps collected for ${timestamp_count} VMs    console=yes
    Log    ✅ STEP 2.5: COMPLETED - Latest backup timestamps collected    console=yes

Critical - Step 2.6: Collect Offsite Replication Status
    [Documentation]    📊 Retrieve offsite replication status via vCenter REST API
    ...                Step 2 of validation process: Collect Backup Configuration Data (Part 6)
    [Tags]             critical    backup_collection    step2    data_collection    replication

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 2.6: COLLECT OFFSITE REPLICATION STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Collect offsite replication status
    Log    📊 Retrieving offsite replication status...    console=yes
    ${replication_data}=    Collect Offsite Replication Status
    Set Suite Variable    ${REPLICATION_DATA}    ${replication_data}
    ${replication_count}=    Get Length    ${replication_data}
    Should Be True    ${replication_count} > 0    msg=No offsite replication data found
    FOR    ${replication}    IN    @{replication_data}
        Log    📊 VM: ${replication['vm_name']} - Enabled: ${replication['offsite_enabled']}, Target: ${replication['offsite_target']}    console=yes
    END
    Log    ✅ Offsite replication status collected for ${replication_count} VMs    console=yes
    Log    ✅ STEP 2.6: COMPLETED - Offsite replication status collected    console=yes

Critical - Step 3.1: Validate Backup Policy Applied
    [Documentation]    ✅ Validate that backup policies are properly applied to all VMs
    ...                Step 3 of validation process: Validate Against Compliance Standards (Part 1)
    [Tags]             critical    validation    step3    compliance    policy

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.1: VALIDATE BACKUP POLICY APPLIED    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    📋 Validating against data criticality requirements    console=yes

    # Validate backup policy applied
    Log    🔍 Validating backup policy application...    console=yes
    ${policy_results}=    Validate Backup Policy Applied    ${POLICY_DATA}
    ${violations}=    Get From Dictionary    ${policy_results}    violations
    ${violation_count}=    Get Length    ${violations}
    Log    📊 Policy validation: ${violation_count} violations found    console=yes
    IF    ${violation_count} > 0
        FOR    ${violation}    IN    @{violations}
            Log    ⚠️ Violation: VM ${violation['vm_name']} - ${violation['reason']}    console=yes
        END
        Fail    Backup policy validation failed: ${violation_count} VMs without proper policies
    END
    Log    ✅ Applied policy validated    console=yes
    Log    ✅ STEP 3.1: COMPLETED - Backup policy validated    console=yes

Critical - Step 3.2: Validate Schedule Alignment With RPO
    [Documentation]    ✅ Validate that backup schedules align with RPO requirements
    ...                Step 3 of validation process: Validate Against Compliance Standards (Part 2)
    [Tags]             critical    validation    step3    compliance    rpo

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.2: VALIDATE SCHEDULE ALIGNMENT WITH RPO    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate schedule alignment with RPO
    Log    🔍 Validating backup schedule alignment with RPO requirements...    console=yes
    ${schedule_results}=    Validate Schedule Alignment With RPO    ${SCHEDULE_DATA}
    ${rpo_violations}=    Get From Dictionary    ${schedule_results}    rpo_violations
    ${rpo_violation_count}=    Get Length    ${rpo_violations}
    Log    📊 RPO validation: ${rpo_violation_count} violations found    console=yes
    IF    ${rpo_violation_count} > 0
        FOR    ${violation}    IN    @{rpo_violations}
            Log    ⚠️ RPO Violation: VM ${violation['vm_name']} - Current: ${violation['current_rpo']}h, Required: ${violation['required_rpo']}h    console=yes
        END
        Fail    RPO validation failed: ${rpo_violation_count} VMs exceed RPO requirements
    END
    Log    ✅ Schedule alignment with RPO validated    console=yes
    Log    ✅ STEP 3.2: COMPLETED - RPO alignment validated    console=yes

Critical - Step 3.3: Validate Retention Settings Compliance
    [Documentation]    ✅ Validate that retention settings meet compliance requirements
    ...                Step 3 of validation process: Validate Against Compliance Standards (Part 3)
    [Tags]             critical    validation    step3    compliance    retention

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.3: VALIDATE RETENTION SETTINGS COMPLIANCE    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate retention settings
    Log    🔍 Validating retention settings compliance...    console=yes
    Log    📋 Minimum daily retention: ${MIN_DAILY_RETENTION} days    console=yes
    Log    📋 Minimum weekly retention: ${MIN_WEEKLY_RETENTION} weeks    console=yes
    ${retention_results}=    Validate Retention Settings Compliance    ${RETENTION_DATA}
    ${retention_violations}=    Get From Dictionary    ${retention_results}    violations
    ${retention_violation_count}=    Get Length    ${retention_violations}
    Log    📊 Retention validation: ${retention_violation_count} violations found    console=yes
    IF    ${retention_violation_count} > 0
        FOR    ${violation}    IN    @{retention_violations}
            Log    ⚠️ Retention Violation: VM ${violation['vm_name']} - ${violation['reason']}    console=yes
        END
        Fail    Retention validation failed: ${retention_violation_count} VMs with insufficient retention
    END
    Log    ✅ Retention settings validated    console=yes
    Log    ✅ STEP 3.3: COMPLETED - Retention settings validated    console=yes

Critical - Step 3.4: Validate Recent Job Completion Status
    [Documentation]    ✅ Validate that recent backup jobs completed successfully
    ...                Step 3 of validation process: Validate Against Compliance Standards (Part 4)
    [Tags]             critical    validation    step3    compliance    job_status

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.4: VALIDATE RECENT JOB COMPLETION STATUS    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate job completion status
    Log    🔍 Validating recent backup job completion status...    console=yes
    ${job_results}=    Validate Recent Job Completion Status    ${JOB_STATUS}
    ${failed_jobs}=    Get From Dictionary    ${job_results}    failed_jobs
    ${failed_count}=    Get Length    ${failed_jobs}
    Log    📊 Job validation: ${failed_count} failed jobs found    console=yes
    IF    ${failed_count} > 0
        FOR    ${failed}    IN    @{failed_jobs}
            Log    ⚠️ Failed Job: VM ${failed['vm_name']} - Status: ${failed['status']}, Error: ${failed['error_message']}    console=yes
        END
        Fail    Job validation failed: ${failed_count} backup jobs failed
    END
    Log    ✅ Job completion status validated    console=yes
    Log    ✅ STEP 3.4: COMPLETED - Job completion validated    console=yes

Critical - Step 3.5: Validate Backup Recency
    [Documentation]    ✅ Validate that backups are recent and not stale
    ...                Step 3 of validation process: Validate Against Compliance Standards (Part 5)
    [Tags]             critical    validation    step3    compliance    recency

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.5: VALIDATE BACKUP RECENCY    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate backup recency
    Log    🔍 Validating backup recency...    console=yes
    Log    📋 Maximum backup age: ${MAX_BACKUP_AGE_HOURS} hours    console=yes
    ${recency_results}=    Validate Backup Recency    ${TIMESTAMP_DATA}
    ${stale_backups}=    Get From Dictionary    ${recency_results}    stale_backups
    ${stale_count}=    Get Length    ${stale_backups}
    Log    📊 Recency validation: ${stale_count} stale backups found    console=yes
    IF    ${stale_count} > 0
        FOR    ${stale}    IN    @{stale_backups}
            Log    ⚠️ Stale Backup: VM ${stale['vm_name']} - Last backup: ${stale['last_backup_time']}, Age: ${stale['age_hours']}h    console=yes
        END
        Fail    Recency validation failed: ${stale_count} VMs have stale backups
    END
    Log    ✅ Backup recency validated    console=yes
    Log    ✅ STEP 3.5: COMPLETED - Backup recency validated    console=yes

Critical - Step 3.6: Validate Offsite Replication Configuration
    [Documentation]    ✅ Validate that offsite replication is properly configured
    ...                Step 3 of validation process: Validate Against Compliance Standards (Part 6)
    [Tags]             critical    validation    step3    compliance    offsite

    Log    ════════════════════════════════════════════════════════════    console=yes
    Log    🔍 STEP 3.6: VALIDATE OFFSITE REPLICATION CONFIGURATION    console=yes
    Log    ════════════════════════════════════════════════════════════    console=yes

    # Validate offsite replication
    Log    🔍 Validating offsite replication configuration...    console=yes
    ${replication_results}=    Validate Offsite Replication Configuration    ${REPLICATION_DATA}
    ${offsite_violations}=    Get From Dictionary    ${replication_results}    violations
    ${offsite_violation_count}=    Get Length    ${offsite_violations}
    Log    📊 Offsite validation: ${offsite_violation_count} violations found    console=yes
    IF    ${offsite_violation_count} > 0
        FOR    ${violation}    IN    @{offsite_violations}
            Log    ⚠️ Offsite Violation: VM ${violation['vm_name']} - ${violation['reason']}    console=yes
        END
        Fail    Offsite replication validation failed: ${offsite_violation_count} VMs missing offsite protection
    END
    Log    ✅ Offsite replication validated    console=yes

    Log    📊 Backup compliance validation summary:    console=yes
    Log    📊 - Applied policy: ✅    console=yes
    Log    📊 - Schedule alignment with RPO: ✅    console=yes
    Log    📊 - Retention settings: ✅    console=yes
    Log    📊 - Job completion status: ✅    console=yes
    Log    📊 - Backup recency: ✅    console=yes
    Log    📊 - Offsite replication: ✅    console=yes
    Log    ✅ Backup compliance validation: PASSED    console=yes
    Log    ✅ STEP 3.6: COMPLETED - Offsite replication validated    console=yes
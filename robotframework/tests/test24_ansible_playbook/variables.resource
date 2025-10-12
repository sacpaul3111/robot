*** Settings ***
Documentation    🤖 Test-24 Variables: Ansible Playbook Validation
...              📋 Contains all variables specific to Ansible playbook validation testing

*** Variables ***
# 🎯 Test Suite Configuration
${TEST_SUITE_NAME}        Test-24 Ansible Playbook Validation
${TEST_SUITE_ID}          test24
${TEST_DESCRIPTION}       Validate asset built with Ansible playbook successfully

# 📁 Directory Paths
${TEST24_RESULTS_DIR}     results/test24_ansible_playbook
${TEST24_DATA_DIR}        results/test24_ansible_playbook/data

# 🏷️ Test Tags
@{CRITICAL_TAGS}          critical    ansible    compliance    api
@{NORMAL_TAGS}           normal      informational    analysis
@{ANSIBLE_TAGS}          playbook    job    tower    awx

# 🤖 Ansible Tower/AWX Configuration
${ANSIBLE_TOWER_URL}      # Set via command line --variable ANSIBLE_TOWER_URL:https://tower.example.com
${ANSIBLE_USERNAME}       admin
${ANSIBLE_PASSWORD}       # Set via command line --variable ANSIBLE_PASSWORD:password
${ANSIBLE_SSL_VERIFY}     ${False}    # Set to ${True} if using valid SSL certificates
${ANSIBLE_JOB_ID}         # Set via command line --variable ANSIBLE_JOB_ID:12345

# 📊 Ansible API Endpoints
${ANSIBLE_API_VERSION}    v2
${ENDPOINT_PING}          /api/${ANSIBLE_API_VERSION}/ping/
${ENDPOINT_JOBS}          /api/${ANSIBLE_API_VERSION}/jobs/
${ENDPOINT_CONFIG}        /api/${ANSIBLE_API_VERSION}/config/
${ENDPOINT_JOB_TEMPLATES} /api/${ANSIBLE_API_VERSION}/job_templates/
${ENDPOINT_INVENTORIES}   /api/${ANSIBLE_API_VERSION}/inventories/

# ✅ Job Status Values (Expected)
${EXPECTED_STATUS_SUCCESS}    successful
${EXPECTED_FAILED_FLAG}       ${False}
@{VALID_JOB_STATUSES}
...    successful
...    failed
...    running
...    pending
...    canceled

# ⚠️ Warning Thresholds
${MAX_ACCEPTABLE_WARNINGS}    5
${MAX_ACCEPTABLE_SKIPPED}     10
${MAX_EXECUTION_TIME}         3600    # 1 hour in seconds

# 📋 Required Job Fields
@{REQUIRED_JOB_FIELDS}
...    id
...    name
...    status
...    failed
...    started
...    finished
...    elapsed
...    playbook
...    job_template
...    inventory

# 📋 Task Summary Fields
@{TASK_SUMMARY_FIELDS}
...    ok
...    changed
...    failures
...    skipped

# 📄 Report File Templates
${JOB_REPORT_TEMPLATE}=           ansible_job_%s_%s.txt
${JOB_STDOUT_TEMPLATE}=           ansible_job_stdout_%s_%s.txt
${TASK_DETAILS_TEMPLATE}=         ansible_task_details_%s_%s.txt
${EXEC_SUMMARY_TEMPLATE}=         Test24_Ansible_Executive_Summary.txt

# 🎨 Console Output Formatting
${LOG_PREFIX_ANSIBLE}     🤖 Ansible
${LOG_PREFIX_JOB}         📋 Job
${LOG_PREFIX_API}         🔗 API
${LOG_PREFIX_SUCCESS}     ✅ SUCCESS
${LOG_PREFIX_FAILED}      ❌ FAILED
${LOG_PREFIX_VALIDATION}  🔍 Validating
${LOG_PREFIX_PASSED}      ✅ PASSED
${LOG_PREFIX_WARNING}     ⚠️ WARNING
${LOG_PREFIX_INFO}        ℹ️ INFO

# 🔐 SSH Connection Settings (inherited from EDS lookup)
${SSH_USERNAME}           root
${SSH_PASSWORD}           password
${SSH_TIMEOUT}            30

# 🎯 Target Server Configuration (from EDS)
${TARGET_HOSTNAME}        # Set via command line --variable TARGET_HOSTNAME:value
${TARGET_IP}              ${EMPTY}    # Will be populated from EDS lookup

# 📊 API Request Configuration
${API_TIMEOUT}            30
${API_MAX_RETRIES}        3
${API_RETRY_DELAY}        5

# 🔍 Validation Configuration
${VALIDATE_SSL}           ${False}
${VERIFY_CERTIFICATE}     ${False}
${ALLOW_REDIRECTS}        ${True}

# 📈 Performance Thresholds
${PERFORMANCE_GOOD}       300     # Under 5 minutes
${PERFORMANCE_MODERATE}   900     # Under 15 minutes
${PERFORMANCE_SLOW}       1800    # Over 30 minutes

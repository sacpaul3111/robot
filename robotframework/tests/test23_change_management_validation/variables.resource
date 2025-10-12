*** Settings ***
Documentation    Change Management Validation Variables - Test-23

*** Variables ***
# Target Configuration - Set via command line
${TARGET_HOSTNAME}           # Set via command line --variable TARGET_HOSTNAME:value

# SSH Connection Settings - Provided via Ansible/command line
${SSH_USERNAME}            ${EMPTY}
${SSH_PASSWORD}            ${EMPTY}
${SSH_TIMEOUT}             30 seconds

# CRQ System Configuration
${CRQ_SYSTEM_URL}          https://servicenow.company.com    # ServiceNow instance URL
${CRQ_USERNAME}            ${EMPTY}                          # CRQ username (to be configured)
${CRQ_PASSWORD}            ${EMPTY}                          # CRQ password (to be configured)
${CRQ_TIMEOUT}             60 seconds                        # CRQ system connection timeout

# Change Request Information
${CHANGE_REQUEST_NUMBER}   ${EMPTY}    # CRQ number (e.g., CHG0012345)
${CHANGE_FORM_ID}          ${EMPTY}    # Asset change form ID
${PROJECT_NAME}            ${EMPTY}    # Project name for this build
${BUILD_REQUEST_ID}        ${EMPTY}    # Build request identifier

# ServiceNow/Asset Management Platform
${ASSET_MGMT_URL}          https://assetmgmt.company.com     # Asset management platform URL
${ASSET_MGMT_USERNAME}     ${EMPTY}                          # Asset management username
${ASSET_MGMT_PASSWORD}     ${EMPTY}                          # Asset management password
${ASSET_MGMT_TIMEOUT}      60 seconds                        # Asset management timeout

# Access Method
${ACCESS_METHOD}           Citrix    # Access method: Citrix, Jumpbox, Direct

# CIP-010 R1 Requirements - Configuration Change Management
# R1: Each Responsible Entity shall implement a process to monitor for,
#     and alert upon, unauthorized changes to BES Cyber Assets

# Change Management Required Approvals
@{REQUIRED_APPROVALS}
...    Change_Manager
...    Security_Team
...    Operations_Team
...    Project_Manager
...    Technical_Lead

# Change Form Required Fields
@{REQUIRED_CHANGE_FIELDS}
...    Change_Number
...    Change_Type
...    Risk_Assessment
...    Implementation_Plan
...    Backout_Plan
...    Testing_Results
...    Approver_Signatures
...    Implementation_Date
...    Completion_Status

# CRQ Task Categories
@{CRQ_TASK_CATEGORIES}
...    Planning
...    Implementation
...    Testing
...    Documentation
...    Approval
...    Closure

# Required CRQ Tasks
@{REQUIRED_CRQ_TASKS}
...    Change_Planning_Complete
...    Security_Review_Complete
...    Implementation_Complete
...    Testing_Validation_Complete
...    Documentation_Archive_Complete
...    Operations_Handoff_Complete

# Task Completion Status
${TASK_STATUS_COMPLETE}    Closed Complete    # Expected status for completed tasks
${TASK_STATUS_APPROVED}    Approved           # Expected status for approved tasks

# Change Form Validation Requirements
${FORM_MUST_BE_APPROVED}      ${TRUE}    # Change form must be approved
${ALL_FIELDS_MUST_POPULATE}   ${TRUE}    # All mandatory fields must be populated
${RISK_ASSESSMENT_REQUIRED}   ${TRUE}    # Risk assessment must be documented
${BACKOUT_PLAN_REQUIRED}      ${TRUE}    # Backout plan must be documented

# CRQ Closure Requirements
${CRQ_MUST_BE_CLOSED}         ${TRUE}    # CRQ must be in closed status
${ALL_TASKS_MUST_COMPLETE}    ${TRUE}    # All tasks must be completed
${HANDOFF_MUST_COMPLETE}      ${TRUE}    # Handoff to operations must be complete
${DOCUMENTATION_ARCHIVED}     ${TRUE}    # All documentation must be archived

# Documentation Requirements
@{REQUIRED_DOCUMENTATION}
...    Build_Request_Form
...    Change_Request_Form
...    Implementation_Plan
...    Test_Results
...    Configuration_Baseline
...    As-Built_Documentation
...    Handoff_Checklist
...    Sign-Off_Approvals

# Handoff Package Requirements
@{HANDOFF_PACKAGE_ITEMS}
...    System_Configuration_Details
...    Network_Diagram
...    Access_Credentials_Location
...    Monitoring_Setup_Details
...    Backup_Configuration
...    Support_Contacts
...    Troubleshooting_Guide
...    Operational_Procedures

# Change Types
@{VALID_CHANGE_TYPES}
...    Standard
...    Normal
...    Emergency
...    Expedited

# Risk Levels
@{VALID_RISK_LEVELS}
...    Low
...    Medium
...    High
...    Critical

# Change States
@{VALID_CHANGE_STATES}
...    Draft
...    Pending_Approval
...    Approved
...    Scheduled
...    In_Progress
...    Complete
...    Closed

# Testing Validation Requirements
${TESTING_MUST_PASS}          ${TRUE}     # All testing must pass
${TESTING_RESULTS_REQUIRED}   ${TRUE}     # Testing results must be documented
${MIN_TEST_CASES_PASSED}      1           # Minimum test cases that must pass

# Approval Validation
${MIN_APPROVERS_REQUIRED}     2           # Minimum number of approvers required
${SECURITY_APPROVAL_REQUIRED} ${TRUE}     # Security team approval required
${OPS_APPROVAL_REQUIRED}      ${TRUE}     # Operations team approval required

# Timeline Requirements
${MAX_DAYS_OPEN}              90          # Maximum days CRQ can be open
${HANDOFF_WITHIN_DAYS}        7           # Handoff must occur within N days of completion

# Archive and Retention
${ARCHIVE_REQUIRED}           ${TRUE}     # Documentation archival required
${RETENTION_DAYS}             2555        # 7 years retention (CIP requirement)
${ARCHIVE_LOCATION}           ${EMPTY}    # Archive location path

# Notification Requirements
@{NOTIFICATION_STAKEHOLDERS}
...    Operations_Team
...    Security_Team
...    Change_Management
...    Project_Management
...    Support_Team

# Compliance Flags
${CIP010_R1_REQUIRED}         ${TRUE}     # CIP-010 R1 compliance required
${CHANGE_CONTROL_MANDATORY}   ${TRUE}     # Change control process mandatory
${BASELINE_UPDATED_REQUIRED}  ${TRUE}     # Configuration baseline must be updated

# Validation Thresholds
${MAX_OPEN_TASKS}             0           # Maximum open tasks allowed for closure
${MAX_PENDING_APPROVALS}      0           # Maximum pending approvals allowed
${MIN_DOCUMENTATION_ITEMS}    5           # Minimum documentation items required

# Browser/UI Configuration (for Citrix/Web Access)
${BROWSER_TYPE}               Chrome      # Browser for web access
${PAGE_LOAD_TIMEOUT}          30 seconds  # Page load timeout
${ELEMENT_TIMEOUT}            10 seconds  # Element wait timeout

# Screenshot Configuration
${CAPTURE_SCREENSHOTS}        ${TRUE}     # Capture screenshots during validation
${SCREENSHOT_FORMAT}          png         # Screenshot format

# Search Filters
${CRQ_SEARCH_FILTER}          state=All,assigned_to=me    # Default CRQ search filter
${FORM_SEARCH_FILTER}         status=All                  # Default form search filter

# Data Collection Settings
${COLLECT_TASK_HISTORY}       ${TRUE}     # Collect task history
${COLLECT_APPROVAL_HISTORY}   ${TRUE}     # Collect approval history
${COLLECT_COMMENTS}           ${TRUE}     # Collect comments/work notes
${COLLECT_ATTACHMENTS_LIST}   ${TRUE}     # Collect list of attachments

# Integration Settings
${ENABLE_EMAIL_NOTIFICATIONS} ${FALSE}    # Enable email notifications
${ENABLE_SLACK_NOTIFICATIONS} ${FALSE}    # Enable Slack notifications
${WEBHOOK_URL}                ${EMPTY}    # Webhook URL for notifications

# Report Settings
${SAVE_RAW_DATA}              ${TRUE}     # Save raw data collected
${GENERATE_EXECUTIVE_SUMMARY} ${TRUE}     # Generate executive summary
${INCLUDE_SCREENSHOTS}        ${TRUE}     # Include screenshots in report

# Test Timeouts
${CONNECTION_TIMEOUT}         60 seconds   # Connection establishment timeout
${DATA_COLLECTION_TIMEOUT}    120 seconds  # Data collection timeout
${VALIDATION_TIMEOUT}         90 seconds   # Validation execution timeout
${FORM_LOAD_TIMEOUT}          45 seconds   # Form loading timeout
${SEARCH_TIMEOUT}             30 seconds   # Search execution timeout

# Retry Settings
${MAX_RETRIES}                3            # Maximum retry attempts
${RETRY_DELAY}                5 seconds    # Delay between retries

# Manual Verification Steps
@{MANUAL_VERIFICATION_STEPS}
...    Login_to_CRQ_System
...    Search_for_Change_Request
...    Verify_All_Tasks_Closed
...    Verify_All_Approvals_Complete
...    Verify_Documentation_Attached
...    Capture_Screenshot_of_CRQ
...    Verify_Handoff_Complete

# Expected Values
${EXPECTED_CRQ_STATE}         Closed       # Expected CRQ state
${EXPECTED_FORM_STATUS}       Complete     # Expected form status
${EXPECTED_TASK_STATE}        Closed Complete    # Expected task state

# Validation Messages
${MSG_CRQ_FOUND}              ✅ CRQ found in system
${MSG_CRQ_NOT_FOUND}          ❌ CRQ not found in system
${MSG_ALL_TASKS_COMPLETE}     ✅ All required tasks completed
${MSG_TASKS_INCOMPLETE}       ❌ Some tasks remain incomplete
${MSG_APPROVALS_COMPLETE}     ✅ All approvals obtained
${MSG_APPROVALS_PENDING}      ❌ Approvals still pending
${MSG_HANDOFF_COMPLETE}       ✅ Operations handoff complete
${MSG_HANDOFF_INCOMPLETE}     ❌ Operations handoff incomplete
${MSG_DOCUMENTATION_OK}       ✅ Documentation requirements met
${MSG_DOCUMENTATION_MISSING}  ❌ Documentation requirements not met

# Exit Codes
${EXIT_SUCCESS}               0
${EXIT_CRQ_NOT_FOUND}         1
${EXIT_TASKS_INCOMPLETE}      2
${EXIT_APPROVALS_PENDING}     3
${EXIT_HANDOFF_INCOMPLETE}    4
${EXIT_DOCUMENTATION_MISSING} 5

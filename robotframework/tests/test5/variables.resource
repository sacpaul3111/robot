*** Variables ***
...              Configuration variables for disk space, compute, and storage validation

# Test execution settings
${CITRIX_ENV}                 QA                    # Options: QA, Production
${TERMINAL_APP}               Putty                 # Options: Putty, SecureCRT
${CODESERVER_HOST}            codeserver.local      # Codeserver hostname/IP
${TARGET_MACHINE}             target.local          # Target machine hostname/IP

# Disk space validation thresholds (in GB)
${MIN_TOTAL_DISK_SPACE}       100                   # Minimum total disk space required
${MIN_ROOT_PARTITION}         20                    # Minimum root partition size
${MIN_APP_PARTITION}          50                    # Minimum application partition size
${MIN_CYBER_TOOLS_PARTITION}  10                    # Minimum cyber tools partition size

# Storage types to validate
@{EXPECTED_FILESYSTEMS}       ext4    xfs    btrfs    # Expected filesystem types
@{REQUIRED_MOUNT_POINTS}      /       /home    /var    # Required mount points

# CPU validation thresholds
${MIN_CPU_CORES}              4                     # Minimum CPU cores required
${MIN_CPU_THREADS}            8                     # Minimum CPU threads required

# Performance thresholds
${MAX_DISK_USAGE_PERCENT}     85                    # Maximum allowed disk usage percentage
${MIN_FREE_SPACE_GB}          10                    # Minimum free space required (GB)

# File output settings
${OUTPUT_DIR}                 /tmp/system_info      # Directory for output files
${DISK_INFO_FILE}             disk_space_info.txt   # Disk information output file
${CPU_INFO_FILE}              cpu_info.txt          # CPU information output file
${STORAGE_INFO_FILE}          storage_capacity.txt  # Storage capacity output file

# Connection settings
${SSH_TIMEOUT}                30                    # SSH connection timeout (seconds)
${COMMAND_TIMEOUT}            60                    # Command execution timeout (seconds)

# Test counters (initialized in test setup)
${TOTAL_TESTS}                0
${PASSED_TESTS}               0
@{TEST_RESULTS}
@{PERFORMANCE_METRICS}
@{VALIDATION_ERRORS}
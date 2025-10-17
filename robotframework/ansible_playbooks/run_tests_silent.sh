#!/bin/bash
#############################################################################
# Shell Script: Robot Framework Silent Test Execution Wrapper
# Description: Run tests and display only status and artifacts URL
#
# USAGE:
#   ./run_tests_silent.sh <hostname>
#
# EXAMPLE:
#   ./run_tests_silent.sh alhxvdvitap01
#
# PREREQUISITES:
#   - SSH_USERNAME and SSH_PASSWORD must be set in environment
#   - Or source credentials.env first
#############################################################################

# Check if hostname is provided
if [ -z "$1" ]; then
    echo "ERROR: Target hostname is required"
    echo "Usage: $0 <hostname>"
    echo "Example: $0 alhxvdvitap01"
    exit 1
fi

TARGET_HOSTNAME="$1"

# Check if credentials are set
if [ -z "$SSH_USERNAME" ] || [ -z "$SSH_PASSWORD" ]; then
    echo "ERROR: SSH credentials not found in environment"
    echo ""
    echo "Please set credentials first:"
    echo "  export SSH_USERNAME=<your_username>"
    echo "  export SSH_PASSWORD=<your_password>"
    echo ""
    echo "Or source the credentials file:"
    echo "  source credentials.env"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run the silent playbook
echo "Starting Robot Framework tests for $TARGET_HOSTNAME..."
echo "This may take several minutes. Output is being suppressed."
echo ""

ansible-playbook "${SCRIPT_DIR}/run_tests_silent.yml" \
    -e "TargetHostname=${TARGET_HOSTNAME}" \
    -e "SSH_USERNAME=${SSH_USERNAME}" \
    -e "SSH_PASSWORD=${SSH_PASSWORD}"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "Playbook completed successfully"
else
    echo "Playbook completed with errors (exit code: $EXIT_CODE)"
    echo "Check the detailed log at: /tmp/ansible_robot_output_${TARGET_HOSTNAME}.log"
fi

exit $EXIT_CODE

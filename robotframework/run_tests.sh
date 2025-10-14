#!/bin/bash
#############################################################################
# Robot Framework Test Suite - Wrapper Script for Ansible Playbook
#############################################################################
#
# PURPOSE:
#   This script loads credentials from environment file and executes the
#   Ansible playbook to run all Robot Framework tests.
#
# USAGE:
#   ./run_tests.sh TargetHostname
#   ./run_tests.sh alhxvdvitap01
#   ./run_tests.sh alhxvdvitap01 --check  # Dry run
#
# PREREQUISITES:
#   1. Create credentials file: cp credentials.env.example credentials.env
#   2. Edit credentials.env with real values
#   3. Set permissions: chmod 600 credentials.env
#   4. Make this script executable: chmod +x run_tests.sh
#
#############################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

#############################################################################
# Configuration
#############################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CREDENTIALS_FILE="${CREDENTIALS_FILE:-${SCRIPT_DIR}/credentials.env}"
PLAYBOOK="${SCRIPT_DIR}/ansible_playbooks/run_tests.yml"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#############################################################################
# Functions
#############################################################################

print_banner() {
    echo -e "${BLUE}"
    echo "========================================================================"
    echo "   Robot Framework Test Suite - Execution Wrapper"
    echo "========================================================================"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check if ansible-playbook is installed
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "ansible-playbook is not installed!"
        echo "Install Ansible: sudo apt install ansible  OR  sudo yum install ansible"
        exit 1
    fi
    print_success "Ansible is installed: $(ansible-playbook --version | head -1)"

    # Check if python3 is installed
    if ! command -v python3 &> /dev/null; then
        print_error "python3 is not installed!"
        echo "Install Python 3: sudo apt install python3  OR  sudo yum install python3"
        exit 1
    fi
    print_success "Python 3 is installed: $(python3 --version)"

    # Check if robot framework is installed
    if ! python3 -m robot --version &> /dev/null; then
        print_error "Robot Framework is not installed!"
        echo "Install Robot Framework: pip3 install robotframework robotframework-sshlibrary"
        exit 1
    fi
    print_success "Robot Framework is installed: $(python3 -m robot --version)"
}

load_credentials() {
    print_info "Loading credentials from: ${CREDENTIALS_FILE}"

    # Check if credentials file exists
    if [ ! -f "${CREDENTIALS_FILE}" ]; then
        print_error "Credentials file not found: ${CREDENTIALS_FILE}"
        echo ""
        echo "Please create credentials file:"
        echo "  1. cp credentials.env.example credentials.env"
        echo "  2. Edit credentials.env with your actual credentials"
        echo "  3. chmod 600 credentials.env"
        echo ""
        echo "Or specify custom location:"
        echo "  export CREDENTIALS_FILE=/path/to/credentials.env"
        echo "  ./run_tests.sh <hostname>"
        exit 1
    fi

    # Check file permissions (should be 600 or 400)
    PERMS=$(stat -c "%a" "${CREDENTIALS_FILE}" 2>/dev/null || stat -f "%A" "${CREDENTIALS_FILE}" 2>/dev/null)
    if [[ "${PERMS}" != "600" ]] && [[ "${PERMS}" != "400" ]]; then
        print_warning "Credentials file has insecure permissions: ${PERMS}"
        print_warning "Recommended: chmod 600 ${CREDENTIALS_FILE}"
    fi

    # Source the credentials file
    # shellcheck source=/dev/null
    source "${CREDENTIALS_FILE}"

    # Verify critical credentials are loaded
    if [ -z "${SSH_USERNAME:-}" ] || [ -z "${SSH_PASSWORD:-}" ]; then
        print_error "SSH credentials not found in ${CREDENTIALS_FILE}"
        echo "Please ensure SSH_USERNAME and SSH_PASSWORD are defined"
        exit 1
    fi

    print_success "Credentials loaded successfully"
    print_info "SSH Username: ${SSH_USERNAME}"
    print_info "vCenter Username: ${VCENTER_USERNAME:-<not set>}"
    print_info "Splunk Username: ${SPLUNK_USERNAME:-<not set>}"
}

validate_arguments() {
    if [ $# -eq 0 ]; then
        print_error "Target hostname is required!"
        echo ""
        echo "Usage: $0 <TargetHostname> [ansible-playbook options]"
        echo ""
        echo "Examples:"
        echo "  $0 alhxvdvitap01"
        echo "  $0 alhxvdvitap01 --check          # Dry run"
        echo "  $0 alhxvdvitap01 -vv              # Verbose output"
        echo "  $0 alhxvdvitap01 --tags test3     # Run specific test"
        echo ""
        exit 1
    fi

    TARGET_HOSTNAME="$1"
    shift
    EXTRA_ARGS="$@"

    print_success "Target hostname: ${TARGET_HOSTNAME}"
}

run_tests() {
    print_info "Starting Robot Framework test execution..."
    echo ""

    # Build ansible-playbook command
    ANSIBLE_CMD="ansible-playbook ${PLAYBOOK} \
        -e TargetHostname=${TARGET_HOSTNAME} \
        ${EXTRA_ARGS}"

    print_info "Executing: ${ANSIBLE_CMD}"
    echo ""

    # Execute ansible playbook
    # Environment variables are automatically passed to Ansible
    if ${ANSIBLE_CMD}; then
        echo ""
        print_success "Test execution completed successfully!"
        return 0
    else
        echo ""
        print_error "Test execution failed!"
        return 1
    fi
}

display_results() {
    local exit_code=$1

    echo ""
    echo "========================================================================"
    echo "   Test Execution Summary"
    echo "========================================================================"

    SUMMARY_FILE="${SCRIPT_DIR}/results/TEST_SUMMARY.txt"

    if [ -f "${SUMMARY_FILE}" ]; then
        cat "${SUMMARY_FILE}"
    else
        print_warning "Summary file not found: ${SUMMARY_FILE}"
    fi

    echo ""
    echo "========================================================================"
    echo "   Results Location"
    echo "========================================================================"
    echo "  Directory:  ${SCRIPT_DIR}/results/"
    echo "  Log:        ${SCRIPT_DIR}/results/all_log.html"
    echo "  Report:     ${SCRIPT_DIR}/results/all_report.html"
    echo "========================================================================"
    echo ""

    if [ ${exit_code} -eq 0 ]; then
        print_success "All tests completed!"
    else
        print_error "Some tests failed! Check logs for details."
    fi
}

cleanup() {
    # Optional: Unset sensitive environment variables after execution
    if [ "${UNSET_CREDENTIALS:-false}" == "true" ]; then
        print_info "Unsetting credential environment variables..."
        unset SSH_PASSWORD VCENTER_PASSWORD SPLUNK_PASSWORD CYBERARK_PASSWORD
        unset TANIUM_PASSWORD ANSIBLE_TOWER_PASSWORD NEXUS_PASSWORD
        print_success "Credentials unset"
    fi
}

#############################################################################
# Main Execution
#############################################################################

main() {
    print_banner

    # Validate input arguments
    validate_arguments "$@"

    # Check prerequisites
    check_prerequisites

    # Load credentials
    load_credentials

    # Run tests
    if run_tests; then
        EXIT_CODE=0
    else
        EXIT_CODE=1
    fi

    # Display results
    display_results ${EXIT_CODE}

    # Cleanup
    cleanup

    exit ${EXIT_CODE}
}

# Execute main function
main "$@"

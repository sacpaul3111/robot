#!/bin/bash
#############################################################################
# Robot Framework Test Suite - Execution Wrapper with Ansible Vault
#############################################################################
#
# PURPOSE:
#   Execute Robot Framework tests using Ansible Vault for secure credential management
#
# USAGE:
#   ./run_tests_vault.sh <target_hostname>
#
# EXAMPLES:
#   ./run_tests_vault.sh alhxvdvitap01
#   ./run_tests_vault.sh server01
#
# REQUIREMENTS:
#   - Ansible installed
#   - Vault file: /etc/ansible/vault/robot_credentials.yml
#   - Vault password file: /etc/ansible/vault/.vault_pass
#   OR
#   - ANSIBLE_VAULT_PASSWORD_FILE environment variable set
#
#############################################################################

# Configuration (can be overridden via environment variables)
VAULT_FILE="${VAULT_FILE:-/etc/ansible/vault/robot_credentials.yml}"
VAULT_PASSWORD_FILE="${VAULT_PASSWORD_FILE:-/etc/ansible/vault/.vault_pass}"
PLAYBOOK_DIR="${PLAYBOOK_DIR:-ansible_playbooks}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#############################################################################
# Function: Print colored messages
#############################################################################
print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_info() {
    echo "$1"
}

#############################################################################
# Function: Display usage
#############################################################################
usage() {
    cat << EOF
Robot Framework Test Suite - Ansible Vault Execution Wrapper

USAGE:
    $0 <target_hostname> [options]

ARGUMENTS:
    target_hostname         Target server hostname (required)

OPTIONS:
    -v, --vault-file FILE   Path to vault file (default: /etc/ansible/vault/robot_credentials.yml)
    -p, --vault-pass FILE   Path to vault password file (default: /etc/ansible/vault/.vault_pass)
    -h, --help              Show this help message

EXAMPLES:
    # Basic execution
    $0 alhxvdvitap01

    # Custom vault file location
    $0 alhxvdvitap01 --vault-file /opt/vault/creds.yml

    # Use environment variable for vault password
    export ANSIBLE_VAULT_PASSWORD_FILE="/secure/location/.vault_pass"
    $0 alhxvdvitap01

ENVIRONMENT VARIABLES:
    VAULT_FILE              Override default vault file location
    VAULT_PASSWORD_FILE     Override default vault password file location
    ANSIBLE_VAULT_PASSWORD_FILE  Ansible's native vault password file variable

SETUP:
    1. Create vault directory:
       sudo mkdir -p /etc/ansible/vault
       sudo chmod 700 /etc/ansible/vault

    2. Create vault password file:
       echo "YourVaultPassword" | sudo tee /etc/ansible/vault/.vault_pass
       sudo chmod 600 /etc/ansible/vault/.vault_pass

    3. Create encrypted vault:
       ansible-vault create /etc/ansible/vault/robot_credentials.yml \\
         --vault-password-file=/etc/ansible/vault/.vault_pass

    4. Execute tests:
       $0 alhxvdvitap01

For detailed documentation, see: docs/ENVIRONMENT_VARIABLES_APPROACH.md

EOF
}

#############################################################################
# Parse command line arguments
#############################################################################
TARGET_HOSTNAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--vault-file)
            VAULT_FILE="$2"
            shift 2
            ;;
        -p|--vault-pass)
            VAULT_PASSWORD_FILE="$2"
            shift 2
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            if [ -z "$TARGET_HOSTNAME" ]; then
                TARGET_HOSTNAME="$1"
            else
                print_error "Multiple hostnames provided. Only one hostname allowed."
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

#############################################################################
# Validate inputs
#############################################################################

# Check if target hostname provided
if [ -z "$TARGET_HOSTNAME" ]; then
    print_error "Target hostname required"
    echo ""
    usage
    exit 1
fi

# Check if vault file exists
if [ ! -f "$VAULT_FILE" ]; then
    print_error "Vault file not found: $VAULT_FILE"
    echo ""
    echo "Please create vault file first:"
    echo "  ansible-vault create $VAULT_FILE --vault-password-file=$VAULT_PASSWORD_FILE"
    echo ""
    echo "For detailed setup instructions, see:"
    echo "  docs/ENVIRONMENT_VARIABLES_APPROACH.md"
    exit 1
fi

# Check if vault password file exists (if not using ANSIBLE_VAULT_PASSWORD_FILE env)
if [ -z "$ANSIBLE_VAULT_PASSWORD_FILE" ]; then
    if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
        print_error "Vault password file not found: $VAULT_PASSWORD_FILE"
        echo ""
        echo "Options:"
        echo "  1. Create password file:"
        echo "     echo 'YourVaultPassword' > $VAULT_PASSWORD_FILE"
        echo "     chmod 600 $VAULT_PASSWORD_FILE"
        echo ""
        echo "  2. Set environment variable:"
        echo "     export ANSIBLE_VAULT_PASSWORD_FILE='/path/to/.vault_pass'"
        echo ""
        echo "  3. Use --ask-vault-pass (will prompt for password)"
        exit 1
    fi
else
    print_info "Using vault password from ANSIBLE_VAULT_PASSWORD_FILE: $ANSIBLE_VAULT_PASSWORD_FILE"
    VAULT_PASSWORD_FILE="$ANSIBLE_VAULT_PASSWORD_FILE"
fi

# Check if ansible-playbook is installed
if ! command -v ansible-playbook &> /dev/null; then
    print_error "ansible-playbook command not found"
    echo ""
    echo "Please install Ansible:"
    echo "  RHEL/CentOS: sudo yum install ansible"
    echo "  Ubuntu:      sudo apt install ansible"
    echo "  pip:         pip3 install ansible"
    exit 1
fi

# Check if playbook directory exists
if [ ! -d "$PLAYBOOK_DIR" ]; then
    print_error "Playbook directory not found: $PLAYBOOK_DIR"
    echo ""
    echo "Please run this script from the Robot Framework project root directory"
    exit 1
fi

# Check if run_tests.yml exists
if [ ! -f "${PLAYBOOK_DIR}/run_tests.yml" ]; then
    print_error "Playbook not found: ${PLAYBOOK_DIR}/run_tests.yml"
    exit 1
fi

#############################################################################
# Display execution summary
#############################################################################
echo "=========================================="
echo "  Robot Framework Test Suite"
echo "  Ansible Vault Execution"
echo "=========================================="
echo "Target Hostname:  $TARGET_HOSTNAME"
echo "Vault File:       $VAULT_FILE"
echo "Password File:    $VAULT_PASSWORD_FILE"
echo "Playbook:         ${PLAYBOOK_DIR}/run_tests.yml"
echo "=========================================="
echo ""

#############################################################################
# Verify vault can be decrypted (test before execution)
#############################################################################
print_info "Verifying vault credentials..."

# Test vault decryption
if ! ansible-vault view "$VAULT_FILE" --vault-password-file="$VAULT_PASSWORD_FILE" > /dev/null 2>&1; then
    print_error "Failed to decrypt vault file"
    echo ""
    echo "Possible causes:"
    echo "  1. Wrong vault password"
    echo "  2. Corrupted vault file"
    echo "  3. Vault file not encrypted"
    echo ""
    echo "Try manually viewing vault:"
    echo "  ansible-vault view $VAULT_FILE --vault-password-file=$VAULT_PASSWORD_FILE"
    exit 1
fi

print_success "Vault credentials verified"
echo ""

#############################################################################
# Execute Ansible playbook with vault
#############################################################################
print_info "Executing Ansible playbook..."
echo ""

# Execute Ansible playbook
ansible-playbook "${PLAYBOOK_DIR}/run_tests.yml" \
  -e "TargetHostname=$TARGET_HOSTNAME" \
  -e "@$VAULT_FILE" \
  --vault-password-file="$VAULT_PASSWORD_FILE"

# Capture exit code
EXIT_CODE=$?

echo ""
echo "=========================================="
if [ $EXIT_CODE -eq 0 ]; then
    print_success "Test execution completed successfully"
else
    print_error "Test execution failed with exit code: $EXIT_CODE"
fi
echo "=========================================="

# Exit with same code as ansible-playbook
exit $EXIT_CODE

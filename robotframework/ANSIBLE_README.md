# Ansible Playbook Wrapper for Robot Framework Tests

## Overview

This directory contains an Ansible playbook wrapper that triggers the Robot Framework test execution via the bash script. This provides automation and integration capabilities for CI/CD pipelines and remote test execution.

## Files

- `ansible_playbooks/run_tests.yml` - Ansible playbook (unified, self-contained)
- `ansible_playbooks/execute_test_suite.yml` - Task file included by run_tests.yml

## Prerequisites

### Linux System Requirements

1. **Python 3.x** installed
2. **Robot Framework** and dependencies installed (preferably in a virtual environment)
3. **Ansible** installed:
   ```bash
   # Install Ansible
   pip3 install ansible

   # Or using system package manager
   sudo apt-get install ansible  # Debian/Ubuntu
   sudo yum install ansible      # RHEL/CentOS
   ```

### Environment Setup

Set SSH credentials as environment variables:

```bash
export SSH_USERNAME="your_username"
export SSH_PASSWORD="your_password"
```

Or create a `.env` file:

```bash
# .env file
SSH_USERNAME=admin
SSH_PASSWORD=secret123
```

Then source it:
```bash
source .env
```

## Usage

### Method 1: Direct Bash Script Execution (Recommended for manual runs)

```bash
# Make script executable (first time only)
chmod +x run_all_tests.sh

# Run with command line parameters
./run_all_tests.sh -t alhxvdvitap01 -u admin -p password123

# Or use environment variables
export SSH_USERNAME="admin"
export SSH_PASSWORD="password123"
./run_all_tests.sh -t alhxvdvitap01
```

**Bash Script Options:**
- `-u, --username` - SSH username (or set `SSH_USERNAME` env var)
- `-p, --password` - SSH password (or set `SSH_PASSWORD` env var)
- `-t, --target` - Target hostname (REQUIRED)
- `-o, --output` - Output directory (default: results)
- `-h, --help` - Display help message

### Method 2: Ansible Playbook Execution (Recommended for automation)

```bash
# Basic execution with target hostname
ansible-playbook ansible_playbooks/run_tests.yml \
  -e target_hostname=alhxvdvitap01

# With custom output directory
ansible-playbook ansible_playbooks/run_tests.yml \
  -e target_hostname=alhxvdvitap01 \
  -e robot_output_dir=custom_results

# With verbose output
ansible-playbook ansible_playbooks/run_tests.yml \
  -e target_hostname=alhxvdvitap01 -vv

# Fail playbook if any test fails
ansible-playbook ansible_playbooks/run_tests.yml \
  -e target_hostname=alhxvdvitap01 \
  -e fail_on_test_errors=true
```

**Ansible Playbook Variables:**

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `target_hostname` | Target server hostname | - | Yes |
| `robot_username` | SSH username | `$SSH_USERNAME` | Yes |
| `robot_password` | SSH password | `$SSH_PASSWORD` | Yes |
| `robot_output_dir` | Results output directory | `results` | No |
| `robot_project_dir` | Project root directory | `{{ playbook_dir }}` | No |
| `fail_on_test_errors` | Fail playbook on test errors | `false` | No |

## Examples

### Example 1: Run tests with environment variables

```bash
# Set credentials
export SSH_USERNAME="pauls6"
export SSH_PASSWORD="mypassword"

# Run via Ansible
ansible-playbook ansible_playbooks/run_tests.yml \
  -e target_hostname=alhxvdvitap01
```

### Example 2: Run tests with inline credentials (not recommended for production)

```bash
ansible-playbook ansible_playbooks/run_tests.yml \
  -e target_hostname=alhxvdvitap01 \
  -e robot_username=admin \
  -e robot_password=secret123
```

### Example 3: Run from a different directory

```bash
ansible-playbook -i /path/to/robotframework/inventory.ini \
  /path/to/robotframework/run_tests.yml \
  -e target_hostname=alhxvdvitap01 \
  -e robot_project_dir=/path/to/robotframework
```

### Example 4: Integration with Jenkins/GitLab CI

```yaml
# .gitlab-ci.yml example
test:
  stage: test
  script:
    - export SSH_USERNAME="${ROBOT_SSH_USER}"
    - export SSH_PASSWORD="${ROBOT_SSH_PASS}"
    - ansible-playbook ansible_playbooks/run_tests.yml
        -e target_hostname="${TARGET_HOST}"
        -e fail_on_test_errors=true
  artifacts:
    paths:
      - results/
    when: always
```

## Output

After execution, results are stored in the output directory (default: `results/`):

```
results/
├── test3_network_validation/
│   ├── log.html
│   ├── output.xml
│   └── report.html
├── test5_disk_space_validation/
│   └── ...
├── test7_time_configuration_validation/
│   └── ...
├── all_log.html          # Consolidated log
├── all_output.xml        # Consolidated output
└── all_report.html       # Consolidated report
```

## Troubleshooting

### Issue: Ansible not found

```bash
# Install Ansible
pip3 install ansible

# Verify installation
ansible --version
```

### Issue: Permission denied for bash script

```bash
# Make script executable
chmod +x run_all_tests.sh
```

### Issue: Python virtual environment not found

```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Install Robot Framework
pip install robotframework robotframework-sshlibrary openpyxl
```

### Issue: SSH connection fails

- Verify `SSH_USERNAME` and `SSH_PASSWORD` are set correctly
- Check network connectivity to target host
- Verify EDS Excel file has correct IP address for the hostname
- Check firewall rules allow SSH (port 22)

### Issue: Module not found errors

```bash
# Activate virtual environment and install dependencies
source venv/bin/activate
pip install -r requirements.txt  # If you have one

# Or install manually
pip install robotframework robotframework-sshlibrary openpyxl pandas
```

## Advanced Usage

### Run specific test suite only

To run a specific test suite, modify the bash script or robot command directly:

```bash
# Run only test3
./venv/bin/python -m robot \
  --variable SSH_USERNAME:admin \
  --variable SSH_PASSWORD:secret \
  --variable TARGET_HOSTNAME:alhxvdvitap01 \
  --outputdir results/test3_network_validation \
  tests/test3_network_validation/network_validation.robot
```

### Custom Ansible inventory

Create a custom inventory for different environments:

```ini
# inventory_prod.ini
[local]
localhost ansible_connection=local

[local:vars]
ansible_python_interpreter=/usr/bin/python3
robot_output_dir=results_prod
```

Use it:
```bash
ansible-playbook -i inventory_prod.ini run_tests.yml \
  -e target_hostname=prod-server-01
```

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use Ansible Vault** for sensitive variables:
   ```bash
   # Create encrypted vars file
   ansible-vault create secrets.yml

   # Add credentials
   robot_username: admin
   robot_password: secret123

   # Use in playbook
   ansible-playbook ansible_playbooks/run_tests.yml \
     -e target_hostname=server01 \
     --vault-password-file ~/.vault_pass
   ```

3. **Use environment variables** for credentials in CI/CD
4. **Restrict file permissions** on scripts and inventory files:
   ```bash
   chmod 700 run_all_tests.sh
   chmod 600 inventory.ini
   ```

## Support

For issues or questions:
- Check the main README.md for Robot Framework setup
- Review test suite documentation in individual test directories
- Check Robot Framework logs in the results directory

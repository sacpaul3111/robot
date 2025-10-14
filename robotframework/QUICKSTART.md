# Quick Start Guide - Robot Framework Test Suite

## 🚀 Get Started in 5 Minutes

This guide will help you set up and run your first Robot Framework test.

---

## Prerequisites

Ensure you have these installed on your Linux server:

```bash
# Check Python 3
python3 --version  # Should be 3.6+

# Check Ansible
ansible --version  # Should be 2.9+

# Check Robot Framework
python3 -m robot --version  # Should be 3.x+
```

**Don't have them?** Install:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y python3 python3-pip ansible

# RHEL/CentOS
sudo yum install -y python3 python3-pip ansible

# Install Robot Framework
pip3 install robotframework robotframework-sshlibrary
```

---

## Step 1: Clone Repository

```bash
# Clone from GitHub
git clone https://github.com/your-org/robotframework.git
cd robotframework
```

---

## Step 2: Set Up Credentials

```bash
# Copy example credentials file
cp credentials.env.example credentials.env

# Edit with your actual credentials
vim credentials.env

# Update at minimum:
# - SSH_USERNAME
# - SSH_PASSWORD

# Save and exit (:wq in vim)

# Secure the file
chmod 600 credentials.env
```

---

## Step 3: Make Scripts Executable

```bash
chmod +x run_tests.sh
```

---

## Step 4: Run Your First Test

```bash
# Run all tests against target server
./run_tests.sh alhxvdvitap01

# That's it! The script will:
# ✓ Check prerequisites
# ✓ Load credentials
# ✓ Execute all Robot Framework tests
# ✓ Generate consolidated reports
# ✓ Display results summary
```

---

## Step 5: View Results

```bash
# Test results are saved to:
results/
├── all_log.html          # Open in browser - detailed test log
├── all_report.html       # Open in browser - summary report
├── TEST_SUMMARY.txt      # Text summary - good for scripts
└── test3_network_validation/
    ├── data/             # Raw data collected
    └── log.html          # Individual test log
```

**View in Browser:**
```bash
# If server has GUI
firefox results/all_report.html

# If remote server, copy to local machine
scp -r user@server:/path/to/robotframework/results/ ./local_results/
# Then open local_results/all_report.html in browser
```

---

## Common Commands

### Run Tests

```bash
# Basic execution
./run_tests.sh <hostname>

# With verbose output
./run_tests.sh <hostname> -vv

# Dry run (check without executing)
./run_tests.sh <hostname> --check
```

### Run Single Test

```bash
# Run only Test 3 (Network Validation)
robot --variable TARGET_HOSTNAME:alhxvdvitap01 \
      --variable SSH_USERNAME:admin \
      --variable SSH_PASSWORD:yourpass \
      --outputdir results/test3_network_validation \
      tests/test3_network_validation/network_validation.robot
```

### View Test Status

```bash
# Check if all tests passed
grep "Overall Status" results/TEST_SUMMARY.txt

# Count passed/failed tests
grep -E "(Passed Tests|Failed Tests)" results/TEST_SUMMARY.txt
```

---

## What Gets Tested?

| Test | What It Validates |
|------|-------------------|
| Test 3 | Network configuration (hostname, IP, subnet, gateway, DNS, NTP) |
| Test 5 | System resources (CPU, RAM, disk space, storage type) |
| Test 7 | Time configuration (timezone, NTP, chrony service) |
| Test 11 | Services inventory and status documentation |
| Test 17 | Mail/SMTP configuration and relay settings |
| Test 18 | RSA authentication and patch management registration |
| Test 20 | Antivirus agent (CIP-007 R3.1 compliance) |
| Test 22 | System logs and critical errors |

**All tests validate against EDS (Enterprise Design Standards)**

---

## Understanding Results

### All Tests Passed ✅

```
========================================================
           TEST EXECUTION SUMMARY
========================================================
Total Tests:    47
Passed Tests:   47
Failed Tests:   0
========================================================
Overall Status: PASSED ✅
========================================================
```

**Action:** Server meets all requirements, ready for production

---

### Some Tests Failed ❌

```
========================================================
           TEST EXECUTION SUMMARY
========================================================
Total Tests:    47
Passed Tests:   45
Failed Tests:   2
========================================================
Overall Status: FAILED ❌
========================================================
```

**Action:** Review failed tests in `all_report.html`, fix issues, re-run tests

---

## Troubleshooting

### Issue: "Credentials file not found"

```bash
# Solution: Create credentials file
cp credentials.env.example credentials.env
vim credentials.env  # Add your credentials
chmod 600 credentials.env
```

---

### Issue: "SSH connection failed"

```bash
# Test SSH manually
ssh $SSH_USERNAME@alhxvdvitap01

# If that fails, check:
# 1. Firewall rules (port 22)
# 2. Credentials are correct
# 3. Target server is reachable
ping alhxvdvitap01
```

---

### Issue: "Ansible not found"

```bash
# Install Ansible
sudo apt install ansible  # Ubuntu/Debian
sudo yum install ansible  # RHEL/CentOS
```

---

### Issue: "Robot Framework not found"

```bash
# Install Robot Framework
pip3 install robotframework robotframework-sshlibrary

# Verify installation
python3 -m robot --version
```

---

## Advanced Usage

### Run Specific Tests

```bash
# Run only critical tests
./run_tests.sh alhxvdvitap01 --tags critical

# Run only Test 3
./run_tests.sh alhxvdvitap01 --tags test3

# Skip certain tests
./run_tests.sh alhxvdvitap01 --exclude slow
```

### Custom Credentials Location

```bash
# Use custom credentials file
export CREDENTIALS_FILE=/etc/robot_credentials.env
./run_tests.sh alhxvdvitap01
```

### Integration with CI/CD

```bash
# Jenkins/GitLab CI
source /etc/robot_credentials.env
ansible-playbook ansible_playbooks/run_tests.yml \
  -e TargetHostname=${TARGET_HOSTNAME}

# Check exit code
if [ $? -eq 0 ]; then
  echo "All tests passed"
else
  echo "Tests failed"
fi
```

---

## File Structure

```
robotframework/
├── run_tests.sh                    # ⭐ Main execution script
├── credentials.env.example         # Example credentials (SAFE to commit)
├── credentials.env                 # Your credentials (DO NOT commit)
├── ansible_playbooks/
│   └── run_tests.yml              # Ansible orchestration
├── tests/
│   ├── test3_network_validation/
│   ├── test5_disk_space_validation/
│   └── ...
├── results/                        # Test results (created after run)
│   ├── all_log.html
│   ├── all_report.html
│   └── TEST_SUMMARY.txt
└── docs/
    └── test_explanations/          # Detailed test documentation
```

---

## Next Steps

1. ✅ **Run tests** against your first server
2. 📖 **Read test documentation** in `docs/test_explanations/`
3. 🔧 **Customize** for your environment (EDS file, credentials)
4. 🔄 **Integrate** with CI/CD pipeline (Itential, Jenkins, GitLab)
5. 📊 **Review results** regularly for compliance

---

## Important Security Notes

### ⚠️ DO NOT:
- ❌ Commit `credentials.env` to Git
- ❌ Share credentials via email/Slack
- ❌ Set credentials file permissions to 777 or 666
- ❌ Store credentials in test code

### ✅ DO:
- ✅ Use `credentials.env` for local credentials
- ✅ Set file permissions to 600: `chmod 600 credentials.env`
- ✅ Store production credentials in secure vault (Ansible Vault, CyberArk, etc.)
- ✅ Rotate credentials every 90 days
- ✅ Keep `.gitignore` updated

---

## Getting Help

### Documentation
- 📖 [Credentials Setup Guide](CREDENTIALS_SETUP.md)
- 📖 [Test Explanations](docs/test_explanations/README.md)
- 📖 [Ansible Playbook Documentation](docs/test_explanations/ANSIBLE_run_tests_yml_Working_Explanation.md)

### Test a Specific Component
```bash
# View specific test documentation
cat docs/test_explanations/TEST3_Network_Validation_Working_Explanation.md
cat docs/test_explanations/TEST20_AV_Agent_Validation_Working_Explanation.md
```

### Check Test Prerequisites
```bash
# Run prerequisite check
./run_tests.sh --help  # Shows usage
python3 -m robot --version
ansible-playbook --version
```

---

## Example: Complete First Run

```bash
# 1. Clone repository
git clone https://github.com/your-org/robotframework.git
cd robotframework

# 2. Set up credentials
cp credentials.env.example credentials.env
vim credentials.env  # Update SSH_USERNAME and SSH_PASSWORD
chmod 600 credentials.env

# 3. Make script executable
chmod +x run_tests.sh

# 4. Run tests
./run_tests.sh alhxvdvitap01

# 5. View results
cat results/TEST_SUMMARY.txt
# or
firefox results/all_report.html  # if GUI available
```

**Time to first test run: ~5 minutes** ⏱️

---

## Success!

If you see this output, you're all set:

```
✓ Ansible is installed: ansible-playbook [core 2.12.0]
✓ Python 3 is installed: Python 3.9.7
✓ Robot Framework is installed: Robot Framework 4.1.3
✓ Credentials loaded successfully
✓ Test execution completed successfully!

========================================================
Overall Status: PASSED ✅
========================================================
```

🎉 **Congratulations!** Your Robot Framework test suite is running!

---

**Quick Start Version:** 1.0
**Last Updated:** 2025-10-14

 Method 1: Pass everything via command line and environment variables

  # First, export your SSH credentials as environment variables
  export SSH_USERNAME=robotuser
  export SSH_PASSWORD='R0botuserwashere!'

  # Then run the playbook with the target hostname
  ansible-playbook robotframework/ansible_playbooks/run_tests.yml \
    -e TargetHostname=alhxvdvitap01

  Method 2: All in one command (inline environment variables)

  SSH_USERNAME=robotuser SSH_PASSWORD='R0botuserwashere!' \
  ansible-playbook robotframework/ansible_playbooks/run_tests.yml \
    -e TargetHostname=alhxvdvitap01

  Method 3: Using a credentials file (cleaner approach)

  Create a file called credentials.env:
  export SSH_USERNAME=robotuser
  export SSH_PASSWORD='R0botuserwashere!'

  Then run:
  source credentials.env
  ansible-playbook robotframework/ansible_playbooks/run_tests.yml \
    -e TargetHostname=alhxvdvitap01

  Notes:

  - The playbook expects SSH_USERNAME and SSH_PASSWORD as environment variables (lines 195-208 in the
  playbook)
  - The target hostname is passed with the -e TargetHostname=<hostname> flag
  - The playbook will automatically find and run all test suites in the tests/ directory
  - Results will be saved to the results/ directory

  For your specific example:
  export SSH_USERNAME=robotuser
  export SSH_PASSWORD='R0botuserwashere!'

  ansible-playbook robotframework/ansible_playbooks/run_tests.yml \
    -e TargetHostname=alhxvdvitap01
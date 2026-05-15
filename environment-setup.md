# Environment Setup & Tooling Documentation

This document captures the full development environment used to build and run the Terraform + Ansible infrastructure pipeline. It ensures reproducibility across machines and serves as evidence of the toolchain configuration.

---

# Operating System

- **OS:** Ubuntu (WSL2 / Linux subsystem)
- **Kernel:** Linux x86_64
- **Shell:** bash

To verify:
I run this command on the terminal:
uname -a

Output:
uname -a
Linux StacyKangethe 6.17.0-19-generic #19~24.04.2-Ubuntu SMP PREEMPT_DYNAMIC Fri Mar  6 23:08:46 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

# Tooling Documentation
I used:
1. Terraform:
To check version, run on command line: terraform version
My Output:terraform version
Terraform v1.15.2
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.15.3. You can update by downloading from https://developer.hashicorp.com/terraform/install
 


2. Ansible:
To check version, run on command line: ansible -- version
My Output: ansible --version
ansible [core 2.20.5]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/kangethe/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/kangethe/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.3 (main, Mar 23 2026, 19:04:32) [GCC 13.3.0] (/usr/bin/python3)
  jinja version = 3.1.2
  pyyaml version = 6.0.1 (with libyaml v0.2.5)


3. AWS CLI:
To check version, run on command line: aws -- version
My Output: aws --version
aws-cli/2.34.20 Python/3.14.3 Linux/6.17.0-19-generic exe/x86_64.ubuntu.24

# Tools used in Pipeline
Infrastructure Provisioning - Terraform(IaC), AWS Provider(EC2, VPC, Security Groups)
Configuration Management - Ansible(server provisioning)
Data Processing - jq(for parsing Terraform JSON Outputs)
Networking for Validation - curl(used for Ip detection via http provider), ssh(remote provisioning)

Project Structure Overview:
Run the command:
tree

To reproduce this environment:
1. Install Terraform
2. Install Ansible
3. Install jq
4. Configure AWS credentials
5. Clone repository
And run on the terminal, this command:
chmod +x pipeline.sh
./pipeline.sh

Key Design Decisions:
1. Terraform state managed locally (or configured backend if enabled)
2. Inventory is dynamically generated from Terraform outputs
3. No hardcoded EC2 IPs (fully dynamic infrastructure)
4. Pipeline supports two deterministic runs:
RUN 1 → infrastructure change
RUN 2 → stable convergence

Verification Checklist
1. Terraform installs successfully
2. EC2 instances provisioned via module
3. Security groups applied correctly
4. Ansible connects via SSH
5. Inventory generated dynamically
6. Pipeline produces RUN1 + RUN2 logs

This environment is fully reproducible and automated using Infrastructure as Code (Terraform) and Configuration Management(Ansible), orchestrated via a Bash pipeline.


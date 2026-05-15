# Reflection – Terraform + Ansible Pipeline

## 1. Requirement Conflict Discovery

The conflict became clear during pipeline integration between Terraform and Ansible.

Initially, Terraform was configured to generate infrastructure outputs and Ansible inventory dynamically. At the same time, Ansible expected a stable and immediately reachable SSH endpoint.

The conflict emerged when:

- Terraform correctly provisioned EC2 instances
- But Ansible failed with SSH timeouts or unresolved hosts (e.g., `null`, delayed IP propagation, or security group lag)

### Conflict Summary
- Terraform optimistically assumes infrastructure is ready immediately after `apply`
- Ansible assumes SSH is instantly available after instance creation

In reality, AWS provisioning introduces delays in:
- Public IP assignment
- Security group rule propagation
- SSH service readiness

### What I learned
Infrastructure provisioning and configuration management are not synchronous systems. Even when Terraform reports “Apply complete”, the runtime environment may not yet be operational.

The correct engineering approach is to introduce:
- readiness validation (SSH port checks)
- retry/backoff logic
- or explicit wait conditions between provisioning and configuration

---

## 2. Hardening Documentation Translation (Nia → Tendo)

### Original sentence (for Nia):
> “The system is locked down so that only my current IP can access SSH.”

### Technical version (for Tendo):
> “Ingress SSH access is restricted to a dynamically resolved /32 CIDR block derived from the current public IP at provisioning time using a Terraform HTTP data source.”

### What is lost in translation:
- Simplicity and immediate readability
- Human context (“my current IP”)

### What is gained:
- Precision and unambiguous scope definition
- Reproducibility across environments
- Clear security implementation detail (CIDR /32, dynamic resolution)

This reflects the trade-off between operational communication and engineering documentation rigor.

---

## 3. Most Fragile Handoff in the Pipeline

The most fragile point in the pipeline is:

> **Terraform → Ansible inventory generation (tf-output.json → inventory.ini)**

### Why this is fragile:
- It depends on Terraform outputs being fully populated and correctly structured
- Any missing or null value results in invalid Ansible inventory (e.g., `ansible_host=null`)
- The pipeline assumes immediate consistency after `terraform apply`

### Real failure modes:
- Terraform outputs not yet available or partially computed
- JSON parsing failure in `jq`
- Race condition between instance creation and IP assignment
- SSH not yet reachable even if IP exists

### What would make it robust:

To make this production-grade, I would need:

- Guaranteed output schema validation (Terraform output contract)
- Retry mechanism for IP readiness (polling AWS instance state = running)
- SSH readiness probe before Ansible execution
- Explicit dependency wait step (e.g., `aws ec2 wait instance-status-ok`)
- Validation layer before generating inventory

### Engineering insight:
The pipeline is currently *eventually consistent*, not *strictly consistent*. Production systems must explicitly handle this gap.

---

## Final takeaway

The system works correctly in controlled environments, but production reliability depends on treating infrastructure as asynchronous rather than immediate.

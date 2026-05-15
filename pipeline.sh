#!/bin/bash

set -e
export TF_INPUT=0

FRIDAY_DIR="$(cd "$(dirname "$0")" && pwd)"
TERRAFORM_DIR="$FRIDAY_DIR/terraform"
ANSIBLE_DIR="$FRIDAY_DIR/ansible"

RUN1_LOG="$FRIDAY_DIR/pipeline-run1.log"
RUN2_LOG="$FRIDAY_DIR/pipeline-run2.log"

# mode control

TF_MODE=${TF_MODE:-stable}

echo "Pipeline Mode: $TF_MODE"

# FUNCTION: RUN PIPELINE (ISOLATED LOGGING)

run_pipeline () {
  LOG_FILE=$1

  {

    echo "STARTING  RUN -MODE: $TF_MODE"

    echo "LOG FILE: $LOG_FILE"

    # TERRAFORM

    echo "Running Terraform..."

    cd "$TERRAFORM_DIR"

    terraform init -reconfigure -input=false

    if [ "$TF_MODE" = "change" ]; then
      echo "Applying CHANGE mode (RUN 1 behavior)..."

      terraform apply -auto-approve \
        -var="app_tag_suffix=v1"
    else
      echo "Applying STABLE mode (RUN 2 behavior)..."

      terraform apply -auto-approve \
        -var="app_tag_suffix=v0"
    fi

    echo "Extracting Terraform outputs..."
    terraform output -json > tf-output.json

    cd "$FRIDAY_DIR"

    # INVENTORY GENERATION

    echo "Generating Ansible inventory..."

    jq -r '
      .server_ips.value |
      to_entries[] |
      "\(.key) ansible_host=\(.value) ansible_user=ubuntu"
    ' terraform/tf-output.json > ansible/inventory.ini

    cat ansible/inventory.ini

    ########################################
    # ANSIBLE
    ########################################
    echo "Running Ansible..."

    cd "$ANSIBLE_DIR"

    ansible-playbook -i inventory.ini playbook.yml

    cd "$FRIDAY_DIR"

    echo "PIPELINE COMPLETED SUCCESSFULLY"
    echo "======================================="
  } 2>&1 | tee "$LOG_FILE"
}

############################################
# RUN 1
############################################

export TF_MODE=stable

echo "RUN 1 START"
run_pipeline "$RUN1_LOG"

############################################
# RUN 2
############################################
echo "RUN 2 START"
run_pipeline "$RUN2_LOG"

echo "ALL RUNS COMPLETE"

.PHONY: help init plan apply destroy validate clean test diagrams cost

# Project root directory
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
PROJECT_ROOT := $(ROOT_DIR)/..

# Default target
help:
	@echo "Multi-Cloud Infrastructure Management"
	@echo ""
	@echo "Usage:"
	@echo "  make init ENV=<dev|staging|prod>      - Initialize Terraform for environment"
	@echo "  make init CLOUD=<aws|gcp|azure>       - Initialize Terraform for cloud module"
	@echo "  make plan ENV=<dev|staging|prod>      - Plan infrastructure changes"
	@echo "  make apply ENV=<dev|staging|prod>     - Apply infrastructure changes"
	@echo "  make destroy ENV=<dev|staging|prod>   - Destroy infrastructure"
	@echo "  make validate ENV=<dev|staging|prod>  - Validate Terraform configuration"
	@echo "  make diagrams                          - Generate infrastructure diagrams"
	@echo "  make cost                              - Estimate infrastructure costs"
	@echo "  make test                              - Run Python unit tests"
	@echo "  make clean                             - Clean temporary files"
	@echo ""
	@echo "Examples:"
	@echo "  make init ENV=dev"
	@echo "  make apply ENV=staging"
	@echo "  make init CLOUD=aws"
	@echo "  make diagrams"

# Initialize Terraform
init:
ifdef ENV
	@echo "Initializing $(ENV) environment..."
	cd $(PROJECT_ROOT)/terraform/environments/$(ENV) && terraform init
else ifdef CLOUD
	@echo "Initializing $(CLOUD) module..."
	cd $(PROJECT_ROOT)/terraform/modules/$(CLOUD) && terraform init
else
	@echo "Error: ENV or CLOUD variable not set. Use: make init ENV=<dev|staging|prod> or make init CLOUD=<aws|gcp|azure>"
	@exit 1
endif

# Plan infrastructure changes
plan:
ifdef ENV
	@echo "Planning $(ENV) environment..."
	cd $(PROJECT_ROOT)/terraform/environments/$(ENV) && terraform plan
else ifdef CLOUD
	@echo "Planning $(CLOUD) module..."
	cd $(PROJECT_ROOT)/terraform/modules/$(CLOUD) && terraform plan
else
	@echo "Error: ENV or CLOUD variable not set. Use: make plan ENV=<dev|staging|prod>"
	@exit 1
endif

# Apply infrastructure changes
apply:
ifdef ENV
	@echo "Applying $(ENV) environment..."
	cd $(PROJECT_ROOT)/terraform/environments/$(ENV) && terraform apply
else ifdef CLOUD
	@echo "Applying $(CLOUD) module..."
	cd $(PROJECT_ROOT)/terraform/modules/$(CLOUD) && terraform apply
else
	@echo "Error: ENV or CLOUD variable not set. Use: make apply ENV=<dev|staging|prod>"
	@exit 1
endif

# Destroy infrastructure
destroy:
ifdef ENV
	@echo "Destroying $(ENV) environment..."
	cd $(PROJECT_ROOT)/terraform/environments/$(ENV) && terraform destroy
else ifdef CLOUD
	@echo "Destroying $(CLOUD) module..."
	cd $(PROJECT_ROOT)/terraform/modules/$(CLOUD) && terraform destroy
else
	@echo "Error: ENV or CLOUD variable not set. Use: make destroy ENV=<dev|staging|prod>"
	@exit 1
endif

# Validate Terraform configuration
validate:
ifdef ENV
	@echo "Validating $(ENV) environment..."
	cd $(PROJECT_ROOT)/terraform/environments/$(ENV) && terraform validate
	cd $(PROJECT_ROOT)/terraform/environments/$(ENV) && terraform fmt -check
else ifdef CLOUD
	@echo "Validating $(CLOUD) module..."
	cd $(PROJECT_ROOT)/terraform/modules/$(CLOUD) && terraform validate
	cd $(PROJECT_ROOT)/terraform/modules/$(CLOUD) && terraform fmt -check
else
	@echo "Error: ENV or CLOUD variable not set. Use: make validate ENV=<dev|staging|prod>"
	@exit 1
endif

# Validate all modules
validate-all:
	@echo "Validating all modules..."
	cd $(PROJECT_ROOT) && python scripts/python/validate_infrastructure.py

# Generate infrastructure diagrams
diagrams:
	@echo "Generating infrastructure diagrams..."
	cd $(PROJECT_ROOT) && python scripts/python/generate_diagrams.py

# Estimate costs
cost:
	@echo "Estimating infrastructure costs..."
	cd $(PROJECT_ROOT) && python scripts/python/cost_estimator.py

# Run tests
test:
	@echo "Running unit tests..."
	cd $(PROJECT_ROOT) && pytest tests/python/ -v

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	cd $(PROJECT_ROOT) && pytest tests/python/ --cov=scripts/python --cov-report=html --cov-report=term

# Format Terraform code
fmt:
	@echo "Formatting Terraform code..."
	cd $(PROJECT_ROOT)/terraform && terraform fmt -recursive .

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	cd $(PROJECT_ROOT) && find . -type f -name "*.tfstate" -delete
	cd $(PROJECT_ROOT) && find . -type f -name "*.tfstate.backup" -delete
	cd $(PROJECT_ROOT) && find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	cd $(PROJECT_ROOT) && find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	cd $(PROJECT_ROOT) && find . -type f -name "*.pyc" -delete
	cd $(PROJECT_ROOT) && find . -type f -name "cost-estimate.json" -delete
	cd $(PROJECT_ROOT) && rm -rf htmlcov/ .coverage .pytest_cache/

# Install Python dependencies
install:
	@echo "Installing Python dependencies..."
	cd $(PROJECT_ROOT) && pip install -r config/requirements.txt

# Setup development environment
setup: install
	@echo "Setting up development environment..."
	@echo "Installing pre-commit hooks..."
	pip install pre-commit
	@echo "Done! Run 'make help' to see available commands."

# Deploy to all clouds (with confirmation)
deploy-all:
	@echo "WARNING: This will deploy infrastructure to ALL cloud providers!"
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read confirm
	cd $(PROJECT_ROOT) && python scripts/python/infra_cli.py deploy-all

# Quick status check
status:
	@echo "=== Repository Status ==="
	@echo ""
	@echo "Git Status:"
	cd $(PROJECT_ROOT) && git status --short
	@echo ""
	@echo "Terraform State:"
	@for cloud in aws gcp azure; do \
		if [ -f "$(PROJECT_ROOT)/terraform/modules/$$cloud/.terraform/terraform.tfstate" ]; then \
			echo "  $$cloud: Initialized"; \
		else \
			echo "  $$cloud: Not initialized"; \
		fi; \
	done
	@echo ""
	@echo "Environments:"
	@for env in dev staging prod; do \
		if [ -f "$(PROJECT_ROOT)/terraform/environments/$$env/.terraform/terraform.tfstate" ]; then \
			echo "  $$env: Initialized"; \
		else \
			echo "  $$env: Not initialized"; \
		fi; \
	done

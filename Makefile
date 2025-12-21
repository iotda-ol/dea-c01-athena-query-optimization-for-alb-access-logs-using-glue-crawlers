.PHONY: help init plan apply destroy validate clean test diagrams cost

# Default target
help:
	@echo "Multi-Cloud Infrastructure Management"
	@echo ""
	@echo "Usage:"
	@echo "  make init CLOUD=<aws|gcp|azure>     - Initialize Terraform for cloud provider"
	@echo "  make plan CLOUD=<aws|gcp|azure>     - Plan infrastructure changes"
	@echo "  make apply CLOUD=<aws|gcp|azure>    - Apply infrastructure changes"
	@echo "  make destroy CLOUD=<aws|gcp|azure>  - Destroy infrastructure"
	@echo "  make validate CLOUD=<aws|gcp|azure> - Validate Terraform configuration"
	@echo "  make diagrams                        - Generate infrastructure diagrams"
	@echo "  make cost                            - Estimate infrastructure costs"
	@echo "  make test                            - Run Python unit tests"
	@echo "  make clean                           - Clean temporary files"
	@echo ""
	@echo "Examples:"
	@echo "  make init CLOUD=aws"
	@echo "  make apply CLOUD=gcp"
	@echo "  make diagrams"

# Initialize Terraform for a specific cloud
init:
ifndef CLOUD
	@echo "Error: CLOUD variable not set. Use: make init CLOUD=<aws|gcp|azure>"
	@exit 1
endif
	@echo "Initializing $(CLOUD) module..."
	cd modules/$(CLOUD) && terraform init

# Plan infrastructure changes
plan:
ifndef CLOUD
	@echo "Error: CLOUD variable not set. Use: make plan CLOUD=<aws|gcp|azure>"
	@exit 1
endif
	@echo "Planning $(CLOUD) infrastructure..."
	cd modules/$(CLOUD) && terraform plan

# Apply infrastructure changes
apply:
ifndef CLOUD
	@echo "Error: CLOUD variable not set. Use: make apply CLOUD=<aws|gcp|azure>"
	@exit 1
endif
	@echo "Applying $(CLOUD) infrastructure..."
	cd modules/$(CLOUD) && terraform apply

# Destroy infrastructure
destroy:
ifndef CLOUD
	@echo "Error: CLOUD variable not set. Use: make destroy CLOUD=<aws|gcp|azure>"
	@exit 1
endif
	@echo "Destroying $(CLOUD) infrastructure..."
	cd modules/$(CLOUD) && terraform destroy

# Validate Terraform configuration
validate:
ifndef CLOUD
	@echo "Error: CLOUD variable not set. Use: make validate CLOUD=<aws|gcp|azure>"
	@exit 1
endif
	@echo "Validating $(CLOUD) configuration..."
	cd modules/$(CLOUD) && terraform validate
	cd modules/$(CLOUD) && terraform fmt -check

# Validate all modules
validate-all:
	@echo "Validating all modules..."
	python scripts/python/validate_infrastructure.py

# Generate infrastructure diagrams
diagrams:
	@echo "Generating infrastructure diagrams..."
	python scripts/python/generate_diagrams.py

# Estimate costs
cost:
	@echo "Estimating infrastructure costs..."
	python scripts/python/cost_estimator.py

# Run tests
test:
	@echo "Running unit tests..."
	pytest tests/python/ -v

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	pytest tests/python/ --cov=scripts/python --cov-report=html --cov-report=term

# Format Terraform code
fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive .

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	find . -type f -name "*.tfstate" -delete
	find . -type f -name "*.tfstate.backup" -delete
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "cost-estimate.json" -delete
	rm -rf htmlcov/ .coverage .pytest_cache/

# Install Python dependencies
install:
	@echo "Installing Python dependencies..."
	pip install -r requirements.txt

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
	python scripts/python/infra_cli.py deploy-all

# Quick status check
status:
	@echo "=== Repository Status ==="
	@echo ""
	@echo "Git Status:"
	git status --short
	@echo ""
	@echo "Terraform State:"
	@for cloud in aws gcp azure; do \
		if [ -f "modules/$$cloud/.terraform/terraform.tfstate" ]; then \
			echo "  $$cloud: Initialized"; \
		else \
			echo "  $$cloud: Not initialized"; \
		fi; \
	done

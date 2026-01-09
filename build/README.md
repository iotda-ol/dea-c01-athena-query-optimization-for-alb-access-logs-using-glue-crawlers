# Build Configuration

This directory contains build and automation configuration files.

## Contents

- **Makefile** - Build automation and common tasks

## Usage

View all available commands:
```bash
cd .. && make help
```

Common commands:
```bash
# Initialize Terraform for a cloud provider
make init CLOUD=aws

# Plan infrastructure changes
make plan CLOUD=aws

# Apply infrastructure
make apply CLOUD=aws

# Generate diagrams
make diagrams

# Run tests
make test

# Clean temporary files
make clean
```

## Related

- **Terraform**: See `../terraform/` for infrastructure code
- **Scripts**: See `../scripts/` for automation scripts

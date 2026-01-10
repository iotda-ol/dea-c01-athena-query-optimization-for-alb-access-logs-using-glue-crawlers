# Repository Navigation Guide

This file provides a complete map of the repository structure to help you find what you need quickly.

## 🗂️ Directory Overview

```
Repository Root
│
├── 📄 README.md                    ← You are here (Main entry point)
├── 📄 Makefile                     ← Build automation (forwards to build/)
├── 📄 .gitignore                   ← Git exclusions
│
├── 🏗️  build/                      ← Build & Automation Configuration
│   ├── Makefile                    ← Main build automation
│   └── README.md                   ← Build documentation
│
├── ⚙️  config/                     ← Configuration Files
│   ├── requirements.txt            ← Python dependencies
│   └── README.md                   ← Configuration docs
│
├── 📚 docs/                        ← All Documentation
│   ├── README.md                   ← Documentation index
│   ├── architecture/               ← Architecture diagrams & docs
│   ├── development/                ← Developer guides
│   ├── guides/                     ← How-to guides
│   ├── operations/                 ← Operational guides
│   ├── project/                    ← Project documentation
│   └── tutorials/                  ← Step-by-step tutorials
│
├── 📝 examples/                    ← Example Configurations
│   ├── sample-logs/                ← Sample log files
│   └── upload-sample-logs.sh       ← Upload script
│
├── 🗺️  map-diagram-infra/          ← Infrastructure Diagrams
│   └── README.md                   ← Diagram documentation
│
├── 🔧 scripts/                     ← Automation Scripts
│   ├── bash/                       ← Shell scripts
│   └── python/                     ← Python utilities
│
├── 🏗️  terraform/                   ← Infrastructure as Code
│   ├── README.md                   ← Terraform documentation
│   ├── main.tf                     ← Root module
│   ├── variables.tf                ← Root variables
│   ├── outputs.tf                  ← Root outputs
│   ├── environments/               ← Environment configs
│   │   ├── dev/                    ← Development
│   │   ├── staging/                ← Staging
│   │   └── prod/                   ← Production
│   └── modules/                    ← Reusable modules
│       ├── aws/                    ← AWS resources
│       ├── azure/                  ← Azure resources
│       ├── gcp/                    ← GCP resources
│       └── common/                 ← Shared resources
│
└── 🧪 tests/                       ← Test Suites
    └── python/                     ← Python tests
```

## 🎯 Common Tasks

### Deploy Infrastructure
```bash
# Development environment
make init ENV=dev
make apply ENV=dev

# Production environment
make init ENV=prod
make apply ENV=prod
```

### Run Tests
```bash
make test
```

### Generate Diagrams
```bash
make diagrams
```

### Estimate Costs
```bash
make cost
```

### Clean Up
```bash
make clean
```

## 📖 Documentation Shortcuts

| What You Want | Where to Look |
|---------------|---------------|
| **Get Started** | [docs/operations/QUICKSTART.md](docs/operations/QUICKSTART.md) |
| **Understand Architecture** | [docs/project/ARCHITECTURE.md](docs/project/ARCHITECTURE.md) |
| **Contribute Code** | [docs/development/CONTRIBUTING.md](docs/development/CONTRIBUTING.md) |
| **Learn Best Practices** | [docs/development/DEA-C01-BEST-PRACTICES.md](docs/development/DEA-C01-BEST-PRACTICES.md) |
| **Complete Tutorial** | [docs/tutorials/100-STEP-GUIDE.md](docs/tutorials/100-STEP-GUIDE.md) |
| **Multi-Cloud Setup** | [docs/architecture/MULTI-CLOUD-ARCHITECTURE.md](docs/architecture/MULTI-CLOUD-ARCHITECTURE.md) |
| **See Changes** | [docs/operations/CHANGELOG.md](docs/operations/CHANGELOG.md) |

## 🔍 File Locations

### Infrastructure Code
- **Terraform Root**: `terraform/`
- **AWS Module**: `terraform/modules/aws/`
- **GCP Module**: `terraform/modules/gcp/`
- **Azure Module**: `terraform/modules/azure/`
- **Dev Environment**: `terraform/environments/dev/`
- **Staging Environment**: `terraform/environments/staging/`
- **Prod Environment**: `terraform/environments/prod/`

### Scripts & Tools
- **Python Scripts**: `scripts/python/`
  - Infrastructure CLI: `infra_cli.py`
  - Diagram Generator: `generate_diagrams.py`
  - Cost Estimator: `cost_estimator.py`
  - Validator: `validate_infrastructure.py`
- **Bash Scripts**: `scripts/bash/`
  - Quick Start: `quickstart.sh`

### Configuration
- **Python Dependencies**: `config/requirements.txt`
- **Build Config**: `build/Makefile`

### Tests
- **Python Tests**: `tests/python/`

### Examples
- **Sample Logs**: `examples/sample-logs/`
- **Upload Script**: `examples/upload-sample-logs.sh`

## 🚀 Quick Commands

```bash
# Show all available commands
make help

# Check repository status
make status

# Install dependencies
make install

# Setup dev environment
make setup

# Format code
make fmt

# Validate configuration
make validate ENV=dev

# Full cleanup
make clean
```

## 📝 Notes

- All documentation is in `docs/` organized by category
- All infrastructure code is in `terraform/` with clear separation
- All automation scripts are in `scripts/` by language
- Configuration files are in `config/`
- Build automation is in `build/`
- Root directory only has essential files (README, Makefile, .gitignore)

This structure maximizes organization, modularity, and ease of navigation! 🎉

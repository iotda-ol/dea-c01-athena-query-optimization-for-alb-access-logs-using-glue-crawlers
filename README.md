# Multi-Cloud Infrastructure Composer
## Universal Log Analysis Platform for AWS, GCP, and Azure

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple.svg)](https://www.terraform.io/)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![AWS](https://img.shields.io/badge/AWS-Supported-orange.svg)](https://aws.amazon.com/)
[![GCP](https://img.shields.io/badge/GCP-Supported-blue.svg)](https://cloud.google.com/)
[![Azure](https://img.shields.io/badge/Azure-Supported-blue.svg)](https://azure.microsoft.com/)

---

## 🎯 Overview

A comprehensive, production-ready, multi-cloud infrastructure solution for analyzing load balancer access logs. Built with **maximum modularity**, **reusability**, and **best practices** across AWS, GCP, and Azure.

### Key Features

- ✅ **Multi-Cloud Support**: Deploy to AWS, GCP, Azure, or all three simultaneously
- ✅ **Infrastructure as Code**: 100% Terraform-based with modular architecture
- ✅ **Python Automation**: CLI tools for deployment, validation, and cost estimation
- ✅ **Auto-Generated Diagrams**: Visual infrastructure maps for all clouds
- ✅ **100-Step Tutorial**: Complete guide from novice to expert
- ✅ **Production-Ready**: Security hardened, cost-optimized, scalable
- ✅ **Well-Architected**: Follows AWS, GCP, and Azure best practices

---

## 📁 Repository Structure

```
.
├── modules/                      # Terraform modules (organized by cloud)
│   ├── aws/                      # AWS implementation (S3, Glue, Athena)
│   ├── gcp/                      # GCP implementation (GCS, BigQuery)
│   ├── azure/                    # Azure implementation (Blob, Synapse)
│   └── common/                   # Shared/reusable components
│
├── scripts/                      # Automation scripts
│   ├── python/                   # Python utilities
│   │   ├── infra_cli.py         # Main CLI for infrastructure management
│   │   ├── generate_diagrams.py # Infrastructure diagram generator
│   │   ├── validate_infrastructure.py  # Validation utility
│   │   └── cost_estimator.py    # Cost estimation tool
│   └── bash/                     # Bash helper scripts
│
├── docs/                         # Documentation
│   ├── tutorials/                # Step-by-step guides
│   │   └── 100-STEP-GUIDE.md    # Comprehensive tutorial (novice → expert)
│   ├── architecture/             # Architecture documentation
│   │   └── MULTI-CLOUD-ARCHITECTURE.md
│   └── guides/                   # Best practices and guides
│       └── BEST-PRACTICES.md
│
├── map-diagram-infra/           # Auto-generated infrastructure diagrams
│   ├── README.md
│   ├── aws-infrastructure.png   # (Generated)
│   ├── gcp-infrastructure.png   # (Generated)
│   ├── azure-infrastructure.png # (Generated)
│   └── multi-cloud-infrastructure.png  # (Generated)
│
├── tests/                        # Test suites
│   ├── python/                   # Python unit tests
│   └── terraform/                # Terraform validation tests
│
├── examples/                     # Usage examples
│   ├── sample-logs/
│   └── upload-sample-logs.sh
│
├── main.tf                       # Root Terraform configuration
├── variables.tf                  # Root variables
├── outputs.tf                    # Root outputs
├── requirements.txt              # Python dependencies
├── README.md                     # This file
└── .gitignore                    # Git ignore patterns
```

---

## 🚀 Quick Start

### Prerequisites

- **Terraform** >= 1.0
- **Python** >= 3.8
- **Cloud CLI** for your chosen provider:
  - AWS CLI (for AWS)
  - gcloud CLI (for GCP)
  - Azure CLI (for Azure)
- **Git**

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd dea-c01-athena-query-optimization-for-alb-access-logs-using-glue-crawlers

# 2. Install Python dependencies
pip install -r requirements.txt

# 3. Choose your deployment path:
```

### Option A: Deploy to AWS

```bash
# Initialize AWS module
cd modules/aws
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

### Option B: Deploy to GCP

```bash
# Set GCP project
export TF_VAR_gcp_project_id="your-project-id"

# Initialize GCP module
cd modules/gcp
terraform init
terraform apply
```

### Option C: Deploy to Azure

```bash
# Set Azure subscription
export TF_VAR_azure_subscription_id="your-subscription-id"

# Initialize Azure module
cd modules/azure
terraform init
terraform apply
```

### Option D: Use Python CLI (Recommended)

```bash
# Deploy to AWS
python scripts/python/infra_cli.py init aws
python scripts/python/infra_cli.py plan aws
python scripts/python/infra_cli.py apply aws

# Or deploy to all clouds
python scripts/python/infra_cli.py deploy-all
```

---

## 📊 Architecture

### Common Pattern Across All Clouds

```
Load Balancer → Object Storage (Partitioned) → Metadata Catalog → Query Engine → Results
```

### AWS Implementation

```
ALB → S3 (partitioned) → Glue Crawler → Glue Catalog → Athena → Results S3
```

**Key Services:**
- Amazon S3: Log storage with date partitions
- AWS Glue: Automatic schema detection and partition management
- Amazon Athena: Serverless SQL queries with partition pruning

### GCP Implementation

```
Cloud LB → Cloud Storage → BigQuery Table (partitioned + clustered) → Query Results
```

**Key Services:**
- Cloud Storage: Log storage
- BigQuery: Partitioned tables with clustering for optimization

### Azure Implementation

```
Azure LB → Blob Storage → Synapse Workspace → Spark Pool → Query Results
```

**Key Services:**
- Blob Storage: Log storage with lifecycle management
- Azure Synapse: Analytics workspace with Spark processing

See [Multi-Cloud Architecture](docs/architecture/MULTI-CLOUD-ARCHITECTURE.md) for detailed diagrams.

---

## 🛠️ Python CLI Tools

### Infrastructure Management

```bash
# Initialize infrastructure
python scripts/python/infra_cli.py init <aws|gcp|azure>

# Plan changes
python scripts/python/infra_cli.py plan <aws|gcp|azure>

# Apply changes
python scripts/python/infra_cli.py apply <aws|gcp|azure> [--auto-approve]

# Destroy infrastructure
python scripts/python/infra_cli.py destroy <aws|gcp|azure> [--auto-approve]

# Validate configuration
python scripts/python/infra_cli.py validate <aws|gcp|azure>

# Show outputs
python scripts/python/infra_cli.py output <aws|gcp|azure>
```

### Diagram Generation

```bash
# Generate all infrastructure diagrams
python scripts/python/generate_diagrams.py

# Diagrams saved to: map-diagram-infra/
```

### Validation

```bash
# Validate all modules
python scripts/python/validate_infrastructure.py
```

### Cost Estimation

```bash
# Estimate infrastructure costs
python scripts/python/cost_estimator.py

# View detailed cost breakdown
```

---

## 📚 Documentation

### Quick Links

- **[100-Step Tutorial](docs/tutorials/100-STEP-GUIDE.md)** - Complete guide from novice to expert
- **[Architecture Overview](docs/architecture/MULTI-CLOUD-ARCHITECTURE.md)** - Detailed architecture documentation
- **[Best Practices](docs/guides/BEST-PRACTICES.md)** - Production deployment guidelines
- **[Diagram Map](map-diagram-infra/README.md)** - Infrastructure diagrams

### Learning Path

1. **Beginner**: Start with [100-Step Tutorial](docs/tutorials/100-STEP-GUIDE.md) Steps 1-20
2. **Intermediate**: Deploy to single cloud (Steps 21-60)
3. **Advanced**: Multi-cloud deployment (Steps 61-100)
4. **Expert**: Customize and extend the infrastructure

---

## 💰 Cost Estimation

### AWS (Standard Scenario: 100GB logs, 10 queries/day)

| Service | Monthly Cost |
|---------|-------------|
| S3 Storage (100GB) | $2.30 |
| Glue Crawler (30 runs) | $1.32 |
| Athena (300GB scanned) | $1.50 |
| **Total** | **~$5/month** |

### GCP (Similar Scenario)

| Service | Monthly Cost |
|---------|-------------|
| Cloud Storage (100GB) | $2.00 |
| BigQuery (300GB scanned + 100GB storage) | $3.50 |
| **Total** | **~$5.50/month** |

### Azure (Similar Scenario)

| Service | Monthly Cost |
|---------|-------------|
| Blob Storage (100GB) | $1.84 |
| Synapse Spark Pool (10 hours) | $15.00 |
| **Total** | **~$17/month** |

> **Note**: Costs vary by region and usage. Run `cost_estimator.py` for detailed estimates.

---

## 🔒 Security Features

- ✅ **Encryption**: All data encrypted at rest and in transit
- ✅ **Access Control**: Principle of least privilege IAM policies
- ✅ **Network Security**: Public access blocked on all storage
- ✅ **Audit Logging**: Complete audit trail for compliance
- ✅ **Secret Management**: No hard-coded credentials

See [Best Practices](docs/guides/BEST-PRACTICES.md) for security guidelines.

---

## 🧪 Testing

### Run Unit Tests

```bash
# Run Python tests
pytest tests/python/ -v

# Run with coverage
pytest tests/python/ --cov=scripts/python --cov-report=html
```

### Validate Terraform

```bash
# Validate all modules
python scripts/python/validate_infrastructure.py

# Or validate individual modules
cd modules/aws && terraform validate
cd modules/gcp && terraform validate
cd modules/azure && terraform validate
```

---

## 📈 Monitoring & Operations

### Key Metrics

- **Data Ingestion**: Logs received per hour
- **Query Performance**: Execution time, data scanned
- **Cost**: Query costs, storage costs
- **Reliability**: Success/failure rates

### Monitoring Tools

- **AWS**: CloudWatch Metrics & Alarms
- **GCP**: Cloud Monitoring (Stackdriver)
- **Azure**: Azure Monitor & Log Analytics

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add/update tests
5. Update documentation
6. Submit a pull request

---

## 📋 Roadmap

- [ ] Add partition projection support (AWS Athena)
- [ ] BI tool integration (QuickSight, Looker, Power BI)
- [ ] Real-time log processing
- [ ] ML/AI analytics integration
- [ ] Multi-region deployment support
- [ ] Kubernetes deployment option

---

## 🆘 Troubleshooting

### Common Issues

**Issue: Terraform state lock**
```bash
terraform force-unlock <LOCK_ID>
```

**Issue: Permission denied**
- Check IAM permissions for your cloud account
- Verify CLI is authenticated
- Review service account roles

**Issue: Module not found**
```bash
terraform init
```

See [100-Step Tutorial](docs/tutorials/100-STEP-GUIDE.md) Appendix B for detailed troubleshooting.

---

## 📄 License

This project is provided as-is for educational and demonstration purposes.

---

## 🙏 Acknowledgments

- AWS Well-Architected Framework
- GCP Architecture Framework
- Azure Well-Architected Framework
- Terraform Best Practices
- DEA-C01 Data Engineering Certification

---

## 📞 Support

- **Documentation**: See `docs/` directory
- **Issues**: GitHub Issues
- **Tutorial**: [100-Step Guide](docs/tutorials/100-STEP-GUIDE.md)

---

**Built with ❤️ for multi-cloud infrastructure automation**

**Version**: 2.0  
**Last Updated**: 2024-12-21

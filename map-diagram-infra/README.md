# Infrastructure Diagram Map

This directory contains automatically generated infrastructure diagrams for the multi-cloud log analysis system.

## Generated Diagrams

### 1. AWS Infrastructure (`aws-infrastructure.png`)
Visualizes the AWS implementation:
- Application Load Balancer (ALB)
- S3 Buckets (logs and query results)
- AWS Glue (database and crawler)
- Amazon Athena (workgroup)

### 2. GCP Infrastructure (`gcp-infrastructure.png`)
Visualizes the GCP implementation:
- Cloud Load Balancer
- Cloud Storage buckets
- BigQuery (dataset and partitioned table)

### 3. Azure Infrastructure (`azure-infrastructure.png`)
Visualizes the Azure implementation:
- Azure Load Balancer
- Blob Storage accounts
- Azure Synapse (workspace and Spark pool)

### 4. Multi-Cloud Overview (`multi-cloud-infrastructure.png`)
Unified view showing all three cloud providers and their parallel architectures.

## Generating Diagrams

To regenerate the diagrams, run:

```bash
python scripts/python/generate_diagrams.py
```

### Prerequisites

Install the required Python package:

```bash
pip install diagrams graphviz
```

You also need Graphviz installed on your system:

**Ubuntu/Debian:**
```bash
sudo apt-get install graphviz
```

**macOS:**
```bash
brew install graphviz
```

**Windows:**
Download from: https://graphviz.org/download/

## Diagram Format

All diagrams are generated in PNG format with high resolution suitable for:
- Documentation
- Presentations
- Architecture reviews
- Training materials

## Customization

To customize the diagrams, edit the `scripts/python/generate_diagrams.py` file.

You can modify:
- Diagram direction (TB, LR, BT, RL)
- Colors and styling
- Component labels
- Edge labels and connections
- Clusters and groupings

## Architecture Notes

### Data Flow Pattern (Common Across All Clouds)

1. **Ingestion**: Load balancer generates access logs
2. **Storage**: Logs stored in cloud object storage with date-based partitioning
3. **Cataloging**: Metadata catalog discovers schema and partitions
4. **Querying**: Query engine runs SQL queries with partition pruning
5. **Results**: Query results stored in dedicated storage location

### Key Design Principles

- **Serverless**: All components are managed services
- **Partitioned**: Data organized by date for efficient queries
- **Scalable**: Handles petabytes of data
- **Cost-optimized**: Pay only for resources used
- **Automated**: Minimal operational overhead

## Version History

- v1.0 - Initial diagram generation (AWS, GCP, Azure, Multi-cloud)

---

For more information, see the main [README.md](../README.md) and [100-Step Guide](../docs/tutorials/100-STEP-GUIDE.md).

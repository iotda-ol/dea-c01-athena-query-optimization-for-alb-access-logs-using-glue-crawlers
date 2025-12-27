#!/usr/bin/env python3
"""
Unit tests for infrastructure utilities
"""

import pytest
import os
import sys

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'scripts', 'python'))

from cost_estimator import (
    AWSCostEstimator,
    GCPCostEstimator,
    AzureCostEstimator,
    generate_cost_report
)

class TestAWSCostEstimator:
    """Test AWS cost estimation"""
    
    def test_s3_costs(self):
        """Test S3 cost calculation"""
        estimate = AWSCostEstimator.estimate_s3_costs(100, 10000)
        assert estimate.service == "S3"
        assert estimate.monthly_cost > 0
        assert estimate.unit == "USD"
    
    def test_glue_costs(self):
        """Test Glue crawler cost calculation"""
        estimate = AWSCostEstimator.estimate_glue_costs(30)
        assert estimate.service == "AWS Glue"
        assert estimate.monthly_cost > 0
        # 30 runs * 0.1 DPU-hours * $0.44 = $1.32
        assert estimate.monthly_cost == pytest.approx(1.32, rel=0.01)
    
    def test_athena_costs(self):
        """Test Athena cost calculation"""
        estimate = AWSCostEstimator.estimate_athena_costs(1.0)
        assert estimate.service == "Amazon Athena"
        # 1 TB * $5 = $5
        assert estimate.monthly_cost == 5.0

class TestGCPCostEstimator:
    """Test GCP cost estimation"""
    
    def test_gcs_costs(self):
        """Test Cloud Storage cost calculation"""
        estimate = GCPCostEstimator.estimate_gcs_costs(100)
        assert estimate.service == "Cloud Storage"
        assert estimate.monthly_cost > 0
    
    def test_bigquery_costs(self):
        """Test BigQuery cost calculation"""
        estimate = GCPCostEstimator.estimate_bigquery_costs(1.0, 100)
        assert estimate.service == "BigQuery"
        assert estimate.monthly_cost > 0

class TestAzureCostEstimator:
    """Test Azure cost estimation"""
    
    def test_blob_storage_costs(self):
        """Test Blob Storage cost calculation"""
        estimate = AzureCostEstimator.estimate_blob_storage_costs(100)
        assert estimate.service == "Blob Storage"
        assert estimate.monthly_cost > 0
    
    def test_synapse_costs(self):
        """Test Synapse cost calculation"""
        estimate = AzureCostEstimator.estimate_synapse_costs(10)
        assert estimate.service == "Azure Synapse"
        assert estimate.monthly_cost > 0

class TestCostReport:
    """Test cost report generation"""
    
    def test_generate_report(self):
        """Test generating comprehensive cost report"""
        report = generate_cost_report("standard")
        
        assert "scenario" in report
        assert report["scenario"] == "standard"
        
        assert "aws" in report
        assert "gcp" in report
        assert "azure" in report
        
        assert "total" in report["aws"]
        assert "total" in report["gcp"]
        assert "total" in report["azure"]
        
        assert report["grand_total"] > 0
    
    def test_invalid_scenario(self):
        """Test error handling for invalid scenario"""
        with pytest.raises(ValueError):
            generate_cost_report("invalid")

if __name__ == "__main__":
    pytest.main([__file__, "-v"])

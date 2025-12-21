#!/usr/bin/env python3
"""
Cost Estimation Utility
Estimates infrastructure costs across cloud providers
"""

import json
from typing import Dict, List
from dataclasses import dataclass

@dataclass
class CostEstimate:
    """Cost estimate for a resource"""
    service: str
    resource: str
    monthly_cost: float
    unit: str
    notes: str = ""

class AWSCostEstimator:
    """AWS cost estimation"""
    
    @staticmethod
    def estimate_s3_costs(storage_gb: float, requests_per_month: int) -> CostEstimate:
        """Estimate S3 storage costs"""
        # Standard storage: $0.023 per GB/month
        storage_cost = storage_gb * 0.023
        
        # PUT/COPY/POST/LIST: $0.005 per 1,000 requests
        request_cost = (requests_per_month / 1000) * 0.005
        
        total = storage_cost + request_cost
        
        return CostEstimate(
            service="S3",
            resource="Standard Storage",
            monthly_cost=round(total, 2),
            unit="USD",
            notes=f"{storage_gb}GB storage, {requests_per_month:,} requests/month"
        )
    
    @staticmethod
    def estimate_glue_costs(crawler_runs_per_month: int, dpu_hours_per_run: float = 0.1) -> CostEstimate:
        """Estimate Glue Crawler costs"""
        # $0.44 per DPU-Hour
        total = crawler_runs_per_month * dpu_hours_per_run * 0.44
        
        return CostEstimate(
            service="AWS Glue",
            resource="Crawler",
            monthly_cost=round(total, 2),
            unit="USD",
            notes=f"{crawler_runs_per_month} runs/month, {dpu_hours_per_run} DPU-hours/run"
        )
    
    @staticmethod
    def estimate_athena_costs(data_scanned_tb: float) -> CostEstimate:
        """Estimate Athena query costs"""
        # $5 per TB scanned
        total = data_scanned_tb * 5
        
        return CostEstimate(
            service="Amazon Athena",
            resource="Query Execution",
            monthly_cost=round(total, 2),
            unit="USD",
            notes=f"{data_scanned_tb}TB scanned/month"
        )

class GCPCostEstimator:
    """GCP cost estimation"""
    
    @staticmethod
    def estimate_gcs_costs(storage_gb: float, region: str = "us") -> CostEstimate:
        """Estimate Cloud Storage costs"""
        # Standard storage: $0.020 per GB/month (US multi-region)
        rate = 0.020 if region == "us" else 0.023
        total = storage_gb * rate
        
        return CostEstimate(
            service="Cloud Storage",
            resource="Standard Storage",
            monthly_cost=round(total, 2),
            unit="USD",
            notes=f"{storage_gb}GB storage in {region}"
        )
    
    @staticmethod
    def estimate_bigquery_costs(data_processed_tb: float, storage_gb: float) -> CostEstimate:
        """Estimate BigQuery costs"""
        # Query: $5 per TB processed
        # Storage: $0.020 per GB/month (active), $0.010 (long-term)
        query_cost = data_processed_tb * 5
        storage_cost = storage_gb * 0.020
        total = query_cost + storage_cost
        
        return CostEstimate(
            service="BigQuery",
            resource="Queries + Storage",
            monthly_cost=round(total, 2),
            unit="USD",
            notes=f"{data_processed_tb}TB processed, {storage_gb}GB stored"
        )

class AzureCostEstimator:
    """Azure cost estimation"""
    
    @staticmethod
    def estimate_blob_storage_costs(storage_gb: float) -> CostEstimate:
        """Estimate Blob Storage costs"""
        # LRS Hot: $0.0184 per GB/month
        total = storage_gb * 0.0184
        
        return CostEstimate(
            service="Blob Storage",
            resource="LRS Hot Tier",
            monthly_cost=round(total, 2),
            unit="USD",
            notes=f"{storage_gb}GB storage"
        )
    
    @staticmethod
    def estimate_synapse_costs(spark_pool_hours: float) -> CostEstimate:
        """Estimate Synapse Spark Pool costs"""
        # Small node: ~$0.50 per node-hour
        # 3 nodes minimum
        total = spark_pool_hours * 3 * 0.50
        
        return CostEstimate(
            service="Azure Synapse",
            resource="Spark Pool (Small, 3 nodes)",
            monthly_cost=round(total, 2),
            unit="USD",
            notes=f"{spark_pool_hours} hours/month"
        )

def generate_cost_report(scenario: str = "standard") -> Dict:
    """Generate comprehensive cost report"""
    
    if scenario == "standard":
        # Standard scenario: 100GB logs, 10 queries/day
        aws_costs = [
            AWSCostEstimator.estimate_s3_costs(100, 10000),
            AWSCostEstimator.estimate_glue_costs(30),
            AWSCostEstimator.estimate_athena_costs(0.3)  # 300GB scanned
        ]
        
        gcp_costs = [
            GCPCostEstimator.estimate_gcs_costs(100),
            GCPCostEstimator.estimate_bigquery_costs(0.3, 100)
        ]
        
        azure_costs = [
            AzureCostEstimator.estimate_blob_storage_costs(100),
            AzureCostEstimator.estimate_synapse_costs(10)
        ]
    
    else:
        raise ValueError(f"Unknown scenario: {scenario}")
    
    # Calculate totals
    aws_total = sum(c.monthly_cost for c in aws_costs)
    gcp_total = sum(c.monthly_cost for c in gcp_costs)
    azure_total = sum(c.monthly_cost for c in azure_costs)
    
    return {
        "scenario": scenario,
        "aws": {
            "costs": [vars(c) for c in aws_costs],
            "total": round(aws_total, 2)
        },
        "gcp": {
            "costs": [vars(c) for c in gcp_costs],
            "total": round(gcp_total, 2)
        },
        "azure": {
            "costs": [vars(c) for c in azure_costs],
            "total": round(azure_total, 2)
        },
        "grand_total": round(aws_total + gcp_total + azure_total, 2)
    }

def print_cost_report(report: Dict):
    """Print formatted cost report"""
    print("\n" + "="*80)
    print(f"COST ESTIMATE REPORT - Scenario: {report['scenario'].upper()}")
    print("="*80 + "\n")
    
    for cloud in ["aws", "gcp", "azure"]:
        data = report[cloud]
        print(f"\n{cloud.upper()}:")
        print("-" * 80)
        
        for cost in data["costs"]:
            print(f"  {cost['service']} - {cost['resource']}")
            print(f"    Cost: ${cost['monthly_cost']:.2f} {cost['unit']}/month")
            print(f"    Note: {cost['notes']}")
            print()
        
        print(f"  {cloud.upper()} TOTAL: ${data['total']:.2f}/month")
        print("-" * 80)
    
    print(f"\nGRAND TOTAL (All Clouds): ${report['grand_total']:.2f}/month")
    print("="*80 + "\n")

def main():
    """Main function"""
    report = generate_cost_report("standard")
    print_cost_report(report)
    
    # Save to JSON
    with open("cost-estimate.json", "w") as f:
        json.dump(report, f, indent=2)
    
    print("Cost estimate saved to cost-estimate.json")

if __name__ == "__main__":
    main()

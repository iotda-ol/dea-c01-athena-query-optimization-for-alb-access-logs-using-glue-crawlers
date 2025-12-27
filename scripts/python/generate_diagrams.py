#!/usr/bin/env python3
"""
Infrastructure Diagram Generator
Creates visual diagrams of multi-cloud infrastructure using diagrams library
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.aws.storage import S3
from diagrams.aws.analytics import Athena, Glue
from diagrams.aws.compute import LambdaFunction
from diagrams.aws.network import ELB
from diagrams.gcp.storage import GCS
from diagrams.gcp.analytics import BigQuery
from diagrams.gcp.compute import Functions
from diagrams.azure.storage import BlobStorage
from diagrams.azure.analytics import Synapse
from diagrams.azure.compute import FunctionApps
from diagrams.azure.network import LoadBalancers
import os

def create_aws_diagram(output_dir: str):
    """Create AWS infrastructure diagram"""
    with Diagram("AWS - ALB Logs Analysis", 
                 filename=f"{output_dir}/aws-infrastructure",
                 show=False,
                 direction="TB"):
        
        with Cluster("AWS Cloud"):
            with Cluster("Data Ingestion"):
                alb = ELB("Application\nLoad Balancer")
            
            with Cluster("Storage Layer"):
                logs_bucket = S3("ALB Logs\nBucket")
                results_bucket = S3("Athena Results\nBucket")
            
            with Cluster("Data Catalog"):
                glue_db = Glue("Glue Database")
                glue_crawler = Glue("Glue Crawler")
            
            with Cluster("Query Engine"):
                athena_wg = Athena("Athena\nWorkgroup")
            
            # Data flow
            alb >> Edge(label="access logs") >> logs_bucket
            logs_bucket >> Edge(label="crawl") >> glue_crawler
            glue_crawler >> Edge(label="catalog") >> glue_db
            glue_db >> Edge(label="metadata") >> athena_wg
            athena_wg >> Edge(label="results") >> results_bucket

def create_gcp_diagram(output_dir: str):
    """Create GCP infrastructure diagram"""
    with Diagram("GCP - Load Balancer Logs Analysis",
                 filename=f"{output_dir}/gcp-infrastructure",
                 show=False,
                 direction="TB"):
        
        with Cluster("Google Cloud Platform"):
            with Cluster("Data Ingestion"):
                lb = Functions("Cloud\nLoad Balancer")
            
            with Cluster("Storage Layer"):
                logs_bucket = GCS("LB Logs\nBucket")
                results_bucket = GCS("Query Results\nBucket")
            
            with Cluster("Analytics Engine"):
                bq_dataset = BigQuery("BigQuery\nDataset")
                bq_table = BigQuery("Partitioned\nTable")
            
            # Data flow
            lb >> Edge(label="access logs") >> logs_bucket
            logs_bucket >> Edge(label="load") >> bq_table
            bq_table >> Edge(label="metadata") >> bq_dataset
            bq_dataset >> Edge(label="results") >> results_bucket

def create_azure_diagram(output_dir: str):
    """Create Azure infrastructure diagram"""
    with Diagram("Azure - Load Balancer Logs Analysis",
                 filename=f"{output_dir}/azure-infrastructure",
                 show=False,
                 direction="TB"):
        
        with Cluster("Microsoft Azure"):
            with Cluster("Data Ingestion"):
                lb = LoadBalancers("Azure\nLoad Balancer")
            
            with Cluster("Storage Layer"):
                logs_storage = BlobStorage("LB Logs\nBlob Storage")
                results_storage = BlobStorage("Query Results\nBlob Storage")
            
            with Cluster("Analytics Engine"):
                synapse_ws = Synapse("Synapse\nWorkspace")
                synapse_pool = Synapse("Spark Pool")
            
            # Data flow
            lb >> Edge(label="access logs") >> logs_storage
            logs_storage >> Edge(label="process") >> synapse_pool
            synapse_pool >> Edge(label="workspace") >> synapse_ws
            synapse_ws >> Edge(label="results") >> results_storage

def create_multi_cloud_diagram(output_dir: str):
    """Create unified multi-cloud infrastructure diagram"""
    with Diagram("Multi-Cloud Log Analysis Architecture",
                 filename=f"{output_dir}/multi-cloud-infrastructure",
                 show=False,
                 direction="LR",
                 graph_attr={
                     "fontsize": "20",
                     "splines": "ortho"
                 }):
        
        with Cluster("AWS"):
            aws_lb = ELB("ALB")
            aws_storage = S3("S3")
            aws_catalog = Glue("Glue")
            aws_query = Athena("Athena")
            
            aws_lb >> aws_storage >> aws_catalog >> aws_query
        
        with Cluster("GCP"):
            gcp_lb = Functions("LB")
            gcp_storage = GCS("GCS")
            gcp_query = BigQuery("BigQuery")
            
            gcp_lb >> gcp_storage >> gcp_query
        
        with Cluster("Azure"):
            azure_lb = LoadBalancers("LB")
            azure_storage = BlobStorage("Blob")
            azure_query = Synapse("Synapse")
            
            azure_lb >> azure_storage >> azure_query

def main():
    """Main function to generate all diagrams"""
    output_dir = os.path.join(os.path.dirname(__file__), "..", "..", "map-diagram-infra")
    os.makedirs(output_dir, exist_ok=True)
    
    print("Generating infrastructure diagrams...")
    print(f"Output directory: {output_dir}")
    
    print("  - Creating AWS diagram...")
    create_aws_diagram(output_dir)
    
    print("  - Creating GCP diagram...")
    create_gcp_diagram(output_dir)
    
    print("  - Creating Azure diagram...")
    create_azure_diagram(output_dir)
    
    print("  - Creating multi-cloud diagram...")
    create_multi_cloud_diagram(output_dir)
    
    print("\nDiagrams generated successfully!")
    print(f"Check {output_dir}/ for the output files")

if __name__ == "__main__":
    main()

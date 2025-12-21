#!/usr/bin/env python3
"""
Infrastructure Management CLI
Unified command-line interface for deploying and managing multi-cloud infrastructure
"""

import argparse
import subprocess
import sys
import os
import json
from typing import Optional, List, Dict

class InfrastructureCLI:
    """Main CLI class for infrastructure management"""
    
    def __init__(self):
        self.repo_root = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
        self.modules_dir = os.path.join(self.repo_root, "modules")
    
    def run_terraform(self, command: str, module: str, vars_file: Optional[str] = None) -> int:
        """Run terraform command in specified module"""
        module_path = os.path.join(self.modules_dir, module)
        
        if not os.path.exists(module_path):
            print(f"Error: Module '{module}' not found at {module_path}")
            return 1
        
        cmd = ["terraform", command]
        if vars_file:
            cmd.extend(["-var-file", vars_file])
        
        print(f"Running: {' '.join(cmd)} in {module_path}")
        result = subprocess.run(cmd, cwd=module_path)
        return result.returncode
    
    def init(self, cloud: str) -> int:
        """Initialize Terraform for specified cloud provider"""
        print(f"Initializing {cloud.upper()} infrastructure...")
        return self.run_terraform("init", cloud)
    
    def plan(self, cloud: str, vars_file: Optional[str] = None) -> int:
        """Plan Terraform changes for specified cloud provider"""
        print(f"Planning {cloud.upper()} infrastructure changes...")
        return self.run_terraform("plan", cloud, vars_file)
    
    def apply(self, cloud: str, vars_file: Optional[str] = None, auto_approve: bool = False) -> int:
        """Apply Terraform changes for specified cloud provider"""
        print(f"Applying {cloud.upper()} infrastructure...")
        cmd = "apply"
        if auto_approve:
            cmd += " -auto-approve"
        return self.run_terraform(cmd, cloud, vars_file)
    
    def destroy(self, cloud: str, vars_file: Optional[str] = None, auto_approve: bool = False) -> int:
        """Destroy Terraform infrastructure for specified cloud provider"""
        print(f"Destroying {cloud.upper()} infrastructure...")
        cmd = "destroy"
        if auto_approve:
            cmd += " -auto-approve"
        return self.run_terraform(cmd, cloud, vars_file)
    
    def validate(self, cloud: str) -> int:
        """Validate Terraform configuration"""
        print(f"Validating {cloud.upper()} infrastructure configuration...")
        return self.run_terraform("validate", cloud)
    
    def output(self, cloud: str, output_name: Optional[str] = None) -> int:
        """Show Terraform outputs"""
        cmd = "output"
        if output_name:
            cmd += f" {output_name}"
        return self.run_terraform(cmd, cloud)
    
    def generate_diagrams(self) -> int:
        """Generate infrastructure diagrams"""
        print("Generating infrastructure diagrams...")
        diagram_script = os.path.join(self.repo_root, "scripts", "python", "generate_diagrams.py")
        
        if not os.path.exists(diagram_script):
            print(f"Error: Diagram script not found at {diagram_script}")
            return 1
        
        result = subprocess.run([sys.executable, diagram_script])
        return result.returncode
    
    def cost_estimate(self, cloud: str) -> int:
        """Estimate infrastructure costs"""
        print(f"Estimating costs for {cloud.upper()} infrastructure...")
        print("Note: This is a placeholder. Integrate with Infracost or similar tool.")
        return 0
    
    def deploy_all(self, auto_approve: bool = False) -> int:
        """Deploy infrastructure to all cloud providers"""
        clouds = ["aws", "gcp", "azure"]
        
        for cloud in clouds:
            print(f"\n{'='*60}")
            print(f"Deploying to {cloud.upper()}")
            print(f"{'='*60}\n")
            
            # Initialize
            if self.init(cloud) != 0:
                print(f"Failed to initialize {cloud}")
                continue
            
            # Validate
            if self.validate(cloud) != 0:
                print(f"Failed to validate {cloud}")
                continue
            
            # Plan
            if self.plan(cloud) != 0:
                print(f"Failed to plan {cloud}")
                continue
            
            # Apply (only if auto-approve)
            if auto_approve:
                if self.apply(cloud, auto_approve=True) != 0:
                    print(f"Failed to apply {cloud}")
                    return 1
        
        return 0

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Multi-Cloud Infrastructure Management CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Initialize AWS infrastructure
  python infra_cli.py init aws
  
  # Plan GCP infrastructure changes
  python infra_cli.py plan gcp
  
  # Apply Azure infrastructure
  python infra_cli.py apply azure --auto-approve
  
  # Generate diagrams
  python infra_cli.py diagrams
  
  # Deploy to all clouds
  python infra_cli.py deploy-all
        """
    )
    
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Init command
    init_parser = subparsers.add_parser("init", help="Initialize Terraform")
    init_parser.add_argument("cloud", choices=["aws", "gcp", "azure", "common"], help="Cloud provider")
    
    # Plan command
    plan_parser = subparsers.add_parser("plan", help="Plan infrastructure changes")
    plan_parser.add_argument("cloud", choices=["aws", "gcp", "azure", "common"], help="Cloud provider")
    plan_parser.add_argument("--vars-file", help="Path to variables file")
    
    # Apply command
    apply_parser = subparsers.add_parser("apply", help="Apply infrastructure changes")
    apply_parser.add_argument("cloud", choices=["aws", "gcp", "azure", "common"], help="Cloud provider")
    apply_parser.add_argument("--vars-file", help="Path to variables file")
    apply_parser.add_argument("--auto-approve", action="store_true", help="Auto-approve changes")
    
    # Destroy command
    destroy_parser = subparsers.add_parser("destroy", help="Destroy infrastructure")
    destroy_parser.add_argument("cloud", choices=["aws", "gcp", "azure", "common"], help="Cloud provider")
    destroy_parser.add_argument("--vars-file", help="Path to variables file")
    destroy_parser.add_argument("--auto-approve", action="store_true", help="Auto-approve destruction")
    
    # Validate command
    validate_parser = subparsers.add_parser("validate", help="Validate configuration")
    validate_parser.add_argument("cloud", choices=["aws", "gcp", "azure", "common"], help="Cloud provider")
    
    # Output command
    output_parser = subparsers.add_parser("output", help="Show outputs")
    output_parser.add_argument("cloud", choices=["aws", "gcp", "azure", "common"], help="Cloud provider")
    output_parser.add_argument("--name", help="Specific output name")
    
    # Diagrams command
    subparsers.add_parser("diagrams", help="Generate infrastructure diagrams")
    
    # Cost estimate command
    cost_parser = subparsers.add_parser("cost-estimate", help="Estimate infrastructure costs")
    cost_parser.add_argument("cloud", choices=["aws", "gcp", "azure"], help="Cloud provider")
    
    # Deploy all command
    deploy_all_parser = subparsers.add_parser("deploy-all", help="Deploy to all cloud providers")
    deploy_all_parser.add_argument("--auto-approve", action="store_true", help="Auto-approve changes")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return 1
    
    cli = InfrastructureCLI()
    
    # Execute command
    if args.command == "init":
        return cli.init(args.cloud)
    elif args.command == "plan":
        return cli.plan(args.cloud, args.vars_file)
    elif args.command == "apply":
        return cli.apply(args.cloud, args.vars_file, args.auto_approve)
    elif args.command == "destroy":
        return cli.destroy(args.cloud, args.vars_file, args.auto_approve)
    elif args.command == "validate":
        return cli.validate(args.cloud)
    elif args.command == "output":
        return cli.output(args.cloud, args.name)
    elif args.command == "diagrams":
        return cli.generate_diagrams()
    elif args.command == "cost-estimate":
        return cli.cost_estimate(args.cloud)
    elif args.command == "deploy-all":
        return cli.deploy_all(args.auto_approve)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())

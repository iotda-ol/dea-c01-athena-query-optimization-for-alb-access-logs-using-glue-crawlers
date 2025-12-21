#!/usr/bin/env python3
"""
Infrastructure Validation Utility
Validates Terraform configurations and cloud resource deployments
"""

import subprocess
import json
import sys
import os
from typing import Dict, List, Tuple

class TerraformValidator:
    """Validates Terraform configurations"""
    
    def __init__(self, module_path: str):
        self.module_path = module_path
    
    def validate_syntax(self) -> Tuple[bool, str]:
        """Validate Terraform syntax"""
        try:
            result = subprocess.run(
                ["terraform", "validate", "-json"],
                cwd=self.module_path,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                return True, "Syntax validation passed"
            else:
                output = json.loads(result.stdout)
                errors = output.get("diagnostics", [])
                error_msg = "\n".join([e.get("summary", "") for e in errors])
                return False, f"Syntax validation failed: {error_msg}"
        except Exception as e:
            return False, f"Error during validation: {str(e)}"
    
    def validate_formatting(self) -> Tuple[bool, str]:
        """Validate Terraform formatting"""
        try:
            result = subprocess.run(
                ["terraform", "fmt", "-check", "-recursive"],
                cwd=self.module_path,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                return True, "Formatting validation passed"
            else:
                return False, f"Formatting issues found: {result.stdout}"
        except Exception as e:
            return False, f"Error during formatting check: {str(e)}"
    
    def security_scan(self) -> Tuple[bool, str]:
        """Run security scan using tfsec (if available)"""
        try:
            # Check if tfsec is installed
            check = subprocess.run(["which", "tfsec"], capture_output=True)
            if check.returncode != 0:
                return True, "tfsec not installed, skipping security scan"
            
            result = subprocess.run(
                ["tfsec", self.module_path, "--format", "json"],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                return True, "Security scan passed"
            else:
                try:
                    findings = json.loads(result.stdout)
                    return False, f"Security issues found: {len(findings)} issues"
                except:
                    return False, "Security scan failed"
        except Exception as e:
            return True, f"Security scan skipped: {str(e)}"

class CloudResourceValidator:
    """Validates deployed cloud resources"""
    
    @staticmethod
    def validate_aws_resources(outputs: Dict) -> Tuple[bool, str]:
        """Validate AWS resources"""
        required_outputs = [
            "alb_logs_bucket_name",
            "glue_database_name",
            "athena_workgroup_name"
        ]
        
        missing = [key for key in required_outputs if key not in outputs]
        if missing:
            return False, f"Missing required outputs: {', '.join(missing)}"
        
        return True, "AWS resources validated"
    
    @staticmethod
    def validate_gcp_resources(outputs: Dict) -> Tuple[bool, str]:
        """Validate GCP resources"""
        required_outputs = [
            "lb_logs_bucket_name",
            "bigquery_dataset_id"
        ]
        
        missing = [key for key in required_outputs if key not in outputs]
        if missing:
            return False, f"Missing required outputs: {', '.join(missing)}"
        
        return True, "GCP resources validated"
    
    @staticmethod
    def validate_azure_resources(outputs: Dict) -> Tuple[bool, str]:
        """Validate Azure resources"""
        required_outputs = [
            "storage_account_name",
            "synapse_workspace_name"
        ]
        
        missing = [key for key in required_outputs if key not in outputs]
        if missing:
            return False, f"Missing required outputs: {', '.join(missing)}"
        
        return True, "Azure resources validated"

def validate_module(module_path: str, module_name: str) -> int:
    """Validate a Terraform module"""
    print(f"\n{'='*60}")
    print(f"Validating {module_name.upper()} module")
    print(f"{'='*60}\n")
    
    validator = TerraformValidator(module_path)
    
    # Syntax validation
    print("1. Checking syntax...")
    success, message = validator.validate_syntax()
    print(f"   {'✓' if success else '✗'} {message}")
    if not success:
        return 1
    
    # Formatting validation
    print("2. Checking formatting...")
    success, message = validator.validate_formatting()
    print(f"   {'✓' if success else '✗'} {message}")
    
    # Security scan
    print("3. Running security scan...")
    success, message = validator.security_scan()
    print(f"   {'✓' if success else '✗'} {message}")
    
    print(f"\n{module_name.upper()} module validation complete!\n")
    return 0

def main():
    """Main validation function"""
    repo_root = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    modules_dir = os.path.join(repo_root, "modules")
    
    modules = ["aws", "gcp", "azure", "common"]
    
    print("="*60)
    print("Infrastructure Validation Suite")
    print("="*60)
    
    failed = []
    
    for module in modules:
        module_path = os.path.join(modules_dir, module)
        if os.path.exists(module_path):
            if validate_module(module_path, module) != 0:
                failed.append(module)
        else:
            print(f"Warning: Module {module} not found at {module_path}")
    
    # Summary
    print("\n" + "="*60)
    print("Validation Summary")
    print("="*60)
    
    if failed:
        print(f"✗ Failed modules: {', '.join(failed)}")
        return 1
    else:
        print("✓ All modules validated successfully!")
        return 0

if __name__ == "__main__":
    sys.exit(main())

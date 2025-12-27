#!/bin/bash
# Quick Start Script for Multi-Cloud Infrastructure
# This script helps you get started quickly with deployment

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Multi-Cloud Infrastructure Quick Start${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing=0
    
    # Check Git
    if command -v git &> /dev/null; then
        print_success "Git installed"
    else
        print_error "Git not found. Please install Git."
        missing=1
    fi
    
    # Check Terraform
    if command -v terraform &> /dev/null; then
        print_success "Terraform installed ($(terraform version | head -n1))"
    else
        print_error "Terraform not found. Please install Terraform >= 1.0"
        missing=1
    fi
    
    # Check Python
    if command -v python3 &> /dev/null; then
        print_success "Python installed ($(python3 --version))"
    else
        print_error "Python 3 not found. Please install Python >= 3.8"
        missing=1
    fi
    
    # Check pip
    if command -v pip3 &> /dev/null; then
        print_success "pip installed"
    else
        print_warning "pip not found. Some Python features may not work."
    fi
    
    echo ""
    
    if [ $missing -eq 1 ]; then
        print_error "Missing required prerequisites. Please install them and try again."
        exit 1
    fi
    
    print_success "All prerequisites met!"
    echo ""
}

setup_python_env() {
    print_info "Setting up Python environment..."
    
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt > /dev/null 2>&1
        print_success "Python dependencies installed"
    else
        print_warning "requirements.txt not found, skipping Python setup"
    fi
    
    echo ""
}

select_cloud() {
    echo "Which cloud provider would you like to deploy to?"
    echo ""
    echo "  1) AWS (Amazon Web Services)"
    echo "  2) GCP (Google Cloud Platform)"
    echo "  3) Azure (Microsoft Azure)"
    echo "  4) All clouds"
    echo "  5) Exit"
    echo ""
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1)
            CLOUD="aws"
            ;;
        2)
            CLOUD="gcp"
            ;;
        3)
            CLOUD="azure"
            ;;
        4)
            CLOUD="all"
            ;;
        5)
            print_info "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid choice. Exiting."
            exit 1
            ;;
    esac
    
    echo ""
}

check_cloud_cli() {
    case $CLOUD in
        aws)
            if command -v aws &> /dev/null; then
                print_success "AWS CLI installed"
            else
                print_warning "AWS CLI not found. You'll need it to deploy to AWS."
                read -p "Continue anyway? (y/n): " continue
                if [ "$continue" != "y" ]; then
                    exit 0
                fi
            fi
            ;;
        gcp)
            if command -v gcloud &> /dev/null; then
                print_success "gcloud CLI installed"
            else
                print_warning "gcloud CLI not found. You'll need it to deploy to GCP."
                read -p "Continue anyway? (y/n): " continue
                if [ "$continue" != "y" ]; then
                    exit 0
                fi
            fi
            ;;
        azure)
            if command -v az &> /dev/null; then
                print_success "Azure CLI installed"
            else
                print_warning "Azure CLI not found. You'll need it to deploy to Azure."
                read -p "Continue anyway? (y/n): " continue
                if [ "$continue" != "y" ]; then
                    exit 0
                fi
            fi
            ;;
    esac
    
    echo ""
}

init_terraform() {
    if [ "$CLOUD" = "all" ]; then
        print_info "Initializing Terraform for all clouds..."
        
        for cloud in aws gcp azure; do
            if [ -d "modules/$cloud" ]; then
                print_info "Initializing $cloud..."
                (cd "modules/$cloud" && terraform init > /dev/null 2>&1)
                print_success "$cloud initialized"
            fi
        done
    else
        if [ -d "modules/$CLOUD" ]; then
            print_info "Initializing Terraform for $CLOUD..."
            (cd "modules/$CLOUD" && terraform init > /dev/null 2>&1)
            print_success "$CLOUD initialized"
        else
            print_error "Module for $CLOUD not found"
            exit 1
        fi
    fi
    
    echo ""
}

show_next_steps() {
    echo ""
    print_header
    print_success "Setup complete!"
    echo ""
    print_info "Next steps:"
    echo ""
    
    if [ "$CLOUD" = "all" ]; then
        echo "  1. Configure cloud provider credentials"
        echo "     - AWS: aws configure"
        echo "     - GCP: gcloud auth login"
        echo "     - Azure: az login"
        echo ""
        echo "  2. Review and customize variables (optional)"
        echo "     - Edit modules/*/variables.tf"
        echo ""
        echo "  3. Deploy infrastructure:"
        echo "     make plan CLOUD=aws    # Preview changes"
        echo "     make apply CLOUD=aws   # Deploy to AWS"
        echo ""
        echo "     Or use Python CLI:"
        echo "     python scripts/python/infra_cli.py apply aws"
    else
        echo "  1. Configure $CLOUD credentials:"
        case $CLOUD in
            aws)
                echo "     aws configure"
                ;;
            gcp)
                echo "     gcloud auth login"
                echo "     gcloud config set project YOUR_PROJECT_ID"
                ;;
            azure)
                echo "     az login"
                echo "     az account set --subscription YOUR_SUBSCRIPTION"
                ;;
        esac
        echo ""
        echo "  2. Review and customize variables (optional):"
        echo "     modules/$CLOUD/variables.tf"
        echo ""
        echo "  3. Deploy infrastructure:"
        echo "     make plan CLOUD=$CLOUD     # Preview changes"
        echo "     make apply CLOUD=$CLOUD    # Deploy"
        echo ""
        echo "     Or use Python CLI:"
        echo "     python scripts/python/infra_cli.py apply $CLOUD"
    fi
    
    echo ""
    echo "  4. Generate infrastructure diagrams (optional):"
    echo "     make diagrams"
    echo ""
    echo "  5. Estimate costs (optional):"
    echo "     make cost"
    echo ""
    print_info "For detailed instructions, see:"
    echo "  - README.md"
    echo "  - docs/tutorials/100-STEP-GUIDE.md"
    echo ""
}

# Main execution
main() {
    print_header
    
    check_prerequisites
    
    print_info "Setting up Python environment..."
    setup_python_env
    
    select_cloud
    
    if [ "$CLOUD" != "all" ]; then
        check_cloud_cli
    fi
    
    init_terraform
    
    show_next_steps
}

# Run main
main

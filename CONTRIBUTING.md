# Contributing to Multi-Cloud Infrastructure Composer

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Coding Standards](#coding-standards)
5. [Testing Requirements](#testing-requirements)
6. [Documentation](#documentation)
7. [Pull Request Process](#pull-request-process)

---

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards others

---

## Getting Started

### Prerequisites

- Git
- Terraform >= 1.0
- Python >= 3.8
- Cloud provider CLI (AWS/GCP/Azure)

### Setup Development Environment

```bash
# Clone the repository
git clone <repository-url>
cd dea-c01-athena-query-optimization-for-alb-access-logs-using-glue-crawlers

# Install dependencies
make install

# Or manually:
pip install -r requirements.txt
```

---

## Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

### 2. Make Changes

- Write code following our coding standards
- Add/update tests
- Update documentation
- Run validation locally

### 3. Test Your Changes

```bash
# Validate Terraform
make validate-all

# Run Python tests
make test

# Generate diagrams (if applicable)
make diagrams
```

### 4. Commit Changes

Follow conventional commit messages:

```bash
git commit -m "feat: add new GCP feature"
git commit -m "fix: correct AWS IAM policy"
git commit -m "docs: update README with examples"
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

---

## Coding Standards

### Terraform

- Use consistent naming: `{resource_type}_{purpose}`
- Add comments for complex logic
- Use variables for configurable values
- Include descriptions for all variables
- Document all outputs

Example:
```hcl
variable "retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 90
  
  validation {
    condition     = var.retention_days >= 1 && var.retention_days <= 3650
    error_message = "Retention must be between 1 and 3650 days."
  }
}
```

### Python

- Follow PEP 8 style guide
- Use type hints
- Write docstrings for functions
- Keep functions focused and small
- Use meaningful variable names

Example:
```python
def estimate_costs(
    storage_gb: float,
    queries_per_month: int
) -> CostEstimate:
    """
    Estimate infrastructure costs.
    
    Args:
        storage_gb: Amount of storage in GB
        queries_per_month: Number of queries per month
        
    Returns:
        CostEstimate object with breakdown
    """
    # Implementation
```

### Documentation

- Use Markdown for all documentation
- Include code examples
- Keep README files up-to-date
- Add inline comments for complex logic
- Document breaking changes

---

## Testing Requirements

### Terraform Tests

All Terraform modules must:
- Pass `terraform validate`
- Pass `terraform fmt -check`
- Be tested with `terraform plan`

```bash
cd modules/aws
terraform init
terraform validate
terraform fmt -check
```

### Python Tests

All Python code must:
- Have unit tests with >80% coverage
- Pass pytest
- Follow type hints

```bash
# Run tests
pytest tests/python/ -v

# Check coverage
pytest tests/python/ --cov=scripts/python --cov-report=term
```

### Adding Tests

When adding new features:

1. **Terraform**: Add example in module README
2. **Python**: Add unit tests in `tests/python/`

Example test:
```python
def test_cost_estimation():
    """Test cost estimation accuracy"""
    estimate = estimate_s3_costs(100, 10000)
    assert estimate.monthly_cost > 0
    assert estimate.service == "S3"
```

---

## Documentation

### Required Documentation

When adding features, update:

1. **Module README**: If changing modules
2. **Root README**: If changing architecture
3. **Tutorial**: If adding user-facing features
4. **Architecture Docs**: If changing design

### Documentation Structure

```
docs/
├── architecture/     # Technical architecture
├── tutorials/        # How-to guides
└── guides/          # Best practices
```

---

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Tests added/updated and passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] No sensitive data committed
- [ ] Branch is up-to-date with main

### PR Template

```markdown
## Description
[Describe your changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
[Describe testing performed]

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

### Review Process

1. Automated checks run
2. At least one reviewer approves
3. All discussions resolved
4. Merge to main

### After Merge

- Delete your branch
- Update local main branch
- Close related issues

---

## Issue Reporting

### Bug Reports

Include:
- Description of the bug
- Steps to reproduce
- Expected vs actual behavior
- Environment details
- Error messages/logs

### Feature Requests

Include:
- Use case description
- Proposed solution
- Alternative solutions considered
- Additional context

---

## Questions?

- Check existing documentation
- Search closed issues
- Ask in discussions
- Create a new issue

---

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in commit messages

---

**Thank you for contributing!** 🎉

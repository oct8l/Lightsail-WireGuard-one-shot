# GitHub Actions CI Workflows

This directory contains automated CI workflows that validate changes to the repository.

## Workflows

### 1. Ansible Validation (`ansible-validation.yml`)
Validates Ansible playbooks and configuration files.

**Triggered on:**
- Pull requests that modify `ansible/**` files
- Pushes to `main` branch that modify `ansible/**` files

**Checks performed:**
- ✅ YAML syntax validation with `yamllint`
- ✅ Ansible playbook syntax check
- ✅ `requirements.yml` structure validation
- ✅ Validation that all role/collection references in playbooks exist in `requirements.yml`
- ✅ `ansible-lint` checks (non-blocking)

### 2. Ansible Dependencies Test (`ansible-dependencies.yml`)
Tests that all Ansible dependencies can be successfully installed.

**Triggered on:**
- Pull requests that modify `ansible/requirements.yml`
- Pushes to `main` branch that modify `ansible/requirements.yml`

**Checks performed:**
- ✅ Installation of all collections from `requirements.yml`
- ✅ Installation of all roles from `requirements.yml`
- ✅ Verification that each dependency is properly installed
- ✅ Lists all installed collections and roles for inspection

**Why this matters:** This workflow catches dependency issues that Renovate would encounter, ensuring all packages exist and can be installed before they're merged.

### 3. Renovate Validation (`renovate-validation.yml`)
Validates that Renovate can successfully look up and update all dependencies.

**Triggered on:**
- Pull requests that modify `renovate.json` or `ansible/requirements.yml`
- Pushes to `main` branch that modify these files

**Checks performed:**
- ✅ `renovate.json` syntax validation
- ✅ Checks that all Ansible Galaxy collections exist (via API)
- ✅ Checks that all Ansible Galaxy roles exist (via API)
- ✅ Detects known problematic packages

**Why this matters:** This prevents Renovate lookup failures and ensures dependency updates work smoothly.

### 4. Terraform Validation (`terraform-validation.yml`)
Validates Terraform configuration files.

**Triggered on:**
- Pull requests that modify `terraform/**` files
- Pushes to `main` branch that modify `terraform/**` files

**Checks performed:**
- ✅ Terraform formatting check
- ✅ Terraform initialization
- ✅ Terraform configuration validation

### 5. Shell Script Validation (`shell-validation.yml`)
Validates shell scripts for syntax and best practices.

**Triggered on:**
- Pull requests that modify `.sh` files
- Pushes to `main` branch that modify `.sh` files

**Checks performed:**
- ✅ ShellCheck validation for best practices and common issues
- ✅ Script permission checks
- ✅ Bash syntax validation

## Why These Workflows?

These automated tests ensure that:
1. **Pull requests don't break functionality** - Changes are validated before merge
2. **Dependencies are valid** - Ansible roles/collections exist and are properly referenced
3. **Code quality is maintained** - Syntax errors and common issues are caught early
4. **Renovate updates work correctly** - Dependency updates are automatically validated

## Local Testing

You can run similar checks locally before submitting a PR:

### Ansible
```bash
pip install ansible ansible-lint yamllint
yamllint ansible/
ansible-playbook --syntax-check ansible/wireguard-server.yml
ansible-lint ansible/wireguard-server.yml

# Test dependency installation
ansible-galaxy collection install -r ansible/requirements.yml
ansible-galaxy role install -r ansible/requirements.yml
```

### Terraform
```bash
cd terraform
terraform fmt -check
terraform init -backend=false
terraform validate
```

### Shell Scripts
```bash
shellcheck *.sh
bash -n *.sh
```

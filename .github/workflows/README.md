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
- ✅ Detection of non-existent or deprecated packages (e.g., `lablabs.wireguard`)
- ✅ Validation that all role/collection references in playbooks exist in `requirements.yml`
- ✅ `ansible-lint` checks (non-blocking)

### 2. Terraform Validation (`terraform-validation.yml`)
Validates Terraform configuration files.

**Triggered on:**
- Pull requests that modify `terraform/**` files
- Pushes to `main` branch that modify `terraform/**` files

**Checks performed:**
- ✅ Terraform formatting check
- ✅ Terraform initialization
- ✅ Terraform configuration validation

### 3. Shell Script Validation (`shell-validation.yml`)
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

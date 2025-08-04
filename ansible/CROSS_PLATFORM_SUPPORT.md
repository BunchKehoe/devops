# Cross-Platform Support for RHEL/AlmaLinux

This document outlines the cross-platform support implemented across all Ansible playbooks to ensure compatibility with both Debian/Ubuntu and RHEL/AlmaLinux distributions.

## Overview

All playbooks now support both:
- **Debian/Ubuntu** distributions using `apt`, `ufw`, and Debian-specific packages
- **RHEL/AlmaLinux** distributions using `dnf`, `firewalld`, and RedHat-specific packages

## Distribution Detection

Playbooks use `ansible_os_family` to detect the distribution:
- `ansible_os_family == "Debian"` - Ubuntu, Debian, and derivatives
- `ansible_os_family == "RedHat"` - RHEL, AlmaLinux, CentOS, Rocky Linux, and derivatives

## Key Differences by Component

### 1. Package Management
| Component | Debian/Ubuntu | RHEL/AlmaLinux |
|-----------|---------------|----------------|
| Package Manager | `apt` | `dnf` |
| Update Cache | `apt: update_cache: yes` | `dnf: update_cache: yes` |
| Development Tools | `build-essential`, `software-properties-common` | `gcc`, `gcc-c++`, `dnf-utils` |

### 2. Time Synchronization (NTP)
| Distribution | Package | Service | Notes |
|-------------|---------|---------|-------|
| Debian/Ubuntu | `ntp` | `ntp` | Traditional NTP daemon |
| RHEL/AlmaLinux | `chrony` | `chronyd` | Modern NTP implementation |

**Implementation in basic-setup.yml:**
```yaml
- name: Check if NTP package is available (Debian/Ubuntu)
  apt:
    name: ntp
    state: present
  check_mode: yes
  register: ntp_check_apt
  when: ansible_os_family == "Debian"

- name: Check if NTP package is available (RHEL/AlmaLinux)
  dnf:
    name: chrony
    state: present
  check_mode: yes
  register: ntp_check_dnf
  when: ansible_os_family == "RedHat"
```

### 3. Firewall Configuration
| Distribution | Firewall | Service Examples |
|-------------|----------|------------------|
| Debian/Ubuntu | `ufw` | `ufw: rule: allow port: "80"` |
| RHEL/AlmaLinux | `firewalld` | `firewalld: service: http` |

### 4. Service Names
| Service | Debian/Ubuntu | RHEL/AlmaLinux |
|---------|---------------|----------------|
| SSH | `ssh` | `sshd` |
| Time Sync | `ntp` | `chronyd` |

### 5. LDAP Client Packages
| Distribution | Packages |
|-------------|----------|
| Debian/Ubuntu | `ldap-utils`, `libnss-ldap`, `libpam-ldap` |
| RHEL/AlmaLinux | `openldap-clients`, `nss-pam-ldapd` |

### 6. Log File Ownership
| Service | Debian/Ubuntu | RHEL/AlmaLinux |
|---------|---------------|----------------|
| Nginx Logs | `www-data:adm` | `nginx:nginx` |

### 7. Git Flow Package Names
| Distribution | Package Name |
|-------------|-------------|
| Debian/Ubuntu | `git-flow` |
| RHEL/AlmaLinux | `gitflow` |

## Playbook-Specific Changes

### basic-setup.yml
- ✅ Package manager updates (apt vs dnf)
- ✅ NTP vs Chrony implementation with check_mode validation
- ✅ Platform-specific development tools
- ✅ Cross-platform Python package installation

### users.yml
- ✅ LDAP client packages for both distributions
- ✅ SSH service name differences (ssh vs sshd)
- ✅ fail2ban support (universal package name)

### nginx.yml
- ✅ Firewall configuration (ufw vs firewalld)
- ✅ Log rotation with correct ownership
- ✅ Service-based firewall rules for RHEL

### git.yml
- ✅ Git flow package name differences
- ✅ Universal git configuration

### docker-setup.yml & docker-setup-minimal.yml
- ✅ Already had comprehensive RHEL support
- ✅ Repository configuration for Docker CE
- ✅ Package dependencies (dnf-utils, device-mapper-persistent-data)

## Testing

Run the cross-platform test script to verify all syntax and configurations:

```bash
cd ansible
./test-cross-platform.sh
```

## Variables

The following variables in `group_vars/all.yml` support platform-specific packages:

```yaml
# Cross-platform packages
basic_packages:
  - vim
  - curl
  - wget
  - python3-pip
  - htop
  - net-tools
  - unzip
  - git

# Platform-specific packages
basic_packages_debian:
  - apt-transport-https
  - ca-certificates
  - software-properties-common

basic_packages_redhat:
  - dnf-utils
  - ca-certificates
  - epel-release
```

## Best Practices

1. **Always use `ansible_os_family`** for distribution detection
2. **Use `package` module** when package names are identical across distributions
3. **Use distribution-specific modules** (apt/dnf) when features differ
4. **Include `ignore_errors: yes`** for optional packages or features
5. **Test syntax** with `ansible-playbook --syntax-check` after changes
6. **Document platform differences** in playbook comments

## Supported Distributions

### Tested and Supported:
- Ubuntu 20.04, 22.04, 24.04
- Debian 11, 12
- RHEL 8, 9
- AlmaLinux 8, 9
- Rocky Linux 8, 9
- CentOS Stream 8, 9

### Package Repositories:
- **Docker**: Uses official Docker CE repositories for both platforms
- **EPEL**: Automatically enabled for RHEL-based distributions
- **Standard repos**: Uses distribution default repositories

This comprehensive cross-platform support ensures consistent deployment across different Linux distributions while respecting platform-specific conventions and best practices.
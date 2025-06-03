# ⚠️ SECURITY WARNING

**DO NOT ADD SSH KEYS TO THIS REPOSITORY!**

- ✅ `README.md` and `config` files should be in this repo and stowed
- ❌ SSH private keys (e.g., `github_key`, `aws_key`, `work_key`) should **NEVER** be committed
- ❌ SSH public keys should also be kept outside the repo for security

The actual SSH keys should be stored locally in your actual `~/.ssh` folder, outside of this repo.

Note that any files in the .ssh directory are ignored by git except for `*.md` and `config` files.

---

# SSH Configuration Structure

This directory is organized by service, with each service containing its own SSH configuration and keys.

## Directory Structure

```
.ssh/
├── config                   # Main SSH config (contains Include statements)
├── aws/
│   ├── config               # AWS-specific SSH hosts and settings
│   ├── aws_key              # Private key for AWS services
│   └── aws_key.pub          # Public key for AWS services
├── github/
│   ├── config               # GitHub SSH configuration
│   ├── github_key           # Private key for GitHub
│   └── github_key.pub       # Public key for GitHub
└── work/
    ├── config               # Work-related SSH hosts
    ├── work_key             # Private key for work servers
    └── work_key.pub         # Public key for work servers
```

## How It Works

The main `~/.ssh/config` file includes all service-specific configurations:

```bash
# Config for each service
Include ~/.ssh/git/config
Include ~/.ssh/aws/config
Include ~/.ssh/hostinger/config

# Global defaults
Host *
    IdentitiesOnly yes
    ServerAliveInterval 60
```

Each service directory contains:
- **config**: SSH host configurations specific to that service
- **service_key**: Private SSH key (permissions: 600)  
- **service_key.pub**: Public SSH key (permissions: 644)

## Benefits

- **Organized**: Everything for each service is grouped together
- **Portable**: Easy to backup or share specific service configurations
- **Clear**: No confusion about which keys belong to which services
- **Maintainable**: Changes to one service don't affect others

## Adding New Services

1. Create a new directory: `mkdir ~/.ssh/newservice`
2. Generate keys: `ssh-keygen -t ed25519 -f ~/.ssh/newservice/newservice_key`
3. Create config file: `~/.ssh/newservice/config`
4. Add include to main config: `Include ~/.ssh/newservice/config`

## Security Notes

- Private keys should have 600 permissions
- Public keys should have 644 permissions  
- Service directories should have 700 permissions
- Never commit private keys to version control
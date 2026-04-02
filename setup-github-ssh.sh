#!/bin/bash

KEY_FILE="$HOME/.ssh/github"
SSH_TARGET="git@github.com:jadenbertino/.dotfiles.git"

if [ -f "$KEY_FILE" ]; then
  echo "GitHub SSH key already exists at $KEY_FILE, skipping."
  return 0 2>/dev/null || exit 0
fi

echo "Generating GitHub SSH key..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keygen -t ed25519 -C "jaden@bertinofamily.com" -f "$KEY_FILE" -N "" > /dev/null 2>&1

# Update SSH config
SSH_CONFIG="$HOME/.ssh/config"
if grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
  echo "SSH config already has a github.com entry, skipping."
else
  cat >> "$SSH_CONFIG" << EOF

Host github.com
  HostName github.com
  User git
  IdentityFile $KEY_FILE
  IdentitiesOnly yes
EOF
  chmod 600 "$SSH_CONFIG"
fi

echo ""
echo "1. Copy this public key:"
echo ""
cat "$KEY_FILE.pub"
echo ""
echo -e "2. Go to \e]8;;https://github.com/settings/ssh/new\e\\https://github.com/settings/ssh/new\e]8;;\e\\ to add this key"

# Update dotfiles remote to SSH
git -C "$(dirname "${BASH_SOURCE[0]:-$0}")" remote set-url origin "$SSH_TARGET"

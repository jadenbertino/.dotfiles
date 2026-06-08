#!/bin/bash

set -euo pipefail

KEY_FILE="$HOME/.ssh/github"
PUB_KEY_FILE="${KEY_FILE}.pub"
SSH_TARGET="git@github.com:jadenbertino/.dotfiles.git"
SSH_CONFIG="$HOME/.ssh/config"
ALLOWED_SIGNERS_FILE="$HOME/.config/git/allowed_signers"
DOTFILES_DIR="$(dirname "${BASH_SOURCE[0]:-$0}")"
DEFAULT_EMAIL="jaden@neonpay.com"
KEY_MATERIAL="$(cat "$PUB_KEY_FILE" 2>/dev/null || true)"
KEY_BODY="$(printf '%s\n' "$KEY_MATERIAL" | awk '{print $1 " " $2}')"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$KEY_FILE" ]; then
  echo "Generating GitHub SSH key..."
  ssh-keygen -t ed25519 -C "$DEFAULT_EMAIL" -f "$KEY_FILE" -N "" > /dev/null 2>&1
fi

KEY_MATERIAL="$(cat "$PUB_KEY_FILE")"
KEY_BODY="$(printf '%s\n' "$KEY_MATERIAL" | awk '{print $1 " " $2}')"

python3 - <<PY
from pathlib import Path

ssh_config = Path("$SSH_CONFIG")
key_file = "$KEY_FILE"
block = f"""Host github.com
  HostName github.com
  User git
  IdentityFile {key_file}
  IdentitiesOnly yes
"""

if ssh_config.exists():
    text = ssh_config.read_text()
else:
    text = ""

lines = text.splitlines()
result = []
i = 0
replaced = False

while i < len(lines):
    line = lines[i]
    if line.strip() == "Host github.com":
        replaced = True
        result.extend(block.strip().splitlines())
        i += 1
        while i < len(lines):
            candidate = lines[i]
            if candidate.startswith("Host ") and candidate.strip() != "Host github.com":
                break
            i += 1
        continue
    result.append(line)
    i += 1

if not replaced:
    if result and result[-1] != "":
        result.append("")
    result.extend(block.strip().splitlines())

ssh_config.write_text("\n".join(result) + "\n")
PY
chmod 600 "$SSH_CONFIG"
echo "Ensured github.com SSH config entry uses $KEY_FILE."

SIGNING_EMAIL="$(git config --global user.email || git config --get user.email || echo "$DEFAULT_EMAIL")"
mkdir -p "$(dirname "$ALLOWED_SIGNERS_FILE")"
printf '%s %s\n' "$SIGNING_EMAIL" "$(cat "$PUB_KEY_FILE")" > "$ALLOWED_SIGNERS_FILE"
chmod 600 "$ALLOWED_SIGNERS_FILE"

# Override Codespaces gh-gpgsign and use native Git SSH signing instead.
git config --global gpg.format ssh
git config --global user.signingkey "$PUB_KEY_FILE"
git config --global commit.gpgsign true
git config --global gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS_FILE"
git config --global gpg.ssh.program "$(command -v ssh-keygen)"
git config --global --unset-all gpg.program || true

github_key_registration_failed=false

ensure_github_key() {
  local key_type="$1"
  local title="$2"
  local api_path=""

  if ! command -v gh >/dev/null 2>&1; then
    github_key_registration_failed=true
    return 1
  fi

  if ! gh auth status >/dev/null 2>&1; then
    github_key_registration_failed=true
    return 1
  fi

  if [ "$key_type" = "authentication" ]; then
    api_path="/user/keys"
  else
    api_path="/user/ssh_signing_keys"
  fi

  if gh api "$api_path" --paginate --jq '.[].key' 2>/dev/null | grep -Fqx "$KEY_BODY"; then
    return
  fi

  echo "Adding GitHub ${key_type} key..."
  if ! gh ssh-key add "$PUB_KEY_FILE" --title "$title" --type "$key_type"; then
    github_key_registration_failed=true
    return 1
  fi
}

ensure_github_key authentication "codespace auth" || true
ensure_github_key signing "codespace signing" || true

echo "Git SSH signing configured."
echo "Public key:"
cat "$PUB_KEY_FILE"

if [ "$github_key_registration_failed" = true ]; then
  echo "GitHub key registration was attempted automatically."
  echo "If GitHub CLI auth was unavailable, add this key manually as both:"
  echo "1. An SSH authentication key: https://github.com/settings/keys"
  echo "2. An SSH signing key: https://github.com/settings/ssh/new"
fi

# Update dotfiles remote to SSH
git -C "$DOTFILES_DIR" remote set-url origin "$SSH_TARGET"

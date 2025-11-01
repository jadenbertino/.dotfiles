source "$HOME/.config/zsh/utils.sh"

detect_os

if [[ "$OS" == "wsl" ]]; then
  pasteclip() {
    powershell.exe -NoProfile -NonInteractive -Command \
      "[Console]::OutputEncoding=[System.Text.Encoding]::UTF8; Get-Clipboard -Raw" \
    | tr -d '\r'
  }

elif [[ "$OS" == "macos" ]]; then
  pasteclip() {
    # macOS has pbpaste natively
    pbpaste | tr -d '\r'
  }

else
  pasteclip() {
    echo "pasteclip not supported for OS=$OS" >&2
    return 1
  }
fi

runclip() {
  pasteclip | bash -x
}
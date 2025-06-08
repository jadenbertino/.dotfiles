detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        VERSION=$(sw_vers -productVersion)
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        echo "Could not detect OS."
        exit 1
    fi
}

is_command_available() {
    local CMD=$1
    command -v "$CMD" &> /dev/null && [[ -x "$(command -v "$CMD")" ]]
}

install_package() {
    local PKG=$1
    detect_os
    case "$OS" in
        ubuntu|debian)
            sudo apt-get update -y >/dev/null
            sudo apt-get install -y "$PKG" >/dev/null
            ;;
        fedora|rhel)
            sudo dnf install -y "$PKG" >/dev/null
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                echo "Homebrew is not installed. Please install Homebrew first."
                exit 1
            fi
            brew install "$PKG" >/dev/null
            ;;
        *)
            ;;
    esac
}
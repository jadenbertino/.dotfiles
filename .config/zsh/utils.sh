# detect_os
# Sets the following global variables based on the current operating system:
#   OS:     'macos', 'wsl', or 'linux'
#   DISTRO: Linux distribution name (e.g., 'ubuntu', 'debian'), or empty on macOS
#   VERSION: Version string (macOS version, or Linux distro version)
#
# Usage:
#   Call detect_os, then use $OS, $DISTRO, and $VERSION as needed.
#   Example values:
#     OS="wsl", DISTRO="ubuntu", VERSION="22.04"
#     OS="linux", DISTRO="debian", VERSION="12"
#     OS="macos", DISTRO="", VERSION="14.4.1"
#     OS="windows", DISTRO="", VERSION="10.0.19045"
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO=""
        VERSION=$(sw_vers -productVersion)
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        OS="windows"
        DISTRO=""
        VERSION=$(cmd.exe /c ver 2>/dev/null | grep -o "Version [0-9.]*" | cut -d' ' -f2 || echo "unknown")
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
        # WSL detection (do not distinguish between WSL1 and WSL2)
        if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version; then
            OS="wsl"
        else
            OS="linux"
        fi
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
    if [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            echo "Homebrew is not installed. Please install Homebrew first."
            exit 1
        fi
        brew install "$PKG" >/dev/null
    else
        case "$DISTRO" in
            ubuntu|debian)
                sudo apt-get update -y >/dev/null
                sudo apt-get install -y "$PKG" >/dev/null
                ;;
            fedora|rhel)
                sudo dnf install -y "$PKG" >/dev/null
                ;;
            *)
                echo "Unsupported Linux distribution: $DISTRO"
                return 1
                ;;
        esac
    fi
}
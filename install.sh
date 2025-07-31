#!/bin/bash

# Agent Scripts Installation Script
# Creates symbolic links to make scripts available system-wide

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default installation directory
INSTALL_DIR="${HOME}/.local/bin"

# Function to print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Installs agent scripts by creating symbolic links in your PATH."
    echo ""
    echo "Options:"
    echo "  -d, --dir PATH    Installation directory (default: ~/.local/bin)"
    echo "  -u, --uninstall   Remove installed symbolic links"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                          # Install to ~/.local/bin"
    echo "  $0 --dir /usr/local/bin    # Install to /usr/local/bin"
    echo "  $0 --uninstall             # Remove installed links"
    exit 1
}

# Parse command line arguments
UNINSTALL=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        -u|--uninstall)
            UNINSTALL=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Expand ~ to home directory if present
INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

# Create installation directory if it doesn't exist
if [ "$UNINSTALL" = false ]; then
    if [ ! -d "$INSTALL_DIR" ]; then
        print_color $YELLOW "Creating installation directory: $INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    fi
fi

# Check if installation directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    print_color $YELLOW "Warning: $INSTALL_DIR is not in your PATH"
    print_color $YELLOW "You may need to add it to your shell configuration:"
    print_color $YELLOW "  echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> ~/.bashrc"
    print_color $YELLOW "  # or for zsh:"
    print_color $YELLOW "  echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> ~/.zshrc"
    echo ""
fi

# Find all executable scripts in subdirectories
print_color $GREEN "Finding scripts to install..."
SCRIPTS=()
while IFS= read -r -d '' script; do
    # Skip the install script itself
    if [ "$(basename "$script")" != "install.sh" ]; then
        SCRIPTS+=("$script")
    fi
done < <(find "$SCRIPT_DIR" -type f -perm +111 -not -path "*/\.*" -print0)

if [ ${#SCRIPTS[@]} -eq 0 ]; then
    print_color $RED "No executable scripts found to install."
    exit 1
fi

# Process each script
INSTALLED=0
SKIPPED=0
FAILED=0

for script in "${SCRIPTS[@]}"; do
    script_name=$(basename "$script")
    link_path="$INSTALL_DIR/$script_name"
    
    if [ "$UNINSTALL" = true ]; then
        # Uninstall mode
        if [ -L "$link_path" ]; then
            # Verify the link points to our script
            if [ "$(readlink "$link_path")" = "$script" ]; then
                rm "$link_path"
                print_color $GREEN "  ✓ Removed: $script_name"
                ((INSTALLED++))
            else
                print_color $YELLOW "  ⚠ Skipped: $script_name (link points elsewhere)"
                ((SKIPPED++))
            fi
        else
            print_color $YELLOW "  - Skipped: $script_name (not installed)"
            ((SKIPPED++))
        fi
    else
        # Install mode
        if [ -e "$link_path" ]; then
            if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$script" ]; then
                print_color $YELLOW "  - Skipped: $script_name (already installed)"
                ((SKIPPED++))
            else
                print_color $RED "  ✗ Failed: $script_name (file exists at $link_path)"
                ((FAILED++))
            fi
        else
            ln -s "$script" "$link_path"
            print_color $GREEN "  ✓ Installed: $script_name"
            ((INSTALLED++))
        fi
    fi
done

# Print summary
echo ""
if [ "$UNINSTALL" = true ]; then
    print_color $GREEN "Uninstallation complete!"
    print_color $GREEN "  Removed: $INSTALLED scripts"
    if [ $SKIPPED -gt 0 ]; then
        print_color $YELLOW "  Skipped: $SKIPPED scripts"
    fi
else
    print_color $GREEN "Installation complete!"
    print_color $GREEN "  Installed: $INSTALLED scripts"
    if [ $SKIPPED -gt 0 ]; then
        print_color $YELLOW "  Skipped: $SKIPPED scripts"
    fi
    if [ $FAILED -gt 0 ]; then
        print_color $RED "  Failed: $FAILED scripts"
    fi
    
    if [ $INSTALLED -gt 0 ]; then
        echo ""
        print_color $GREEN "You can now use the following commands from anywhere:"
        for script in "${SCRIPTS[@]}"; do
            script_name=$(basename "$script")
            link_path="$INSTALL_DIR/$script_name"
            if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$script" ]; then
                echo "  - $script_name"
            fi
        done
    fi
fi
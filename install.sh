#!/usr/bin/env bash

#######################################################################
# pr1 - Global Installer
# Version: 2.0.0
#
# Installs pr1 command globally
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/haidoan/pr1/main/install.sh | bash
#
#   # Or with sudo for /usr/local/bin:
#   curl -fsSL https://raw.githubusercontent.com/haidoan/pr1/main/install.sh | sudo bash
#
#   # Or locally:
#   ./install.sh
#######################################################################

set -e

VERSION="2.0.0"
REPO_RAW_URL="https://raw.githubusercontent.com/haidoan/pr1/main"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║               pr1 v${VERSION} - Installer                      ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Determine install location
determine_install_dir() {
    if [[ $EUID -eq 0 ]]; then
        echo "/usr/local/bin"
    else
        echo "$HOME/.local/bin"
    fi
}

# Check if a command exists
check_dependency() {
    local cmd="$1"
    local install_hint="$2"
    
    if command -v "$cmd" &>/dev/null; then
        log_success "$cmd found"
        return 0
    else
        log_error "$cmd not found"
        if [[ -n "$install_hint" ]]; then
            echo -e "    ${DIM}$install_hint${NC}"
        fi
        return 1
    fi
}

main() {
    print_banner
    
    INSTALL_DIR=$(determine_install_dir)
    log_info "Install location: $INSTALL_DIR"
    echo ""
    
    # Check dependencies
    echo "Checking dependencies..."
    echo ""
    
    local deps_ok=true
    
    check_dependency "git" "Install: https://git-scm.com/" || deps_ok=false
    check_dependency "gh" "Install: https://cli.github.com/" || deps_ok=false
    check_dependency "curl" "Install with your package manager" || deps_ok=false
    check_dependency "jq" "Install: brew install jq (macOS) / apt install jq (Linux)" || deps_ok=false
    
    echo ""
    
    if [[ "$deps_ok" != "true" ]]; then
        log_error "Please install missing dependencies and try again"
        exit 1
    fi
    
    # Check GitHub CLI authentication
    if ! gh auth status &>/dev/null 2>&1; then
        log_warn "GitHub CLI not authenticated yet"
        echo -e "    ${DIM}Run 'gh auth login' after installation${NC}"
        echo ""
    else
        log_success "GitHub CLI authenticated"
    fi
    
    echo ""
    
    # Create install directory
    log_info "Creating install directory..."
    mkdir -p "$INSTALL_DIR"
    
    # Determine source (local or remote)
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"

    if [[ -f "$SCRIPT_DIR/pr1" ]]; then
        # Local install
        log_info "Installing from local directory..."
        cp "$SCRIPT_DIR/pr1" "$INSTALL_DIR/pr1"
    else
        # Remote install
        log_info "Downloading pr1 from repository..."
        if ! curl -fsSL "$REPO_RAW_URL/pr1" -o "$INSTALL_DIR/pr1"; then
            log_error "Failed to download pr1"
            echo ""
            echo "Please check your internet connection and try again."
            echo "Or install manually from: https://github.com/haidoan/pr1"
            exit 1
        fi
    fi

    # Make executable
    chmod +x "$INSTALL_DIR/pr1"
    log_success "Installed pr1 to $INSTALL_DIR/pr1"
    
    # Check if in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo ""
        log_warn "$INSTALL_DIR is not in your PATH"
        echo ""
        echo "Add this line to your shell config (~/.bashrc, ~/.zshrc, etc.):"
        echo ""
        echo -e "    ${CYAN}export PATH=\"$INSTALL_DIR:\$PATH\"${NC}"
        echo ""
        echo "Then restart your terminal or run:"
        echo ""
        echo -e "    ${CYAN}source ~/.bashrc${NC}  # or ~/.zshrc"
        echo ""
    fi
    
    # Success message
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              Installation Complete!                       ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Quick Start:${NC}"
    echo ""
    echo -e "  ${CYAN}pr1${NC}                  Create PR (prompts for AI setup on first run)"
    echo -e "  ${CYAN}pr1 -t main${NC}          Create PR targeting main branch"
    echo -e "  ${CYAN}pr1 -r \"alice,bob\"${NC}   Create PR with reviewers"
    echo -e "  ${CYAN}pr1 --preview${NC}        Preview PR without creating"
    echo -e "  ${CYAN}pr1 --help${NC}           Show all options"
    echo ""
    echo -e "${BOLD}Optional Per-Repo Config:${NC}"
    echo ""
    echo -e "  ${CYAN}pr1 --init${NC}           Create .pr1.json template (optional)"
    echo ""
    echo "The tool works without .pr1.json using sensible defaults."
    echo "Only create one if you need custom reviewers or settings per repo."
    echo ""
}

main "$@"

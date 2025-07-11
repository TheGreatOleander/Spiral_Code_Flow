#!/bin/bash
# 🏗️ SPIRAL FORGE FORTRESS INSTALLER
# Automated setup and fortification of your Spiral Forge system

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARN: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $1${NC}"
}

banner() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                   🌀 SPIRAL FORGE FORTRESS 🛡️                   ║"
    echo "║                      Automated Setup System                    ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Default configuration
DEFAULT_INSTALL_DIR="$HOME/spiral-forge"
DEFAULT_USER=$(whoami)

# Installation functions
check_system() {
    log "Checking system requirements..."
    
    # Check OS
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        error "This installer is designed for Linux systems"
        exit 1
    fi
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        warn "Running as root - this is not recommended"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    success "System check passed"
}

install_dependencies() {
    log "Installing system dependencies..."
    
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt-get"
        UPDATE_CMD="apt-get update"
        INSTALL_CMD="apt-get install -y"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        UPDATE_CMD="yum update -y"
        INSTALL_CMD="yum install -y"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        UPDATE_CMD="dnf update -y"
        INSTALL_CMD="dnf install -y"
    else
        error "Unsupported package manager. Please install dependencies manually:"
        echo "  - curl, jq, xdotool, xclip, xwininfo"
        exit 1
    fi
    
    # Required packages
    PACKAGES=(
        "curl"
        "jq"
        "xdotool"
        "xclip"
        "xwininfo"
        "cron"
        "logrotate"
    )
    
    log "Using package manager: $PKG_MANAGER"
    
    # Update package lists
    if ! sudo $UPDATE_CMD; then
        warn "Failed to update package lists, continuing anyway..."
    fi
    
    # Install packages
    for package in "${PACKAGES[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            log "Installing $package..."
            if ! sudo $INSTALL_CMD "$package"; then
                warn "Failed to install $package, you may need to install it manually"
            fi
        else
            log "$package is already installed"
        fi
    done
    
    success "Dependencies installation complete"
}

setup_directories() {
    log "Setting up directory structure..."
    
    local install_dir="$1"
    
    # Create main directories
    mkdir -p "$install_dir"/{prompts,episodes,logs,backups,scripts}
    
    # Set permissions
    chmod 755 "$install_dir"
    chmod 755 "$install_dir"/{prompts,episodes,logs,backups,scripts}
    
    # Create subdirectories
    mkdir -p "$install_dir/logs"/{archive,errors}
    mkdir -p "$install_dir/backups"/{daily,weekly,monthly}
    
    success "Directory structure created at $install_dir"
}

install_scripts() {
    log "Installing Spiral Forge scripts..."
    
    local install_dir="$1"
    local script_dir="$install_dir/scripts"
    
    # Note: In a real installation, these would be copied from the package
    # For now, we'll create placeholder files with instructions
    
    cat > "$script_dir/generate.sh" << 'EOF'
#!/bin/bash
# This is a placeholder for the fortified generator script
# Replace this with the actual fortified generate.sh script
echo "Please install the fortified generate.sh script here"
exit 1
EOF
    
    cat > "$script_dir/chatgpt-puller.sh" << 'EOF'
#!/bin/bash
# This is a placeholder for the fortified puller script
# Replace this with the actual fortified chatgpt-puller.sh script
echo "Please install the fortified chatgpt-puller.sh script here"
exit 1
EOF
    
    # Make scripts executable
    chmod +x "$script_dir"/*.sh
    
    # Create symlinks in the main directory
    ln -sf "$script_dir/generate.sh" "$install_dir/generate.sh"
    ln -sf "$script_dir/chatgpt-puller.sh" "$install_dir/chatgpt-puller.sh"
    
    success "Scripts installed (placeholders created)"
}

setup_config() {
    log "Setting up configuration..."
    
    local install_dir="$1"
    local config_file="$install_dir/config.env"
    
    if [[ -f "$config_file" ]]; then
        warn "Config file already exists, creating backup..."
        cp "$config_file" "$config_file.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create default config
    cat > "$config_file" << EOF
# 🛡️ SPIRAL FORGE CONFIGURATION - Auto-generated by installer
# Generated on: $(date)

# === AI SERVICE SETTINGS ===
LM_STUDIO_URL="http://localhost:1234/v1/chat/completions"
MODEL_NAME="your-model-name"
TEMPERATURE=0.8
MAX_TOKENS=2000
TIMEOUT=300

# === RETRY AND RECOVERY ===
MAX_RETRIES=3
RETRY_DELAY=30
BACKUP_DAYS=30

# === CLIPBOARD PULLER SETTINGS ===
CLIPBOARD_TIMEOUT=10
MIN_CONTENT_LENGTH=50
MAX_CONTENT_LENGTH=50000
CHATGPT_TITLES="ChatGPT|OpenAI|GPT"

# === DIRECTORIES ===
SPIRAL_FORGE_PATH="$install_dir"
PROMPTS_DIR="prompts"
EPISODES_DIR="episodes"
LOGS_DIR="logs"
BACKUPS_DIR="backups"

# === LOGGING ===
LOG_LEVEL="INFO"
KEEP_LOGS_DAYS=90

# === QUALITY CONTROL ===
MIN_EPISODE_LENGTH=500
MAX_EPISODE_LENGTH=10000
QUALITY_CHECK_ENABLED=true

# === NOTIFICATIONS ===
NOTIFY_ON_SUCCESS=false
NOTIFY_ON_ERROR=true
WEBHOOK_URL=""
EMAIL_ALERTS=""

# === SECURITY ===
SECURE_CLIPBOARD=true
BACKUP_ENCRYPTION=false
LOG_SANITIZATION=true

# === PERFORMANCE ===
PARALLEL_PROCESSING=false
MEMORY_LIMIT="512M"
CPU_LIMIT="2"

# === DEVELOPMENT ===
DEBUG_MODE=false
DRY_RUN=false
VERBOSE_LOGGING=false
EOF
    
    success "Configuration file created at $config_file"
}

setup_logrotate() {
    log "Setting up log rotation..."
    
    local install_dir="$1"
    local logrotate_config="/etc/logrotate.d/spiral-forge"
    
    cat > "/tmp/spiral-forge-logrotate" << EOF
$install_dir/logs/*.log {
    daily
    missingok
    rotate 90
    compress
    delaycompress
    notifempty
    create 644 $DEFAULT_USER $DEFAULT_USER
    postrotate
        # Clean up old backups
        find $install_dir/backups -type f -mtime +30 -delete 2>/dev/null || true
    endscript
}
EOF
    
    if sudo cp "/tmp/spiral-forge-logrotate" "$logrotate_config"; then
        success "Log rotation configured"
    else
        warn "Failed to setup log rotation (needs sudo access)"
    fi
    
    rm -f "/tmp/spiral-forge-logrotate"
}

setup_cron() {
    log "Setting up cron job..."
    
    local install_dir="$1"
    local cron_entry="0 12 * * * cd $install_dir && bash generate.sh prompts/episode_\$(date +\\%Y-\\%m-\\%d).txt >> logs/cron.log 2>&1"
    
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "spiral-forge\|generate.sh"; then
        warn "Spiral Forge cron job already exists, skipping..."
    else
        # Add cron job
        (crontab -l 2>/dev/null; echo "# Spiral Forge daily generation"; echo "$cron_entry") | crontab -
        success "Cron job added (daily at 12:00 PM)"
    fi
}

create_test_files() {
    log "Creating test files..."
    
    local install_dir="$1"
    local today=$(date +%Y-%m-%d)
    
    # Create a test prompt
    cat > "$install_dir/prompts/test_prompt.txt" << EOF
Write a short story about a mystical forge that creates spirals of light. The story should be engaging and mysterious, around 500-1000 words.
EOF
    
    # Create today's prompt if it doesn't exist
    if [[ ! -f "$install_dir/prompts/episode_$today.txt" ]]; then
        cp "$install_dir/prompts/test_prompt.txt" "$install_dir/prompts/episode_$today.txt"
        success "Created today's prompt file"
    fi
    
    success "Test files created"
}

run_health_check() {
    log "Running system health check..."
    
    local install_dir="$1"
    local issues=0
    
    # Check directory permissions
    if [[ ! -w "$install_dir" ]]; then
        error "Install directory is not writable: $install_dir"
        ((issues++))
    fi
    
    # Check script permissions
    if [[ ! -x "$install_dir/generate.sh" ]]; then
        error "Generate script is not executable: $install_dir/generate.sh"
        ((issues++))
    fi
    
    # Check config file
    if [[ ! -f "$install_dir/config.env" ]]; then
        error "Config file missing: $install_dir/config.env"
        ((issues++))
    fi
    
    # Check dependencies
    local missing_deps=()
    for dep in curl jq xdotool xclip; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing_deps[*]}"
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        success "Health check passed - system is ready!"
    else
        error "Health check failed with $issues issues"
        return 1
    fi
}

print_next_steps() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        🎉 INSTALLATION COMPLETE! 🎉              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${YELLOW}📋 NEXT STEPS:${NC}"
    echo "1. Install the actual fortified scripts:"
    echo "   - Copy generate.sh to $DEFAULT_INSTALL_DIR/scripts/"
    echo "   - Copy chatgpt-puller.sh to $DEFAULT_INSTALL_DIR/scripts/"
    echo
    echo "2. Configure your AI service:"
    echo "   - Edit $DEFAULT_INSTALL_DIR/config.env"
    echo "   - Set your LM_STUDIO_URL and MODEL_NAME"
    echo
    echo "3. Set up n8n workflow:"
    echo "   - Import the fortified n8n workflow"
    echo "   - Configure the workflow paths"
    echo
    echo "4. Test the system:"
    echo "   - Run: cd $DEFAULT_INSTALL_DIR && bash generate.sh prompts/test_prompt.txt"
    echo
    echo -e "${BLUE}📁 Installation Directory: $DEFAULT_INSTALL_DIR${NC}"
    echo -e "${BLUE}📋 Configuration File: $DEFAULT_INSTALL_DIR/config.env${NC}"
    echo -e "${BLUE}📚 Documentation: Check the README files in each directory${NC}"
    echo
}

# Main installation function
main() {
    banner
    
    # Get installation directory
    read -p "Install directory [$DEFAULT_INSTALL_DIR]: " install_dir
    install_dir="${install_dir:-$DEFAULT_INSTALL_DIR}"
    
    # Confirm installation
    echo
    log "Installation Summary:"
    echo "  - Install Directory: $install_dir"
    echo "  - User: $DEFAULT_USER"
    echo "  - Cron Job: Daily at 12:00 PM"
    echo
    read -p "Proceed with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Installation cancelled"
        exit 0
    fi
    
    # Run installation steps
    check_system
    install_dependencies
    setup_directories "$install_dir"
    install_scripts "$install_dir"
    setup_config "$install_dir"
    setup_logrotate "$install_dir"
    setup_cron "$install_dir"
    create_test_files "$install_dir"
    
    # Final health check
    if run_health_check "$install_dir"; then
        print_next_steps
    else
        error "Installation completed with issues - please review the errors above"
        exit 1
    fi
}

# Check if running directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
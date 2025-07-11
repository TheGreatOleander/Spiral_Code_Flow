#!/bin/bash
# 🛡️ FORTIFIED CHATGPT PULLER - Armored Clipboard Fallback
# Safely extracts content from ChatGPT with multiple fallback strategies

set -euo pipefail

# === CONFIGURATION ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
PROMPTS_DIR="$PROJECT_ROOT/prompts"
LOGS_DIR="$PROJECT_ROOT/logs"
CONFIG_FILE="$PROJECT_ROOT/config.env"

# Load config
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# Defaults
CLIPBOARD_TIMEOUT=${CLIPBOARD_TIMEOUT:-10}
MIN_CONTENT_LENGTH=${MIN_CONTENT_LENGTH:-50}
MAX_CONTENT_LENGTH=${MAX_CONTENT_LENGTH:-50000}
CHATGPT_TITLES=${CHATGPT_TITLES:-"ChatGPT|OpenAI|GPT"}

# === LOGGING ===
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="$LOGS_DIR/puller_$TODAY.log"
ERROR_LOG="$LOGS_DIR/puller_errors_$TODAY.log"

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

error_log() {
    echo "[$TIMESTAMP] ERROR: $1" | tee -a "$ERROR_LOG" >&2
}

# === DEPENDENCY CHECK ===
check_dependencies() {
    local missing=()
    command -v xdotool >/dev/null || missing+=("xdotool")
    command -v xclip >/dev/null || missing+=("xclip")
    command -v xwininfo >/dev/null || missing+=("xwininfo")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error_log "Missing dependencies: ${missing[*]}"
        log "Install with: sudo apt-get install ${missing[*]}"
        exit 1
    fi
}

# === WINDOW DETECTION ===
find_chatgpt_window() {
    log "🔍 Searching for ChatGPT window..."
    
    # Try multiple search strategies
    local strategies=(
        "xdotool search --name 'ChatGPT'"
        "xdotool search --name 'OpenAI'"
        "xdotool search --name 'GPT'"
        "xdotool search --class 'chrome' --name 'ChatGPT'"
        "xdotool search --class 'firefox' --name 'ChatGPT'"
    )
    
    for strategy in "${strategies[@]}"; do
        log "Trying: $strategy"
        local window_ids=$(eval "$strategy" 2>/dev/null | head -3)
        
        if [[ -n "$window_ids" ]]; then
            # Validate windows exist and are visible
            for win_id in $window_ids; do
                if xwininfo -id "$win_id" &>/dev/null; then
                    local window_name=$(xdotool getwindowname "$win_id" 2>/dev/null || echo "Unknown")
                    log "✅ Found window: $win_id ($window_name)"
                    echo "$win_id"
                    return 0
                fi
            done
        fi
    done
    
    error_log "No ChatGPT window found"
    return 1
}

# === CLIPBOARD OPERATIONS ===
safe_clipboard_copy() {
    local window_id="$1"
    local max_attempts=3
    
    for attempt in $(seq 1 $max_attempts); do
        log "📋 Clipboard copy attempt $attempt/$max_attempts"
        
        # Focus window
        if ! xdotool windowactivate "$window_id" 2>/dev/null; then
            error_log "Failed to activate window $window_id"
            continue
        fi
        
        sleep 1
        
        # Try to scroll to bottom to get latest content
        xdotool key --window "$window_id" ctrl+End 2>/dev/null || true
        sleep 2
        
        # Try different selection methods
        local selection_methods=(
            "ctrl+a"  # Select all
            "ctrl+shift+End"  # Select to end
        )
        
        for method in "${selection_methods[@]}"; do
            log "Using selection method: $method"
            
            # Clear clipboard first
            echo -n "" | xclip -selection clipboard
            
            # Select content
            xdotool key --window "$window_id" $method 2>/dev/null || continue
            sleep 1
            
            # Copy to clipboard
            xdotool key --window "$window_id" ctrl+c 2>/dev/null || continue
            sleep 2
            
            # Test if clipboard has content
            if timeout $CLIPBOARD_TIMEOUT xclip -selection clipboard -o &>/dev/null; then
                log "✅ Clipboard copy successful with $method"
                return 0
            fi
        done
        
        if [[ $attempt -lt $max_attempts ]]; then
            log "⏳ Waiting 3s before retry..."
            sleep 3
        fi
    done
    
    error_log "All clipboard copy attempts failed"
    return 1
}

# === CONTENT VALIDATION ===
validate_content() {
    local content="$1"
    local length=${#content}
    
    if [[ $length -lt $MIN_CONTENT_LENGTH ]]; then
        error_log "Content too short: $length chars (minimum: $MIN_CONTENT_LENGTH)"
        return 1
    fi
    
    if [[ $length -gt $MAX_CONTENT_LENGTH ]]; then
        error_log "Content too long: $length chars (maximum: $MAX_CONTENT_LENGTH)"
        return 1
    fi
    
    # Check for common error patterns
    if [[ "$content" =~ ^[[:space:]]*$ ]]; then
        error_log "Content is empty or whitespace only"
        return 1
    fi
    
    # Check for clipboard errors
    if [[ "$content" == *"clipboard"* && "$content" == *"error"* ]]; then
        error_log "Clipboard error detected in content"
        return 1
    fi
    
    log "✅ Content validated: $length characters"
    return 0
}

# === CONTENT EXTRACTION ===
extract_content() {
    local output_file="$1"
    
    # Find ChatGPT window
    local window_id
    if ! window_id=$(find_chatgpt_window); then
        return 1
    fi
    
    # Extract content via clipboard
    if ! safe_clipboard_copy "$window_id"; then
        return 1
    fi
    
    # Get clipboard content with timeout
    local content
    if ! content=$(timeout $CLIPBOARD_TIMEOUT xclip -selection clipboard -o 2>/dev/null); then
        error_log "Failed to read clipboard content"
        return 1
    fi
    
    # Validate content
    if ! validate_content "$content"; then
        return 1
    fi
    
    # Save to file
    echo "$content" > "$output_file"
    log "💾 Content saved to $output_file"
    
    # Clear clipboard for security
    echo -n "" | xclip -selection clipboard 2>/dev/null || true
    
    return 0
}

# === MAIN EXECUTION ===
main() {
    log "📡 SPIRAL PULLER STARTING - Fallback Content Extraction"
    
    # Create required directories
    mkdir -p "$PROMPTS_DIR" "$LOGS_DIR"
    
    # Check dependencies
    check_dependencies
    
    # Determine output file
    local output_file="$PROMPTS_DIR/episode_$TODAY.txt"
    
    # Backup existing file if it exists
    if [[ -f "$output_file" ]]; then
        local backup_file="$output_file.backup_$TIMESTAMP"
        cp "$output_file" "$backup_file"
        log "📦 Backed up existing file to $backup_file"
    fi
    
    # Extract content
    if extract_content "$output_file"; then
        local final_size=$(wc -c < "$output_file")
        log "🎉 SUCCESS: Content extracted ($final_size characters)"
        log "📁 Saved to: $output_file"
    else
        error_log "Content extraction failed"
        exit 1
    fi
    
    log "🏁 SPIRAL PULLER COMPLETE"
}

# === SIGNAL HANDLERS ===
trap 'error_log "Script interrupted"; exit 130' INT TERM

# Execute main function
main "$@"
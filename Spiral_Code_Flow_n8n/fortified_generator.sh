#!/bin/bash
# 🛡️ FORTIFIED SPIRAL GENERATOR - Armored for Battle
# Usage: ./generate.sh [prompt_file]

set -euo pipefail  # Exit on any error, undefined vars, or pipe failures

# === CONFIGURATION ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
PROMPTS_DIR="$PROJECT_ROOT/prompts"
OUTPUT_DIR="$PROJECT_ROOT/episodes"
LOGS_DIR="$PROJECT_ROOT/logs"
BACKUPS_DIR="$PROJECT_ROOT/backups"
CONFIG_FILE="$PROJECT_ROOT/config.env"

# === ARMOR PLATING (Create directories if missing) ===
mkdir -p "$PROMPTS_DIR" "$OUTPUT_DIR" "$LOGS_DIR" "$BACKUPS_DIR"

# === LOAD CONFIGURATION ===
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "⚠️  Config file missing. Creating default..."
    cat > "$CONFIG_FILE" << 'EOF'
# Spiral Forge Configuration
LM_STUDIO_URL="http://localhost:1234/v1/chat/completions"
MODEL_NAME="your-model-name"
MAX_RETRIES=3
TEMPERATURE=0.8
MAX_TOKENS=2000
TIMEOUT=300
BACKUP_DAYS=30
EOF
    source "$CONFIG_FILE"
fi

# === LOGGING SETUP ===
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="$LOGS_DIR/spiral_$TODAY.log"
ERROR_LOG="$LOGS_DIR/errors_$TODAY.log"

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

error_log() {
    echo "[$TIMESTAMP] ERROR: $1" | tee -a "$ERROR_LOG" >&2
}

# === HEALTH CHECK FUNCTIONS ===
check_dependencies() {
    local missing=()
    command -v curl >/dev/null || missing+=("curl")
    command -v jq >/dev/null || missing+=("jq")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error_log "Missing dependencies: ${missing[*]}"
        log "Install with: sudo apt-get install ${missing[*]}"
        exit 1
    fi
}

test_lm_studio() {
    log "🔍 Testing LM Studio connection..."
    if ! curl -s --max-time 5 "$LM_STUDIO_URL" >/dev/null 2>&1; then
        error_log "LM Studio not responding at $LM_STUDIO_URL"
        return 1
    fi
    log "✅ LM Studio is alive"
    return 0
}

# === PROMPT VALIDATION ===
validate_prompt() {
    local prompt_file="$1"
    
    if [[ ! -f "$prompt_file" ]]; then
        error_log "Prompt file not found: $prompt_file"
        return 1
    fi
    
    if [[ ! -s "$prompt_file" ]]; then
        error_log "Prompt file is empty: $prompt_file"
        return 1
    fi
    
    # Check for minimum viable prompt length
    local word_count=$(wc -w < "$prompt_file")
    if [[ $word_count -lt 10 ]]; then
        error_log "Prompt too short ($word_count words). Minimum 10 words required."
        return 1
    fi
    
    log "✅ Prompt validated: $word_count words"
    return 0
}

# === BACKUP SYSTEM ===
backup_existing() {
    local output_file="$1"
    if [[ -f "$output_file" ]]; then
        local backup_file="$BACKUPS_DIR/$(basename "$output_file")_$TIMESTAMP.bak"
        cp "$output_file" "$backup_file"
        log "📦 Backed up existing file to $backup_file"
    fi
}

cleanup_old_backups() {
    log "🧹 Cleaning backups older than $BACKUP_DAYS days..."
    find "$BACKUPS_DIR" -name "*.bak" -mtime +$BACKUP_DAYS -delete 2>/dev/null || true
}

# === AI GENERATION WITH RETRY LOGIC ===
generate_episode() {
    local prompt_file="$1"
    local output_file="$2"
    local prompt_content=$(cat "$prompt_file")
    
    for attempt in $(seq 1 $MAX_RETRIES); do
        log "🤖 Generation attempt $attempt/$MAX_RETRIES"
        
        # Create JSON payload
        local json_payload=$(jq -n \
            --arg model "$MODEL_NAME" \
            --arg content "$prompt_content" \
            --argjson temp "$TEMPERATURE" \
            --argjson max_tokens "$MAX_TOKENS" \
            '{
                model: $model,
                messages: [{"role": "user", "content": $content}],
                temperature: $temp,
                max_tokens: $max_tokens,
                stream: false
            }')
        
        # Make API call with timeout
        local response=$(curl -s \
            --max-time "$TIMEOUT" \
            --header "Content-Type: application/json" \
            --data "$json_payload" \
            "$LM_STUDIO_URL" 2>/dev/null)
        
        if [[ $? -eq 0 && -n "$response" ]]; then
            # Extract content from response
            local content=$(echo "$response" | jq -r '.choices[0].message.content // empty' 2>/dev/null)
            
            if [[ -n "$content" && "$content" != "null" ]]; then
                echo "$content" > "$output_file"
                log "✅ Episode generated successfully (${#content} characters)"
                return 0
            else
                error_log "Attempt $attempt: Invalid response format"
                echo "Response: $response" >> "$ERROR_LOG"
            fi
        else
            error_log "Attempt $attempt: API call failed"
        fi
        
        # Wait before retry (exponential backoff)
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            local wait_time=$((attempt * 30))
            log "⏳ Waiting ${wait_time}s before retry..."
            sleep $wait_time
        fi
    done
    
    error_log "All generation attempts failed"
    return 1
}

# === MAIN EXECUTION ===
main() {
    log "🌀 SPIRAL FORGE GENERATOR STARTING"
    log "Project root: $PROJECT_ROOT"
    
    # Validate input
    if [[ $# -lt 1 ]]; then
        error_log "Usage: $0 <prompt_file>"
        exit 1
    fi
    
    local prompt_file="$1"
    local output_file="$OUTPUT_DIR/episode_$TODAY.txt"
    
    # Pre-flight checks
    check_dependencies
    validate_prompt "$prompt_file"
    
    # Test AI service
    if ! test_lm_studio; then
        error_log "LM Studio health check failed"
        exit 1
    fi
    
    # Backup existing episode
    backup_existing "$output_file"
    
    # Generate new episode
    if generate_episode "$prompt_file" "$output_file"; then
        log "🎉 SUCCESS: Episode saved to $output_file"
        
        # Cleanup old backups
        cleanup_old_backups
        
        # Final validation
        if [[ -f "$output_file" && -s "$output_file" ]]; then
            local final_size=$(wc -c < "$output_file")
            log "📊 Final episode size: $final_size characters"
        else
            error_log "Generated file is missing or empty!"
            exit 1
        fi
    else
        error_log "Episode generation failed"
        exit 1
    fi
    
    log "🏁 SPIRAL FORGE GENERATOR COMPLETE"
}

# === SIGNAL HANDLERS ===
trap 'error_log "Script interrupted"; exit 130' INT TERM

# Execute main function
main "$@"
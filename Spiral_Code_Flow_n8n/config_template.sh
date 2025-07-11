# 🛡️ SPIRAL FORGE CONFIGURATION - Fortress Settings
# Copy this to config.env and customize for your setup

# === AI SERVICE SETTINGS ===
LM_STUDIO_URL="http://localhost:1234/v1/chat/completions"
MODEL_NAME="your-model-name"
TEMPERATURE=0.8
MAX_TOKENS=2000
TIMEOUT=300  # API timeout in seconds

# === RETRY AND RECOVERY ===
MAX_RETRIES=3
RETRY_DELAY=30  # Base delay between retries in seconds
BACKUP_DAYS=30  # Keep backups for this many days

# === CLIPBOARD PULLER SETTINGS ===
CLIPBOARD_TIMEOUT=10  # Timeout for clipboard operations
MIN_CONTENT_LENGTH=50  # Minimum acceptable content length
MAX_CONTENT_LENGTH=50000  # Maximum acceptable content length
CHATGPT_TITLES="ChatGPT|OpenAI|GPT"  # Window titles to search for

# === DIRECTORIES ===
SPIRAL_FORGE_PATH="/home/user/spiral-forge"  # Base project directory
PROMPTS_DIR="prompts"  # Relative to base path
EPISODES_DIR="episodes"  # Relative to base path
LOGS_DIR="logs"  # Relative to base path
BACKUPS_DIR="backups"  # Relative to base path

# === LOGGING ===
LOG_LEVEL="INFO"  # DEBUG, INFO, WARN, ERROR
KEEP_LOGS_DAYS=90  # Keep logs for this many days

# === QUALITY CONTROL ===
MIN_EPISODE_LENGTH=500  # Minimum episode length in characters
MAX_EPISODE_LENGTH=10000  # Maximum episode length in characters
QUALITY_CHECK_ENABLED=true  # Enable basic quality checks

# === NOTIFICATIONS (Optional) ===
NOTIFY_ON_SUCCESS=false  # Send notifications on success
NOTIFY_ON_ERROR=true  # Send notifications on error
WEBHOOK_URL=""  # Optional webhook for notifications
EMAIL_ALERTS=""  # Optional email for alerts

# === SECURITY ===
SECURE_CLIPBOARD=true  # Clear clipboard after use
BACKUP_ENCRYPTION=false  # Encrypt backups (requires gpg)
LOG_SANITIZATION=true  # Remove sensitive data from logs

# === PERFORMANCE ===
PARALLEL_PROCESSING=false  # Enable parallel processing (experimental)
MEMORY_LIMIT="512M"  # Memory limit for processes
CPU_LIMIT="2"  # CPU core limit

# === DEVELOPMENT ===
DEBUG_MODE=false  # Enable debug output
DRY_RUN=false  # Test mode - don't actually generate
VERBOSE_LOGGING=false  # Extra detailed logs
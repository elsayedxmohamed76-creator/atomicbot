#!/usr/bin/env bash
# ClawDock - Docker helpers for AtomicBot
# Inspired by Simon Willison's "Running AtomicBot in Docker"
# https://til.simonwillison.net/llms/atomicbot-docker
#
# Installation:
#   mkdir -p ~/.atomicock && curl -sL https://raw.githubusercontent.com/atomicbot/atomicbot/main/scripts/shell-helpers/atomicock-helpers.sh -o ~/.atomicock/atomicock-helpers.sh
#   echo 'source ~/.atomicock/atomicock-helpers.sh' >> ~/.zshrc
#
# Usage:
#   atomicock-help    # Show all available commands

# =============================================================================
# Colors
# =============================================================================
_CLR_RESET='\033[0m'
_CLR_BOLD='\033[1m'
_CLR_DIM='\033[2m'
_CLR_GREEN='\033[0;32m'
_CLR_YELLOW='\033[1;33m'
_CLR_BLUE='\033[0;34m'
_CLR_MAGENTA='\033[0;35m'
_CLR_CYAN='\033[0;36m'
_CLR_RED='\033[0;31m'

# Styled command output (green + bold)
_clr_cmd() {
  echo -e "${_CLR_GREEN}${_CLR_BOLD}$1${_CLR_RESET}"
}

# Inline command for use in sentences
_cmd() {
  echo "${_CLR_GREEN}${_CLR_BOLD}$1${_CLR_RESET}"
}

# =============================================================================
# Config
# =============================================================================
ATOMICOCK_CONFIG="${HOME}/.atomicock/config"

# Common paths to check for AtomicBot
ATOMICOCK_COMMON_PATHS=(
  "${HOME}/atomicbot"
  "${HOME}/workspace/atomicbot"
  "${HOME}/projects/atomicbot"
  "${HOME}/dev/atomicbot"
  "${HOME}/code/atomicbot"
  "${HOME}/src/atomicbot"
)

_atomicock_filter_warnings() {
  grep -v "^WARN\|^time="
}

_atomicock_trim_quotes() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  printf "%s" "$value"
}

_atomicock_read_config_dir() {
  if [[ ! -f "$ATOMICOCK_CONFIG" ]]; then
    return 1
  fi
  local raw
  raw=$(sed -n 's/^ATOMICOCK_DIR=//p' "$ATOMICOCK_CONFIG" | head -n 1)
  if [[ -z "$raw" ]]; then
    return 1
  fi
  _atomicock_trim_quotes "$raw"
}

# Ensure ATOMICOCK_DIR is set and valid
_atomicock_ensure_dir() {
  # Already set and valid?
  if [[ -n "$ATOMICOCK_DIR" && -f "${ATOMICOCK_DIR}/docker-compose.yml" ]]; then
    return 0
  fi

  # Try loading from config
  local config_dir
  config_dir=$(_atomicock_read_config_dir)
  if [[ -n "$config_dir" && -f "${config_dir}/docker-compose.yml" ]]; then
    ATOMICOCK_DIR="$config_dir"
    return 0
  fi

  # Auto-detect from common paths
  local found_path=""
  for path in "${ATOMICOCK_COMMON_PATHS[@]}"; do
    if [[ -f "${path}/docker-compose.yml" ]]; then
      found_path="$path"
      break
    fi
  done

  if [[ -n "$found_path" ]]; then
    echo ""
    echo "🦞 Found AtomicBot at: $found_path"
    echo -n "   Use this location? [Y/n] "
    read -r response
    if [[ "$response" =~ ^[Nn] ]]; then
      echo ""
      echo "Set ATOMICOCK_DIR manually:"
      echo "  export ATOMICOCK_DIR=/path/to/atomicbot"
      return 1
    fi
    ATOMICOCK_DIR="$found_path"
  else
    echo ""
    echo "❌ AtomicBot not found in common locations."
    echo ""
    echo "Clone it first:"
    echo ""
    echo "  git clone https://github.com/atomicbot/atomicbot.git ~/atomicbot"
    echo "  cd ~/atomicbot && ./docker-setup.sh"
    echo ""
    echo "Or set ATOMICOCK_DIR if it's elsewhere:"
    echo ""
    echo "  export ATOMICOCK_DIR=/path/to/atomicbot"
    echo ""
    return 1
  fi

  # Save to config
  if [[ ! -d "${HOME}/.atomicock" ]]; then
    /bin/mkdir -p "${HOME}/.atomicock"
  fi
  echo "ATOMICOCK_DIR=\"$ATOMICOCK_DIR\"" > "$ATOMICOCK_CONFIG"
  echo "✅ Saved to $ATOMICOCK_CONFIG"
  echo ""
  return 0
}

# Wrapper to run docker compose commands
_atomicock_compose() {
  _atomicock_ensure_dir || return 1
  local compose_args=(-f "${ATOMICOCK_DIR}/docker-compose.yml")
  if [[ -f "${ATOMICOCK_DIR}/docker-compose.extra.yml" ]]; then
    compose_args+=(-f "${ATOMICOCK_DIR}/docker-compose.extra.yml")
  fi
  command docker compose "${compose_args[@]}" "$@"
}

_atomicock_read_env_token() {
  _atomicock_ensure_dir || return 1
  if [[ ! -f "${ATOMICOCK_DIR}/.env" ]]; then
    return 1
  fi
  local raw
  raw=$(sed -n 's/^ATOMICBOT_GATEWAY_TOKEN=//p' "${ATOMICOCK_DIR}/.env" | head -n 1)
  if [[ -z "$raw" ]]; then
    return 1
  fi
  _atomicock_trim_quotes "$raw"
}

# Basic Operations
atomicock-start() {
  _atomicock_compose up -d atomicbot-gateway
}

atomicock-stop() {
  _atomicock_compose down
}

atomicock-restart() {
  _atomicock_compose restart atomicbot-gateway
}

atomicock-logs() {
  _atomicock_compose logs -f atomicbot-gateway
}

atomicock-status() {
  _atomicock_compose ps
}

# Navigation
atomicock-cd() {
  _atomicock_ensure_dir || return 1
  cd "${ATOMICOCK_DIR}"
}

atomicock-config() {
  cd ~/.atomicbot
}

atomicock-workspace() {
  cd ~/.atomicbot/workspace
}

# Container Access
atomicock-shell() {
  _atomicock_compose exec atomicbot-gateway \
    bash -c 'echo "alias atomicbot=\"./atomicbot.mjs\"" > /tmp/.bashrc_atomicbot && bash --rcfile /tmp/.bashrc_atomicbot'
}

atomicock-exec() {
  _atomicock_compose exec atomicbot-gateway "$@"
}

atomicock-cli() {
  _atomicock_compose run --rm atomicbot-cli "$@"
}

# Maintenance
atomicock-rebuild() {
  _atomicock_compose build atomicbot-gateway
}

atomicock-clean() {
  _atomicock_compose down -v --remove-orphans
}

# Health check
atomicock-health() {
  _atomicock_ensure_dir || return 1
  local token
  token=$(_atomicock_read_env_token)
  if [[ -z "$token" ]]; then
    echo "❌ Error: Could not find gateway token"
    echo "   Check: ${ATOMICOCK_DIR}/.env"
    return 1
  fi
  _atomicock_compose exec -e "ATOMICBOT_GATEWAY_TOKEN=$token" atomicbot-gateway \
    node dist/index.js health
}

# Show gateway token
atomicock-token() {
  _atomicock_read_env_token
}

# Fix token configuration (run this once after setup)
atomicock-fix-token() {
  _atomicock_ensure_dir || return 1

  echo "🔧 Configuring gateway token..."
  local token
  token=$(atomicock-token)
  if [[ -z "$token" ]]; then
    echo "❌ Error: Could not find gateway token"
    echo "   Check: ${ATOMICOCK_DIR}/.env"
    return 1
  fi

  echo "📝 Setting token: ${token:0:20}..."

  _atomicock_compose exec -e "TOKEN=$token" atomicbot-gateway \
    bash -c './atomicbot.mjs config set gateway.remote.token "$TOKEN" && ./atomicbot.mjs config set gateway.auth.token "$TOKEN"' 2>&1 | _atomicock_filter_warnings

  echo "🔍 Verifying token was saved..."
  local saved_token
  saved_token=$(_atomicock_compose exec atomicbot-gateway \
    bash -c "./atomicbot.mjs config get gateway.remote.token 2>/dev/null" 2>&1 | _atomicock_filter_warnings | tr -d '\r\n' | head -c 64)

  if [[ "$saved_token" == "$token" ]]; then
    echo "✅ Token saved correctly!"
  else
    echo "⚠️  Token mismatch detected"
    echo "   Expected: ${token:0:20}..."
    echo "   Got: ${saved_token:0:20}..."
  fi

  echo "🔄 Restarting gateway..."
  _atomicock_compose restart atomicbot-gateway 2>&1 | _atomicock_filter_warnings

  echo "⏳ Waiting for gateway to start..."
  sleep 5

  echo "✅ Configuration complete!"
  echo -e "   Try: $(_cmd atomicock-devices)"
}

# Open dashboard in browser
atomicock-dashboard() {
  _atomicock_ensure_dir || return 1

  echo "🦞 Getting dashboard URL..."
  local output exit_status url
  output=$(_atomicock_compose run --rm atomicbot-cli dashboard --no-open 2>&1)
  exit_status=$?
  url=$(printf "%s\n" "$output" | _atomicock_filter_warnings | grep -o 'http[s]\?://[^[:space:]]*' | head -n 1)
  if [[ $exit_status -ne 0 ]]; then
    echo "❌ Failed to get dashboard URL"
    echo -e "   Try restarting: $(_cmd atomicock-restart)"
    return 1
  fi

  if [[ -n "$url" ]]; then
    echo "✅ Opening: $url"
    open "$url" 2>/dev/null || xdg-open "$url" 2>/dev/null || echo "   Please open manually: $url"
    echo ""
    echo -e "${_CLR_CYAN}💡 If you see 'pairing required' error:${_CLR_RESET}"
    echo -e "   1. Run: $(_cmd atomicock-devices)"
    echo "   2. Copy the Request ID from the Pending table"
    echo -e "   3. Run: $(_cmd 'atomicock-approve <request-id>')"
  else
    echo "❌ Failed to get dashboard URL"
    echo -e "   Try restarting: $(_cmd atomicock-restart)"
  fi
}

# List device pairings
atomicock-devices() {
  _atomicock_ensure_dir || return 1

  echo "🔍 Checking device pairings..."
  local output exit_status
  output=$(_atomicock_compose exec atomicbot-gateway node dist/index.js devices list 2>&1)
  exit_status=$?
  printf "%s\n" "$output" | _atomicock_filter_warnings
  if [ $exit_status -ne 0 ]; then
    echo ""
    echo -e "${_CLR_CYAN}💡 If you see token errors above:${_CLR_RESET}"
    echo -e "   1. Verify token is set: $(_cmd atomicock-token)"
    echo "   2. Try manual config inside container:"
    echo -e "      $(_cmd atomicock-shell)"
    echo -e "      $(_cmd 'atomicbot config get gateway.remote.token')"
    return 1
  fi

  echo ""
  echo -e "${_CLR_CYAN}💡 To approve a pairing request:${_CLR_RESET}"
  echo -e "   $(_cmd 'atomicock-approve <request-id>')"
}

# Approve device pairing request
atomicock-approve() {
  _atomicock_ensure_dir || return 1

  if [[ -z "$1" ]]; then
    echo -e "❌ Usage: $(_cmd 'atomicock-approve <request-id>')"
    echo ""
    echo -e "${_CLR_CYAN}💡 How to approve a device:${_CLR_RESET}"
    echo -e "   1. Run: $(_cmd atomicock-devices)"
    echo "   2. Find the Request ID in the Pending table (long UUID)"
    echo -e "   3. Run: $(_cmd 'atomicock-approve <that-request-id>')"
    echo ""
    echo "Example:"
    echo -e "   $(_cmd 'atomicock-approve 6f9db1bd-a1cc-4d3f-b643-2c195262464e')"
    return 1
  fi

  echo "✅ Approving device: $1"
  _atomicock_compose exec atomicbot-gateway \
    node dist/index.js devices approve "$1" 2>&1 | _atomicock_filter_warnings

  echo ""
  echo "✅ Device approved! Refresh your browser."
}

# Show all available atomicock helper commands
atomicock-help() {
  echo -e "\n${_CLR_BOLD}${_CLR_CYAN}🦞 ClawDock - Docker Helpers for AtomicBot${_CLR_RESET}\n"

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}⚡ Basic Operations${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-start)       ${_CLR_DIM}Start the gateway${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-stop)        ${_CLR_DIM}Stop the gateway${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-restart)     ${_CLR_DIM}Restart the gateway${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-status)      ${_CLR_DIM}Check container status${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-logs)        ${_CLR_DIM}View live logs (follows)${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}🐚 Container Access${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-shell)       ${_CLR_DIM}Shell into container (atomicbot alias ready)${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-cli)         ${_CLR_DIM}Run CLI commands (e.g., atomicock-cli status)${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-exec) ${_CLR_CYAN}<cmd>${_CLR_RESET}  ${_CLR_DIM}Execute command in gateway container${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}🌐 Web UI & Devices${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-dashboard)   ${_CLR_DIM}Open web UI in browser ${_CLR_CYAN}(auto-guides you)${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-devices)     ${_CLR_DIM}List device pairings ${_CLR_CYAN}(auto-guides you)${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-approve) ${_CLR_CYAN}<id>${_CLR_RESET} ${_CLR_DIM}Approve device pairing ${_CLR_CYAN}(with examples)${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}⚙️  Setup & Configuration${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-fix-token)   ${_CLR_DIM}Configure gateway token ${_CLR_CYAN}(run once)${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}🔧 Maintenance${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-rebuild)     ${_CLR_DIM}Rebuild Docker image${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-clean)       ${_CLR_RED}⚠️  Remove containers & volumes (nuclear)${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_MAGENTA}🛠️  Utilities${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-health)      ${_CLR_DIM}Run health check${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-token)       ${_CLR_DIM}Show gateway auth token${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-cd)          ${_CLR_DIM}Jump to atomicbot project directory${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-config)      ${_CLR_DIM}Open config directory (~/.atomicbot)${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-workspace)   ${_CLR_DIM}Open workspace directory${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_CLR_RESET}"
  echo -e "${_CLR_BOLD}${_CLR_GREEN}🚀 First Time Setup${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  1.${_CLR_RESET} $(_cmd atomicock-start)          ${_CLR_DIM}# Start the gateway${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  2.${_CLR_RESET} $(_cmd atomicock-fix-token)      ${_CLR_DIM}# Configure token${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  3.${_CLR_RESET} $(_cmd atomicock-dashboard)      ${_CLR_DIM}# Open web UI${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  4.${_CLR_RESET} $(_cmd atomicock-devices)        ${_CLR_DIM}# If pairing needed${_CLR_RESET}"
  echo -e "${_CLR_CYAN}  5.${_CLR_RESET} $(_cmd atomicock-approve) ${_CLR_CYAN}<id>${_CLR_RESET}   ${_CLR_DIM}# Approve pairing${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_GREEN}💬 WhatsApp Setup${_CLR_RESET}"
  echo -e "  $(_cmd atomicock-shell)"
  echo -e "    ${_CLR_BLUE}>${_CLR_RESET} $(_cmd 'atomicbot channels login --channel whatsapp')"
  echo -e "    ${_CLR_BLUE}>${_CLR_RESET} $(_cmd 'atomicbot status')"
  echo ""

  echo -e "${_CLR_BOLD}${_CLR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_CLR_RESET}"
  echo ""

  echo -e "${_CLR_CYAN}💡 All commands guide you through next steps!${_CLR_RESET}"
  echo -e "${_CLR_BLUE}📚 Docs: ${_CLR_RESET}${_CLR_CYAN}https://docs.atomicbot.ai${_CLR_RESET}"
  echo ""
}

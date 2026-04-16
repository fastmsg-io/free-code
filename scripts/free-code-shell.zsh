# free-code shell entrypoint
# Source this file from ~/.zshrc to register project commands.

# Determine repository root from this file location when sourced.
typeset -g FREE_CODE_ROOT="${FREE_CODE_ROOT:-${0:A:h:h}}"
typeset -g FREE_CODE_BIN="${FREE_CODE_BIN:-$FREE_CODE_ROOT/cli-dev}"

# Load project-local environment variables from .env (ignored by git).
if [[ -f "$FREE_CODE_ROOT/.env" ]]; then
  set -a
  source "$FREE_CODE_ROOT/.env"
  set +a
fi

# Backward compatibility with older local override file.
[[ -f "$FREE_CODE_ROOT/.free-code.local.zsh" ]] && source "$FREE_CODE_ROOT/.free-code.local.zsh"

free-local() {
  local model="${FREE_LOCAL_MODEL:-minimax-m2.7:cloud}"
  local base
  if [[ -n "${FREE_LOCAL_ANTHROPIC_BASE_URL}" ]]; then
    base="${FREE_LOCAL_ANTHROPIC_BASE_URL}"
  elif [[ -n "${FREE_LOCAL_FASTMSG_TOKEN}" ]]; then
    local t="${FREE_LOCAL_FASTMSG_TOKEN#/}"
    base="https://ollama.fastmsg.io/${t}"
  else
    echo 'free-local: define FREE_LOCAL_FASTMSG_TOKEN or FREE_LOCAL_ANTHROPIC_BASE_URL.' >&2
    return 1
  fi

  local key="${FREE_LOCAL_API_KEY:-sk-local}"
  local ollama_models="${FREE_LOCAL_OLLAMA_MODELS:-minimax-m2.7:cloud,glm-5.1:cloud,gemma4:31b-cloud,qwen3.5:cloud,qwen3-coder-next:cloud}"

  [[ -x "$FREE_CODE_BIN" ]] || {
    echo "free-local: binary not found/executable at $FREE_CODE_BIN" >&2
    echo "Tip: run 'bun run build:dev' in $FREE_CODE_ROOT or set FREE_CODE_BIN." >&2
    return 1
  }

  env -u ANTHROPIC_API_KEY -u ANTHROPIC_BASE_URL -u ANTHROPIC_AUTH_TOKEN \
    ANTHROPIC_API_KEY="$key" \
    ANTHROPIC_AUTH_TOKEN="${FREE_LOCAL_ANTHROPIC_AUTH_TOKEN:-ollama}" \
    ANTHROPIC_BASE_URL="$base" \
    FREE_LOCAL_OLLAMA_MODELS="$ollama_models" \
    CLAUDE_CONFIG_DIR="$HOME/.free-code" \
    "$FREE_CODE_BIN" --model "$model" "$@"
}

#!/bin/bash
# ============================================================================
#  Claude Code Buddy — One-Line Installer
#
#  Install:
#    curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code-buddy/main/install.sh | bash
#
#  Or from cloned repo:
#    ./install.sh
# ============================================================================

set -e

INSTALL_DIR="$HOME/.claude/scripts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" 2>/dev/null)" 2>/dev/null && pwd 2>/dev/null || echo "")"
REPO_BASE="https://raw.githubusercontent.com/anthropics/claude-code-buddy/main"

echo ""
echo "  ┌───────────┐"
echo "  │  ●     ●  │  Claude Code Buddy"
echo "  │   ◡◡◡    │  Installer"
echo "  └─────┬─────┘"
echo "   ( ▀▀▀▀▀ )"
echo "   ▀▀ ▀▀ ▀▀ ▀▀"
echo ""

# ── Check dependencies ──────────────────────────────────────────
missing=0

if ! command -v tmux &>/dev/null; then
    echo "⚠  tmux is required but not installed."
    echo "   Install with: brew install tmux (macOS) or apt install tmux (Linux)"
    missing=1
fi

if ! command -v claude &>/dev/null; then
    echo "⚠  Claude CLI not found in PATH."
    echo "   Install from: https://docs.anthropic.com/en/docs/claude-code"
    missing=1
fi

if ! command -v jq &>/dev/null; then
    echo "⚠  jq is required but not installed."
    echo "   Install with: brew install jq (macOS) or apt install jq (Linux)"
    missing=1
fi

if [[ "$missing" -eq 1 ]]; then
    echo ""
    echo "Please install missing dependencies and try again."
    exit 1
fi

echo "✓ Dependencies found (tmux, claude, jq)"

# ── Install scripts ─────────────────────────────────────────────
mkdir -p "$INSTALL_DIR"

# Try local files first (if run from cloned repo), otherwise download
if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/claude-buddy-animation.sh" ]]; then
    echo "  Installing from local files..."
    cp "$SCRIPT_DIR/claude-buddy-animation.sh" "$INSTALL_DIR/claude-buddy-animation.sh"
    cp "$SCRIPT_DIR/claude-with-buddy.sh" "$INSTALL_DIR/claude-with-buddy.sh"
    cp "$SCRIPT_DIR/sprites.sh" "$INSTALL_DIR/sprites.sh"
else
    echo "  Downloading scripts..."
    if command -v curl &>/dev/null; then
        curl -fsSL "$REPO_BASE/claude-buddy-animation.sh" -o "$INSTALL_DIR/claude-buddy-animation.sh"
        curl -fsSL "$REPO_BASE/claude-with-buddy.sh" -o "$INSTALL_DIR/claude-with-buddy.sh"
        curl -fsSL "$REPO_BASE/sprites.sh" -o "$INSTALL_DIR/sprites.sh"
    elif command -v wget &>/dev/null; then
        wget -qO "$INSTALL_DIR/claude-buddy-animation.sh" "$REPO_BASE/claude-buddy-animation.sh"
        wget -qO "$INSTALL_DIR/claude-with-buddy.sh" "$REPO_BASE/claude-with-buddy.sh"
        wget -qO "$INSTALL_DIR/sprites.sh" "$REPO_BASE/sprites.sh"
    else
        echo "Error: curl or wget required to download scripts"
        exit 1
    fi
fi

chmod +x "$INSTALL_DIR/claude-buddy-animation.sh"
chmod +x "$INSTALL_DIR/claude-with-buddy.sh"
chmod +x "$INSTALL_DIR/sprites.sh"

echo "✓ Scripts installed to $INSTALL_DIR"

# ── Detect shell ────────────────────────────────────────────────
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bashrc" ;;
    *)    RC_FILE="$HOME/.${SHELL_NAME}rc" ;;
esac

# ── Add aliases ─────────────────────────────────────────────────
ALIAS_BLOCK="
# Claude Code Buddy — animated companion for Claude CLI
alias claude-buddy='bash $INSTALL_DIR/claude-with-buddy.sh'
alias shizuka='bash $INSTALL_DIR/claude-with-buddy.sh --dangerously-skip-permissions'
alias claude='bash $INSTALL_DIR/claude-with-buddy.sh'"

if grep -q "claude-buddy" "$RC_FILE" 2>/dev/null; then
    echo "✓ Aliases already exist in $RC_FILE"
else
    echo "$ALIAS_BLOCK" >> "$RC_FILE"
    echo "✓ Aliases added to $RC_FILE"
fi

echo ""
echo "┌──────────────────────────────────────────────────┐"
echo "│  Installation complete!                          │"
echo "│                                                  │"
echo "│  Usage:                                          │"
echo "│    claude                  # start with buddy    │"
echo "│    claude -p 'hi'          # pass any args       │"
echo "│    shizuka                 # skip permissions    │"
echo "│    claude-buddy            # same as claude      │"
echo "│                                                  │"
echo "│  Works with multiple parallel sessions!          │"
echo "│                                                  │"
echo "│  Reload your shell:                              │"
echo "│    source $RC_FILE"
echo "│                                                  │"
echo "│  Or just run:                                    │"
echo "│    bash $INSTALL_DIR/claude-with-buddy.sh"
echo "│                                                  │"
echo "└──────────────────────────────────────────────────┘"
echo ""

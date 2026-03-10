#!/bin/bash
# ============================================================================
#  Claude Code Buddy — Installer
#  Copies scripts to ~/.claude/scripts/ and sets up shell aliases
# ============================================================================

set -e

INSTALL_DIR="$HOME/.claude/scripts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  ┌─────────┐"
echo "  │ ◉     ◉ │  Claude Code Buddy Installer"
echo "  │   ◡     │"
echo "  └────┬────┘"
echo "   ┌───┴───┐"
echo "   │ █████ │"
echo "   └───────┘"
echo ""

# ── Check dependencies ──────────────────────────────────────────
if ! command -v tmux &>/dev/null; then
    echo "⚠  tmux is required but not installed."
    echo "   Install with: brew install tmux (macOS) or apt install tmux (Linux)"
    exit 1
fi

if ! command -v claude &>/dev/null; then
    echo "⚠  Claude CLI not found in PATH."
    echo "   Install from: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "⚠  jq is required but not installed."
    echo "   Install with: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
fi

echo "✓ Dependencies found (tmux, claude, jq)"

# ── Install scripts ─────────────────────────────────────────────
mkdir -p "$INSTALL_DIR"

cp "$SCRIPT_DIR/claude-buddy-animation.sh" "$INSTALL_DIR/claude-buddy-animation.sh"
cp "$SCRIPT_DIR/claude-with-buddy.sh" "$INSTALL_DIR/claude-with-buddy.sh"
chmod +x "$INSTALL_DIR/claude-buddy-animation.sh"
chmod +x "$INSTALL_DIR/claude-with-buddy.sh"

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
alias shizuka='bash $INSTALL_DIR/claude-with-buddy.sh --dangerously-skip-permissions'"

if grep -q "claude-buddy" "$RC_FILE" 2>/dev/null; then
    echo "✓ Aliases already exist in $RC_FILE"
else
    echo "$ALIAS_BLOCK" >> "$RC_FILE"
    echo "✓ Aliases added to $RC_FILE"
fi

echo ""
echo "┌──────────────────────────────────────────────┐"
echo "│  Installation complete!                      │"
echo "│                                              │"
echo "│  Usage:                                      │"
echo "│    claude-buddy          # start with buddy  │"
echo "│    claude-buddy -p 'hi'  # pass any args     │"
echo "│    shizuka               # skip permissions  │"
echo "│                                              │"
echo "│  Reload your shell:                          │"
echo "│    source $RC_FILE"
echo "│                                              │"
echo "└──────────────────────────────────────────────┘"
echo ""

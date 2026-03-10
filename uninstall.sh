#!/bin/bash
# ============================================================================
#  Claude Code Buddy — Uninstaller
# ============================================================================

INSTALL_DIR="$HOME/.claude/scripts"

echo "Removing Claude Code Buddy..."

rm -f "$INSTALL_DIR/claude-buddy-animation.sh"
rm -f "$INSTALL_DIR/claude-with-buddy.sh"

SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
    zsh)  RC_FILE="$HOME/.zshrc" ;;
    bash) RC_FILE="$HOME/.bashrc" ;;
    *)    RC_FILE="$HOME/.${SHELL_NAME}rc" ;;
esac

if [[ -f "$RC_FILE" ]]; then
    # Remove the alias block
    sed -i.bak '/# Claude Code Buddy/d' "$RC_FILE"
    sed -i.bak "/alias claude-buddy=/d" "$RC_FILE"
    sed -i.bak "/alias shizuka=/d" "$RC_FILE"
    rm -f "${RC_FILE}.bak"
    echo "✓ Aliases removed from $RC_FILE"
fi

echo "✓ Claude Code Buddy uninstalled"
echo "  Reload your shell: source $RC_FILE"

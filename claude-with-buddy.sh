#!/bin/bash
# ============================================================================
#  Claude Code + Buddy Launcher
#  Opens Claude CLI with an animated buddy in a TOP tmux pane
#  Supports multiple parallel sessions — each buddy tracks its own Claude
# ============================================================================

SESSION_NAME="claude-buddy-$$"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUDDY_SCRIPT="$SCRIPT_DIR/claude-buddy-animation.sh"
BUDDY_HEIGHT=6  # 5 lines for mascot + 1 line buffer

# Pass current working directory so buddy tracks the right project
export PROJECT_DIR="$PWD"

# Fallback: check common install locations
if [[ ! -f "$BUDDY_SCRIPT" ]]; then
    BUDDY_SCRIPT="$HOME/.claude/scripts/claude-buddy-animation.sh"
fi
if [[ ! -f "$BUDDY_SCRIPT" ]]; then
    echo "Error: claude-buddy-animation.sh not found"
    echo "Run: curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code-buddy/main/install.sh | bash"
    exit 1
fi

# Check tmux
if ! command -v tmux &>/dev/null; then
    echo "Error: tmux is required. Install with: brew install tmux"
    exit 1
fi

# Build the claude command with all passed arguments
claude_cmd="claude"
for arg in "$@"; do
    claude_cmd+=" $(printf '%q' "$arg")"
done

# ──────────────────────────────────────────────────────────────
#  If already inside tmux, split a top pane for buddy
# ──────────────────────────────────────────────────────────────
if [[ -n "$TMUX" ]]; then
    # Split current pane: create a pane ABOVE for the buddy
    tmux split-window -b -v -l "$BUDDY_HEIGHT" \
        "PROJECT_DIR='$PROJECT_DIR' bash '$BUDDY_SCRIPT'"
    # Fix border colors — uniform orange, no half-grey/half-orange
    tmux set-option pane-border-style "fg=colour209"
    tmux set-option pane-active-border-style "fg=colour209"
    tmux set-option pane-border-lines simple
    # Focus back on the bottom pane (Claude)
    tmux select-pane -D
    exec $claude_cmd
fi

# ──────────────────────────────────────────────────────────────
#  Fresh tmux session: buddy on top, Claude on bottom
# ──────────────────────────────────────────────────────────────

# Create session running the buddy animation (pass PROJECT_DIR)
tmux new-session -d -s "$SESSION_NAME" \
    -x "$(tput cols)" -y "$(tput lines)" \
    "PROJECT_DIR='$PROJECT_DIR' bash '$BUDDY_SCRIPT'"

# Split below for Claude CLI — Claude gets most of the space
tmux split-window -v -t "$SESSION_NAME:0.0" \
    -l $(($(tput lines) - BUDDY_HEIGHT - 1)) \
    "$claude_cmd; tmux kill-session -t '$SESSION_NAME' 2>/dev/null"

# Focus the Claude pane (bottom)
tmux select-pane -t "$SESSION_NAME:0.1"

# Style: uniform border color (no half-grey/half-orange split)
tmux set-option -t "$SESSION_NAME" pane-border-style "fg=colour209"
tmux set-option -t "$SESSION_NAME" pane-active-border-style "fg=colour209"
tmux set-option -t "$SESSION_NAME" pane-border-lines simple
tmux set-option -t "$SESSION_NAME" status off

# Attach
exec tmux attach-session -t "$SESSION_NAME"

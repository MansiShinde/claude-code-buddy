#!/bin/bash
# ============================================================================
#  Claude Code Buddy — Animation Engine
#  Sources sprites.sh for all frames, handles state detection + movement
# ============================================================================

R=$'\033[0m'
BG_TAN=$'\033[48;5;173m'
FG_TAN=$'\033[38;5;173m'
FG_DTAN=$'\033[38;5;137m'
BG_DTAN=$'\033[48;5;137m'
FG_BLACK=$'\033[38;5;16m'
BG_BLACK=$'\033[48;5;16m'
FG_WHITE=$'\033[38;5;255m'
BG_WHITE=$'\033[48;5;255m'
FG_YELLOW=$'\033[38;5;222m'
BG_YELLOW=$'\033[48;5;222m'
FG_BLUE=$'\033[38;5;74m'
BG_BLUE=$'\033[48;5;74m'
FG_GRAY=$'\033[38;5;245m'
BG_GRAY=$'\033[48;5;245m'
FG_DGRAY=$'\033[38;5;240m'
FG_GREEN=$'\033[38;5;114m'
FG_PINK=$'\033[38;5;211m'
FG_CYAN=$'\033[38;5;80m'
FG_ORANGE=$'\033[38;5;209m'
FG_RED=$'\033[38;5;196m'
BG_RED=$'\033[48;5;196m'
FG_PURPLE=$'\033[38;5;141m'
FG_BOLD=$'\033[1m'

FRAME_DELAY=0.3
STATE_CHECK_EVERY=1
MASCOT_WIDTH=12

# Source sprite sheet (with hot-reload support)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPRITES_FILE=""
if [[ -f "$SCRIPT_DIR/sprites.sh" ]]; then
    SPRITES_FILE="$SCRIPT_DIR/sprites.sh"
elif [[ -f "$HOME/.claude/scripts/sprites.sh" ]]; then
    SPRITES_FILE="$HOME/.claude/scripts/sprites.sh"
fi
[[ -n "$SPRITES_FILE" ]] && source "$SPRITES_FILE"
sprites_mtime=$(stat -f %m "$SPRITES_FILE" 2>/dev/null || stat -c %Y "$SPRITES_FILE" 2>/dev/null || echo 0)

# ── Transcript detection ───────────────────────────────────────
find_transcript() {
    local search_dir=""
    if [[ -n "$PROJECT_DIR" ]]; then
        local encoded
        encoded=$(echo "$PROJECT_DIR" | sed 's|^/|-|;s|/|-|g')
        search_dir="$HOME/.claude/projects/${encoded}"
    fi
    [[ -z "$search_dir" || ! -d "$search_dir" ]] && search_dir="$HOME/.claude/projects"
    local latest="" lt=0
    while IFS= read -r f; do
        local mt
        mt=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0)
        [[ "$mt" -gt "$lt" ]] && lt=$mt && latest="$f"
    done < <(find "$search_dir" -maxdepth 3 -name "*.jsonl" -not -path "*/subagents/*" 2>/dev/null)
    echo "$latest"
}

detect_state() {
    local t="$1"
    [[ -z "$t" || ! -f "$t" ]] && echo "idle" && return
    local age
    age=$(( $(date +%s) - $(stat -f %m "$t" 2>/dev/null || stat -c %Y "$t" 2>/dev/null || echo 0) ))
    # Use -x to match exact process name "claude", not our "claude-buddy" scripts
    local claude_running=0
    pgrep -x "claude" >/dev/null 2>&1 && claude_running=1
    [[ "$age" -gt 30 ]] && echo "idle" && return
    local recent
    recent=$(tail -15 "$t" 2>/dev/null)
    local lt
    lt=$(echo "$recent" | jq -r 'select(.type != null and .type != "file-history-snapshot") | .type' 2>/dev/null | tail -1)
    local last_has_tool
    last_has_tool=$(echo "$recent" | jq -r 'select(.type == "assistant") | .message.content // [] | if type == "array" then [.[] | select(.type == "tool_use")] | length else 0 end' 2>/dev/null | tail -1)
    if [[ "$lt" == "assistant" && ( -z "$last_has_tool" || "$last_has_tool" == "0" ) ]]; then
        # Only show brewing if Claude CLI is actively running
        [[ "$claude_running" -eq 1 && "$age" -le 15 ]] && echo "brewing" && return
    fi
    case "$lt" in
        assistant|progress|result)
            [[ "$claude_running" -eq 1 ]] && echo "working" || echo "idle" ;;
        user) [[ "$age" -le 5 && "$claude_running" -eq 1 ]] && echo "working" || echo "idle" ;;
        *) [[ "$claude_running" -eq 1 && "$age" -le 10 ]] && echo "working" || echo "idle" ;;
    esac
}

read_tool() {
    local t="$1"
    [[ -z "$t" || ! -f "$t" ]] && return
    tail -10 "$t" 2>/dev/null | jq -r 'select(.type == "assistant" or .type == "progress") | .message.content // [] | if type == "array" then [.[] | select(.type == "tool_use") | .name] | last // empty else empty end' 2>/dev/null | tail -1
}

tool_label() {
    case "$1" in
        Read) echo "reading" ;; Edit) echo "editing" ;; Write) echo "writing" ;;
        Bash) echo "running" ;; Grep) echo "searching" ;; Glob) echo "finding" ;;
        Agent) echo "delegating" ;; WebSearch) echo "googling" ;; WebFetch) echo "fetching" ;;
        Skill) echo "skill" ;; ToolSearch) echo "loading" ;; thinking) echo "brewing" ;;
        *) echo "thinking" ;;
    esac
}

# ── Drawing helpers ────────────────────────────────────────────
PAD=""
pl() { printf '%s%b' "$PAD" "$1"; tput el; printf '\n'; }
set_pad() { PAD=""; (( $1 > 0 )) && PAD=$(printf '%*s' "$1" ''); }
get_center() { local c; c=$(tput cols 2>/dev/null || echo 80); echo $(( (c - MASCOT_WIDTH) / 2 )); }

# ── Idle sequence with eye-tracking animation ──────────────────
IDLE_SEQUENCE=(
    # Watching user type — eyes scan down left/center/right
    sprite_idle_watch_down_center
    sprite_idle_watch_down_left
    sprite_idle_watch_down_center
    sprite_idle_watch_down_right
    sprite_idle_watch_down_center
    sprite_idle_watch_down_smile
    sprite_idle_blink
    # Peek down toward typing
    sprite_idle_peek_down_0
    sprite_idle_peek_down_1
    sprite_idle_peek_down_0
    sprite_idle_watch_down_left
    sprite_idle_watch_down_right
    sprite_idle_watch_down_center
    sprite_idle_normal
    # Quick look around then back to watching
    sprite_idle_look_left
    sprite_idle_look_right
    sprite_idle_blink
    sprite_idle_watch_down_center
    sprite_idle_watch_down_left
    sprite_idle_watch_down_right
    sprite_idle_watch_down_smile
    # Fun break
    sprite_idle_wave_0
    sprite_idle_wave_1
    sprite_idle_wave_0
    sprite_idle_watch_down_center
    sprite_idle_watch_down_left
    sprite_idle_watch_down_right
    # Sing a little then keep watching
    sprite_idle_sing_0
    sprite_idle_sing_1
    sprite_idle_sing_0
    sprite_idle_wink
    sprite_idle_watch_down_center
    sprite_idle_watch_down_right
    sprite_idle_watch_down_left
    sprite_idle_blink
    # Sleepy if user types for a while
    sprite_idle_yawn
    sprite_idle_sleep_0
    sprite_idle_sleep_1
    sprite_idle_sleep_0
    sprite_idle_sleep_1
    sprite_idle_surprised
    sprite_idle_jump
    # Back to watching
    sprite_idle_watch_down_center
    sprite_idle_watch_down_left
    sprite_idle_watch_down_right
    sprite_idle_watch_down_smile
    # Dance break
    sprite_idle_dance_0
    sprite_idle_dance_1
    sprite_idle_dance_0
    sprite_idle_dance_1
    sprite_idle_watch_down_center
    sprite_idle_watch_down_right
    # More watching with interruptions
    sprite_idle_tap_0
    sprite_idle_tap_1
    sprite_idle_tap_0
    sprite_idle_watch_down_left
    sprite_idle_watch_down_center
    sprite_idle_juggle_0
    sprite_idle_juggle_1
    sprite_idle_juggle_0
    sprite_idle_juggle_1
    sprite_idle_watch_down_center
    sprite_idle_peek
    sprite_idle_watch_down_smile
    sprite_idle_flex
    sprite_idle_blink
    sprite_idle_watch_down_center
)
IDLE_COUNT=${#IDLE_SEQUENCE[@]}

# ── Tool-to-sprite mapping ────────────────────────────────────
draw_for_tool() {
    local tool="$1" f="$2" label="$3"
    case "$tool" in
        Read)
            case $(( f % 4 )) in
                0) sprite_work_read_0 "$label" "$f" ;; 1) sprite_work_read_1 "$label" "$f" ;;
                2) sprite_work_think_0 "$label" "$f" ;; 3) sprite_work_read_0 "$label" "$f" ;;
            esac ;;
        Edit|Write)
            case $(( f % 8 )) in
                0) sprite_work_type_0 "$label" "$f" ;; 1) sprite_work_type_1 "$label" "$f" ;;
                2) sprite_work_tongue_0 "$label" "$f" ;; 3) sprite_work_tongue_1 "$label" "$f" ;;
                4) sprite_work_type_0 "$label" "$f" ;; 5) sprite_work_type_1 "$label" "$f" ;;
                6) sprite_work_sweat_0 "$label" "$f" ;; 7) sprite_work_sweat_1 "$label" "$f" ;;
            esac ;;
        Bash)
            case $(( f % 8 )) in
                0) sprite_work_build_0 "$label" "$f" ;; 1) sprite_work_build_1 "$label" "$f" ;;
                2) sprite_work_battle_0 "$label" "$f" ;; 3) sprite_work_battle_1 "$label" "$f" ;;
                4) sprite_work_ninja_0 "$label" "$f" ;; 5) sprite_work_ninja_1 "$label" "$f" ;;
                6) sprite_work_build_0 "$label" "$f" ;; 7) sprite_work_sweat_0 "$label" "$f" ;;
            esac ;;
        Grep|Glob|WebSearch|WebFetch)
            case $(( f % 4 )) in
                0) sprite_work_search_0 "$label" "$f" ;; 1) sprite_work_search_1 "$label" "$f" ;;
                2) sprite_work_search_0 "$label" "$f" ;; 3) sprite_work_think_0 "$label" "$f" ;;
            esac ;;
        Agent|ToolSearch|Skill)
            case $(( f % 6 )) in
                0) sprite_work_think_0 "$label" "$f" ;; 1) sprite_work_think_1 "$label" "$f" ;;
                2) sprite_work_battle_0 "$label" "$f" ;; 3) sprite_work_think_0 "$label" "$f" ;;
                4) sprite_work_eureka "$label" "$f" ;; 5) sprite_work_think_1 "$label" "$f" ;;
            esac ;;
        thinking)
            case $(( f % 8 )) in
                0) sprite_work_brew_0 "$label" "$f" ;; 1) sprite_work_brew_1 "$label" "$f" ;;
                2) sprite_work_coffee_0 "$label" "$f" ;; 3) sprite_work_coffee_1 "$label" "$f" ;;
                4) sprite_work_ponder_0 "$label" "$f" ;; 5) sprite_work_ponder_1 "$label" "$f" ;;
                6) sprite_work_think_0 "$label" "$f" ;; 7) sprite_work_think_1 "$label" "$f" ;;
            esac ;;
        *)
            case $(( f % 14 )) in
                0) sprite_work_type_0 "$label" "$f" ;; 1) sprite_work_type_1 "$label" "$f" ;;
                2) sprite_work_think_0 "$label" "$f" ;; 3) sprite_work_think_1 "$label" "$f" ;;
                4) sprite_work_tongue_0 "$label" "$f" ;; 5) sprite_work_tongue_1 "$label" "$f" ;;
                6) sprite_work_sweat_0 "$label" "$f" ;; 7) sprite_work_coffee_0 "$label" "$f" ;;
                8) sprite_work_coffee_1 "$label" "$f" ;; 9) sprite_work_headbang_0 "$label" "$f" ;;
                10) sprite_work_headbang_1 "$label" "$f" ;; 11) sprite_work_battle_0 "$label" "$f" ;;
                12) sprite_work_eureka "$label" "$f" ;; 13) sprite_work_facepalm "$label" "$f" ;;
            esac ;;
    esac
}

# ── Movement ───────────────────────────────────────────────────
work_pos=0; work_dir=1; WALK_SPEED=3
update_work_position() {
    local cols; cols=$(tput cols 2>/dev/null || echo 80)
    local max_x=$(( cols - MASCOT_WIDTH - 22 ))
    (( max_x < 2 )) && max_x=2
    work_pos=$(( work_pos + work_dir * WALK_SPEED ))
    (( work_pos >= max_x )) && work_pos=$max_x && work_dir=-1
    (( work_pos <= 0 )) && work_pos=0 && work_dir=1
}

# ── Main loop ──────────────────────────────────────────────────
cleanup() { tput cnorm; tput sgr0; clear; exit 0; }
trap cleanup INT TERM
tput civis; clear

state="idle"; frame=0; fc=0; current_tool=""

while true; do
    # Hot-reload sprites.sh if modified
    if [[ -n "$SPRITES_FILE" && $((fc % 10)) -eq 0 ]]; then
        new_mtime=$(stat -f %m "$SPRITES_FILE" 2>/dev/null || stat -c %Y "$SPRITES_FILE" 2>/dev/null || echo 0)
        if [[ "$new_mtime" != "$sprites_mtime" ]]; then
            source "$SPRITES_FILE"
            sprites_mtime=$new_mtime
        fi
    fi

    if [[ $((fc % STATE_CHECK_EVERY)) -eq 0 ]]; then
        transcript=$(find_transcript)
        new_state=$(detect_state "$transcript")
        if [[ "$new_state" == "brewing" ]]; then
            current_tool="thinking"; new_state="working"
        else
            current_tool=$(read_tool "$transcript")
        fi
        if [[ "$new_state" != "$state" ]]; then
            frame=0
            [[ "$new_state" == "working" ]] && work_pos=0 && work_dir=1
        fi
        state=$new_state
    fi
    fc=$((fc + 1))
    tput cup 0 0

    if [[ "$state" == "working" ]]; then
        update_work_position
        set_pad "$work_pos"
        label=$(tool_label "$current_tool")
        draw_for_tool "$current_tool" "$frame" "$label"
    else
        center=$(get_center)
        set_pad "$center"
        idx=$(( frame % IDLE_COUNT ))
        ${IDLE_SEQUENCE[$idx]}
    fi

    frame=$((frame + 1))
    sleep "$FRAME_DELAY"
done

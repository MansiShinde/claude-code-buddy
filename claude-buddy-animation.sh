#!/bin/bash
# ============================================================================
#  Claude Code Buddy — animated pixel-art mascot with movement & personality
#  Now with arms, hands, legs, and even MORE personality!
# ============================================================================

R=$'\033[0m'
BG_TAN=$'\033[48;5;173m'
FG_TAN=$'\033[38;5;173m'
FG_BLACK=$'\033[38;5;16m'
BG_BLACK=$'\033[48;5;16m'
FG_WHITE=$'\033[38;5;255m'
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
FG_BOLD=$'\033[1m'
FG_PURPLE=$'\033[38;5;141m'

FRAME_DELAY=0.35
STATE_CHECK_EVERY=1  # check every frame for snappy state transitions
MASCOT_WIDTH=15  # visual width of mascot (wider now with arms)

# ── Transcript detection ────────────────────────────────────────
find_transcript() {
    local latest="" lt=0
    while IFS= read -r f; do
        local mt
        mt=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0)
        [[ "$mt" -gt "$lt" ]] && lt=$mt && latest="$f"
    done < <(find "$HOME/.claude/projects" -maxdepth 2 -name "*.jsonl" -not -path "*/subagents/*" 2>/dev/null)
    echo "$latest"
}

detect_state() {
    local t="$1"
    [[ -z "$t" || ! -f "$t" ]] && echo "idle" && return
    local age
    age=$(( $(date +%s) - $(stat -f %m "$t" 2>/dev/null || stat -c %Y "$t" 2>/dev/null || echo 0) ))
    # If transcript hasn't been touched in 5s, Claude is idle
    [[ "$age" -gt 5 ]] && echo "idle" && return

    # Check recent lines for state
    local recent
    recent=$(tail -10 "$t" 2>/dev/null)

    # Check for "Brewing" — assistant generating with stop_reason: null
    local brewing
    brewing=$(echo "$recent" | jq -r 'select(.type == "assistant" and .stop_reason == null) | .type' 2>/dev/null | tail -1)
    if [[ "$brewing" == "assistant" ]]; then
        echo "brewing"
        return
    fi

    local lt
    lt=$(echo "$recent" | jq -r 'select(.type != null) | .type' 2>/dev/null | tail -1)
    case "$lt" in
        user|progress) echo "working" ;;
        assistant)     echo "working" ;;
        result)        echo "working" ;;
        *)             echo "idle" ;;
    esac
}

read_tool() {
    local t="$1"
    [[ -z "$t" || ! -f "$t" ]] && return
    tail -10 "$t" 2>/dev/null | jq -r '
        select(.type == "assistant" or .type == "progress") |
        .message.content // [] |
        if type == "array" then
            [.[] | select(.type == "tool_use") | .name] | last // empty
        else empty end
    ' 2>/dev/null | tail -1
}

tool_label() {
    case "$1" in
        Read)       echo "reading"   ;; Edit)       echo "editing"   ;;
        Write)      echo "writing"   ;; Bash)       echo "running"   ;;
        Grep)       echo "searching" ;; Glob)       echo "finding"   ;;
        Agent)      echo "delegating";; WebSearch)  echo "googling"  ;;
        WebFetch)   echo "fetching"  ;; Skill)      echo "skill"     ;;
        ToolSearch) echo "loading"   ;; thinking)   echo "brewing"   ;;
        *)          echo "thinking"  ;;
    esac
}

# ── Drawing helpers ────────────────────────────────────────────
# Print a line with padding (for horizontal positioning)
PAD=""
pl() { printf '%s%b' "$PAD" "$1"; tput el; printf '\n'; }

set_pad() {
    local n="$1"
    PAD=""
    (( n > 0 )) && PAD=$(printf '%*s' "$n" '')
}

get_center() {
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    echo $(( (cols - MASCOT_WIDTH) / 2 ))
}

# ============================================================================
#  IDLE FRAMES — centered, cute & funny (6 lines each)
# ============================================================================

draw_idle_normal() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}waiting for you~${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_look_left() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}${BG_BLACK}  ${BG_TAN}  ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}...what's over there?${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_look_right() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN}  ${BG_BLACK}  ${R}${FG_TAN}█${R}  ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}hmm, interesting...${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_blink() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}—— ${FG_BLACK}——${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*blink blink*${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_sleep_0() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}  ${FG_DGRAY}z${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}—— ${FG_BLACK}——${BG_TAN} ${R}${FG_TAN}█${R} ${FG_DGRAY}z${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}~~~${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}zzz...${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_sleep_1() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_DGRAY}z${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}—— ${FG_BLACK}——${BG_TAN} ${R}${FG_TAN}█${R}${FG_DGRAY}z${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}~~~${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*snore*${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_sing_0() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_PINK}♪${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}${FG_PINK}♫${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}la la la~${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_sing_1() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}${FG_PINK}♫${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R} ${FG_PINK}♪${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}do re mi~${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_wink() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${FG_BLACK}——${BG_TAN} ${R}${FG_TAN}█${R}${FG_CYAN}✧${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}hey there ;)${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_surprised() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_YELLOW}!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_WHITE}◉${BG_TAN} ${FG_WHITE}◉${BG_TAN}  ${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}   ${FG_BLACK}○${BG_TAN}   ${R}${FG_TAN}█${R}  ${FG_DGRAY}oh! you startled me${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_yawn() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}>${BG_TAN} ${FG_BLACK}<${BG_TAN}  ${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}(○)${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*yaaawn*${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_dance_0() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_PINK}♪${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*boogie*${R}"
    pl " ${FG_TAN}\\▀█▀▀▀▀▀█▀/${R}"
    pl "   ${FG_TAN}▀▀${R} ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_dance_1() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}${FG_PINK}♫${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*shake shake*${R}"
    pl " ${FG_TAN}╰▀█▀▀▀▀▀█▀╯${R}"
    pl "    ${FG_TAN}▀▀${R} ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_peek() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_DGRAY}pssst...${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}type something!${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_flex() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}  ${FG_YELLOW}${FG_BOLD}POW${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}i'm ready!${R}"
    pl " ${FG_TAN}╤▀█▀▀▀▀▀█▀╤${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── NEW idle: waving hand ────────────────────────────────────
draw_idle_wave_0() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_YELLOW}${FG_BOLD}Hi!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*wave wave*${R}"
    pl " ${FG_TAN} ▀█▀▀▀▀▀█▀${R}${FG_TAN}╯${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_idle_wave_1() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}  ${FG_YELLOW}${FG_BOLD}Hey!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}${FG_TAN}/${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}over here!${R}"
    pl " ${FG_TAN} ▀█▀▀▀▀▀█▀${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── NEW idle: stretching arms up ─────────────────────────────
draw_idle_stretch() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}—— ${FG_BLACK}——${BG_TAN} ${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}(○)${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*streeetch*${R}"
    pl " ${FG_TAN}\\▀█▀▀▀▀▀█▀/${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── NEW idle: tapping foot impatiently ───────────────────────
draw_idle_tap_foot_0() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}───${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*tap tap tap*${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}  ${FG_TAN}▀▄${R}"
    pl ""
}

draw_idle_tap_foot_1() {
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}───${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}any day now...${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▄${R}  ${FG_TAN}▀▀${R}"
    pl ""
}

# ── NEW idle: juggling ───────────────────────────────────────
draw_idle_juggle_0() {
    pl "   ${FG_RED}●${R} ${FG_BLUE}●${R} ${FG_GREEN}●${R}"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_DGRAY}wheee!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}"
    pl " ${FG_TAN}\\▀█▀▀▀▀▀█▀/${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

draw_idle_juggle_1() {
    pl "  ${FG_BLUE}●${R}  ${FG_GREEN}●${R}  ${FG_RED}●${R}"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_DGRAY}catch!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}"
    pl " ${FG_TAN}\\▀█▀▀▀▀▀█▀/${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

IDLE_SEQUENCE=(
    draw_idle_normal
    draw_idle_normal
    draw_idle_look_left
    draw_idle_look_right
    draw_idle_blink
    draw_idle_normal
    draw_idle_wave_0
    draw_idle_wave_1
    draw_idle_wave_0
    draw_idle_sing_0
    draw_idle_sing_1
    draw_idle_sing_0
    draw_idle_wink
    draw_idle_normal
    draw_idle_blink
    draw_idle_stretch
    draw_idle_yawn
    draw_idle_sleep_0
    draw_idle_sleep_1
    draw_idle_sleep_0
    draw_idle_sleep_1
    draw_idle_surprised
    draw_idle_normal
    draw_idle_dance_0
    draw_idle_dance_1
    draw_idle_dance_0
    draw_idle_dance_1
    draw_idle_normal
    draw_idle_tap_foot_0
    draw_idle_tap_foot_1
    draw_idle_tap_foot_0
    draw_idle_juggle_0
    draw_idle_juggle_1
    draw_idle_juggle_0
    draw_idle_juggle_1
    draw_idle_normal
    draw_idle_peek
    draw_idle_normal
    draw_idle_flex
    draw_idle_blink
)
IDLE_COUNT=${#IDLE_SEQUENCE[@]}

# ============================================================================
#  WORKING FRAMES — mascot walks left/right, lots of personality (6 lines)
# ============================================================================

# ── Typing furiously ──────────────────────────────────────────
draw_work_type_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN} █${R}${BG_GRAY}${FG_BLUE}▓▓▓▓▓${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN} ╰▀▀▀▀▀▀▀╯${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

draw_work_type_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}—— ${FG_BLACK}——${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}clack clack${R}"
    pl "  ${FG_TAN} █${R}${BG_GRAY}${FG_BLUE}▓▓▓▓▓${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN} ╰▀▀▀▀▀▀▀╯${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

# ── Tongue out, smashing keyboard ────────────────────────────
draw_work_tongue_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}  ${FG_YELLOW}${FG_BOLD}POW!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}>${BG_TAN} ${FG_BLACK}<${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_PINK}:P${BG_TAN}   ${R}${FG_TAN}█${R}  ${FG_DGRAY}SMASH SMASH${R}"
    pl "  ${FG_TAN} █${R}${BG_GRAY}${FG_RED}!▓▓▓!${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN} ╰▀▀▀▀▀▀▀╯${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

draw_work_tongue_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}  ${FG_YELLOW}${FG_BOLD}BAM!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}>${BG_TAN} ${FG_BLACK}<${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_PINK}:P${BG_TAN}   ${R}${FG_TAN}█${R}  ${FG_DGRAY}TYPE TYPE TYPE${R}"
    pl "  ${FG_TAN} █${R}${BG_GRAY}${FG_RED}▓!▓!▓${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN} ╰▀▀▀▀▀▀▀╯${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

# ── Sweating / trying hard ───────────────────────────────────
draw_work_sweat_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_CYAN};${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_WHITE}◉${BG_TAN} ${FG_WHITE}◉${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}~~~${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}this is fine...${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_work_sweat_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}${FG_CYAN};${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_WHITE}◉${BG_TAN} ${FG_WHITE}◉${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}△△△${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}nnngghhh!!${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── Hard hat building ────────────────────────────────────────
draw_work_build_0() {
    local l="$1"
    pl "  ${BG_YELLOW}${FG_YELLOW}▄▄▄▄▄▄▄▄▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}building...${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${FG_GRAY}d${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_work_build_1() {
    local l="$1"
    pl "  ${BG_YELLOW}${FG_YELLOW}▄▄▄▄▄▄▄▄▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}—— ${FG_BLACK}——${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*bang bang*${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█${FG_GRAY}d${FG_TAN})${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── Magnifying glass search ──────────────────────────────────
draw_work_search_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}where is it...${R}"
    pl " ${FG_TAN} ▀█▀▀▀▀▀█▀${R}${FG_CYAN}o${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${FG_CYAN}/${R}"
    pl ""
}

draw_work_search_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}${BG_BLACK}  ${BG_TAN}  ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}   ${FG_DGRAY}AHA!${R}"
    pl " ${FG_CYAN}o${FG_TAN}▀█▀▀▀▀▀█▀${R}"
    pl " ${FG_CYAN}\\${R} ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── Reading with glasses ─────────────────────────────────────
draw_work_read_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${FG_GRAY}(${R}${BG_BLACK}  ${R}${FG_GRAY})${FG_GRAY}(${R}${BG_BLACK}  ${R}${FG_GRAY})${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}hmm interesting${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_work_read_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${FG_GRAY}(${R}${BG_BLACK}  ${R}${FG_GRAY})${FG_GRAY}(${R}${BG_BLACK}  ${R}${FG_GRAY})${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}~~~${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}I see I see...${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── Thinking sparkle / magic ─────────────────────────────────
draw_work_think_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_CYAN}*${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_CYAN}*${BG_TAN}  ${FG_CYAN}*${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}╰◡◡◡╯${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_DGRAY}big brain time${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_work_think_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}${FG_CYAN}*${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_CYAN}*${BG_TAN} ${FG_CYAN}*${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}╰◡◡◡╯${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_DGRAY}*brain noises*${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── Headbang on keyboard ─────────────────────────────────────
draw_work_headbang_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}x${BG_TAN}  ${FG_BLACK}x${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}___${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}why won't it work${R}"
    pl "  ${FG_TAN} █${R}${BG_GRAY}${FG_BLUE}▓▓▓▓▓${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN} ╰▀▀▀▀▀▀▀╯${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

draw_work_headbang_1() {
    local l="$1"
    pl "   ${FG_YELLOW}${FG_BOLD}*BONK*${R}"
    pl "  ${FG_TAN}▄${FG_BLACK}x  x${FG_TAN}▄${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█▀▀${FG_BLACK}___${FG_TAN}▀█${R}  ${FG_DGRAY}ASDFJKL;${R}"
    pl "  ${FG_TAN} █${R}${BG_GRAY}${FG_RED}@#!%&${R}${FG_TAN}█${R}"
    pl "  ${FG_TAN} ╰▀▀▀▀▀▀▀╯${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

# ── Coffee sip ───────────────────────────────────────────────
draw_work_coffee_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}  ${FG_DGRAY}~${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${FG_DGRAY}~${R} ${FG_DGRAY}sip sip${R}"
    pl " ${FG_TAN} ▀█▀▀▀▀▀█▀${FG_WHITE}[${FG_ORANGE}C${FG_WHITE}]${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_work_coffee_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_DGRAY}~~${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}   ${FG_BLACK}○${BG_TAN}   ${R}${FG_TAN}█${R}  ${FG_DGRAY}mmm caffeine${R}"
    pl " ${FG_TAN} ▀█▀▀▀▀▀█${FG_WHITE}[${FG_ORANGE}C${FG_WHITE}]${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── Determined / battle mode ─────────────────────────────────
draw_work_battle_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_RED}${FG_BOLD}!!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_RED}▼${BG_TAN} ${FG_RED}▼${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}╰███╯${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_DGRAY}LET'S GOOO${R}"
    pl " ${FG_TAN}╤▀█▀▀▀▀▀█▀╤${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_work_battle_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}${FG_RED}${FG_BOLD}!!!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_RED}▼${BG_TAN} ${FG_RED}▼${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_BLACK}╰███╯${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_DGRAY}MAXIMUM EFFORT${R}"
    pl " ${FG_TAN}\\▀█▀▀▀▀▀█▀/${R}${FG_YELLOW}*${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── NEW: Eureka / lightbulb moment ───────────────────────────
draw_work_eureka() {
    local l="$1"
    pl "       ${FG_YELLOW}${FG_BOLD}!${R}"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_WHITE}◉${BG_TAN} ${FG_WHITE}◉${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}EUREKA!${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}"
    pl " ${FG_TAN}\\▀█▀▀▀▀▀█▀/${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

# ── NEW: Facepalm ────────────────────────────────────────────
draw_work_facepalm() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}${FG_TAN}▓▓▓▓▓▓▓${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}___${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}*sigh*...${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── NEW: Ninja mode ──────────────────────────────────────────
draw_work_ninja_0() {
    local l="$1"
    pl "  ${FG_RED}━━━━━━━━━${R}${FG_RED}~${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_WHITE}▸${BG_TAN} ${FG_WHITE}◂${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}====${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_DGRAY}*swoosh*${R}"
    pl " ${FG_TAN}(▀█▀▀▀▀▀█▀)${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_work_ninja_1() {
    local l="$1"
    pl "  ${FG_RED}━━━━━━━━━━${R}${FG_RED}~${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${FG_WHITE}▸${BG_TAN} ${FG_WHITE}◂${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}====${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_DGRAY}HYAH!${R}"
    pl " ${FG_TAN}\\▀█▀▀▀▀▀█▀/${R}"
    pl "   ${FG_TAN}▀▀${R} ${FG_TAN}▀▀${R}"
    pl ""
}

# ============================================================================
#  BREWING/THINKING FRAMES — for when Claude is generating text (6 lines)
# ============================================================================

# ── Brewing: stirring a cauldron ─────────────────────────────
draw_work_brew_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}  ${FG_PURPLE}~${FG_GREEN}~${FG_PURPLE}~${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_PURPLE}${FG_BOLD}◎ brewing${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}stirring thoughts...${R}"
    pl " ${FG_TAN} ▀█${R}${FG_PURPLE}(${FG_GREEN}▓▓▓${FG_PURPLE})${R}${FG_TAN}█▀${R}"
    pl "  ${FG_PURPLE} ╰▀▀▀▀▀▀▀╯${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

draw_work_brew_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_GREEN}~${FG_PURPLE}~${FG_GREEN}~${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}  ${FG_PURPLE}${FG_BOLD}◎ brewing${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}bubble bubble...${R}"
    pl " ${FG_TAN} ▀█${R}${FG_PURPLE}(${FG_GREEN}▓${FG_YELLOW}▓${FG_GREEN}▓${FG_PURPLE})${R}${FG_TAN}█▀${R}"
    pl "  ${FG_PURPLE} ╰▀▀▀▀▀▀▀╯${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
}

# ── Pondering: chin on hand, thought bubbles ─────────────────
draw_work_ponder_0() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R}  ${FG_DGRAY}○ ○${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}${FG_DGRAY}o${R} ${FG_PURPLE}${FG_BOLD}◎ brewing${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}~~~${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}hmmmm....${R}"
    pl " ${FG_TAN} ▀█▀▀▀▀▀█▀${R}${FG_TAN})${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

draw_work_ponder_1() {
    local l="$1"
    pl "  ${FG_TAN}▄▀▀▀▀▀▀▀▄${R} ${FG_DGRAY}○  ○${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${BG_BLACK}  ${BG_TAN} ${R}${FG_TAN}█${R}${FG_DGRAY}o${R} ${FG_PURPLE}${FG_BOLD}◎ brewing${R}"
    pl "  ${FG_TAN}█${R}${BG_TAN}  ${FG_BLACK}◡◡◡${BG_TAN}  ${R}${FG_TAN}█${R}  ${FG_DGRAY}let me think...${R}"
    pl " ${FG_TAN} ▀█▀▀▀▀▀█▀${R}${FG_TAN})${R}"
    pl "   ${FG_TAN}▀▀${R}   ${FG_TAN}▀▀${R}"
    pl ""
}

# ── Tool-to-animation mapping ──────────────────────────────────
draw_for_tool() {
    local tool="$1" f="$2" label="$3"

    case "$tool" in
        Read)
            case $(( f % 4 )) in
                0) draw_work_read_0 "$label" ;;
                1) draw_work_read_1 "$label" ;;
                2) draw_work_think_0 "$label" ;;
                3) draw_work_read_0 "$label" ;;
            esac ;;
        Edit|Write)
            case $(( f % 8 )) in
                0) draw_work_type_0 "$label" ;;
                1) draw_work_type_1 "$label" ;;
                2) draw_work_tongue_0 "$label" ;;
                3) draw_work_tongue_1 "$label" ;;
                4) draw_work_type_0 "$label" ;;
                5) draw_work_type_1 "$label" ;;
                6) draw_work_sweat_0 "$label" ;;
                7) draw_work_sweat_1 "$label" ;;
            esac ;;
        Bash)
            case $(( f % 8 )) in
                0) draw_work_build_0 "$label" ;;
                1) draw_work_build_1 "$label" ;;
                2) draw_work_battle_0 "$label" ;;
                3) draw_work_battle_1 "$label" ;;
                4) draw_work_ninja_0 "$label" ;;
                5) draw_work_ninja_1 "$label" ;;
                6) draw_work_build_0 "$label" ;;
                7) draw_work_sweat_0 "$label" ;;
            esac ;;
        Grep|Glob|WebSearch|WebFetch)
            case $(( f % 4 )) in
                0) draw_work_search_0 "$label" ;;
                1) draw_work_search_1 "$label" ;;
                2) draw_work_search_0 "$label" ;;
                3) draw_work_think_0 "$label" ;;
            esac ;;
        Agent|ToolSearch|Skill)
            case $(( f % 6 )) in
                0) draw_work_think_0 "$label" ;;
                1) draw_work_think_1 "$label" ;;
                2) draw_work_battle_0 "$label" ;;
                3) draw_work_think_0 "$label" ;;
                4) draw_work_eureka "$label" ;;
                5) draw_work_think_1 "$label" ;;
            esac ;;
        thinking)
            # Brewing/thinking state — Claude is generating text
            case $(( f % 8 )) in
                0) draw_work_brew_0 "$label" ;;
                1) draw_work_brew_1 "$label" ;;
                2) draw_work_ponder_0 "$label" ;;
                3) draw_work_ponder_1 "$label" ;;
                4) draw_work_brew_0 "$label" ;;
                5) draw_work_brew_1 "$label" ;;
                6) draw_work_think_0 "$label" ;;
                7) draw_work_think_1 "$label" ;;
            esac ;;
        *)
            case $(( f % 14 )) in
                0)  draw_work_type_0 "$label" ;;
                1)  draw_work_type_1 "$label" ;;
                2)  draw_work_think_0 "$label" ;;
                3)  draw_work_think_1 "$label" ;;
                4)  draw_work_tongue_0 "$label" ;;
                5)  draw_work_tongue_1 "$label" ;;
                6)  draw_work_sweat_0 "$label" ;;
                7)  draw_work_coffee_0 "$label" ;;
                8)  draw_work_coffee_1 "$label" ;;
                9)  draw_work_headbang_0 "$label" ;;
                10) draw_work_headbang_1 "$label" ;;
                11) draw_work_battle_0 "$label" ;;
                12) draw_work_eureka "$label" ;;
                13) draw_work_facepalm "$label" ;;
            esac ;;
    esac
}

# ============================================================================
#  Movement — horizontal position calculation
# ============================================================================
# Working: mascot walks left and right across the pane
# Idle: mascot stays centered

work_pos=0
work_dir=1  # 1 = right, -1 = left
WALK_SPEED=3  # columns per frame

get_work_position() {
    local cols
    cols=$(tput cols 2>/dev/null || echo 80)
    local max_x=$(( cols - MASCOT_WIDTH - 20 ))  # leave room for status text
    (( max_x < 2 )) && max_x=2

    work_pos=$(( work_pos + work_dir * WALK_SPEED ))

    # Bounce off edges
    if (( work_pos >= max_x )); then
        work_pos=$max_x
        work_dir=-1
    elif (( work_pos <= 0 )); then
        work_pos=0
        work_dir=1
    fi

    echo "$work_pos"
}

# ============================================================================
#  Main loop
# ============================================================================
cleanup() { tput cnorm; tput sgr0; clear; exit 0; }
trap cleanup INT TERM
tput civis
clear

state="idle"
frame=0
fc=0
current_tool=""

while true; do
    if [[ $((fc % STATE_CHECK_EVERY)) -eq 0 ]]; then
        transcript=$(find_transcript)
        new_state=$(detect_state "$transcript")
        if [[ "$new_state" == "brewing" ]]; then
            # Map brewing to working with a special tool marker
            current_tool="thinking"
            new_state="working"
        else
            current_tool=$(read_tool "$transcript")
        fi
        if [[ "$new_state" != "$state" ]]; then
            frame=0
            # Reset walk position when switching to working
            if [[ "$new_state" == "working" ]]; then
                work_pos=0
                work_dir=1
            fi
        fi
        state=$new_state
    fi
    fc=$((fc + 1))

    tput cup 0 0

    if [[ "$state" == "working" ]]; then
        # Walking mascot
        pos=$(get_work_position)
        set_pad "$pos"
        label=$(tool_label "$current_tool")
        draw_for_tool "$current_tool" "$frame" "$label"
    else
        # Centered idle mascot
        center=$(get_center)
        set_pad "$center"
        idx=$(( frame % IDLE_COUNT ))
        ${IDLE_SEQUENCE[$idx]}
    fi

    frame=$((frame + 1))
    sleep "$FRAME_DELAY"
done

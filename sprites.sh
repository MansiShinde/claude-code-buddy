#!/bin/bash
# ============================================================================
#  Claude Code Buddy — Sprite Sheet (Compact 5-line design)
#  Body: 8-char wide, half-block edges, white eyes with black pupils
# ============================================================================
#
#  Design (5 lines):
#   ▄▄▄▄▄▄▄▄         <- top edge (FG_TAN half-blocks)
#  ▌ ● ● ▐  ● idle   <- eyes row: WHITE bg + BLACK pupil on TAN body
#  ▌ ▄▄▄▄ ▐          <- mouth row (BG_TAN body + BG_DTAN mouth)
#   ▀▀▀▀▀▀▀▀         <- bottom edge
#   ▀▀ ▀▀ ▀▀ ▀▀      <- 4 legs
# ============================================================================

# ── Leg helpers ─────────────────────────────────────────────
_wl() { if (( $1 % 2 == 0 )); then pl " ${FG_DTAN}▀▀${R}${FG_DTAN}▀▄${R} ${FG_DTAN}▀▀${R}${FG_DTAN}▀▄${R}"; else pl " ${FG_DTAN}▀▄${R}${FG_DTAN}▀▀${R} ${FG_DTAN}▀▄${R}${FG_DTAN}▀▀${R}"; fi; }
_sl() { pl " ${FG_DTAN}▀▀${R} ${FG_DTAN}▀▀${R} ${FG_DTAN}▀▀${R} ${FG_DTAN}▀▀${R}"; }

# ── Eye helpers ─────────────────────────────────────────────
# Each eye: 2 chars on BG_WHITE with FG_BLACK pupil (●)
# Pupil placement controls gaze direction
_E="${BG_WHITE}${FG_BLACK}"  # eye color base

# ─── IDLE SPRITES ─────────────────────────────────────────────

sprite_idle_normal() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_blink() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_BLACK}▄▄${BG_TAN}  ${FG_BLACK}▄▄${BG_TAN}${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*blink*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_look_left() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E}● ${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_look_right() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E} ●${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_peek_down_0() {
    pl ""
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ▼${BG_TAN}  ${_E}▼ ${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}whatcha typing?${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
}

sprite_idle_peek_down_1() {
    pl ""
    pl ""
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ▼${BG_TAN}  ${_E}▼ ${R}${FG_TAN}▐${R} ${FG_DGRAY}ooh! show me!${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
}

sprite_idle_jump() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_YELLOW}!${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*boing*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    pl ""
}

sprite_idle_sleep_0() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_DGRAY}z${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_BLACK}——${BG_TAN}  ${FG_BLACK}——${BG_TAN}${R}${FG_TAN}▐${R}${FG_DGRAY}z${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}~~~~${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}zzz...${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_sleep_1() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}${FG_DGRAY}z${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_BLACK}——${BG_TAN}  ${FG_BLACK}——${BG_TAN}${R}${FG_TAN}▐${R} ${FG_DGRAY}z${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}~~~~${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*snore*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_sing_0() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_PINK}♪${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R}${FG_PINK}♫${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}la la la~${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_sing_1() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}${FG_PINK}♫${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_PINK}♪${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}do re mi~${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_wink() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${FG_BLACK}▄▄${BG_TAN}${R}${FG_TAN}▐${R}${FG_CYAN}✧${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}hey ;)${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_surprised() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_YELLOW}!${R}"
    pl "${FG_TAN}▌${_E} ○${BG_TAN}  ${_E}○ ${R}${FG_TAN}▐${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN} ${FG_BLACK}○○${BG_DTAN} ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}oh!${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_wave_0() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_YELLOW}${FG_BOLD}Hi!${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${FG_TAN}/${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_wave_1() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_YELLOW}${FG_BOLD}Hey!${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${FG_TAN}\\${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_dance_0() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_PINK}♪${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*boogie*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    pl "  ${FG_DTAN}▀▀${R}${FG_DTAN}▀▀▀▀${R}${FG_DTAN}▀▀${R}"
}

sprite_idle_dance_1() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}${FG_PINK}♫${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*shake*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    pl " ${FG_DTAN}▀▀${R}${FG_DTAN}▀▀▀▀${R}${FG_DTAN}▀▀${R}"
}

sprite_idle_tap_0() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}════${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*tap tap*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    pl " ${FG_DTAN}▀▀${R} ${FG_DTAN}▀▀${R} ${FG_DTAN}▀▀${R} ${FG_DTAN}▀▄${R}"
}

sprite_idle_tap_1() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}════${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}any day now...${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    pl " ${FG_DTAN}▀▄${R} ${FG_DTAN}▀▀${R} ${FG_DTAN}▀▀${R} ${FG_DTAN}▀▀${R}"
}

sprite_idle_flex() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_YELLOW}${FG_BOLD}POW${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R}"
    pl "${FG_TAN}╤${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}╤${R} ${FG_DGRAY}i'm ready!${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_peek() {
    pl ""
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_DGRAY}pssst...${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
}

sprite_idle_yawn() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_BLACK}▄▄${BG_TAN}  ${FG_BLACK}▄▄${BG_TAN}${R}${FG_TAN}▐${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}${FG_BLACK}○○○○${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*yaaawn*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

# ─── WATCHING USER TYPE (eyes look down, scanning left/right) ────

sprite_idle_watch_down_left() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E}▼ ${BG_TAN}  ${_E}▼ ${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_watch_down_center() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ▼${BG_TAN}  ${_E}▼ ${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_watch_down_right() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ▼${BG_TAN}  ${_E} ▼${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_watch_down_smile() {
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ▼${BG_TAN}  ${_E}▼ ${R}${FG_TAN}▐${R} ${FG_GREEN}${FG_BOLD}● idle${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}‿‿‿‿${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}type type...${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_idle_juggle_0() {
    pl " ${FG_RED}●${R} ${FG_BLUE}●${R} ${FG_GREEN}●${R}"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_DGRAY}wheee!${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
}

sprite_idle_juggle_1() {
    pl "  ${FG_BLUE}●${R} ${FG_GREEN}●${R} ${FG_RED}●${R}"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_DGRAY}catch!${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
}

# ─── WORKING SPRITES ─────────────────────────────────────────

# ── Typing / coding (Edit/Write) ─────────────────────────────
sprite_work_type_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ▼${BG_TAN}  ${_E}▼ ${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀${R}${BG_GRAY}${FG_BLUE}▓▓▓▓▓▓${R}${FG_TAN}▀${R}"
    _wl "$f"
}

sprite_work_type_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_BLACK}▄▄${BG_TAN}  ${FG_BLACK}▄▄${BG_TAN}${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}clack clack${R}"
    pl " ${FG_TAN}▀${R}${BG_GRAY}${FG_BLUE}▓▓▓▓▓▓${R}${FG_TAN}▀${R}"
    _wl "$f"
}

# ── Tongue out smashing keyboard ──────────────────────────────
sprite_work_tongue_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_YELLOW}${FG_BOLD}POW!${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${FG_PINK}:P${BG_TAN}${BG_DTAN}   ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀${R}${BG_GRAY}${FG_RED}!▓▓▓▓!${R}${FG_TAN}▀${R}"
    _wl "$f"
}

sprite_work_tongue_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_YELLOW}${FG_BOLD}BAM!${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${FG_PINK}:P${BG_TAN}${BG_DTAN}   ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀${R}${BG_GRAY}${FG_RED}▓!▓▓!▓${R}${FG_TAN}▀${R}"
    _wl "$f"
}

# ── Sweating / trying hard ────────────────────────────────────
sprite_work_sweat_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}${FG_CYAN};${R}"
    pl "${FG_TAN}▌${_E} ○${BG_TAN}  ${_E}○ ${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}~~~~${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}this is fine${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

sprite_work_sweat_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_CYAN};${R}"
    pl "${FG_TAN}▌${_E} ○${BG_TAN}  ${_E}○ ${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}△△△△${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}nnngghhh!${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

# ── Hard hat + wrench (Building/Bash) ─────────────────────────
sprite_work_build_0() {
    local l="$1" f="$2"
    pl " ${BG_YELLOW}${FG_YELLOW}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${FG_GRAY}d${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}building...${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

sprite_work_build_1() {
    local l="$1" f="$2"
    pl " ${BG_YELLOW}${FG_YELLOW}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_BLACK}▄▄${BG_TAN}  ${FG_BLACK}▄▄${BG_TAN}${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${FG_GRAY}d${R} ${FG_DGRAY}*bang bang*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

# ── Magnifying glass (Search) ─────────────────────────────────
sprite_work_search_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E}● ${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}where is it...${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}${FG_CYAN}o${R}"
    _wl "$f"
}

sprite_work_search_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E} ●${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}AHA! found it!${R}"
    pl "${FG_CYAN}o${R}${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

# ── Reading with glasses ──────────────────────────────────────
sprite_work_read_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_GRAY}(${_E}●${FG_GRAY})${BG_TAN}${FG_GRAY}(${_E}●${FG_GRAY})${BG_TAN}${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}interesting${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

sprite_work_read_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_GRAY}(${_E}●${FG_GRAY})${BG_TAN}${FG_GRAY}(${_E}●${FG_GRAY})${BG_TAN}${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}~~~~${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}I see I see${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

# ── Thinking sparkle ──────────────────────────────────────────
sprite_work_think_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_CYAN}*${R}"
    pl "${FG_TAN}▌${_E}${FG_CYAN}*${_E}●${BG_TAN}  ${_E}${FG_CYAN}*${_E}●${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}big brain time${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

sprite_work_think_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}${FG_CYAN}*${R}"
    pl "${FG_TAN}▌${_E} ${FG_CYAN}*${BG_TAN} ${_E} ${FG_CYAN}*${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*brain noises*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

# ── Headbang ──────────────────────────────────────────────────
sprite_work_headbang_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_BLACK}xx${BG_TAN}  ${FG_BLACK}xx${BG_TAN}${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}____${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}why won't it work${R}"
    pl " ${FG_TAN}▀${R}${BG_GRAY}${FG_BLUE}▓▓▓▓▓▓${R}${FG_TAN}▀${R}"
    _wl "$f"
}

sprite_work_headbang_1() {
    local l="$1" f="$2"
    pl " ${FG_YELLOW}${FG_BOLD}*BONK*${R}"
    pl " ${FG_TAN}▄${FG_BLACK}xx  xx${FG_TAN}▄${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl " ${FG_TAN}▀${BG_DTAN}______${FG_TAN}▀${R} ${FG_DGRAY}ASDFJKL;${R}"
    pl " ${FG_TAN}▀${R}${BG_GRAY}${FG_RED}@#!%&!${R}${FG_TAN}▀${R}"
    _wl "$f"
}

# ── Coffee (brewing) ─────────────────────────────────────────
sprite_work_coffee_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_DGRAY}~${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_PURPLE}${FG_BOLD}◎ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${FG_DGRAY}~${R} ${FG_DGRAY}sip sip${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀${R}${FG_WHITE}[${FG_ORANGE}C${FG_WHITE}]${R}"
    _sl
}

sprite_work_coffee_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}${FG_DGRAY}~~${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_PURPLE}${FG_BOLD}◎ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}${FG_BLACK}○○○○${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}mmm caffeine${R}"
    pl " ${FG_TAN}▀▀▀▀▀${R}${FG_WHITE}[${FG_ORANGE}C${FG_WHITE}]${R}"
    _sl
}

# ── Battle mode ───────────────────────────────────────────────
sprite_work_battle_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_RED}${FG_BOLD}!!${R}"
    pl "${FG_TAN}▌${_E}${FG_RED} ▼${BG_TAN}  ${_E}${FG_RED}▼ ${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}╤${BG_TAN} ${BG_DTAN}████${BG_TAN} ${R}${FG_TAN}╤${R} ${FG_DGRAY}LET'S GOOO${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

sprite_work_battle_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}${FG_RED}${FG_BOLD}!!!${R}"
    pl "${FG_TAN}▌${_E}${FG_RED} ▼${BG_TAN}  ${_E}${FG_RED}▼ ${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}╤${BG_TAN} ${BG_DTAN}████${BG_TAN} ${R}${FG_TAN}╤${R} ${FG_DGRAY}MAX EFFORT${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}${FG_YELLOW}*${R}"
    _wl "$f"
}

# ── Ninja mode ────────────────────────────────────────────────
sprite_work_ninja_0() {
    local l="$1" f="$2"
    pl " ${FG_RED}━━━━━━━━${R}${FG_RED}~${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_WHITE}▸▸${BG_TAN}  ${FG_WHITE}◂◂${BG_TAN}${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}====${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*swoosh*${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

sprite_work_ninja_1() {
    local l="$1" f="$2"
    pl " ${FG_RED}━━━━━━━━━${R}${FG_RED}~${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_WHITE}▸▸${BG_TAN}  ${FG_WHITE}◂◂${BG_TAN}${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}====${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}HYAH!${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _wl "$f"
}

# ── Eureka ────────────────────────────────────────────────────
sprite_work_eureka() {
    local l="$1" f="$2"
    pl "     ${FG_YELLOW}${FG_BOLD}!${R}"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${_E} ○${BG_TAN}  ${_E}○ ${R}${FG_TAN}▐${R} ${FG_DGRAY}EUREKA!${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
}

# ── Facepalm ─────────────────────────────────────────────────
sprite_work_facepalm() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}"
    pl "${FG_TAN}▌${BG_TAN}${FG_TAN}▓▓▓▓▓▓${BG_TAN}${R}${FG_TAN}▐${R} ${FG_YELLOW}${FG_BOLD}⟳ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}____${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}*sigh*...${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

# ── Brewing: cauldron ─────────────────────────────────────────
sprite_work_brew_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_PURPLE}~${FG_GREEN}~${FG_PURPLE}~${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_PURPLE}${FG_BOLD}◎ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}stirring...${R}"
    pl " ${FG_TAN}▀${R}${FG_PURPLE}(${FG_GREEN}▓▓▓▓${FG_PURPLE})${R}${FG_TAN}▀${R}"
    _sl
}

sprite_work_brew_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}${FG_GREEN}~${FG_PURPLE}~${FG_GREEN}~${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E}● ${R}${FG_TAN}▐${R} ${FG_PURPLE}${FG_BOLD}◎ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}bubble bubble${R}"
    pl " ${FG_TAN}▀${R}${FG_PURPLE}(${FG_GREEN}▓${FG_YELLOW}▓${FG_GREEN}▓${FG_YELLOW}▓${FG_PURPLE})${R}${FG_TAN}▀${R}"
    _sl
}

# ── Pondering ─────────────────────────────────────────────────
sprite_work_ponder_0() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R} ${FG_DGRAY}○ ○${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E} ●${R}${FG_TAN}▐${FG_DGRAY}o${R} ${FG_PURPLE}${FG_BOLD}◎ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}~~~~${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}hmmmm....${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

sprite_work_ponder_1() {
    local l="$1" f="$2"
    pl " ${FG_TAN}▄▄▄▄▄▄▄▄${R}${FG_DGRAY}○  ○${R}"
    pl "${FG_TAN}▌${_E} ●${BG_TAN}  ${_E} ●${R}${FG_TAN}▐${FG_DGRAY}o${R} ${FG_PURPLE}${FG_BOLD}◎ ${l}${R}"
    pl "${FG_TAN}▌${BG_TAN} ${BG_DTAN}    ${BG_TAN} ${R}${FG_TAN}▐${R} ${FG_DGRAY}let me think...${R}"
    pl " ${FG_TAN}▀▀▀▀▀▀▀▀${R}"
    _sl
}

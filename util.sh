#!/usr/bin/env bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -Eeuxo pipefail
set -Euo pipefail

T_COLS="" # Get the column size when the command is executed.
T_RESET="" # Turn off all attribute modes.
T_BOLD=""
T_ITALIC="" # Most terminal font families does not support italics.
T_UNDERLINE=""
T_STANDOUT="" # Reverse fg color and bg color.
TF_BLACK="";   TB_BLACK=""
TF_RED="";     TB_RED=""
TF_GREEN="";   TB_GREEN=""
TF_YELLOW="";  TB_YELLOW=""
TF_BLUE="";    TB_BLUE=""
TF_MAGENTA=""; TB_MAGENTA=""
TF_CYAN="";    TB_CYAN=""
TF_WHITE="";   TB_WHITE=""
# If the user is in the terminal, use color.
if [ -t 1 ]; then
    ncolors=$(which tput > /dev/null && tput colors)
    if [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        # For more macros, see tput(1) or terminfo(5).
        # Check the control characters by executing echo $T_XXX | xxd.
        T_COLS="$(tput cols)"
        T_RESET="$(tput sgr0)"
        T_BOLD="$(tput bold)"
        T_ITALIC="$(tput sitm)"
        T_UNDERLINE="$(tput smul)"
        T_STANDOUT="$(tput smso)"
        TF_BLACK="$(tput setaf 0)";   TB_BLACK="$(tput setab 0)"
        TF_RED="$(tput setaf 1)";     TB_RED="$(tput setab 1)"
        TF_GREEN="$(tput setaf 2)";   TB_GREEN="$(tput setab 2)"
        TF_YELLOW="$(tput setaf 3)";  TB_YELLOW="$(tput setab 3)"
        TF_BLUE="$(tput setaf 4)";    TB_BLUE="$(tput setab 4)"
        TF_MAGENTA="$(tput setaf 5)"; TB_MAGENTA="$(tput setab 5)"
        TF_CYAN="$(tput setaf 6)";    TB_CYAN="$(tput setab 6)"
        TF_WHITE="$(tput setaf 7)";   TB_WHITE="$(tput setab 7)"
    fi
fi

perror() {
    echo "${TF_RED}$1${T_RESET} (exit: $?)"
    exit
}

pinfo() {
    echo "${TF_CYAN}$1${T_RESET}"
}

wait_bg() {
    for job in `jobs -p`; do
        wait ${job}
    done
}

JSON() {
    echo `jq -r "$1" <<< "$2"`
}

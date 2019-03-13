#!/usr/bin/env zsh

function _lux_log() {
    # Exit unless LUX_DEBUG=1
    [[ "$LUX_DEBUG" != "1" ]] && return 0

    # Passed args
    while [[ $1 ]]; do
        # Log every arg
        echo "[LUX] $1";
        shift
    done

    # Piped stdin (if any)
    if [ -t 0 ]; then
        # There's no stdin (fd 0)
        return 0
    else
        # Log every line
        while read line; do
            echo "[LUX] $line"
        done
    fi
}

function macos_is_dark() {
    local dark_mode=$(osascript -l JavaScript -e \
        "Application('System Events').appearancePreferences.darkMode.get()")

    _lux_log "fct: $funcstack[1]" "dark mode? $dark_mode"

    if   [[ "$dark_mode" == "true" ]];  then return 0
    elif [[ "$dark_mode" == "false" ]]; then return 1
    else
        _lux_log "can't get macOS dark mode status."
        return 2
    fi
}

LUX_MACOS_LIGHT='false'
LUX_MACOS_DARK='true'
function _lux_set_macos() {
    osascript -l JavaScript -e \
        "Application('System Events').appearancePreferences.darkMode.set($1)"
}

LUX_MACOS_DESKTOP_LIGHT='/Library/Desktop Pictures/Mojave Day.jpg'
LUX_MACOS_DESKTOP_DARK='/Library/Desktop Pictures/Mojave Night.jpg'
function _lux_set_macos_desktop {
    osascript -l JavaScript <<- EOF
        desktops = Application('System Events').desktops()
        for (d in desktops) {
            desktops[d].picture = '$1'
        }
EOF
}

LUX_ITERM_LIGHT='Solarized Light'
LUX_ITERM_DARK='Solarized Dark'
function _lux_set_iterm() {
    osascript -l JavaScript <<- EOF
        windows = Application('iTerm').windows()
        for (w in windows) {
            tabs = windows[w].tabs()
            for (t in tabs) {
                sessions = tabs[t].sessions()
                for (s in sessions) {
                    sessions[s].colorPreset = '$1'
                }
            }
        }
EOF
}

LUX_VSCODE_LIGHT='Solarized Light'
LUX_VSCODE_DARK='Solarized Dark'
function _lux_set_vscode() {
    LUX_VSCODE_USER_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
    LUX_VSCODE_COLORTHEME_KEY="workbench.colorTheme"

    touch "$LUX_VSCODE_USER_SETTINGS"
    jq '.[$key] = $val' \
        --arg key "$LUX_VSCODE_COLORTHEME_KEY" \
        --arg val "$1" <<< $(cat "$LUX_VSCODE_USER_SETTINGS") \
        > "$LUX_VSCODE_USER_SETTINGS"
}

LUX_ALL_LIGHT='light'
LUX_ALL_DARK='dark'
function _lux_set_all() {
    LUX_ALL_LIST=( macos macos_desktop iterm vscode )
    for item in $LUX_ALL_LIST; do
        lux $item $1 &
    done
}

function lux() {
    local item=$1  # e.g. macos, iterm..
    local mode=$2  # i.e. light, dark, <custom>

    # Function name
    # e.g. _lux_set_iterm
    local fct="_lux_set_${item}"

    # Function arg (variable name (uppercase))
    # e.g. LUX_ITERM_LIGHT
    typeset -u arg_var
    local arg_var="LUX_${item}_${mode}"

    # Function arg (variable value)
    # e.g. 'Solarized Light'
    local arg="${(P)${arg_var}}"

    # Run (and log: fct, arg, arg var name)
    $fct "$arg" | _lux_log "fct: $fct" \
                           "arg: '$arg' (arg_var: $arg_var)"
}

# Fun aliases!
alias lumos='lux all light'
alias nox='lux all dark'
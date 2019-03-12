#!/usr/bin/env zsh

function _lux_is_dark_mode() {
    osascript -l JavaScript -e \
        "Application('System Events').appearancePreferences.darkMode.get()"
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
    jq '.[$key] = $val' --arg key "$LUX_VSCODE_COLORTHEME_KEY" \
                        --arg val "$1" <<< $(cat "$LUX_VSCODE_USER_SETTINGS") \
                        > "$LUX_VSCODE_USER_SETTINGS"
}

function lux() {
    local item=$1
    local mode=$2

    local fct="_lux_set_${item}"

    typeset -u fct_mod_name
    local fct_mod_name="LUX_${item}_${mode}"
    local fct_mod="${(P)${fct_mod_name}}"

    # echo "$fct"
    # echo "$fct_mod_name"
    # echo "$fct_mod"
    out=$($fct "$fct_mod")
    echo output: $out
}
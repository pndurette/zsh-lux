#!/usr/bin/env zsh

#-----------------------------------------
# Utility functions
#-----------------------------------------

# _lux_log: simple debugging function
# * Only if LUX_DEBUG=1
# * Will echo every arg passed to it, one per line
# * Will echo every line of stdin piped to it (optional)
# e.g. echo 'hello' | _lux_log "hello called"

function _lux_log() {
    # Exit when LUX_DEBUG!=1
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

# '_lux_defined' & '_lux_default',
# from 'defined' & 'set_default' by powerlevel9k, the zsh theme:
# https://github.com/bhilburn/powerlevel9k/blob/master/functions/utilities.zsh

# _lux_defined: check if a var is already defined (even if empty)
# * Takes the name of a var to check
# * Exits 0 if var has been set (even if empty)
# e.g. _lux_defined SOME_VAR

function _lux_defined() {
  [[ ! -z "${(tP)1}" ]]
}

# _lux_default: given a var name and value as args,
# sets the var to value only if var has not been defined
# * Takes a var name and a var value
# * Can't work on arrays, for arrays do:
#   defined ARRAY_VAR || ARRAY_VAR=( some values )
# e.g. _lux_default SOME_VAR "some value"

function _lux_default() {
  local varname="$1"
  local default_value="$2"

  _lux_defined "$varname" || typeset -g "$varname"="$default_value"
}

# _lux_is_macos: check if OS is macOS
# * Returns 1 if OS is not macOS
# * Echos to stderr with name of calling function

function _lux_is_macos() {
    local fct=$funcstack[2]
    if [[ ! "$OSTYPE" =~ ^darwin ]]; then
        echo "'$fct' requires macOS." >&2
        return 1;
    fi
}

# _lux_is_macos: check if macOS app is installed
# * Returns 1 if macOS app is not installed
# * Echos to stderr with name of calling function

function _lux_macos_app_found() {
    local app="$1"
    local fct=$funcstack[2]
    if ! osascript -l JavaScript -e "Application('$app')" >/dev/null 2>&1; then
        echo "'$fct' requires '$app'." >&2
        return 1
    fi
}

# _lux_command_found: check if command is in PATH
# * Returns 1 if command is in not in PATH
# * Echos to stderr with name of calling function

function _lux_command_found() {
    local cmd=$1
    local fct=$funcstack[2]
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "'$fct' requires '$cmd'." >&2
        return 1
    fi
}

#-----------------------------------------
# Get functions
#-----------------------------------------

# macos_is_dark: check if the dark mode in macOS is active
# * Returns:
# *  0 if dark mode is active
# *  1 if light mode is active
# *  2 if the status of the dark mode can't be determined
#    (i.e. the version of macOS does not support it)

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

# macos_release_name: get the release name of macOS
# * Echos the capitalized release name of macOS
#   (e.g. "Catalina" for macOS 10.15.*)

function macos_release_name() {
    declare -A _lux_macos_release_names=(
        "10.14" "Mojave"
        "10.15" "Catalina"
        "11"    "Big Sur"
        "12"    "Monterey"
        "13"    "Ventura"
    )
    local macos_version=$(sw_vers -productVersion)
    local macos_release=$_lux_macos_release_names[${macos_version%.*}]

    _lux_log "fct: $funcstack[1]" "macOS version: $macos_version" \
                                  "macOS release: $macos_release"

    echo $macos_release
}

#-----------------------------------------
# Set functions
#-----------------------------------------

#-----------------------------------------
# Element: 'macos'
# Action: Sets macOS dark mode
# Default modes (non-customizable):
#  * 'light': 'false'
#  * 'dark': 'true'
# Extra configuration: N/A
# Requires:
#  * macOS

LUX_MACOS_LIGHT='false'
LUX_MACOS_DARK='true'

function _lux_set_macos() {
    if ! _lux_is_macos; then return 1; fi
    osascript -l JavaScript -e \
        "Application('System Events').appearancePreferences.darkMode.set($1)"
}

#-----------------------------------------
# Element: 'macos_desktop'
# Action: Sets macOS desktop picture
# Default modes:
#  * 'light': '/System/Library/Desktop Pictures/$(macos_release_name) Graphic.heic'
#  * 'dark': '/System/Library/Desktop Pictures/$(macos_release_name) Graphic.heic'
# Extra configuration: N/A
# Requires:
#  * macOS

_lux_default LUX_MACOS_DESKTOP_LIGHT "/System/Library/Desktop Pictures/$(macos_release_name) Graphic.heic"
_lux_default LUX_MACOS_DESKTOP_DARK  "/System/Library/Desktop Pictures/$(macos_release_name) Graphic.heic"

function _lux_set_macos_desktop() {
    if ! _lux_is_macos; then return 1; fi
    osascript -l JavaScript <<- EOF
        desktops = Application('System Events').desktops()
        for (d in desktops) {
            desktops[d].picture = '$1'
        }
EOF
}

#-----------------------------------------
# Element: 'macos_desktop_style'
# Action: Sets macOS desktop picture style (for pictures that support it)
# Default modes:
#  * 'light': 'light'
#  * 'dark': 'dark'
#  * 'auto': 'auto'
#  * 'dynamic': 'dynamic'
# Extra configuration: N/A
# Requires:
#  * macOS

LUX_MACOS_DESKTOP_STYLE_LIGHT="light"
LUX_MACOS_DESKTOP_STYLE_DARK="dark"
LUX_MACOS_DESKTOP_STYLE_AUTO="auto"
LUX_MACOS_DESKTOP_STYLE_DYNAMIC="dynamic"

LUX_MACOS_DESKTOP_STYLE_EXTRAS="auto dynamic"

function _lux_set_macos_desktop_style() {
    if ! _lux_is_macos; then return 1; fi
    osascript -l JavaScript <<- EOF
        desktops = Application('System Events').desktops()
        for (d in desktops) {
            desktops[d].dynamicStyle = '$1'
        }
EOF
}

#-----------------------------------------
# Element: 'iterm'
# Action: Sets the current iTerm session's color by preset name
# Default modes:
#  * 'light': 'Solarized Light'
#  * 'dark': 'Solarized Dark'
# Extra configuration: N/A
# Requires:
#  * iTerm

_lux_default LUX_ITERM_LIGHT 'Solarized Light'
_lux_default LUX_ITERM_DARK  'Solarized Dark'

function _lux_set_iterm() {
    if ! _lux_macos_app_found 'iTerm'; then return 1; fi
    osascript -l JavaScript -e \
        "Application('iTerm').currentWindow().currentSession().colorPreset = '$1'"
}

#-----------------------------------------
# Element: 'iterm_all'
# Action: Sets all iTerm sessions' color by preset name
# Default modes:
#  * 'light': 'Solarized Light'
#  * 'dark': 'Solarized Dark'
# Extra configuration: N/A
# Requires:
#  * iTerm

_lux_default LUX_ITERM_ALL_LIGHT 'Solarized Light'
_lux_default LUX_ITERM_ALL_DARK  'Solarized Dark'

function _lux_set_iterm_all() {
    if ! _lux_macos_app_found 'iTerm'; then return 1; fi
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

#-----------------------------------------
# Element: 'iterm'
# Action: Sets Visual Studio Code color theme
# Default modes:
#  * 'light': 'Solarized Light'
#  * 'dark': 'Solarized Dark'
# Extra configuration:
#  * LUX_VSCODE_USER_SETTINGS: "$HOME/Library/Application Support/Code/User/settings.json"
# Requires:
#  * Visual Studio Code
#  * jq

_lux_default LUX_VSCODE_LIGHT 'Solarized Light'
_lux_default LUX_VSCODE_DARK  'Solarized Dark'

function _lux_set_vscode() {
    if ! _lux_command_found code; then return 1; fi
    if ! _lux_command_found jq;   then return 1; fi

    LUX_VSCODE_COLORTHEME_KEY="workbench.colorTheme"
    _lux_default LUX_VSCODE_USER_SETTINGS "$HOME/Library/Application Support/Code/User/settings.json"

    touch "$LUX_VSCODE_USER_SETTINGS"
    jq '.[$key] = $val' \
        --arg key "$LUX_VSCODE_COLORTHEME_KEY" \
        --arg val "$1" <<< $(cat "$LUX_VSCODE_USER_SETTINGS") \
        > "$LUX_VSCODE_USER_SETTINGS"
}

#-----------------------------------------
# Element: 'all'
# Action: Sets the mode of a list of (above) elements at once
# Default modes (non-customizable):
#  * 'light': 'light'
#  * 'dark': 'dark'
# Extra configuration:
#  * LUX_ALL_LIST: ( macos macos_desktop iterm_all vscode )

LUX_ALL_LIGHT='light'
LUX_ALL_DARK='dark'

function _lux_set_all() {
    _lux_defined LUX_ALL_LIST || LUX_ALL_LIST=( macos macos_desktop iterm_all vscode )
    for item in $LUX_ALL_LIST; do
        lux $item $1 &
    done
}

#-----------------------------------------
# Main function
#-----------------------------------------

# lux: toggle appearance mode of elements
# * Takes <item> <mode> (e.g. lux macos light)
# * Calls the appropricate function (_set_lux_<item>)
# *  with the appropriate var (LUX_<ITEM>_<MODE>) value

function lux() {
    local item=$1  # e.g. macos, iterm..
    local mode=$2  # i.e. light, dark, <custom>

    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <item> <mode>"
        return 1
    fi

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
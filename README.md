# zsh-lux

A zsh plugin featuring:

* The `lux` command:  toggle between light & dark modes of various applications and components (including macOS itself)—fully customizable and expandable;
* The `macos_is_dark` helper function: determine if the macOS dark mode (in 10.14+) is active—for example to handle terminal theming.

Complete documentation in progress ⏳

```bash
# lux
lux macos <light|dark>
lux macos_desktop <light|dark>
lux iterm <light|dark>
lux iterm_all <light|dark>
lux vscode <light|dark>
lux all <light|dark>

# macos_is_dark e.g.
if macos_is_dark; then
    POWERLEVEL9K_COLOR_SCHEME="dark"
    lux iterm dark
else
    POWERLEVEL9K_COLOR_SCHEME="light"
    lux iterm light
fi
```
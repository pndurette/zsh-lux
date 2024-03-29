# zsh-lux

**zsh-lux**, a zsh plugin to toggle the light & dark modes of macOS and other items and applications via the `lux` command. Highly customizable: included items can be configured by defining variables. Highly extensible: items can be added by defining functions.

Also features the `macos_is_dark` helper function to determine if the macOS dark mode (in 10.14+) is active, for example to handle terminal theming.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Demo

![Imgur](https://i.imgur.com/r5F5aSB.gif)

## Documentation

* [Installation](#installation)
   * [Usage](#usage)
       * [lux](#lux)
       * [macos_is_dark](#macos_is_dark)
       * [macos_release_name](#macos_release_name)
       * [Debug mode](#debug-mode)
   * [Items](#items)
       * [macos](#macos)
       * [macos_desktop](#macos_desktop)
       * [macos_desktop_style](#macos_desktop_style)
       * [iterm](#iterm)
       * [iterm_all](#iterm_all)
       * [vscode](#vscode)
       * [all](#all)
   * [Extending zsh-lux](#extending-zsh-lux)
       * [Adding items](#adding-items)
       * [Adding modes](#adding-modes)
   * [Caveats / known issues](#caveats--known-issues)
       * [macOS Sonoma (14)](#macos-sonoma-14)

### Installation

**[Antigen](https://github.com/zsh-users/antigen)**

```bash
antigen bundle pndurette/zsh-lux   # in your ~/.zshrc
```

**[Antibody](https://github.com/getantibody/antibody)**

```bash
antibody bundle pndurette/zsh-lux   # in your ~/.zshrc
```

**[Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh)**

```bash
cd ~/.oh-my-zsh/custom/plugins/
git clone https://github.com/pndurette/zsh-lux.git
```

```bash
plugins=( ... zsh-lux )   # in your ~/.zshrc
```

**[Zplug](https://github.com/zplug/zplug)**

```bash
zplug "pndurette/zsh-lux"   # in your ~/.zshrc
```

**Manual Install**

```bash
git clone https://github.com/pndurette/zsh-lux.git
cd zsh-lux && source ./zsh-lux.plugin.zsh
```

```bash
fpath=(/your/zsh-lux/directory/ $fpath)    # (before compinit) load shell completion
```


### Usage

#### `lux`

Switch to/activate the mode (i.e `light`, `dark`) of macOS or of another item.

`lux <item> <mode>` 

Example usage:

```bash
lux macos dark
lux macos light
lux iterm light
# ...
```

#### `macos_is_dark`

Helper function that checks if the dark mode in macOS is active.

* Returns:
  * `0` if dark mode is active
  * `1` if light mode is active
  * `2` if the status of the dark mode can't be determined (i.e. the version of macOS does not support it)

Example usage:

```bash
if macos_is_dark; then
    echo "macOS is dark!"
else
    echo "macOS is light!"
fi
```

#### `macos_release_name`

Helper function that returns the capitalized release name of macOS (e.g. "Monterey")

Example usage:

```bash
$ sw_vers -productVersion
12.6
$ macos_release_name
Monterey
```

#### Debug mode

Set `LUX_DEBUG=1` to get a log output for debuging purposes.

### Items

An item is represented by one function that can trigger an appearance change for that item. These functions take an argument (e.g. the name of a theme) which are retrieved from a variable which name's depends on the chosen mode (i.e. `light`, `dark`).  These variables follow the convention `LUX_<ITEM>_<MODE>`. In most cases, these variables can be redefined (e.g. in `.zshrc`).

#### `macos`

**Action**: Sets macOS dark mode

**Requires**: macOS

**Modes**:

| Mode    | Variable          | Default | Customizable |
| ------- | ----------------- | ------- | ------------ |
| `light` | `LUX_MACOS_LIGHT` | `false` | 🚫            |
| `dark`  | `LUX_MACOS_DARK`  | `true`  | 🚫            |

**Extra configuration**: N/A

---

#### `macos_desktop`

**Action**: Sets macOS desktop picture. On Mojave and above, _Dynamic_ and _Light and Dark_ Desktop pictures are special `.heic` files that contain multiple images that macOS can [automatically change throughout the day](https://support.apple.com/en-ca/guide/mac-help/mchlp3013/12.0/mac/12.0). For those desktop pictures, set the same path for both `light` and `dark` and use [macos_desktop_style](#macos_desktop_style) to choose the appearance setting.

*Note:* Only the `<macOS name> Graphic.heic` (e.g. `Ventura Graphic.heic`) Dynamic Desktop comes pre-installed. To use other images than the default (below), select the image in System Preferences which will download it to `~/Library/Application Support/com.apple.mobileAssetDesktop/`

**Requires**: macOS

**Modes**:

| Mode    | Variable                  | Default                                                      | Customizable |
| ------- | ------------------------- | ------------------------------------------------------------ | ------------ |
| `light` | `LUX_MACOS_DESKTOP_LIGHT` | `/System/Library/Desktop Pictures/<macOS name> Graphic.heic` | ✅            |
| `dark`  | `LUX_MACOS_DESKTOP_DARK`  | ``/System/Library/Desktop Pictures/<macOS name> Graphic.heic`` | ✅            |

**Extra configuration**: N/A

---

#### `macos_desktop_style`

**Action**: Sets macOS desktop picture _style_, for certain `.heic` images (in Mojave and above) that support it. Supported image types are either "Dynamic Desktop" (`dynamic`, image changes throughout the day) or "Light and Dark" (`auto`, image matches the macOS apperance). Either types can be expliclty set to their `light` or `dark` setting).

**Requires**: macOS

**Modes**:

| Mode      | Variable                          | Default   | Customizable |
| --------- | --------------------------------- | --------- | ------------ |
| `light`   | `LUX_MACOS_DESKTOP_STYLE_LIGHT`   | `light`   | 🚫            |
| `dark`    | `LUX_MACOS_DESKTOP_STYLE_DARK`    | `dark`    | 🚫            |
| `auto`    | `LUX_MACOS_DESKTOP_STYLE_AUTO`    | `auto`    | 🚫            |
| `dynamic` | `LUX_MACOS_DESKTOP_STYLE_DYNAMIC` | `dynamic` | 🚫            |

**Extra configuration**: N/A

------

#### `iterm`

**Action**:  Sets the *current* iTerm2 session's color to a **preset name** (the equivalent of `⌘-i → Colors → Color Presets… `). It does not affect profiles or preferences. Creating/importing/naming colour schemes is left to the user. See https://github.com/mbadolato/iTerm2-Color-Schemes for examples.

**Requires**: macOS, [iTerm2](https://iterm2.com)

**Modes**:

| Mode    | Variable          | Default           | Customizable |
| ------- | ----------------- | ----------------- | ------------ |
| `light` | `LUX_ITERM_LIGHT` | `Solarized Light` | ✅            |
| `dark`  | `LUX_ITERM_DARK`  | `Solarized Dark`  | ✅            |

**Extra configuration**: N/A

------

#### `iterm_all`

**Action**:  Same as [`iterm`](#iterm) but for all open sessions.

**Requires**: macOS, [iTerm2](https://iterm2.com)

**Modes**:

| Mode    | Variable              | Default           | Customizable |
| ------- | --------------------- | ----------------- | ------------ |
| `light` | `LUX_ITERM_ALL_LIGHT` | `Solarized Light` | ✅            |
| `dark`  | `LUX_ITERM_ALL_DARK`  | `Solarized Dark`  | ✅            |

**Extra configuration**: N/A

------

#### `vscode`

**Action**:  Sets Visual Studio Code color theme. Modifies the `workbench.colorTheme` setting in the `settings.json` user file. Visual Studio Code applies settings as they are changed.

**Requires**: [Visual Studio Code](https://code.visualstudio.com), [jq](https://stedolan.github.io/jq/)

**Modes**:

| Mode    | Variable           | Default           | Customizable |
| ------- | ------------------ | ----------------- | ------------ |
| `light` | `LUX_VSCODE_LIGHT` | `Solarized Light` | ✅            |
| `dark`  | `LUX_VSCODE_DARK`  | `Solarized Dark`  | ✅            |

**Extra configuration**:

| Setting                                   | Variable                   | Default                                                     | Customizable |
| ----------------------------------------- | -------------------------- | ----------------------------------------------------------- | ------------ |
| Location of the `settings.json` user file | `LUX_VSCODE_USER_SETTINGS` | `$HOME/Library/Application Support/Code/User/settings.json` | ✅            |

------

#### `all`

**Action**:  Sets all items to the same mode at once. Under the hood, this calls `lux` on each item of a list.

**Requires**: Any requirements of the referenced items.

**Modes**:

| Mode    | Variable        | Default | Customizable |
| ------- | --------------- | ------- | ------------ |
| `light` | `LUX_ALL_LIGHT` | `light` | 🚫            |
| `dark`  | `LUX_ALL_DARK`  | `dark`  | 🚫            |

**Extra configuration**:

| Setting                              | Variable       | Default                                                      | Customizable |
| ------------------------------------ | -------------- | :----------------------------------------------------------- | ------------ |
| Array of the items affected by `all` | `LUX_ALL_LIST` | `( macos macos_desktop macos_desktop_style iterm_all vscode )` | ✅            |

------

### Extending `zsh-lux`

`zsh-lux` is convention-based and can therefore be easily expanded. See the plugin file for examples.

#### Adding items

Better explained with an example: let's pretend we want to add an item for an application called 'wow' that reads its theme name in `/tmp/wow.cfg`. 'wow' is in light mode when the theme is '*white*' and in dark mode when the theme is '*black*':

1. Define a function named `_lux_set_<item>`  that sets theme name in `/tmp/wow.cfg` from an argument `$1`:

   ```bash
   function _lux_set_wow() {
     echo "$1" > /tmp/wow.cfg
   }
   ```

2. Define `LUX_<ITEM>_<MODE>` for the modes:

   ```bash
   LUX_WOW_LIGHT='white'
   LUX_WOW_DARK='black'
   ```

**Done!** Now just call:

```bash
lux wow light # or
lux wow dark
```

This new item will also be automatically be added to zsh's tab autocompletion.

#### Adding modes

By default, items have a `light` and `dark` mode, but adding other modes is a simple as defining a new variable.

For example to add the modes `superhero` (that sets the [`batman`](https://github.com/mbadolato/iTerm2-Color-Schemes#batman) iTerm colour scheme) and `purple` (that sets the [`c64`](https://github.com/mbadolato/iTerm2-Color-Schemes#c64) iTerm2 colour scheme), define `LUX_<ITEM>_<MODE>` for each:

```bash
LUX_ITERM_SUPERHERO="batman"
LUX_ITERM_PURPLE="c64"
```
**Done!** Now just call:

```bash
lux iterm superhero
lux iterm purple
```
*(Optional)* To add those extra modes to the tab autocompletion, define the `LUX_<ITEM>_EXTRAS` variable with space-delimited values of those extra modes:

```bash
LUX_ITERM_EXTRAS="superhero purple"
```

### Caveats / known issues

#### macOS Sonoma (14)

* Using certain HEIF images as desktop picture will cause `macos_desktop_style` to sometimes reset the desktop picture to the system default, Sonoma Horizons (the vineyard photo).

  (This is the case of `System/Library/Desktop Pictures/Sonoma.heic` which is the default used by `macos_desktop` when on Sonoma.)

  **Workaround:** Don't use `macos_desktop_style` with these images. When setting `Sonoma.heic` or any other troublesome image, the image acts as if `macos_desktop_style` was set to  `auto` , i.e. the light/dark of the image will follow the system appearance.

  To use the `all` item, override the `LUX_ALL_LIST` in your shell config to skip `macos_desktop_style` , e.g. `LUX_ALL_LIST=( macos macos_desktop iterm_all vscode )`

## Fun aliases!

```bash
alias lumos='lux all light'
alias nox='lux all dark'
```

## License

[The MIT License (MIT)](LICENSE) Copyright © 2019-2024 Pierre Nicolas Durette

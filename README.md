# zsh-lux

**zsh-lux**, a zsh plugin to toggle the light & dark modes of macOS and other items and applications via the `lux` command. Highly customizable, included items can be configured by defining variables. Highly extensible,  items can be added by definiting functions. 

Also features the `macos_is_dark` helper function to determine if the macOS dark mode (in 10.14+) is active—for example to handle terminal theming.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Demo

<gif here>

## Documentation



[TOC]



### Installation

**[Antigen](https://github.com/zsh-users/antigen)**

```bash
antigen bundle pndurette/zsh-lux   # in your ~/.zshrc
```

**[Antiboy](https://github.com/getantibody/antibody)**

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

Activates light or dark modes of macOS and other items

`lux <item> <mode>` 

Example usage:

```bash
lux macos dark
lux macos light
lux iterm light
# ...
```

#### `macos_is_dark`

Checks if dark mode in macOS is active.

* Returns:
  * `0` if dark mode is active
  * `1` if light mode is active
  * `2` if the status of the dark mode can't be determined (i.e. the version of macOS does not support it)

Example usage:

```bash
if macos_is_dark; then
    echo "macOs is dark!"
else
    echo "macOs is light!"
fi
```



### Items

An item is represented by one function that can trigger an appearance change for that item. These functions take an argument (e.g. the name of a theme) which are retreived from a variable that depends on the chosen mode (i.e. 'light' or 'dark').  These variables follow the convention `LUX_<ITEM>_<MODE>`. In most cases, these variables can be redefined (e.g. in `.zshrc`).

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

#### `iterm`

#### `iterm_all`

#### `vscode`

#### `all`



### Extending `zsh-lux`

####Adding Items

#### Adding modes
# CVIM

A minimal Neovim configuration for Neovim 0.12+.

CVIM keeps core editing behavior, UI settings, diagnostics, messages, keymaps, the Minmax colorscheme, Lazy.nvim, and the Mini.nvim modules separated.

## Included

- Native Neovim options, autocmds, diagnostics, and keymaps
- Minmax green terminal-style colorscheme
- Lazy.nvim with automatic bootstrap
- Mini.ai, Mini.files, Mini.icons, Mini.pairs, and Mini.surround

Mini.notify is intentionally excluded. Notifications use Neovim's native `vim.notify`.

## UI

CVIM uses a transparent UI with visible, rounded borders:

- Floating windows, diagnostics, completion menus, and Lazy.nvim use rounded borders.
- Border foregrounds come from the active colorscheme; border backgrounds remain transparent.
- Float and popup content backgrounds remain transparent through Minmax's `NONE` highlight backgrounds.
- Popup blending is disabled, so no tinted halo is introduced around completion menus.
- CVIM-owned floating layouts add no extra outer margin; only the cells needed to draw the border are reserved.
- Colors and syntax highlights remain the colorscheme's responsibility.

Neovim does not provide one global margin or padding option for every window. CVIM avoids adding spacing in its own floating-window layouts; plugin-owned layouts keep their own sizing where required.

## Structure

- `lua/soul/core`: editing options, platform integration, autocmds, and keymaps
- `lua/soul/ui`: global presentation defaults, diagnostic floats, and message UI
- `lua/soul/plugins`: plugin specifications and colorscheme loading

No separate documentation directory is needed for this configuration. The README is the entry point and describes the setup and its conventions.

## Key mappings

| Mapping | Action |
|---|---|
| `<leader>e` | Open Mini.files |
| `<leader>L` | Open Lazy.nvim |
| `,,` | Exit insert/visual mode; clear search in normal mode |

Inside Mini.files, `g.` toggles hidden files, `g~` changes the working directory, and `gx` opens the selected entry with the system application.

## Install

Clone this repository into Neovim's config directory and start Neovim. Lazy.nvim bootstraps itself and installs the Mini modules.

Requires Git and Neovim 0.12 or newer.

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
- Border foregrounds come from the active colorscheme and remain visible.
- Border, float, title, footer, and popup backgrounds are forced to `NONE`, preventing a colored strip or halo around the outline.
- Popup blending is disabled; completion selection colors and syntax highlighting remain intact.
- The `:Messages` history opens in a centered, compact window with a titled rounded border.
- CVIM-owned floating layouts avoid unnecessary outer spacing; plugin-owned layouts keep their own sizing where required.

Neovim does not provide one global margin or padding option for every window.

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

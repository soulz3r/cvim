# CVIM

A minimal Neovim configuration for Neovim 0.12+.

CVIM keeps its core editing behavior, UI defaults, diagnostics, messages, keymaps, a phosphor-green colorscheme, Lazy.nvim, and the Mini.nvim modules deliberately separated.

## Included

- Native Neovim options, autocmds, diagnostics, and keymaps
- Minimal green terminal-style colorscheme
- Lazy.nvim with automatic bootstrap
- Mini.ai, Mini.files, Mini.icons, Mini.pairs, and Mini.surround

Mini.notify is intentionally excluded. Notifications use Neovim's native vim.notify.

## Structure

- `soul.core`: editing options, platform integration, autocmds, and keymaps
- `soul.ui`: global presentation defaults, diagnostic floats, and message UI
- `soul.plugins`: plugin specifications and colorscheme loading

Global floating-window and completion-menu borders are configured in `soul.ui.options`. Plugin-specific windows, such as Mini.files and Lazy.nvim, retain their own layout settings. Colors and highlight groups belong to the colorscheme, not the UI behavior modules.

## Key mappings

| Mapping | Action |
|---|---|
| <leader>e | Open Mini.files |
| <leader>L | Open Lazy.nvim |
| ,, | Exit insert/visual mode; clear search in normal mode |

Inside Mini.files, g. toggles hidden files, g~ changes the working directory, and gx opens the selected entry with the system application.

## Install

Clone this repository into Neovim's config directory and start Neovim. Lazy.nvim bootstraps itself and installs the Mini modules.

Requires Git and Neovim 0.12 or newer.

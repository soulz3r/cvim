# CVIM

A minimal Neovim configuration for Neovim 0.12+.

CVIM keeps native Neovim settings, keymaps, autocmds, a phosphor-green colorscheme, Lazy.nvim, and the Mini.nvim modules.

## Included

- Native Neovim options, autocmds, diagnostics, and keymaps
- Minimal green terminal-style colorscheme
- Lazy.nvim with automatic bootstrap
- Mini.ai, Mini.files, Mini.icons, Mini.pairs, and Mini.surround

Mini.notify is intentionally excluded. Notifications use Neovim's native vim.notify.

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

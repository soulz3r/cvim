# CVIM

A minimal Neovim configuration for Neovim 0.12+.

CVIM keeps core editing behavior, UI settings, diagnostics, messages, keymaps, the Minmax colorscheme, Lazy.nvim, Mini.nvim, and a compact command-line UI separated into small modules.

## Included

- Native Neovim options, autocmds, diagnostics, and keymaps
- Minmax green terminal-style colorscheme
- Lazy.nvim with automatic bootstrap
- Mini.ai, Mini.files, Mini.icons, Mini.pairs, and Mini.surround
- Tiny-cmdline with Blink's reposition adapter and Neovim 0.12 UI2 support

Tiny-cmdline is optional at startup. If Neovim's UI2 API is unavailable or setup fails, CVIM falls back to the native command line.

Mini.notify is intentionally excluded. Error and warning messages use native notifications.

## UI

CVIM uses a transparent UI with visible, rounded borders:

- Floating windows, diagnostics, completion menus, and Lazy.nvim use rounded borders.
- Border foregrounds come from the active colorscheme and remain visible.
- Border, float, title, footer, and popup backgrounds are forced to NONE, preventing a colored strip or halo around the outline.
- Popup blending is disabled; completion selection colors and syntax highlighting remain intact.
- The Messages history opens in a centered, compact window with a titled rounded border.
- Read-only inspection output such as nmap, vmap, scriptnames, and registers opens in the same floating-window style.
- CVIM-owned floating layouts avoid unnecessary outer spacing; plugin-owned layouts keep their own sizing where required.

Neovim does not provide one global margin or padding option for every window.

## Structure

- lua/soul/core: editing options, platform integration, autocmds, and keymaps
- lua/soul/ui: global presentation defaults, diagnostic floats, and message/output UI
- lua/soul/plugins: plugin specifications and colorscheme loading

Side-effect modules expose M.setup(). Plugin specification modules return their specification tables. The entrypoint calls setup functions explicitly.

No separate documentation directory is needed for this configuration. The README is the entry point.

## Key mappings

| Mapping | Action |
|---|---|
| <leader>e | Open Mini.files |
| <leader>L | Open Lazy.nvim |
| ,, | Exit insert/visual mode; clear search in normal mode |

Inside Mini.files, g. toggles hidden files, g~ changes the working directory, and gx opens the selected entry with the system application.

## Install

Clone this repository into Neovim's config directory and start Neovim. Lazy.nvim bootstraps itself and installs the configured plugins.

Requires Git and Neovim 0.12 or newer.

# CVIM

A minimal Neovim configuration for Neovim 0.12+.

CVIM keeps core editing behavior, UI settings, diagnostics, messages, keymaps, the Minmax colorscheme, Lazy.nvim, Mini.nvim, and a compact command-line UI separated into small modules.

## Included

- Native Neovim options, autocmds, diagnostics, and keymaps
- Minmax green terminal-style colorscheme
- Lazy.nvim with automatic bootstrap
- Mini.ai, Mini.files, Mini.icons, Mini.pairs, and Mini.surround
- Tiny-cmdline with Blink's reposition adapter and Neovim 0.12 UI2 support

Tiny-cmdline is optional at startup. CVIM initializes UI2 once through `soul.ui.ui2`; if UI2 is unavailable or Tiny-cmdline setup fails, CVIM restores the native command line and message handler.

Mini.notify is intentionally excluded. Error and warning messages use native notifications when Tiny-cmdline is active.

## UI

CVIM uses a transparent UI with visible, rounded borders:

- Floating windows, diagnostics, completion menus, and Lazy.nvim use rounded borders.
- Border foregrounds come from the active colorscheme and remain visible.
- Border, float, title, footer, and popup backgrounds are forced to NONE, preventing a colored strip or halo around the outline.
- Popup blending is disabled; completion selection colors and syntax highlighting remain intact.
- Neovim's native `:checkhealth` uses its built-in floating style, with its preview dimensions configured before the float is created.
- Messages, command listings, help pages, and other supported read-only output open in a centered floating window.
- Supported output includes mapping listings, registers, highlights, marks, jumps, changes, digraphs, script names, version, buffers, history, and autocmd listings.
- Commands that modify mappings, options, files, or editor state keep their normal behavior.
- Temporary help/man command windows are cleaned up across tabs before the captured output is displayed.
- CVIM-owned floating layouts avoid unnecessary outer spacing; plugin-owned layouts keep their own sizing where required.

Neovim does not provide one global margin or padding option for every window. The UI2 and health-float integrations use Neovim 0.12 internal interfaces, so they are isolated in small modules and covered by smoke tests where practical.

## Structure

- `lua/soul/core`: editing options, platform integration, autocmds, and keymaps
- `lua/soul/ui`: global presentation defaults, diagnostics, UI2 initialization, and message/output UI
- `lua/soul/plugins`: plugin specifications and colorscheme loading
- `tests`: headless regression checks
- `.github/workflows`: automated syntax and smoke checks

Side-effect modules expose `M.setup()`. Plugin specification modules return their specification tables. The entrypoint calls setup functions explicitly.

No separate documentation directory is needed for this configuration. The README is the entry point.

## Key mappings

| Mapping | Action |
|---|---|
| <leader>e | Open Mini.files |
| <leader>L | Open Lazy.nvim |
| ,, | Exit insert/visual mode; clear search in normal mode |

Inside Mini.files, `g.` toggles hidden files, `g~` changes the working directory, and `gx` opens the selected entry with the system application.

## Checks

Run the headless regression suite from the repository root:

```sh
nvim --headless -u NONE -c "lua dofile('tests/run.lua')" -c "qa!"
```

GitHub Actions runs the same checks against the current stable Neovim release.

## Install

Clone this repository into Neovim's config directory and start Neovim. Lazy.nvim bootstraps itself and installs the configured plugins.

Requires Git and Neovim 0.12 or newer.

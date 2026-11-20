# CVIM

A minimal Neovim configuration for Neovim 0.12+.

CVIM keeps core editing behavior, UI settings, diagnostics, messages, keymaps, the Minmax colorscheme, Lazy.nvim, Mini.nvim, Telescope, and a compact command-line UI separated into small modules.

## Included

- Native Neovim options, autocmds, diagnostics, and keymaps
- Minmax green terminal-style colorscheme
- Lazy.nvim with automatic bootstrap
- Mini.ai, Mini.files, Mini.icons, Mini.pairs, and Mini.surround
- Eyeliner for subtle character-jump hints
- Telescope for file finding, live grep, buffers, and help
- ToggleTerm with a floating terminal, using Git Bash on Windows and explicitly loading `D:/config/bash/.bashrc`, with `pwsh` and Windows PowerShell fallbacks
- Tiny-cmdline with Neovim's built-in command-line completion and Neovim 0.12 UI2 support across Windows and Linux

Tiny-cmdline is optional at startup and UI2 is initialized once through `soul.ui.ui2` on supported platforms, including Windows. If UI2 is unavailable or Tiny-cmdline setup fails, CVIM falls back to native command-line handling and restores the original UI2 message handlers.

Mini.notify is intentionally excluded. Error and warning messages use native notifications when Tiny-cmdline is active.

## UI

CVIM uses a transparent UI with visible, rounded borders:

- Floating windows, diagnostics, popup menus, and Lazy.nvim use rounded borders.
- Border foregrounds come from the active colorscheme and remain visible.
- Border, float, title, footer, and popup backgrounds are forced to NONE, preventing a colored strip or halo around the outline.
- Popup blending is disabled; selection colors and syntax highlighting remain intact.
- Neovim's native `:checkhealth` uses its built-in floating style, with its preview dimensions configured before the float is created.
- Messages, command listings, help pages, and other supported read-only output open in a centered floating window.
- Supported output includes mapping listings, registers, highlights, marks, jumps, changes, digraphs, script names, version, buffers, history, and autocmd listings.
- Commands that modify mappings, options, files, or editor state keep their normal behavior.
- Temporary help/man command windows are cleaned up across tabs before the captured output is displayed.
- CVIM-owned floating layouts avoid unnecessary outer spacing; plugin-owned layouts keep their own sizing where required.

Neovim does not provide one global margin or padding option for every window. The UI2 and health-float integrations use Neovim 0.12 internal interfaces, so they are isolated in small modules and covered by focused regression tests. UI2 is experimental and can change between Neovim releases.

## Structure

- `lua/soul/core`: editing options, platform integration, autocmds, and keymaps
- `lua/soul/ui`: global presentation defaults, diagnostics, UI2 initialization, and message/output UI
- `lua/soul/plugins`: plugin specifications and colorscheme loading
- `tests`: headless regression checks and isolated startup smoke test
- `.github/workflows`: automated formatting, syntax, and smoke checks

Side-effect modules expose `M.setup()`. Plugin specification modules return their specification tables. The entrypoint calls setup functions explicitly.

No separate documentation directory is needed for this configuration. The README is the entry point.

## Key mappings

| Mapping | Action |
|---|---|
| <leader>e | Open Mini.files |
| <leader>ff | Find files |
| <leader>fg | Live grep |
| <leader>fs | Search word under cursor |
| <leader>fb | Find buffers |
| <leader>fo | Recent files |
| <leader>fc | Colorscheme picker |
| <leader>fC | Commands |
| <leader>fk | Keymaps |
| <leader>fh | Help tags |
| <leader>fp | Telescope picker list |
| <leader>fr | Resume last picker |
| <leader>fd | Diagnostics |
| <leader>fq | Quickfix list |
| <leader>fR | Registers |
| <leader>fm | Marks |
| <leader>fj | Jump list |
| <leader>fO | Neovim options |
| <leader>fH | Highlight groups |
| <leader>gs | Git status |
| <leader>gc | Git commits |
| <leader>gb | Git branches |
| <leader>L | Open Lazy.nvim |
| Ctrl+\\ | Toggle the terminal |
| ,, | Exit insert/visual mode; clear search in normal mode |

Inside Mini.files, `g.` toggles hidden files, `g~` changes the working directory, and `gx` opens the selected entry with the system application.

Live grep uses ripgrep, so `rg` must be available on PATH.

## Checks

Run the headless regression suite from the repository root:

```sh
nvim --headless -u NONE -c "lua dofile('tests/run.lua')" -c "qa!"
```

Run the isolated startup test:

```sh
nvim --headless -u NONE -c "lua dofile('tests/startup.lua')" -c "qa!"
```

GitHub Actions checks StyLua formatting across Lua modules and tests, runs the regression suite, and exercises the complete `init.lua` startup with Lazy.nvim isolated from network access.

## Install

Clone this repository into Neovim's config directory and start Neovim. Lazy.nvim bootstraps itself and installs the configured plugins.

Requires Git and Neovim 0.12 or newer.

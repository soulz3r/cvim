<<<<<<< HEAD
# CVIM

A personal Neovim configuration for **Windows 11**, **WSL**, and **Linux** (including Arch Linux and Hyprland). CVIM is built around C development, a focused terminal workflow, and a deliberately customized editor UI.

The configuration is built around Lazy.nvim, native Neovim LSP, Blink.cmp, Telescope, Mini Files, Treesitter, custom LLDB debugging, and an Everforest-oriented UI.

> **Target:** Neovim 0.12 or newer. This configuration uses modern Neovim APIs such as `vim.lsp.config`, `vim.lsp.enable`, and the current Treesitter setup API. Older versions are not a supported target.

## Features

- Lazy.nvim plugin management with automatic bootstrap
- Native Neovim LSP configuration, without Mason
- Blink.cmp completion
- clangd support for C and C++
- Fish shell language-server support
- Project-aware LLDB DAP configuration and executable discovery
- Independent DAP project state for selected executables and per-project launch arguments
- Project actions hub for build, run, clean, and executable selection
- C/C++ helpers for source-header switching, include insertion, and compile metadata
- Independent DAP project registry, with optional YAP project status in Lualine
- Telescope pickers with project-root search and Mini Files with preview and hidden-file controls
- Mini sessions for project session save, restore, and automatic persistence
- Mini.ai text objects, Mini.surround editing, and Mini.notify notifications
- Treesitter highlighting and folding integration
- A floating single-file C23 compile/run terminal across Windows, WSL, and Linux
- YAP's Telescope project picker, project actions, and ANSI-colored floating runner output
- ToggleTerm with persistent horizontal, vertical, and floating terminals
- Alpha dashboard with an animated C/VIM identity, randomized cyberpunk-style wordmark glitches, quick actions, project context, and an optional animated C tutorial
- LSP-aware breadcrumbs in the winbar
- Minimal context-aware Lualine statusline with optional YAP project and LSP indicators
- Shared floating-window helpers and centralized Everforest palette/highlights
- Consistent rounded borders and transparent float backgrounds across editor and plugin UI
- Windows, WSL, and Linux path, shell, clipboard, compiler, and debugger handling

## Requirements

### Core

- Neovim 0.12 or newer
- Git
- A Nerd Font
- Neovide 0.16+ (optional; required for all configured GUI options)
- `ripgrep` (`rg`) for live grep
- `fd` for file discovery
- A C compiler for `telescope-fzf-native.nvim`; Windows builds prefer CMake/Visual Studio and fall back to Make or LLVM Clang

### Language tools

Install the tools you intend to use and make sure they are available on `PATH`:

- `clangd` for C and C++
- `lua-language-server` for Lua
- `bash-language-server` for Bash scripts
- `fish-lsp` for Fish scripts
- `stylua` for Lua formatting and format-on-save
- `lldb-dap` for C/C++ debugging

C project build scripts are launched with `cmd.exe` on Windows and `bash` (falling back to `sh`) on Unix-like systems.

The LSP servers and debugger are intentionally installed outside Neovim. **Mason is not used.**

## Installation

Clone this repository into the directory returned by:

```vim
:echo stdpath('config')
```

### Linux

The default Neovim config directory is usually `~/.config/nvim`.

```sh
git clone https://github.com/soulz3r/cvim.git ~/.config/nvim
nvim
```

### WSL

Install Neovim inside the WSL distribution, then clone the same repository into that distribution's `~/.config/nvim`:

```sh
git clone https://github.com/soulz3r/cvim.git ~/.config/nvim
nvim
```

WSL Neovim uses Linux binaries and POSIX build/run commands. To share a Windows project directory, set `PROJECTS_DIR` to its mounted path, for example `/mnt/d/projects`. Windows clipboard integration is enabled when `clip.exe` and PowerShell are available in WSL's `PATH`.

### Windows

The standard Neovim config directory is usually `%LOCALAPPDATA%\nvim`.

```powershell
git clone https://github.com/soulz3r/cvim.git "$env:LOCALAPPDATA\nvim"
nvim
```

If you use a custom location (for example, `D:\.config\nvim`), clone the repository into that directory instead.

On the first launch, Lazy.nvim bootstraps itself and installs the configured plugins. Then run:

```vim
:Lazy sync
:checkhealth
```

Install the external tools listed above separately. A plugin manager cannot install your system toolchain by telepathy, sadly.

## C and C++ development

clangd reads project build metadata. Prefer a generated `compile_commands.json` when your build system supports it. For small projects, a `compile_flags.txt` in the project root also works.

Example for a C23 project:

```text
-std=c23
-Iinclude
-Isrc
-g
```

Keep the language standard in the project configuration rather than forcing `-std=c23` globally. That lets C++ projects choose their own standard.

The clangd configuration recognizes project markers including:

- `.clangd`
- `.clang-tidy`
- `.clang-format`
- `compile_commands.json`
- `compile_flags.txt`
- `.git`

Useful LSP mappings are documented in [docs/keymaps.md](docs/keymaps.md).

## Debugging with LLDB

The custom DAP configuration uses `lldb-dap` directly. No Mason adapter is required.

The adapter defaults to:

- Windows: `C:/Program Files/LLVM/bin/lldb-dap.exe`
- Linux: `lldb-dap` from `PATH`

Override the executable with the `LLDB_DAP` environment variable if it is installed elsewhere.

The debugger detects project roots from common markers such as `.git`, `CMakeLists.txt`, `Makefile`, `build.sh`, `build.bat`, `compile_commands.json`, `meson.build`, and `Cargo.toml`. It searches common build directories for executables and also lets you select an executable manually.

See [docs/debugging.md](docs/debugging.md) for setup, mappings, and registry details.

## Environment variables

| Variable | Purpose | Default |
|---|---|---|
| `PROJECTS_DIR` | Base directory for YAP project picker and project discovery | `~/projects` on all platforms |
| `LLDB_DAP` | Full path or command name for `lldb-dap` | Windows LLVM path; Linux `lldb-dap` |
| `PWSH` | PowerShell executable used by the configured shell and C runner | `pwsh` or `pwsh.exe` |
| `CLANG` | Clang executable used by the C compile/run keymap | `clang` from `PATH` |

## Projects

YAP uses `telescope-project.nvim` for project selection and adds project-specific actions to that picker. The integration is enabled in `lua/soul/plugins/yap.lua`; it does not use Nui or NuiComponents.

Use `<leader>pp` to open the project picker. Select a project to change Neovim's working directory. While the picker is open:

| Mapping | Action |
|---|---|
| `Ctrl-g` | Build and run the selected project |
| `Ctrl-y` | Build the selected project |
| `Ctrl-e` | Choose an executable and run it |
| `Ctrl-a` | Open the project's action menu |
| `gR` / `gB` / `gE` | Run / build / choose executable in Normal mode |
| `gC` / `gX` / `gS` | Clean / rebuild / choose build script in Normal mode |
| `gA` | Open the project action menu in Normal mode |

Direct actions are also available from the current working directory:

| Key | Action |
|---|---|
| `<leader>pp` | Open the YAP project picker |
| `<leader>pr` | Build and run the current project, then enter arguments |
| `<leader>pb` | Build the current project |
| `<leader>pc` | Clean the current project |
| `<leader>pB` | Clean and rebuild the current project |
| `<leader>pS` | Choose a build script |
| `<leader>pe` | Select an executable and run it with arguments |
| `<leader>ps` | Stop the active project process |
| `<leader>pR` | Rerun the most recently used executable and saved arguments |

The runner opens a read-only floating output window with an operation summary and ANSI-colored process output. Press `q` or `Esc` to close it, `Ctrl-c` to stop a running process, or `<leader>pq` inside the output window to send parsed compiler diagnostics to quickfix.

YAP's C/C++ helpers are buffer-local:

| Key | Action |
|---|---|
| `<leader>ch` | Switch between matching source and header files |
| `<leader>ci` | Insert an include directive |
| `<leader>cp` | Show project root, compile metadata, and attached LSP clients |

The project runner and C helper windows use YAP's own Neovim floating-window helpers.
## Local project state

YAP's project registry stores YAP-owned project metadata and is not committed to Git:

```text
stdpath("state")/yap/projects.json
```

DAP maintains a separate registry for saved debugger projects, selected executables, and launch arguments:

```text
stdpath("state")/soul/dap/projects.json
```

DAP does not depend on YAP's Lua modules or registry at runtime. During the first startup after this change, a one-time importer copies only DAP-specific fields from the former YAP registry into DAP's own registry. The YAP registry is left untouched, and a migration marker prevents the old values from being imported again.

Older DAP-only registries are also imported from:

- `stdpath("config")/lsp/dap-projects.json`
- `stdpath("state")/soul/dap-projects.json`

After a successful import, each old DAP-only file is renamed with a `.migrated` suffix (or a timestamped suffix if that backup already exists). The original data is preserved as a backup.

## Repository layout

See [docs/dashboard.md](docs/dashboard.md) for the animated startup dashboard. YAP project restoration is handled by a lightweight core module, while YAP and Telescope load when a file or project action needs them. See [docs/design-decisions.md](docs/design-decisions.md) for the reasoning behind the main architectural choices. See [docs/architecture.md](docs/architecture.md) for the module map, [docs/performance.md](docs/performance.md) for resource lifetimes and benchmarking, [docs/plugin-inventory.md](docs/plugin-inventory.md) for plugin ownership, [docs/development.md](docs/development.md) for project metadata and UI conventions, and [docs/contributing.md](docs/contributing.md) for maintenance rules.

## Compatibility

This configuration targets **Neovim 0.12 or newer**. The compatibility workflow checks the latest Neovim stable release and nightly build on every push and pull request.

The main configuration uses public Neovim APIs. The only private API dependency is the optional tiny-cmdline integration, which uses experimental UI2. If UI2 is unavailable or its setup fails, the configuration keeps Neovim's native command line enabled. See [docs/compatibility.md](docs/compatibility.md) for the support policy and update procedure.

Neovide settings are kept in one module and use documented Neovide options. The CI workflow cannot exercise the graphical frontend, so verify the Neovide UI after upgrading Neovide itself.

## Checks

Run the repository's static checks with:

```sh
bash scripts/check.sh
```

Python 3 is required for repository checks only; it is not a Neovim runtime dependency. The script validates JSON configuration, plugin lockfile revisions, Lua indentation and line endings, deprecated/private API usage, Lua syntax, and core/plugin-spec imports. It also runs unit tests for the repository's Python check helpers. GitHub Actions runs the checks against the latest Neovim stable release and nightly build. The headless smoke test does not install or execute third-party plugin configurations, so test those features after plugin updates and on the operating systems you use. Follow [docs/manual-testing.md](docs/manual-testing.md) for real DAP, Telescope/fzf-native, PowerShell, resource-lifecycle, UI, and platform checks.

## Troubleshooting

- Run `:checkhealth` after installation.
- Run `:Lazy` and check whether plugin installation or compilation failed.
- Make sure `rg`, `fd`, `clangd`, `stylua`, language servers, and `lldb-dap` are visible on `PATH`.
- If DAP cannot start, check `LLDB_DAP` and confirm that the executable exists.
- If the configured PowerShell shell or Windows C runner cannot start, inspect the validated executable with `:lua local p = require("soul.core.helpers.paths").resolve_powershell(); print(p, vim.fn.executable(p))`. The cheap `paths.pwsh` value is only a shell command hint; full PowerShell 7 validation is deferred until the C runner needs it. Set `PWSH` to the full path of PowerShell 7's `pwsh.exe` if automatic discovery selects the wrong installation. Windows PowerShell 5.1 is intentionally not accepted by the C runner.
- If C diagnostics are missing or use the wrong standard, check the project's `compile_commands.json` or `compile_flags.txt`.
- If Treesitter highlighting is missing after first install, run `:TSUpdate` and reopen the buffer.
- If Telescope reports that the `fzf` extension or `libfzf.dll` is missing, run `:Lazy build telescope-fzf-native.nvim` to rebuild the native library, then restart Neovim so Telescope can load it.

## License

This is a personal configuration repository. Check individual plugin licenses for the software managed by the configuration.
=======
# CVIM

https://github.com/user-attachments/assets/dbed007c-070e-4e26-bb39-83793c824f62

<p align="center">
  A personal Neovim configuration for Windows, WSL, and Linux.
  <br />
  <strong>C, with a better editor.</strong>
</p>

CVIM is a C-focused Neovim environment built around a fast terminal workflow, native Neovim tooling, project-aware development, and a deliberately customized interface. It runs across Windows 11, WSL, and Linux, including Arch Linux and Hyprland.

The configuration uses Lazy.nvim, native Neovim LSP, Blink.cmp, Telescope, Mini Files, Treesitter, custom LLDB debugging, and an Everforest-oriented UI.

> **Requirements:** Neovim 0.12 or newer. CVIM uses modern Neovim APIs including `vim.lsp.config`, `vim.lsp.enable`, and the current Treesitter setup API. Older versions are not supported.

## What CVIM includes

### C and C++ development

- clangd support for C and C++
- C/C++ helpers for source-header switching, include insertion, and compile metadata
- A floating single-file C23 compile/run terminal
- Project-aware LLDB debugging with executable discovery
- Independent DAP project state for selected executables and launch arguments
- Build metadata support through `compile_commands.json` and `compile_flags.txt`

### Project workflow

- Project picker powered by Telescope and `telescope-project.nvim`
- Project actions for build, run, clean, rebuild, and executable selection
- Floating runner with ANSI-colored process output
- Quickfix integration for compiler diagnostics
- Mini sessions for project session save, restore, and automatic persistence
- Optional YAP project status in Lualine

### Editor experience

- Lazy.nvim plugin management with automatic bootstrap
- Native Neovim LSP configuration, without Mason
- Blink.cmp completion
- Telescope pickers with project-root search
- Mini Files with preview and hidden-file controls
- Treesitter highlighting and folding
- Mini.ai text objects and Mini.surround editing
- ToggleTerm with persistent horizontal, vertical, and floating terminals
- Alpha dashboard with an animated C/VIM identity, randomized wordmark glitches, quick actions, project context, and an optional animated C tutorial
- LSP-aware breadcrumbs in the winbar
- Context-aware Lualine statusline
- Mini.notify notifications

### Cross-platform UI and tooling

- Windows, WSL, and Linux path, shell, clipboard, compiler, and debugger handling
- Shared floating-window helpers
- Centralized Everforest palette and highlights
- Rounded borders and transparent floating-window backgrounds
- Optional Neovide integration

## Requirements

### Core

- Neovim 0.12 or newer
- Git
- A Nerd Font
- `ripgrep` (`rg`) for live grep
- `fd` for file discovery
- A C compiler for `telescope-fzf-native.nvim`
  - Windows builds prefer CMake/Visual Studio and fall back to Make or LLVM Clang
- Neovide 0.16 or newer (optional; required for the configured Neovide-specific options)

### Language tools

Install the tools you intend to use and make sure they are available on `PATH`:

| Tool | Purpose |
|---|---|
| `clangd` | C and C++ language server |
| `lua-language-server` | Lua language server |
| `bash-language-server` | Bash language server |
| `fish-lsp` | Fish language server |
| `stylua` | Lua formatting and format-on-save |
| `lldb-dap` | C/C++ debugging adapter |

The language servers and debugger are installed outside Neovim. **Mason is intentionally not used.**

C project build scripts are launched with `cmd.exe` on Windows and `bash` (falling back to `sh`) on Unix-like systems.

## Installation

Clone CVIM into the directory returned by:

```vim
:echo stdpath('config')
```

### Linux

The default Neovim configuration directory is usually `~/.config/nvim`.

```sh
git clone https://github.com/soulz3r/cvim.git ~/.config/nvim
nvim
```

### WSL

Install Neovim inside your WSL distribution, then clone CVIM into that distribution's configuration directory.

```sh
git clone https://github.com/soulz3r/cvim.git ~/.config/nvim
nvim
```

WSL Neovim uses Linux binaries and POSIX build/run commands. To share a Windows project directory, set `PROJECTS_DIR` to its mounted path, for example `/mnt/d/projects`.

Windows clipboard integration is enabled when `clip.exe` and PowerShell are available in WSL's `PATH`.

### Windows

The standard Neovim configuration directory is usually `%LOCALAPPDATA%\nvim`.

```powershell
git clone https://github.com/soulz3r/cvim.git "$env:LOCALAPPDATA\nvim"
nvim
```

If you use a custom location, such as `D:\.config\nvim`, clone the repository into that directory instead.

### First launch

Lazy.nvim bootstraps itself and installs the configured plugins on the first launch. After installation, run:

```vim
:Lazy sync
:checkhealth
```

Install the external tools listed above separately. A plugin manager cannot install your system toolchain by telepathy.

## C and C++ development

CVIM uses clangd and project build metadata to provide accurate diagnostics and completion.

Prefer a generated `compile_commands.json` when your build system supports it. For smaller projects, a `compile_flags.txt` file in the project root is also supported.

Example for a C23 project:

```text
-std=c23
-Iinclude
-Isrc
-g
```

Keep the language standard in the project configuration rather than forcing `-std=c23` globally. That allows C++ projects to use their own standard.

The clangd configuration recognizes project markers including:

- `.clangd`
- `.clang-tidy`
- `.clang-format`
- `compile_commands.json`
- `compile_flags.txt`
- `.git`

Useful LSP mappings are documented in [docs/keymaps.md](docs/keymaps.md).

## Debugging with LLDB

CVIM configures the DAP adapter to use `lldb-dap` directly. No Mason adapter is required.

Default adapter locations:

| Platform | Adapter |
|---|---|
| Windows | `C:/Program Files/LLVM/bin/lldb-dap.exe` |
| Linux / WSL | `lldb-dap` from `PATH` |

Set the `LLDB_DAP` environment variable to override the adapter executable.

The debugger detects project roots from common markers such as `.git`, `CMakeLists.txt`, `Makefile`, `build.sh`, `build.bat`, `compile_commands.json`, `meson.build`, and `Cargo.toml`.

It searches common build directories for executables and also lets you select an executable manually.

See [docs/debugging.md](docs/debugging.md) for setup, mappings, and registry details.

## Project workflow

CVIM integrates YAP with Telescope for project selection and project-specific actions. The integration is configured in `lua/soul/plugins/yap.lua` and does not use Nui or NuiComponents.

Use `<leader>pp` to open the project picker. Selecting a project changes Neovim's working directory.

### Project picker mappings

| Mapping | Action |
|---|---|
| `Ctrl-g` | Build and run the selected project |
| `Ctrl-y` | Build the selected project |
| `Ctrl-e` | Choose an executable and run it |
| `Ctrl-a` | Open the project's action menu |
| `gR` | Run the project |
| `gB` | Build the project |
| `gE` | Choose an executable |
| `gC` | Clean the project |
| `gX` | Rebuild the project |
| `gS` | Choose a build script |
| `gA` | Open the project action menu |

### Project actions from the current working directory

| Mapping | Action |
|---|---|
| `<leader>pp` | Open the YAP project picker |
| `<leader>pr` | Build and run the current project, then enter arguments |
| `<leader>pb` | Build the current project |
| `<leader>pc` | Clean the current project |
| `<leader>pB` | Clean and rebuild the current project |
| `<leader>pS` | Choose a build script |
| `<leader>pe` | Select an executable and run it with arguments |
| `<leader>ps` | Stop the active project process |
| `<leader>pR` | Rerun the most recently used executable and saved arguments |

The runner opens a read-only floating output window with an operation summary and ANSI-colored process output.

- Press `q` or `Esc` to close the output window.
- Press `Ctrl-c` to stop a running process.
- Press `<leader>pq` inside the output window to send parsed compiler diagnostics to quickfix.

### C/C++ helper mappings

These helpers are buffer-local.

| Mapping | Action |
|---|---|
| `<leader>ch` | Switch between matching source and header files |
| `<leader>ci` | Insert an include directive |
| `<leader>cp` | Show project root, compile metadata, and attached LSP clients |

## Environment variables

| Variable | Purpose | Default |
|---|---|---|
| `PROJECTS_DIR` | Base directory for YAP project picker and project discovery | `~/projects` on all platforms |
| `LLDB_DAP` | Full path or command name for `lldb-dap` | Windows LLVM path; Linux `lldb-dap` |
| `PWSH` | PowerShell executable used by the configured shell and C runner | `pwsh` or `pwsh.exe` |
| `CLANG` | Clang executable used by the C compile/run keymap | `clang` from `PATH` |

## Local project state

YAP and DAP keep their state separately.

YAP's project registry stores YAP-owned project metadata:

```text
stdpath("state")/yap/projects.json
```

DAP maintains its own registry for saved debugger projects, selected executables, and launch arguments:

```text
stdpath("state")/soul/dap/projects.json
```

DAP does not depend on YAP's Lua modules or registry at runtime.

On the first startup after the registry separation, a one-time importer copies only DAP-specific fields from the former YAP registry into DAP's own registry. The YAP registry is left untouched, and a migration marker prevents the old values from being imported again.

Older DAP-only registries are also imported from:

- `stdpath("config")/lsp/dap-projects.json`
- `stdpath("state")/soul/dap-projects.json`

After a successful import, each old DAP-only file is renamed with a `.migrated` suffix, or a timestamped suffix if that backup already exists. Original data is preserved.

## Documentation

| Document | Contents |
|---|---|
| [Architecture](docs/architecture.md) | Module map and how the configuration is connected |
| [Design decisions](docs/design-decisions.md) | Main architectural choices and rationale |
| [Dashboard](docs/dashboard.md) | Animated startup dashboard |
| [Debugging](docs/debugging.md) | LLDB setup, mappings, and project registry |
| [Keymaps](docs/keymaps.md) | Keybinding reference |
| [Performance](docs/performance.md) | Resource lifetimes and benchmarking |
| [Plugin inventory](docs/plugin-inventory.md) | Plugin ownership and responsibilities |
| [Development](docs/development.md) | Project metadata and UI conventions |
| [Compatibility](docs/compatibility.md) | Supported Neovim versions and update policy |
| [Manual testing](docs/manual-testing.md) | Platform and feature testing procedures |
| [Contributing](docs/contributing.md) | Maintenance and contribution rules |

## Compatibility

CVIM targets **Neovim 0.12 or newer**.

The compatibility workflow checks the latest Neovim stable release and nightly build on every push and pull request. The main configuration uses public Neovim APIs.

The optional tiny-cmdline integration is the only private API dependency. It uses experimental UI2. If UI2 is unavailable or setup fails, CVIM keeps Neovim's native command line enabled.

Neovide settings are kept in one module and use documented Neovide options. CI cannot exercise the graphical frontend, so verify the Neovide UI after upgrading Neovide itself.

See [docs/compatibility.md](docs/compatibility.md) for the support policy and update procedure.

## Checks

Run the repository's static checks with:

```sh
bash scripts/check.sh
```

Python 3 is required for repository checks only; it is not a Neovim runtime dependency.

The check script validates:

- JSON configuration
- Plugin lockfile revisions
- Lua indentation and line endings
- Deprecated and private API usage
- Lua syntax
- Core, plugin-spec, and module imports
- Unit tests for the repository's Python check helpers

GitHub Actions runs the checks against the latest Neovim stable release and nightly build.

The headless smoke test does not install or execute third-party plugin configurations. Test those features after plugin updates and on the operating systems you use.

See [docs/manual-testing.md](docs/manual-testing.md) for real DAP, Telescope/fzf-native, PowerShell, resource-lifecycle, UI, and platform checks.

## Troubleshooting

- Run `:checkhealth` after installation.
- Run `:Lazy` and check whether plugin installation or compilation failed.
- Make sure `rg`, `fd`, `clangd`, `stylua`, language servers, and `lldb-dap` are available on `PATH`.
- If DAP cannot start, check `LLDB_DAP` and confirm that the executable exists.
- If the configured PowerShell shell or Windows C runner cannot start, inspect the resolved executable:

  ```vim
  :lua local p = require("soul.core.helpers.paths").resolve_powershell(); print(p, vim.fn.executable(p))
  ```

  The cheap `paths.pwsh` value is only a shell command hint. Full PowerShell 7 validation is deferred until the C runner needs it. Set `PWSH` to the full path of PowerShell 7's `pwsh.exe` if automatic discovery selects the wrong installation. Windows PowerShell 5.1 is intentionally not accepted by the C runner.
- If C diagnostics are missing or use the wrong standard, check the project's `compile_commands.json` or `compile_flags.txt`.
- If Treesitter highlighting is missing after first install, run `:TSUpdate` and reopen the buffer.
- If Telescope reports that the `fzf` extension or `libfzf.dll` is missing, run `:Lazy build telescope-fzf-native.nvim`, then restart Neovim.

## License

This is a personal configuration repository. Check individual plugin licenses for the software managed by the configuration.
>>>>>>> 5c15f094ce9bef3ebf37471b99faedb0e4de1d69

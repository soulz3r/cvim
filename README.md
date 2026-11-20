# CVIM

A minimal Neovim configuration.

**C, with a better editor.**

This branch contains only the editor core:

- Basic editing, display, search, clipboard, and indentation options.
- A small set of portable keymaps.
- Core autocmds for formatting behavior, external file changes, yank highlighting, and prose buffers.
- Small platform and path helpers used by the core options.

No plugin manager, plugins, LSP, completion, debugging, dashboard, statusline, project system, or custom UI.

## Requirements

- Neovim 0.12+
- A terminal with true-color support

The entry point is init.lua.

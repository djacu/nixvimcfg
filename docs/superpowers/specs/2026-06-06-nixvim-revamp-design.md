# nixvim revamp — design

**Date:** 2026-06-06
**Status:** design / pending approval
**Repo:** `/home/djacu/dev/djacu/nixvimcfg`

## Goal

Three threads handled as one design:

1. **Fix the nixvim 26.11 evaluation errors** so `nix run .` succeeds.
2. **Restructure the modules** so each module's intent is obvious and plugin/dependency pairings are co-located.
3. **Add productivity plugins** that fill known gaps in the user's day-to-day Neovim workflow, with a particular focus on discoverability (the user's stated meta-pain: "I always am unsure how to use plugins").

## Constraints and decisions made during brainstorming

- **Aggressive swap policy.** Where a clearly-better modern alternative exists, swap.
- **No in-editor AI.** Skip codecompanion / copilot / avante — user runs Claude Code in the terminal.
- **Drop `conform-nvim` entirely.** Format-on-save comes from LSP-provided formatting where available; for the rest, use project tooling from the shell. Rationale: avoids the version-mismatch problem (project-pinned formatter vs. editor-bundled formatter) that nixvim's wrapper PATH precedence makes unsolvable cleanly.
- **DAP and neotest both in scope.**
- **Languages in use:** Go, Rust, Python, TypeScript/JavaScript/web, Bash, Haskell (starting), CMake (occasional), Ansible (occasional), Nix, Typst, LaTeX, Markdown.
- **No lazygit binary on this user's system** — `snacks.lazygit` is excluded.
- **harpoon2 pinned to a specific commit** in `extraPlugins` (no tagged release exists on the harpoon2 branch).
- **`mini.tabline` replaces `bufferline.nvim`** (bufferline.nvim is stale; user prefers mini-suite consistency).
- **`neogit` added alongside `fugitive`** (not replacing).

## Architecture

### Directory layout

```
nixvim-modules/
├── completion/             # blink.cmp + luasnip + friendly-snippets
├── dap/                    # nvim-dap + adapters
├── editing/                # mini editing primitives + guess-indent + nvim-ts-autotag
├── files/                  # oil.nvim
├── git/                    # gitsigns + diffview + fugitive + neogit
├── lsp/                    # LSP servers + lazydev
├── navigation/             # harpoon2 + flash + aerial + grug-far
├── neotest/                # neotest + adapters
├── picker/                 # telescope + extensions
├── snacks/                 # snacks.nvim selected modules
├── treesitter/             # treesitter (main branch) + context + textobjects
├── typst/                  # typst-preview.nvim
├── ui/                     # lualine + mini.tabline + fidget + noice + ...
└── which-key/              # central key-group registry
```

14 modules total. `coq-nvim/` and `conform-nvim/` are removed.

### Module convention

Each module exports exactly one `nixvimcfg.<name>.enable` option:

```nix
{ lib, config, pkgs, ... }:
let cfg = config.nixvimcfg.<name>; in
{
  options.nixvimcfg.<name>.enable = lib.mkEnableOption "<short description>";

  config = lib.mkIf cfg.enable (lib.mkMerge [

    # === plugin-or-feature-X ===
    # WHY: <one-line explanation of why these things are grouped together>
    {
      plugins.X.enable = true;
      plugins.X.settings = { ... };
      extraPackages = [ pkgs.Xdep ];   # paired with X in the same block
    }

    # === plugin-or-feature-Y ===
    # WHY: <…>
    { ... }

    # === which-key entries ===
    # WHY: leaf keymaps for this module's commands; group prefixes live in the which-key module
    (lib.mkIf config.nixvimcfg.which-key.enable {
      plugins.which-key.settings.spec = [ ... ];
    })

  ]);
}
```

Every mkMerge block has a `# === name ===` header and a `# WHY:` line. Dependencies (packages, settings, keymaps) for a single plugin live in the same block as the plugin enable — never split across blocks.

### Top-level configuration

`nixvim-configurations/default.nix` becomes a flat list of enables — no inline plugin config:

```nix
inputs: {
  default = { ... }: {
    imports = [ inputs.self.nixvimModules.default ];
    config = {
      opts        = { number = true; relativenumber = true; shiftwidth = 2; tabstop = 2;
                      expandtab = true; spell = true; spelllang = "en_us"; };
      globals.mapleader = " ";
      colorschemes.kanagawa.enable = true;

      nixvimcfg.completion.enable = true;
      nixvimcfg.dap.enable        = true;
      nixvimcfg.editing.enable    = true;
      nixvimcfg.files.enable      = true;
      nixvimcfg.git.enable        = true;
      nixvimcfg.lsp.enable        = true;
      nixvimcfg.navigation.enable = true;
      nixvimcfg.neotest.enable    = true;
      nixvimcfg.picker.enable     = true;
      nixvimcfg.snacks.enable     = true;
      nixvimcfg.treesitter.enable = true;
      nixvimcfg.typst.enable      = true;
      nixvimcfg.ui.enable         = true;
      nixvimcfg.which-key.enable  = true;
    };
  };
}
```

Loose plugin enables (current `plugins.bufferline.enable`, `plugins.comment.enable`, etc.) all move into the appropriate modules.

## Plugin selection — verified June 2026

### LSP module

Servers enabled:

- Currently enabled (kept): astro, bashls, cssls, eslint, gopls, golangci_lint_ls, html, jsonls, nixd, ruff, rust_analyzer, tailwindcss, taplo, texlab, typos_lsp, tinymist, yamlls.
- **Added:** `hls` (Haskell), `neocmake` (CMake), `ansiblels` (Ansible), `ts_ls` (TypeScript/JavaScript — gap in current setup), `lua_ls` (Lua, for nixvim's inline Lua), `marksman` (Markdown), `harper_ls` (English grammar for prose).
- `nil_ls` stays disabled (nixd is the modern choice; verified active development, options-completion, evaluation-based features; nil has known semantic-highlighting performance issues).

Other:

- `plugins.lazydev.enable = true;` — gives Lua completion that understands nvim's runtime types. lazydev integrates with blink.cmp via blink.cmp's source registration (added in the completion module), not via lazydev settings.
- **`harper_ls` settings** disable `SentenceCapitalization` rule and limit `SpellCheck` to `markdown`, `text`, `gitcommit` filetypes to avoid flagging code identifiers.
- **Conform-related removals:** the `pkgs.golangci-lint` extraPackages entry stays (used by golangci_lint_ls); all formatter extraPackages disappear with the conform module.

### Completion module

- **`blink.cmp v1`** via `extraPlugins = [ pkgs.vimPlugins.blink-cmp ]` (whatever version nixpkgs currently packages — verified v1 at flake.lock pin time). No first-class nixvim module. If/when nixpkgs moves to v2, an overlay pinning to v1 is added at that time and noted in the risks section.
- **`luasnip`** + **`friendly-snippets`** kept (blink.cmp consumes luasnip natively).
- **Sources:** `lsp`, `snippets`, `buffer`, `path`, plus `lazydev` (registered as a blink source so Lua files get nvim-runtime-aware completion). Cmdline completion enabled via `cmdline = { enabled = true }`.
- **Keymap preset:** `default` (`<CR>` accept, `<C-space>` open, `<Tab>`/`<S-Tab>` snippet nav, `<C-n>`/`<C-p>` next/prev).
- **LSP capability wiring:** `extraConfigLua` merges `require('blink.cmp').get_lsp_capabilities()` into `vim.lsp.config('*', { capabilities = … })`.
- **nvim-cmp is removed.**

### Treesitter module

- **`plugins.treesitter` = main-branch nvim-treesitter** (nixvim 26.11's default `package` setting; no override needed).
- **`plugins.treesitter-refactor` REMOVED** — its nixpkgs package hard-deps on `nvim-treesitter-legacy`, which is the root cause of the "two different versions of nvim-treesitter" error.
- **`plugins.treesitter-context` kept** — branch-agnostic.
- **`plugins.treesitter-textobjects` added** (main-branch version, first-class in nixvim). Textobject keymaps configured via Lua keymap API (`require("nvim-treesitter-textobjects.<module>")`), not via `configs.setup`.
- **Option syntax fixes:** `plugins.treesitter.settings.highlight.enable` → `plugins.treesitter.highlight.enable`; `plugins.treesitter.folding = true` → `plugins.treesitter.folding.enable = true`.
- **Lost features and their replacements:**
  - `highlightDefinitions` → `snacks.words` (auto-highlights LSP references) — slightly different but covers the same use case.
  - `navigation` (goto/list definitions) → LSP (`vim.lsp.buf.definition`/`references`) + treesitter-textobjects for structural jumps.
  - `smartRename` → LSP (`vim.lsp.buf.rename`, bound to `<leader>lr`).

### Which-key module

Owns:

1. **Central key-group registry** — every `<leader>X` group prefix declared here, exactly once:

   | Prefix | Group | Source modules |
   |---|---|---|
   | `<leader>?` | Discover | this module (telescope built-ins) |
   | `<leader>a` | Aerial | navigation |
   | `<leader>b` | Buffer | snacks (bufdelete) |
   | `<leader>c` | Code (scratch, profiler) | snacks |
   | `<leader>d` | Debug (dap) | dap |
   | `<leader>e` | Explore (oil) | files |
   | `<leader>f` | Find (telescope) | picker |
   | `<leader>g` | Git | git |
   | `<leader>h` | Harpoon | navigation |
   | `<leader>l` | LSP | lsp |
   | `<leader>m` | Markdown | ui |
   | `<leader>n` | Notifications (noice history) | ui |
   | `<leader>o` | Toggle | snacks |
   | `<leader>s` | Search/Replace | navigation (grug-far) |
   | `<leader>t` | Test (neotest) | neotest |
   | `<leader>x` | Trouble | ui |

2. **Preset enablement** — registers, marks, windows, z-keys, g-keys, operators, motions, text-objects auto-documented.
3. **`<leader>?` discovery namespace** bound to Telescope built-ins:
   - `<leader>?k` → `:Telescope keymaps`
   - `<leader>?c` → `:Telescope commands`
   - `<leader>?h` → `:Telescope help_tags`
   - `<leader>?t` → `:Telescope builtin`
   - `<leader>?p` → `:Telescope`
4. **`delay = 200`** (replaces the current `timeoutlen = 100` which is too aggressive).

Per-module leaf keymaps continue to live in the modules that own the underlying plugin, gated on `mkIf config.nixvimcfg.which-key.enable`. They reference only the prefixes declared in this central registry.

### Picker module

- `plugins.telescope.enable` + extensions: `file-browser`, `frecency`, `fzf-native`, `media-files`.
- Each extension in its own mkMerge block paired with the package it requires (`poppler-utils`, `imagemagick`, `fontpreview`, `ffmpegthumbnailer`, `epub-thumbnailer`, `chafa` for media-files; `fd` for the file-browser).
- which-key leaves under `<leader>f`.

### Files module

- `plugins.oil.enable` only. Buffer-as-fs file editor.
- Replaces (already-disabled) chadtree.
- Keymap `<leader>e` → open oil at current buffer's directory.

### Navigation module

- **`flash.nvim`** — `s`/`S` for jump-to-anywhere by 2-char label. Replaces the need for `f`/`t` for long jumps.
- **`harpoon2` via extraPlugins**, pinned to a specific recent commit on the `harpoon2` branch. Keymaps under `<leader>h`: add, list, prev, next, slot 1–4.
- **`aerial.nvim`** — symbol outline sidebar. Keymap `<leader>a` toggle.
- **`grug-far.nvim`** — project-wide find/replace with editable buffer. Replaces the proposed nvim-spectre (which is stale). Keymaps under `<leader>s`.

### Editing module

- **`mini.surround`** (replaces vim-surround), **`mini.comment`** (replaces vim-comment), **`mini.pairs`** (replaces nvim-autopairs), **`mini.ai`** (richer textobjects), **`mini.move`** (alt-j/k line move).
- **`guess-indent.nvim`** — Lua-native, sub-ms indent detection.
- **`nvim-ts-autotag`** — HTML/JSX/Astro tag auto-close.
- All mini modules go through `plugins.mini.modules.{surround,comment,pairs,ai,move}` (nixvim's mini configuration shape).

### Git module

- **`gitsigns`** — gutter signs + hunk staging + inline blame.
- **`diffview.nvim`** — full-screen diff browser.
- **`fugitive`** kept — `:G` command surface.
- **`neogit`** added — Magit-style interactive porcelain.
- All keymaps under `<leader>g`. Sub-groups: `<leader>gh` for gitsigns hunks, `<leader>gd` for diffview, `<leader>gn` for neogit, plain `<leader>g{a,b,c,d,…}` retained from current config for fugitive.

### UI module

Single module with 10 plugins; each in its own mkMerge block with intent comment.

- **`lualine`** replaces lightline. Sections: mode | branch+diff+diagnostics | filename | filetype+encoding+location.
- **`mini.tabline`** replaces bufferline.nvim. (User pick over barbar / native.)
- **`mini.icons`** — icons used by lualine, mini.tabline, oil, telescope.
- **`fidget`** — LSP progress in the corner.
- **`noice`** — cmdline / messages / notifications UI.
- **`todo-comments`** — TODO/FIXME/HACK/NOTE highlighter + telescope picker (`:TodoTelescope`).
- **`render-markdown`** kept — inline markdown rendering.
- **`mini.indentscope`** — visual indent guides.
- **`nvim-origami`** — folding (replaces nvim-ufo).
- **`quicker.nvim`** — modern editable quickfix buffer.

### DAP module

- `plugins.dap.enable`, `plugins.dap-go.enable` (first-class nixvim).
- `extraPlugins = [ pkgs.vimPlugins.nvim-dap-ui pkgs.vimPlugins.nvim-dap-python pkgs.vimPlugins.nvim-dap-virtual-text ]` (no nixvim module).
- `extraConfigLua` registers `dap-ui.setup{}`, `dap-virtual-text.setup{}`, `dap-python.setup(python_path)`. For python: `python_path` set to a derivation of `pkgs.python3.withPackages (ps: [ ps.debugpy ])` exposed via extraPackages.
- For Rust: configurations use `pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter` for codelldb.
- Keymaps under `<leader>d`: toggle breakpoint (`b`), continue (`c`), step over/into/out (`o`/`i`/`O`), repl (`r`), dap-ui toggle (`u`), terminate (`q`).

### Neotest module

- `plugins.neotest.enable` with adapters: `golang`, `python`, `rust`, `jest`, `vitest` (all first-class).
- For python: shares the debugpy python from the dap module via `mkIf config.nixvimcfg.dap.enable`.
- Keymaps under `<leader>t`: run nearest (`r`), run file (`f`), run last (`l`), summary toggle (`s`), output toggle (`o`), stop (`q`).

### Snacks module

Single module exposing `snacks.nvim` with the following submodules in their own mkMerge blocks:

| Submodule | Purpose | Keymap / autoload |
|---|---|---|
| `bigfile` | Disable expensive features on large files | autoload |
| `statuscolumn` | Unified gutter (signs/numbers/folds/git) | autoload |
| `scratch` | Per-cwd persistent scratch buffers | `<leader>cs` |
| `words` | LSP-reference auto-highlight + `]]`/`[[` nav | autoload |
| `toggle` | Toggles auto-registered into which-key under `<leader>o` (spell, wrap, diagnostics, inlay hints, line numbers, etc.) | which-key |
| `profiler` | Lua profiler with flame UI | `<leader>cp` start, `<leader>cP` stop |
| `bufdelete` | Close buffers without destroying window layout | `<leader>bd` |
| `rename` | LSP-aware file rename that updates imports | invoked via oil's actions |
| `gitbrowse` | "Open in GitHub" without rhubarb | `<leader>go` |
| `quickfile` | Renders file before plugins load | autoload |

**`snacks.lazygit` excluded** — user doesn't use the lazygit binary.

### Typst module

- `typst-preview.nvim` via first-class nixvim option (verified). Pairs with `tinymist` LSP.
- Keymaps under filetype `typst`: preview start/stop/sync.

## What's deleted

- `nixvim-modules/coq-nvim/` — unused alternative to cmp.
- `nixvim-modules/conform-nvim/` — formatter dispatcher dropped in favor of LSP / shell tooling.
- All `plugins.{bufferline,comment,chadtree,lightline,nvim-autopairs,vim-surround}.enable` lines from `nixvim-configurations/default.nix` — replaced by per-module configurations.
- `plugins.treesitter-refactor.*` in `nixvim-modules/treesitter/default.nix` — archived upstream, hard-deps on nvim-treesitter-legacy.
- `plugins.cmp.*` (nvim-cmp) — replaced by blink.cmp.
- `plugins.lightline.enable` — replaced by lualine.
- `plugins.bufferline.enable` — replaced by mini.tabline.
- `plugins.nvim-autopairs.enable` — replaced by mini.pairs.
- `plugins.vim-surround.enable` — replaced by mini.surround.
- `plugins.comment.enable` — replaced by mini.comment.

## Staging

The work lands in phases, each individually buildable and validatable:

1. **Unblock (~6 lines)** — drop `plugins.treesitter-refactor.*`, rename `treesitter.folding` and `treesitter.settings.highlight.enable` per the migration. `nix run .` succeeds. No structural change yet.
2. **Internal refactor — no behavior change** — restructure existing modules into mkMerge blocks with intent comments. Move loose plugins from `nixvim-configurations/default.nix` into per-concern modules (preserves current plugin set; just reorganizes).
3. **Drop conform + expand LSP servers** — remove conform-nvim module and its extraPackages. Add hls, neocmake, ansiblels, ts_ls, lua_ls, marksman, harper_ls (with the prose-only narrowing).
4. **Swap completion** — replace nvim-cmp with blink.cmp v1 (via extraPlugins). Add treesitter-textobjects.
5. **Swap UI** — lightline→lualine, bufferline→mini.tabline. Add fidget, noice, todo-comments, mini.indentscope, mini.icons, nvim-origami, quicker. Keep render-markdown.
6. **Swap editing primitives** — vim-surround → mini.surround, comment → mini.comment, nvim-autopairs → mini.pairs. Add mini.ai, mini.move, flash, harpoon2 (extraPlugins, pinned commit), guess-indent, nvim-ts-autotag.
7. **File explorer** — replace (disabled) chadtree with oil.nvim.
8. **Git enhancements** — add gitsigns, diffview, neogit. Keep fugitive.
9. **Snacks adoption** — enable the 10 selected snacks submodules.
10. **DAP + neotest** — add both modules with all language adapters.
11. **Which-key registry overhaul** — central groups + `<leader>?` discovery bindings + presets + delay tuning.
12. **Typst preview** — add typst-preview module.

Each phase produces a separately reviewable change set. Phases 3-12 can be reordered within reason; phase 1 must come first, phase 2 must follow before structural moves get tangled with feature swaps.

## Risks and unverified items

- **harpoon2 commit pin** — branch HEAD has no tagged release. Risk: stale unless manually bumped via overlay. Acceptable; user opted into commit-pin for reproducibility.
- **blink.cmp via extraPlugins** — when nixvim adds a first-class module (likely in a future release), our extraConfigLua becomes redundant and should be migrated.
- **dap-python `debugpy` path** — bundling debugpy via the editor wrapper creates the same "editor's python ≠ project's python" mismatch we explicitly avoided for formatters. Mitigation: dap-python supports `python_path` venv lookup at runtime; we bundle debugpy only as a fallback.
- **`nvim-treesitter-locals` is not first-class in nixvim** — would require extraPlugins. Excluded from the design; the lost `treesitter-refactor` features are covered by LSP + snacks.words. Revisit if there's a real gap in practice.
- **harper_ls false-positive rate** — defaults are noisy on code identifiers. The `SpellCheck` filetype restriction and `SentenceCapitalization` disable should handle most of it; further narrowing may be required after running it.
- **Bufferline replacement (`mini.tabline`)** is more spartan than `bufferline.nvim` — no buffer picker, simpler labels. User accepted this trade for active maintenance + mini-suite consistency.
- **Lost `treesitter-refactor.highlightDefinitions`** — snacks.words is the closest substitute (LSP-reference highlight). Behavior differs slightly; revisit if missed in practice.

## Out of scope

- AI / LLM integration (codecompanion, copilot, avante).
- `nvim-treesitter-locals` (decided against; covered by LSP + snacks.words).
- Replacing telescope with snacks.picker or fzf-lua.
- Replacing noice with snacks.notifier (overlap exists but noice is more feature-complete).
- A startup dashboard (alpha/mini.starter/snacks.dashboard) — user opens projects via CLI.
- Terminal integration (toggleterm/snacks.terminal) — user uses an external shell.
- A formatter dispatcher replacement (efm-langserver, none-ls, nvim-lint).
- Migration of `nixvim-configurations/default.nix` `opts` / `globals` / `colorschemes` — these stay as-is.

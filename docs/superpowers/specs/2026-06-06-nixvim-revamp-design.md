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
- **harpoon2 via the first-class `plugins.harpoon` module** with `package` overridden to the harpoon2 branch (nixpkgs ships `vimPlugins.harpoon2`).
- **`mini.tabline` replaces `bufferline.nvim`** for mini-suite consistency. (bufferline.nvim is not archived — last release v4.9.1 Jan 2025 — but `mini.tabline` matches the rest of the mini suite the user is adopting.)
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

- `plugins.lazydev.enable = true;` — gives Lua completion that understands nvim's runtime types. Integrates with blink.cmp via blink.cmp's `sources.providers.lazydev` registration (in the completion module). **Limitation:** lazydev only fires for `lua` filetypes. Inline Lua inside `.nix` files (e.g. `extraConfigLua = ''…''`) won't trigger it — the buffer is `nix` filetype. For nontrivial Lua, extract to a `.lua` file and import via `lib.fileContents`.
- **`harper_ls` settings** disable `SentenceCapitalization` rule and limit `SpellCheck` to `markdown`, `text`, `gitcommit` filetypes. This **excludes** Python docstrings, Rust/Go doc comments, and Lua comments — accepted as the noise-control tradeoff. Revisit if the user misses prose-checking in code comments.
- **Conform-related removals:** the `pkgs.golangci-lint` extraPackages entry stays (used by golangci_lint_ls); all formatter extraPackages disappear with the conform module.
- **Pre-spec cleanup** (do this during phase 2): lines 41-42 of the existing `nixvim-modules/lsp/default.nix` are `lsp.servers.rust_analyzer.enable = true;` / `lsp.servers.rust_analyzer.packageFallback = true;` — missing the `plugins.` prefix, so they define stray top-level option paths. The correctly-prefixed lines (43-46) immediately below already enable rust_analyzer. Delete lines 41-42.

### Completion module

- **`plugins.blink-cmp.enable = true;`** — first-class in nixvim (verified at the locked commit) with a fully typed `.settings.*` schema. No extraPlugins / extraConfigLua glue required. nixpkgs ships the prebuilt Rust fuzzy-matcher binary as part of the derivation; no user action needed.
- **`luasnip`** + **`friendly-snippets`** kept (blink.cmp consumes luasnip natively via its `snippets` source).
- **Sources:** `lsp`, `snippets`, `buffer`, `path`, plus `lazydev` registered as a blink source so Lua files get nvim-runtime-aware completion:
  ```nix
  plugins.blink-cmp.settings.sources.default = [ "lazydev" "lsp" "snippets" "path" "buffer" ];
  plugins.blink-cmp.settings.sources.providers.lazydev = {
    name = "LazyDev";
    module = "lazydev.integrations.blink";
    score_offset = 100;
  };
  ```
- **Cmdline completion** enabled via `plugins.blink-cmp.settings.cmdline.enabled = true;`. Verify both `/` (search) and `:` (command) modes complete after migration.
- **Keymap preset:** `default` (`<CR>` accept, `<C-space>` open, `<Tab>`/`<S-Tab>` snippet nav, `<C-n>`/`<C-p>` next/prev).
- **LSP capability wiring:** rely on nixvim's auto-wiring through `plugins.lsp.capabilities` rather than hand-rolled `extraConfigLua`. blink.cmp's caps are picked up automatically when both modules are enabled. If a corner case requires manual merging, use `plugins.lsp.capabilities` with a Lua string.
- **nvim-cmp is removed** (the existing cmp module is deleted entirely).

### Treesitter module

- **`plugins.treesitter` = main-branch nvim-treesitter** (nixvim 26.11's default `package` setting; no override needed).
- **`plugins.treesitter-refactor` REMOVED** — its nixpkgs package hard-deps on `nvim-treesitter-legacy`, which is the root cause of the "two different versions of nvim-treesitter" error.
- **`plugins.treesitter-context` kept** — branch-agnostic. The existing config has `settings.enable = false` (line 35 of the current module) which renders it inert; remove that line so the plugin actually does something. If the user actively does *not* want context display, drop the plugin instead.
- **`plugins.treesitter-textobjects` added** (main-branch version, first-class in nixvim). Textobject keymaps configured via Lua keymap API (`require("nvim-treesitter-textobjects.<module>")`), not via `configs.setup`.
- **Parser installation strategy:** declare parsers explicitly via `plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [ bash c cmake cpp css go haskell html javascript json lua markdown markdown_inline nix python regex rust toml tsx typescript typst vim vimdoc yaml ];`. This pins the parser set at flake.lock time; no runtime `:TSInstall` needed; no auto-install assumption. The main-branch rewrite removed `ensure_installed`; this is the nixvim-native substitute.
- **Option syntax fixes:** `plugins.treesitter.settings.highlight.enable` → `plugins.treesitter.highlight.enable`; `plugins.treesitter.folding = true` → `plugins.treesitter.folding.enable = true`.
- **Lost features and their replacements:**
  - `highlightDefinitions` → `snacks.words` (auto-highlights LSP references) — slightly different but covers the same use case.
  - `navigation` (goto/list definitions) → LSP (`vim.lsp.buf.definition`/`references`) + treesitter-textobjects for structural jumps.
  - `smartRename` → LSP (`vim.lsp.buf.rename`, bound to `<leader>lr`).
- **Verification step in phase 1:** after dropping treesitter-refactor, inspect the plugin closure (`nix derivation show .#nixvimConfigurations.default | grep -i treesitter`) to confirm `nvim-treesitter-legacy` is not transitively pulled by any other module in this design.

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
- **`plugins.harpoon.enable = true;`** with `package = pkgs.vimPlugins.harpoon2;` — first-class nixvim module; the harpoon2 branch is shipped by nixpkgs as the `harpoon2` attribute. Set `enableTelescope = true;` for the Telescope integration. Keymaps (concrete leaves, not just "add, list, prev, next"):
  - `<leader>ha` — add file to harpoon
  - `<leader>hh` — toggle quick menu (Harpoon's `:Telescope harpoon marks` view if enableTelescope)
  - `<leader>h1`..`<leader>h4` — jump to slot 1–4
  - `<leader>hn` / `<leader>hp` — next / previous slot
- **`aerial.nvim`** — symbol outline sidebar. Keymap `<leader>aa` toggle, `<leader>an`/`<leader>ap` next/prev symbol.
- **`grug-far.nvim`** — project-wide find/replace with editable buffer. Replaces the proposed nvim-spectre. Keymaps:
  - `<leader>ss` — open grug-far for current buffer's word
  - `<leader>sg` — open grug-far globally (project-wide)

### Editing module

- **`mini.surround`** (replaces vim-surround), **`mini.comment`** (replaces Comment.nvim), **`mini.pairs`** (replaces nvim-autopairs), **`mini.ai`** (richer textobjects), **`mini.move`** (alt-j/k line move).
- **`guess-indent.nvim`** — Lua-native, sub-ms indent detection.
- **`nvim-ts-autotag`** — HTML/JSX/Astro tag auto-close.

**Mini configuration shape — important consistency rule:** mini.nvim is configured via `plugins.mini.modules.<name>`. nixvim also exposes standalone `plugins.mini-tabline`, `plugins.mini-icons`, `plugins.mini-indentscope`, etc. that ship their own `vimPlugins.mini-<name>` packages. **Use one shape only across the entire config** to avoid double-registering mini.nvim. The design uses the modules-merge shape:

```nix
plugins.mini.enable = true;
plugins.mini.modules = {
  surround = { ... };
  comment = { ... };
  pairs = { ... };
  ai = { ... };
  move = { ... };
  # cross-module entries — declared here even though logically owned by ui:
  tabline = { ... };
  indentscope = { ... };
  icons = { ... };
};
```

The `editing/`, `ui/`, and `picker/` modules each contribute keys to `plugins.mini.modules` via `mkMerge`; nixvim's submodule type permits cross-file merging.

**mini.surround mapping note** (muscle-memory regression vs vim-surround): mini.surround defaults to `sa`/`sd`/`sr` (add/delete/replace surround). The user is migrating from vim-surround's `ys`/`ds`/`cs`. Two options:
- (default) Accept the new mappings; mini.surround's defaults are more orthogonal.
- (compat) Set `plugins.mini.modules.surround.mappings = { add = "ys"; delete = "ds"; replace = "cs"; };` to preserve muscle memory.

The design accepts mini's defaults. If the user reports friction during phase 6, swap to the compat mappings.

**mini.comment commentstring regression for JSX/TSX/Astro:** mini.comment uses the buffer's `commentstring` or the active treesitter language, but does *not* switch commentstring based on nested-language context (e.g. JSX inside a TSX file where the comment syntax differs between the outer TypeScript and embedded JSX). For the user's web work, this is a real loss vs. `Comment.nvim` + `ts_context_commentstring`. Mitigation: add the `JoosepAlviste/nvim-ts-context-commentstring` plugin alongside mini.comment and wire it to update `vim.bo.commentstring` on the fly via an autocmd. If the user's web work is rare enough to not warrant this, accept the loss and document.

### Git module

- **`gitsigns`** — gutter signs + hunk staging + inline blame.
- **`diffview.nvim`** — full-screen diff browser.
- **`fugitive`** kept — `:G` command surface.
- **`neogit`** added — Magit-style interactive porcelain.

**Keymap layout** (resolves `<leader>g` collisions between fugitive and diffview that the existing config would create):

| Key | Action | Plugin |
|---|---|---|
| `<leader>ga` | git add current file | fugitive (`:Git add %:p`) |
| `<leader>gb` | git blame | fugitive |
| `<leader>gc` | git commit | fugitive |
| `<leader>gd` | git diff (single-file view) | fugitive |
| `<leader>gg` | open `:Git` status | fugitive |
| `<leader>gl` | git log | fugitive |
| `<leader>gpl` / `<leader>gps` | pull / push | fugitive |
| `<leader>gv` | open diffview | diffview |
| `<leader>gvf` | diffview file history | diffview |
| `<leader>gn` | open neogit | neogit |
| `<leader>gh{s,r,p,u}` | hunk stage / reset / preview / undo | gitsigns |
| `<leader>go` | open current line in GitHub | snacks.gitbrowse |

Diffview moves to `<leader>gv` to avoid collision with fugitive's `<leader>gd`. Gitsigns hunks live under `<leader>gh`. All other fugitive bindings retained verbatim from the existing config.

### UI module

Single module with 11 plugins; each in its own mkMerge block with intent comment.

- **`lualine`** replaces lightline. Sections: mode | branch+diff+diagnostics | filename | filetype+encoding+location.
- **`mini.tabline`** replaces bufferline.nvim (declared under `plugins.mini.modules.tabline`). Note: this is a feature downgrade — no buffer picker, no ordinal labels, no close-others/pin/etc. Accepted for mini-suite consistency.
- **`mini.icons`** — icons used by lualine, mini.tabline, oil, telescope (declared under `plugins.mini.modules.icons`). Must call `mini.icons.mock_nvim_web_devicons()` (configurable via `mock_nvim_web_devicons = true` in the mini.icons settings) so telescope/oil's expected `nvim-web-devicons` shim resolves to mini.icons. Set `plugins.web-devicons.enable = lib.mkForce false;` in the picker module to prevent double-icon-loading.
- **`fidget`** — LSP progress in the corner. **Pair with `plugins.noice.settings.lsp.progress.enabled = false;`** to avoid overlap with noice's built-in progress view (which is on by default).
- **`noice`** — cmdline / messages / notifications UI. LSP progress explicitly disabled (see fidget entry above).
- **`todo-comments`** — TODO/FIXME/HACK/NOTE highlighter + telescope picker (`:TodoTelescope`).
- **`render-markdown`** kept — inline markdown rendering. (External markdown preview deliberately not added; use `glow file.md` / `pandoc -o out.html` from the shell when fidelity is needed.)
- **`mini.indentscope`** — visual indent guides (declared under `plugins.mini.modules.indentscope`). Note: only highlights *current* scope, not all indents. If the user wants full indent guides, swap to indent-blankline.nvim in a follow-up.
- **`nvim-origami`** — folding (replaces nvim-ufo). LSP-aware with treesitter fallback; verified to implement folding, not just decoration.
- **`quicker.nvim`** — modern editable quickfix buffer.
- **`trouble.nvim`** — diagnostics list (was missing from the original spec list; bound to `<leader>x` in the which-key registry). Keymaps: `<leader>xx` toggle, `<leader>xd` document diagnostics, `<leader>xw` workspace diagnostics, `<leader>xl` location list, `<leader>xq` quickfix.

**Fold UI ownership:** snacks.statuscolumn (in the snacks module) and nvim-origami both touch the gutter's fold column. Resolve by setting `plugins.snacks.settings.statuscolumn.folds.open = false;` so origami owns the fold UI; statuscolumn handles signs/numbers/git only. Document this in the snacks block as well.

### DAP module

All four DAP plugins are **first-class in nixvim** (verified) — no extraPlugins needed:

- `plugins.dap.enable = true;`
- `plugins.dap-go.enable = true;`
- `plugins.dap-ui.enable = true;`
- `plugins.dap-virtual-text.enable = true;`
- `plugins.dap-python = { enable = true; adapterPythonPath = …; resolvePython = …; };`

**dap-python's two python knobs (don't conflate):**
- `adapterPythonPath` — the python that runs the *debugpy server*. Must have `debugpy` importable. Set to `"${pkgs.python3.withPackages (ps: [ps.debugpy])}/bin/python"` — a derivation pinned by the flake.
- `resolvePython` — Lua function string selecting the *debuggee* python per session. Default walks `$VIRTUAL_ENV`/`pyproject.toml`. Spec uses:
  ```nix
  plugins.dap-python.resolvePython = ''
    function()
      if vim.env.VIRTUAL_ENV then return vim.env.VIRTUAL_ENV .. '/bin/python' end
      return vim.fn.exepath('python3')
    end
  '';
  ```

**Cross-module dep declaration:** the neotest module's python adapter needs the same adapterPythonPath. Declare an option on the dap module so neotest can read it:

```nix
options.nixvimcfg.dap.pythonPath = lib.mkOption {
  type = lib.types.path;
  default = "${pkgs.python3.withPackages (ps: [ps.debugpy])}/bin/python";
  description = "Path to a python with debugpy. Shared with neotest-python.";
};
```

This is the one exception to the "only `.enable`" module convention. Document explicitly.

**For Rust:** configurations use `pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter` for codelldb (set via `plugins.dap.adapters.codelldb`).

**Keymaps under `<leader>d`** (single-letter leaves under leader+d, not bare letters):
- `<leader>db` toggle breakpoint
- `<leader>dB` conditional breakpoint
- `<leader>dc` continue / start
- `<leader>do` step over
- `<leader>di` step into
- `<leader>dO` step out
- `<leader>dr` open repl
- `<leader>du` toggle dap-ui
- `<leader>dq` terminate session

### Neotest module

- `plugins.neotest.enable` with adapters: `golang`, `python`, `rust`, `jest`, `vitest` (all first-class).
- For python: shares the debugpy python from the dap module by reading `config.nixvimcfg.dap.pythonPath` (the cross-module option declared in §DAP). Gated on `mkIf config.nixvimcfg.dap.enable` so if dap is disabled the python adapter doesn't break.

**Keymaps under `<leader>t`:**
- `<leader>tr` run nearest test
- `<leader>tf` run file
- `<leader>tl` run last
- `<leader>tt` run dir
- `<leader>ts` summary toggle
- `<leader>to` output toggle
- `<leader>tq` stop

### Snacks module

Single module exposing `snacks.nvim` with the following submodules in their own mkMerge blocks:

| Submodule | Purpose | Keymap / autoload |
|---|---|---|
| `bigfile` | Disable expensive features on large files | autoload |
| `statuscolumn` | Unified gutter (signs/numbers/folds/git) | autoload |
| `scratch` | Per-cwd persistent scratch buffers | `<leader>cs` |
| `words` | LSP-reference auto-highlight + `]]`/`[[` nav. Note: `]]`/`[[` may conflict with treesitter-textobjects defaults; if so, rebind one. | autoload |
| `toggle` | Toggles auto-registered into which-key under `<leader>o` (spell, wrap, diagnostics, inlay hints, line numbers, etc.) | which-key |
| `profiler` | Lua profiler with flame UI | `<leader>cp` start, `<leader>cP` stop |
| `bufdelete` | Close buffers without destroying window layout | `<leader>bd` |
| `rename` | LSP-aware file rename that updates imports | invoked via oil's actions |
| `gitbrowse` | "Open in GitHub" without rhubarb | `<leader>go` |

**statuscolumn fold ownership:** set `plugins.snacks.settings.statuscolumn.folds.open = false;` so nvim-origami owns the fold UI (see §UI module).
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

The work lands in phases. Each phase lands as **one commit on `major-upgrade`** (so `git revert <sha>` is the rollback). After each phase: run `nix flake check`; launch `nix run .`; exercise the phase's keymaps from the checklist in that phase's done-criteria.

1. **Unblock (~8 lines)** — drop `plugins.treesitter-refactor.*` (5 lines); rename `treesitter.folding = true` → `treesitter.folding.enable = true`; rewrite `treesitter.settings.highlight.enable` → `treesitter.highlight.enable`; delete the two stray `lsp.servers.rust_analyzer.*` lines (lines 41-42 of LSP module); bind `<leader>lr` to `vim.lsp.buf.rename` (replaces lost smartRename keymap). **Done:** `nix run .` succeeds with no eval errors or deprecation warnings. **Validation:** open a file, confirm syntax highlighting and folding still work.
2. **Internal refactor (survivors only) — no behavior change** — restructure existing modules into mkMerge blocks with `# === name ===` + `# WHY:` intent comments. Move from `nixvim-configurations/default.nix` into per-concern modules only the plugins that survive the migration (i.e. fugitive, render-markdown, telescope etc.). **Skip moving** plugins slated for deletion in later phases (lightline, vim-surround, comment, nvim-autopairs, bufferline) — they get deleted in-place at their replacement phase rather than relocated then deleted. **Done:** `nix derivation show` diff before/after shows no functional change.
3. **Which-key registry + `<leader>?` discovery** (was phase 11, moved up). Central key-group registry table + preset enablement + `delay = 200` + Telescope-builtin `<leader>?` bindings. **Land this BEFORE adding new plugins** so subsequent phases reference declared groups, not ad-hoc ones. **Done:** popping which-key shows the new prefix groups; `<leader>?k` opens telescope keymaps.
4. **Drop conform + expand LSP servers** — remove conform-nvim module and its extraPackages. Add hls, neocmake, ansiblels, ts_ls, lua_ls, marksman, harper_ls (with the prose-only narrowing per §LSP). **Done:** every new LSP attaches when opening a file of its language.
5. **Swap completion** — `plugins.cmp.*` → `plugins.blink-cmp.*` (first-class nixvim module — no extraPlugins). Wire luasnip + friendly-snippets + lazydev as blink sources. **Done:** completion menu pops in lua/python/nix files; cmdline `/` and `:` complete.
6. **Treesitter additions** — add `plugins.treesitter-textobjects.enable = true;` + declarative `grammarPackages`. **Done:** opening a file of each declared language shows highlights; textobject motions (`af`/`if` etc.) work.
7. **Swap UI primitives** — lightline → lualine, bufferline → mini.tabline (via `plugins.mini.modules.tabline`). Add fidget (with `noice.lsp.progress.enabled = false`), noice, todo-comments, mini.indentscope, mini.icons (with mock_nvim_web_devicons + force-disable picker's web-devicons), nvim-origami, quicker.nvim, **trouble.nvim**. Keep render-markdown. **Done:** statusline renders; cmdline overlay works; trouble opens.
8. **Swap editing primitives** — vim-surround → mini.surround, Comment.nvim → mini.comment (note: lose ts_context_commentstring for JSX/TSX — accept or add nvim-ts-context-commentstring), nvim-autopairs → mini.pairs. Add mini.ai, mini.move, flash, **harpoon (first-class) with package=harpoon2**, guess-indent, nvim-ts-autotag. **Done:** common editing motions work; flash `s` jumps; harpoon `<leader>ha` adds.
9. **File explorer** — add `plugins.oil.enable = true;`; remove `plugins.chadtree.enable = false;` line. **Done:** `<leader>e` opens oil at buffer's directory.
10. **Git enhancements** — add gitsigns, diffview (under `<leader>gv`, not `<leader>gd` per the keymap table), neogit. Keep fugitive. **Done:** gitsigns hunks in gutter; `:DiffviewOpen` works; `:Neogit` opens porcelain.
11. **DAP + neotest** — add both modules with **first-class** nixvim options for dap-ui/dap-python/dap-virtual-text (no extraPlugins). Declare the `nixvimcfg.dap.pythonPath` cross-module option. **Must land DAP before or with neotest** (neotest python adapter reads dap.pythonPath). **Done:** breakpoint toggles, debug session starts for a Go and a Python file; `:Neotest` summary toggles.
12. **Snacks adoption** — enable the 10 snacks submodules in order: bigfile, statuscolumn (with `folds.open = false`), quickfile, words (rebind `]]`/`[[` if treesitter-textobjects conflicts), toggle, bufdelete, rename, gitbrowse, scratch, profiler. **Done:** `<leader>o<delay>` shows toggle list; large file opens without lag.
13. **Typst preview** — add typst-preview.nvim module. **Done:** preview start/stop works on a `.typ` file.

**Phase ordering rules:**
- Phase 1 must come first.
- Phase 2 must come before any structural moves (3+).
- Phase 3 must come before phases 4-13 (so keymaps reference declared groups).
- Phase 11 (DAP) must come before or with neotest (cross-module dep).
- Phases 4, 5, 6, 7, 8, 9, 10, 12, 13 can be reordered within reason. They are independent.

**Validation gate after phase 8:** stop and daily-drive for at least a week before continuing. The editing primitive swaps have the highest muscle-memory cost; getting feedback from real use should inform whether to keep going or reverse course.

## Risks and unverified items

- **harpoon2 pin via nixpkgs** — nixpkgs ships `vimPlugins.harpoon2` as a branch snapshot. Risk: a `nix flake update` could move it to a breaking commit. Acceptable; covered by the normal flake-bump review cycle.
- **dap-python `adapterPythonPath` is bundled into the wrapper** — the editor's adapter python is fixed at flake.lock time, not the project's. Mitigation: `resolvePython` selects the *debuggee* python per-session from `$VIRTUAL_ENV` or PATH, so the user's project python still runs the actual code; only the debugpy adapter is pinned. debugpy is python-3.x ABI-tolerant in practice.
- **harper_ls false-positive rate** — defaults are noisy on code identifiers. The `SpellCheck` filetype restriction (markdown/text/gitcommit only) and `SentenceCapitalization` disable should handle most of it. Side-effect: harper does NOT check Python docstrings, Rust/Go doc comments, or Lua comments. If the user wants prose-checking in code comments, expand the filetype list.
- **`mini.tabline` vs `bufferline.nvim` feature gap** — no buffer picker, no ordinal labels, no close-others/pin operations. Accepted for mini-suite consistency; revisit if missed.
- **mini.comment loses ts_context_commentstring** — JSX/TSX/Astro nested commentstring switching gone. If JSX commenting feels wrong, add `nvim-ts-context-commentstring` alongside mini.comment in a follow-up.
- **mini.surround default mappings differ from vim-surround** — `sa`/`sd`/`sr` vs `ys`/`cs`/`ds`. If muscle-memory friction is high, swap to compat mappings (snippet in §Editing).
- **`nvim-treesitter-locals` is not first-class in nixvim** — would require extraPlugins. Excluded from the design; the lost `treesitter-refactor` features are covered by LSP + snacks.words. Revisit if there's a real gap.
- **Lost `treesitter-refactor.highlightDefinitions`** — snacks.words is the closest substitute. Behavior differs slightly; revisit if missed.
- **lazydev gap in nix-embedded Lua** — `extraConfigLua = ''…''` blocks inside `.nix` files don't trigger lua_ls/lazydev. Mitigation: extract large Lua into `.lua` files imported via `lib.fileContents`. For inline snippets, accept no completion.
- **Format-on-save lost outside devShell** — dropping conform-nvim means a freshly-cloned repo with no `direnv allow` has no editor-side format-on-save for non-LSP-formatted languages. Accepted; user runs `direnv allow` or formats from shell.
- **mini.modules vs standalone plugins.mini-* shape mismatch** — design uses the `plugins.mini.modules` shape exclusively. Spec verified that submodule type permits cross-file merging. Risk: if a future addition uses the standalone `plugins.mini-tabline` shape by mistake, mini.nvim could double-register. Catch in code review.
- **`<leader>g` collisions** — addressed by moving diffview to `<leader>gv` and gitsigns hunks under `<leader>gh`. Verify after phase 10 that `<leader>gd` (fugitive diff) still works.
- **Telescope's web-devicons vs mini.icons** — addressed by `mini.icons.mock_nvim_web_devicons = true` + `plugins.web-devicons.enable = lib.mkForce false` in picker module. Verify after phase 7 that telescope/oil show correct icons.
- **snacks.statuscolumn vs nvim-origami fold UI** — addressed by `statuscolumn.folds.open = false`. Verify after phase 12 that fold indicators render once, not twice.
- **kanagawa colorscheme highlight gaps** — kanagawa may not define `MiniIndentscope*`, `RenderMarkdownH{1..6}Bg`, `Noice*` highlight groups. If sections render with default/jarring colors after phase 7/12, add a `colorscheme overrides` block setting `vim.api.nvim_set_hl` for the missing groups, or switch colorscheme (tokyonight, catppuccin both have explicit support).

## Out of scope

- AI / LLM integration (codecompanion, copilot, avante).
- `nvim-treesitter-locals` (decided against; covered by LSP + snacks.words).
- Replacing telescope with snacks.picker or fzf-lua.
- Replacing noice with snacks.notifier (overlap exists but noice is more feature-complete).
- A startup dashboard (alpha/mini.starter/snacks.dashboard) — user opens projects via CLI.
- Terminal integration (toggleterm/snacks.terminal) — user uses an external shell.
- A formatter dispatcher replacement (efm-langserver, none-ls, nvim-lint).
- Migration of `nixvim-configurations/default.nix` `opts` / `globals` / `colorschemes` — these stay as-is.

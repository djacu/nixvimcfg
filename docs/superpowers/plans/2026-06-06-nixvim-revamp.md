# nixvim revamp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix nixvim 26.11 evaluation errors, restructure the module layout into intent-grouped mkMerge blocks, and add productivity plugins per `docs/superpowers/specs/2026-06-06-nixvim-revamp-design.md`.

**Architecture:** 14 modules under `nixvim-modules/` each exposing a single `nixvimcfg.<name>.enable` option, with `mkMerge` blocks paired by intent (`# === name ===` header + `# WHY:` comment). `nixvim-configurations/default.nix` becomes a switchboard of enable flags. Migration lands as 13 phases on the `major-upgrade` branch, one commit per phase, with `nix flake check` + `nix run .` as the validation gate after each.

**Tech Stack:** Nix (flakes), nixvim, Neovim 0.12+, treesitter main-branch, blink.cmp v1, mini.nvim suite, snacks.nvim, neogit, gitsigns, diffview, oil.nvim, flash.nvim, harpoon2, nvim-dap, neotest, telescope.

**Reference docs in this repo:**
- Spec: `docs/superpowers/specs/2026-06-06-nixvim-revamp-design.md`
- Existing config: `nixvim-modules/`, `nixvim-configurations/default.nix`

---

## Pre-flight

- [ ] **Step P1: Confirm working state**

Run: `git status && git branch --show-current`
Expected: branch is `major-upgrade`, working tree may contain `flake.lock` / `flake.nix` modifications but no other dirty files. The spec docs are committed.

- [ ] **Step P2: Confirm spec is committed**

Run: `git log --oneline major-upgrade -5`
Expected: see commits for the design spec (initial + revisions). At minimum: `641e6b6 docs: drop fugitive, expand neogit keymaps`, `3aa0571 docs: revise spec from adversarial review`, `e4f54e1 docs: add nixvim revamp design spec`.

- [ ] **Step P3: Verify the current build fails as expected**

Run: `nix run 2>&1 | head -30`
Expected: evaluation warnings about `nvim-treesitter-legacy`, four `treesitter-refactor.*` rename warnings, and the hard error "You cannot include two different versions of nvim-treesitter".

---

## Phase 1 — Unblock

**Phase goal:** Get `nix run .` succeeding with the existing plugin set. No structural change.

### Task 1: Drop `plugins.treesitter-refactor` and fix treesitter option syntax

**Files:**
- Modify: `nixvim-modules/treesitter/default.nix`

- [ ] **Step 1: Open the file and delete `treesitter-refactor` lines**

Edit `nixvim-modules/treesitter/default.nix`. Delete these five lines from inside the first mkMerge block:

```nix
plugins.treesitter-refactor.enable = true;
plugins.treesitter-refactor.highlightCurrentScope.enable = false;
plugins.treesitter-refactor.highlightDefinitions.enable = true;
plugins.treesitter-refactor.navigation.enable = true;
plugins.treesitter-refactor.smartRename.enable = true;
```

- [ ] **Step 2: Fix the `highlight.enable` option path**

In the same file, change:

```nix
plugins.treesitter.settings.highlight.enable = true;
```

to:

```nix
plugins.treesitter.highlight.enable = true;
```

- [ ] **Step 3: Fix the `folding` option syntax**

In the same file, change:

```nix
plugins.treesitter.folding = true;
```

to:

```nix
plugins.treesitter.folding.enable = true;
```

- [ ] **Step 4: Verify with `nix flake check`**

Run: `nix flake check 2>&1 | tail -30`
Expected: succeeds with no errors. Deprecation warnings about treesitter-refactor option renames should be gone.

### Task 2: Delete the two stray `lsp.servers.rust_analyzer.*` lines

**Files:**
- Modify: `nixvim-modules/lsp/default.nix`

- [ ] **Step 1: Read the file to confirm the bogus lines**

Run: `grep -n "lsp.servers.rust_analyzer" nixvim-modules/lsp/default.nix`
Expected: lines 41-42 show:
```
41:    lsp.servers.rust_analyzer.enable = true;
42:    lsp.servers.rust_analyzer.packageFallback = true;
```
These are missing the `plugins.` prefix and define stray top-level option paths.

- [ ] **Step 2: Delete lines 41-42**

Edit `nixvim-modules/lsp/default.nix`. Delete the two lines above. The correctly-prefixed `plugins.lsp.servers.rust_analyzer.*` lines immediately below (43-46) remain.

- [ ] **Step 3: Verify**

Run: `grep -n "lsp.servers.rust_analyzer" nixvim-modules/lsp/default.nix`
Expected: only the four `plugins.lsp.servers.rust_analyzer.*` lines remain (no top-level `lsp.servers.*` lines).

### Task 3: Pre-bind `<leader>lr` to `vim.lsp.buf.rename` (replacement for lost treesitter-refactor.smartRename)

**Files:**
- Modify: `nixvim-modules/lsp/default.nix`

- [ ] **Step 1: Add a which-key spec entry for `<leader>lr`**

At the bottom of the existing `config = lib.mkIf cfg.enable { ... }` block in `nixvim-modules/lsp/default.nix`, just before the closing brace, add:

```nix
    # === <leader>l LSP keymap leaves ===
    # WHY: lsp module owns <leader>l prefix; smartRename from treesitter-refactor
    # is now provided by vim.lsp.buf.rename, bound here so the keymap doesn't dangle.
    keymaps = [
      {
        mode = "n";
        key = "<leader>lr";
        action.__raw = "function() vim.lsp.buf.rename() end";
        options.desc = "LSP rename";
      }
    ];
```

If `keymaps = [ ... ];` already exists, append to its list.

- [ ] **Step 2: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds with no errors.

### Task 4: Smoke test the build

- [ ] **Step 1: Launch the editor**

Run: `nix run . -- --version`
Expected: prints `NVIM v0.12.x` and nothing on stderr indicating eval problems.

- [ ] **Step 2: Open a nix file and confirm highlighting works**

Run: `nix run . -- flake.nix`
Inside nvim, confirm syntax highlighting is on (you should see keyword/string/number colors). Press `:q` to exit.

- [ ] **Step 3: Confirm `<leader>lr` is bound**

Run: `nix run . -- flake.nix`
Inside nvim, press `<space>` then `l`, wait briefly for which-key to pop up, see `r LSP rename`. Press `<Esc><Esc>:q<CR>`.

### Task 5: Commit Phase 1

- [ ] **Step 1: Stage changes**

Run: `git add nixvim-modules/treesitter/default.nix nixvim-modules/lsp/default.nix`

- [ ] **Step 2: Commit**

Run:
```bash
git commit -m "$(cat <<'EOF'
fix: unblock nixvim 26.11 evaluation

- Drop plugins.treesitter-refactor.* (archived upstream; transitively
  pulled in nvim-treesitter-legacy alongside the new main-branch
  treesitter, triggering the "two different versions" hard error).
- Rewrite plugins.treesitter.settings.highlight.enable to the
  top-level plugins.treesitter.highlight.enable.
- Rewrite plugins.treesitter.folding = true (deprecated boolean form)
  to plugins.treesitter.folding.enable = true.
- Delete stray lsp.servers.rust_analyzer.{enable,packageFallback}
  lines that lacked the plugins. prefix.
- Bind <leader>lr to vim.lsp.buf.rename to replace the lost
  treesitter-refactor.smartRename keymap.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 3: Verify**

Run: `git log --oneline -1`
Expected: commit on `major-upgrade`, subject starts `fix: unblock nixvim 26.11 evaluation`.

---

## Phase 2 — Internal refactor (survivors only)

**Phase goal:** Restructure surviving modules into mkMerge blocks with intent comments. No new plugins, no deletions of plugins slated for later removal.

**Surviving modules to refactor:** `lsp/`, `treesitter/`, `telescope/` → `picker/`, `cmp/` → kept but will be replaced in phase 5, `which-key/`, `render-markdown/` → folded into future ui, `fugitive/` will be deleted in phase 10 (don't touch).

**Strategy:** rename `telescope/` directory to `picker/`, restructure `lsp/` and `treesitter/` with mkMerge blocks. Leave `cmp/`, `render-markdown/`, `fugitive/` in place — they will be deleted at their replacement phase.

### Task 6: Rename `telescope/` directory to `picker/`

**Files:**
- Rename: `nixvim-modules/telescope/` → `nixvim-modules/picker/`
- Modify: `nixvim-configurations/default.nix`
- Modify: `nixvim-modules/picker/default.nix` (after rename)

- [ ] **Step 1: Rename the directory**

Run: `git mv nixvim-modules/telescope nixvim-modules/picker`

- [ ] **Step 2: Rename the option in the module**

Edit `nixvim-modules/picker/default.nix`. Change every reference to `nixvimcfg.telescope` to `nixvimcfg.picker`. There should be 2 references (one in `options`, one in `let cfg = config...`).

After edit, verify:
```bash
grep -n "nixvimcfg\." nixvim-modules/picker/default.nix
```
Expected: only `nixvimcfg.picker` references.

- [ ] **Step 3: Update the enable flag in the top-level config**

Edit `nixvim-configurations/default.nix`. Change:
```nix
nixvimcfg.telescope.enable = true;
```
to:
```nix
nixvimcfg.picker.enable = true;
```

- [ ] **Step 4: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 7: Refactor `picker/` into intent-grouped mkMerge blocks

**Files:**
- Modify: `nixvim-modules/picker/default.nix`

- [ ] **Step 1: Rewrite the module with mkMerge intent blocks**

Replace the body of `nixvim-modules/picker/default.nix` with:

```nix
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.nixvimcfg.picker;
in
{
  options.nixvimcfg.picker.enable = lib.mkEnableOption "telescope picker + extensions";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === telescope core ===
      # WHY: the picker engine itself; everything else extends it.
      {
        plugins.telescope.enable = true;
        extraPackages = with pkgs; [ fd ];
      }

      # === mini.nvim shim for icons ===
      # WHY: telescope expects nvim-web-devicons; mini.icons mocks it
      # via mock_nvim_web_devicons so we don't double-load icon packages.
      # See ui module for the actual mini.icons configuration.
      { plugins.mini.enable = true; }

      # === extension: file-browser ===
      # WHY: file ops from inside the picker (rename/delete/create).
      {
        plugins.telescope.extensions.file-browser.enable = true;
      }

      # === extension: frecency ===
      # WHY: smart ordering of MRU + frequency.
      { plugins.telescope.extensions.frecency.enable = true; }

      # === extension: fzf-native ===
      # WHY: faster matcher (C implementation) for large repos.
      { plugins.telescope.extensions.fzf-native.enable = true; }

      # === extension: media-files ===
      # WHY: preview images/PDFs/videos inside telescope. Requires
      # poppler-utils (PDF), imagemagick (image conv), ffmpegthumbnailer
      # (video frames), epub-thumbnailer (epubs), chafa (terminal display),
      # fontpreview (font files), fd (find binary).
      {
        plugins.telescope.extensions.media-files.enable = true;
        plugins.telescope.extensions.media-files.settings.filetypes = [
          "png" "jpg" "gif" "mp4" "webm" "pdf" "svg"
        ];
        plugins.telescope.extensions.media-files.settings.find_cmd = "fd";

        dependencies.poppler-utils.enable = true;
        dependencies.imagemagick.enable = true;
        dependencies.fontpreview.enable = true;
        dependencies.ffmpegthumbnailer.enable = true;
        dependencies.epub-thumbnailer.enable = true;
        dependencies.chafa.enable = true;
      }

      # === which-key leaves under <leader>f ===
      # WHY: keymaps for the picker live with the picker; the <leader>f
      # group prefix is declared in the central which-key registry.
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>fb"; __unkeyed-2 = "<cmd>Telescope file_browser<cr>"; desc = "File Browser"; }
          { __unkeyed-1 = "<leader>ff"; __unkeyed-2 = "<cmd>Telescope find_files<cr>"; desc = "Find File"; }
          { __unkeyed-1 = "<leader>fl"; __unkeyed-2 = "<cmd>Telescope live_grep<cr>"; desc = "Live Grep"; }
          { __unkeyed-1 = "<leader>fm"; __unkeyed-2 = "<cmd>Telescope media_files<cr>"; desc = "Open Media File"; }
          { __unkeyed-1 = "<leader>fr"; __unkeyed-2 = "<cmd>Telescope oldfiles<cr>"; desc = "Open Recent File"; }
          { __unkeyed-1 = "<leader>ft"; __unkeyed-2 = "<cmd>Telescope<cr>"; desc = "Telescope (all)"; }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds, no warnings.

### Task 8: Refactor `lsp/` into intent-grouped mkMerge blocks (no new servers yet)

**Files:**
- Modify: `nixvim-modules/lsp/default.nix`

- [ ] **Step 1: Rewrite the module body**

Replace the body of `nixvim-modules/lsp/default.nix` (preserving the current LSP server set, the rust_analyzer config, and the `<leader>lr` keymap added in phase 1) with:

```nix
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.lsp;
in
{
  options.nixvimcfg.lsp.enable = lib.mkEnableOption "lsp setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === lsp core ===
      # WHY: the nvim-lsp plugin itself, with per-server enables below.
      { plugins.lsp.enable = true; }

      # === web ===
      # WHY: front-end stack — astro file framework, eslint linter,
      # CSS, HTML, tailwind classes.
      {
        plugins.lsp.servers.astro.enable = true;
        plugins.lsp.servers.cssls.enable = true;
        plugins.lsp.servers.eslint.enable = true;
        plugins.lsp.servers.html.enable = true;
        plugins.lsp.servers.tailwindcss.enable = true;
      }

      # === scripts and config ===
      # WHY: bash + structured-data formats the user works in daily.
      {
        plugins.lsp.servers.bashls.enable = true;
        plugins.lsp.servers.jsonls.enable = true;
        plugins.lsp.servers.taplo.enable = true;   # TOML
        plugins.lsp.servers.yamlls.enable = true;
      }

      # === Go ===
      # WHY: gopls + golangci-lint LSP. golangci-lint binary is bundled
      # via extraPackages because golangci_lint_ls invokes it as a CLI.
      {
        plugins.lsp.servers.gopls.enable = true;
        plugins.lsp.servers.golangci_lint_ls.enable = true;
        extraPackages = [ pkgs.golangci-lint ];
      }

      # === Rust ===
      # WHY: rust-analyzer with bundled cargo/rustc/rustfmt so the editor
      # is self-contained.
      {
        plugins.lsp.servers.rust_analyzer.enable = true;
        plugins.lsp.servers.rust_analyzer.installCargo = true;
        plugins.lsp.servers.rust_analyzer.installRustc = true;
        plugins.lsp.servers.rust_analyzer.installRustfmt = true;
      }

      # === Python ===
      # WHY: ruff is the modern combined linter/formatter for Python.
      { plugins.lsp.servers.ruff.enable = true; }

      # === Nix ===
      # WHY: nixd for options completion and evaluation-based features.
      # nil_ls intentionally not enabled — nixd is the modern choice.
      { plugins.lsp.servers.nixd.enable = true; }

      # === Typst / LaTeX ===
      # WHY: typst via tinymist; LaTeX via texlab.
      {
        plugins.lsp.servers.tinymist.enable = true;
        plugins.lsp.servers.texlab.enable = true;
      }

      # === prose checking ===
      # WHY: typos catches misspellings in identifiers/comments.
      { plugins.lsp.servers.typos_lsp.enable = true; }

      # === <leader>l LSP keymap leaves ===
      # WHY: lsp module owns <leader>l prefix; smartRename from
      # treesitter-refactor is now provided by vim.lsp.buf.rename.
      {
        keymaps = [
          {
            mode = "n";
            key = "<leader>lr";
            action.__raw = "function() vim.lsp.buf.rename() end";
            options.desc = "LSP rename";
          }
        ];
      }

    ]
  );
}
```

- [ ] **Step 2: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

- [ ] **Step 3: Smoke test that LSPs still attach**

Run: `nix run . -- flake.nix`
Inside nvim: `:LspInfo` should show `nixd` attached. `:q` to exit.

### Task 9: Refactor `treesitter/` into intent-grouped mkMerge blocks

**Files:**
- Modify: `nixvim-modules/treesitter/default.nix`

- [ ] **Step 1: Rewrite the module body**

Replace `nixvim-modules/treesitter/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.treesitter;
in
{
  options.nixvimcfg.treesitter.enable = lib.mkEnableOption "treesitter setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === treesitter core ===
      # WHY: the main-branch nvim-treesitter rewrite. Highlighting and
      # folding configured via top-level options (not under settings.)
      # which the new module routes through vim.treesitter.start /
      # vim.treesitter.foldexpr.
      {
        plugins.treesitter.enable = true;
        plugins.treesitter.highlight.enable = true;
        plugins.treesitter.folding.enable = true;

        extraConfigLua = ''
          vim.opt.foldenable = false
        '';
      }

      # === treesitter-context ===
      # WHY: sticky scope display at top of buffer. Branch-agnostic, no
      # dependency on legacy treesitter. Previous config disabled this
      # via settings.enable = false (made the plugin inert) — fixed here.
      {
        plugins.treesitter-context.enable = true;
        plugins.treesitter-context.settings.trim_scope = "outer";
      }

      # === which-key leaves under <leader>t ===
      # WHY: treesitter context toggle keymap. (<leader>t group prefix
      # is registered in the which-key module — and yes, <leader>t will
      # be reassigned to "Test" in phase 11; that's a planned future
      # collision we'll resolve there. For now this is what current
      # config has.)
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>tc";
            __unkeyed-2 = "<cmd>TSContextToggle<cr>";
            desc = "Context Toggle";
          }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Verify**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 10: Commit Phase 2

- [ ] **Step 1: Verify final state**

Run: `nix run . -- --version 2>&1 | head -3`
Expected: prints `NVIM v0.12.x`, no errors.

- [ ] **Step 2: Stage and commit**

Run:
```bash
git add nixvim-modules/picker nixvim-modules/lsp/default.nix nixvim-modules/treesitter/default.nix nixvim-configurations/default.nix
git status  # verify no other files
git commit -m "$(cat <<'EOF'
refactor(nixvim-modules): restructure surviving modules into mkMerge intent blocks

- Rename telescope/ -> picker/; restructure into per-extension mkMerge
  blocks pairing each extension with its required packages.
- lsp/: regroup servers by domain (web / scripts / Go / Rust / Python /
  Nix / Typst+LaTeX / prose); keymap entry block; intent comments.
- treesitter/: collapse into core + context + which-key blocks; remove
  the inert settings.enable = false from treesitter-context.

No behavior change intended. The plugins enabled and their settings
remain identical to phase 1 state.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 3 — Which-key registry overhaul + `<leader>?` discovery

**Phase goal:** Land the central key-group registry, preset enablement, snappy delay, and Telescope-built-in discovery bindings BEFORE adding new plugins (so subsequent phases reference declared prefixes).

### Task 11: Rewrite `which-key/` with central registry

**Files:**
- Modify: `nixvim-modules/which-key/default.nix`

- [ ] **Step 1: Replace the module**

Replace `nixvim-modules/which-key/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.which-key;
in
{
  options.nixvimcfg.which-key.enable = lib.mkEnableOption "which-key setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === which-key core + delay tuning ===
      # WHY: 200ms popup delay (previous timeoutlen=100 fired before
      # multi-key sequences finished).
      {
        plugins.which-key.enable = true;
        plugins.which-key.settings.show_keys = true;
        plugins.which-key.settings.delay = 200;
      }

      # === presets ===
      # WHY: auto-document built-in keys (registers, marks, windows,
      # z-commands, operators, motions, text-objects).
      {
        plugins.which-key.settings.preset = "modern";
        plugins.which-key.settings.plugins = {
          marks = true;
          registers = true;
          presets = {
            operators = true;
            motions = true;
            text_objects = true;
            windows = true;
            nav = true;
            z = true;
            g = true;
          };
        };
      }

      # === central key-group registry ===
      # WHY: every <leader>X group prefix declared here exactly once.
      # Individual plugin modules append their leaf keymaps; the group
      # labels live here so there's a single grep target.
      {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>?"; group = " Discover"; }
          { __unkeyed-1 = "<leader>a"; group = " Aerial"; }
          { __unkeyed-1 = "<leader>b"; group = " Buffer"; }
          { __unkeyed-1 = "<leader>c"; group = " Code"; }
          { __unkeyed-1 = "<leader>d"; group = " Debug"; }
          { __unkeyed-1 = "<leader>e"; group = " Explore"; }
          { __unkeyed-1 = "<leader>f"; group = " Find"; }
          { __unkeyed-1 = "<leader>g"; group = " Git"; }
          { __unkeyed-1 = "<leader>gh"; group = " Hunks"; }
          { __unkeyed-1 = "<leader>h"; group = "ﯬ Harpoon"; }
          { __unkeyed-1 = "<leader>l"; group = " LSP"; }
          { __unkeyed-1 = "<leader>m"; group = " Markdown"; }
          { __unkeyed-1 = "<leader>n"; group = " Notifications"; }
          { __unkeyed-1 = "<leader>o"; group = " Toggle"; }
          { __unkeyed-1 = "<leader>s"; group = " Search/Replace"; }
          { __unkeyed-1 = "<leader>t"; group = " Test"; }
          { __unkeyed-1 = "<leader>w"; group = "WhichKey"; }
          { __unkeyed-1 = "<leader>x"; group = " Trouble"; }
        ];
      }

      # === <leader>? discovery namespace ===
      # WHY: this directly serves the user's stated "I always am unsure
      # how to use plugins" pain — Telescope built-ins expose every
      # registered keymap, command, and help tag.
      {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>?k"; __unkeyed-2 = "<cmd>Telescope keymaps<cr>"; desc = "Keymaps"; }
          { __unkeyed-1 = "<leader>?c"; __unkeyed-2 = "<cmd>Telescope commands<cr>"; desc = "Commands"; }
          { __unkeyed-1 = "<leader>?h"; __unkeyed-2 = "<cmd>Telescope help_tags<cr>"; desc = "Help Tags"; }
          { __unkeyed-1 = "<leader>?t"; __unkeyed-2 = "<cmd>Telescope builtin<cr>"; desc = "Telescope builtins"; }
          { __unkeyed-1 = "<leader>?p"; __unkeyed-2 = "<cmd>Telescope<cr>"; desc = "Pick a picker"; }
          { __unkeyed-1 = "<leader>w"; __unkeyed-2 = "<cmd>WhichKey<cr>"; desc = "WhichKey?!"; }
        ];
      }

    ]
  );
}
```

- [ ] **Step 2: Verify**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 12: Smoke test which-key behavior

- [ ] **Step 1: Open editor, trigger which-key popup**

Run: `nix run . -- flake.nix`
Press `<space>` (leader). After ~200ms, which-key popup appears showing all the registered prefix groups (Discover, Aerial, Buffer, etc.).

- [ ] **Step 2: Test `<leader>?k`**

In the same session, press `<space>?k`. Telescope keymaps picker opens listing every active keymap with descriptions. `<Esc><Esc>:q<CR>` to exit.

### Task 13: Commit Phase 3

- [ ] **Step 1: Stage and commit**

Run:
```bash
git add nixvim-modules/which-key/default.nix
git commit -m "$(cat <<'EOF'
feat(which-key): central key-group registry, presets, <leader>? discovery

- Declare every <leader>X group prefix once in the which-key module so
  there's a single grep target. Subsequent phases that add plugins
  reference these prefixes; they don't define their own group labels.
- Enable v3 presets (marks/registers/windows/z/g + operators/motions/
  text-objects) so built-in keys are auto-documented.
- Tune popup delay to 200ms (vs previous timeoutlen=100, which fired
  before multi-key sequences finished).
- Bind <leader>? to Telescope built-in pickers (keymaps/commands/
  help_tags/builtin) — directly addresses the user's "unsure how to
  use plugins" pain by making every registered keymap fuzzy-searchable.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 4 — Drop conform + expand LSP servers

**Phase goal:** Remove the conform-nvim module entirely (per Option 3 in the spec — no formatter dispatcher; rely on LSP formatting + project shell tooling). Add seven new LSP servers.

### Task 14: Delete the conform-nvim module

**Files:**
- Delete: `nixvim-modules/conform-nvim/`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Remove the directory**

Run: `git rm -r nixvim-modules/conform-nvim`

- [ ] **Step 2: Remove the enable flag**

Edit `nixvim-configurations/default.nix`. Delete the line:
```nix
nixvimcfg.conform-nvim.enable = true;
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds. Editor no longer ships with prettierd/prettier/nixfmt/etc. bundled.

### Task 15: Add the new LSP servers to `lsp/`

**Files:**
- Modify: `nixvim-modules/lsp/default.nix`

- [ ] **Step 1: Add new mkMerge blocks for the new servers**

Append the following mkMerge blocks inside `nixvim-modules/lsp/default.nix`'s `lib.mkMerge [ ... ]` list, before the closing `]`:

```nix
      # === Haskell ===
      # WHY: user is starting Haskell. hls is the only real option.
      { plugins.lsp.servers.hls.enable = true; }

      # === CMake ===
      # WHY: occasional reading of CMake files. neocmake is the modern
      # successor to the older cmake LSP.
      { plugins.lsp.servers.neocmake.enable = true; }

      # === Ansible ===
      # WHY: occasional playbook editing. Catches YAML schema errors.
      { plugins.lsp.servers.ansiblels.enable = true; }

      # === TypeScript / JavaScript ===
      # WHY: gap in current setup — eslint LSP is a linter, not a
      # navigation/hover language server. ts_ls covers plain .ts/.tsx/.js.
      { plugins.lsp.servers.ts_ls.enable = true; }

      # === Lua ===
      # WHY: lua_ls + lazydev for completion when editing inline Lua.
      # Lazydev only fires on lua filetypes (not on inline Lua inside
      # .nix files); extract nontrivial Lua to .lua files via
      # lib.fileContents to get completion there.
      {
        plugins.lsp.servers.lua_ls.enable = true;
        plugins.lazydev.enable = true;
      }

      # === Markdown ===
      # WHY: link/heading completion for markdown files. Pairs with
      # render-markdown for the visual side.
      { plugins.lsp.servers.marksman.enable = true; }

      # === English grammar (prose) ===
      # WHY: harper_ls catches grammar errors in prose. SpellCheck rule
      # narrowed to markdown/text/gitcommit filetypes so it doesn't
      # flag code identifiers. SentenceCapitalization disabled to
      # reduce noise on terse docs.
      {
        plugins.lsp.servers.harper_ls.enable = true;
        plugins.lsp.servers.harper_ls.settings = {
          "harper-ls" = {
            linters.SentenceCapitalization = false;
            fileDictPath = null;
          };
          # SpellCheck only runs on these filetypes; harper still
          # parses code files but skips spell-checking identifiers.
          filetypes = [ "markdown" "text" "gitcommit" ];
        };
      }
```

- [ ] **Step 2: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 16: Smoke test the new LSPs

- [ ] **Step 1: Make a Lua file to test lua_ls + lazydev**

Run:
```bash
mkdir -p /tmp/lsp-smoke
echo 'local x = vim.api' > /tmp/lsp-smoke/test.lua
nix run . -- /tmp/lsp-smoke/test.lua
```

Inside nvim, the cursor is after `vim.api`. Press `<C-x><C-o>` (omnifunc completion) — completion menu shows nvim API functions. `:LspInfo` lists `lua_ls` attached. `:q` to exit.

- [ ] **Step 2: Test ts_ls**

Run:
```bash
echo 'const x: number = 1' > /tmp/lsp-smoke/test.ts
nix run . -- /tmp/lsp-smoke/test.ts
```

Inside nvim, `:LspInfo` shows `ts_ls` attached. `:q`.

- [ ] **Step 3: Cleanup**

Run: `rm -rf /tmp/lsp-smoke`

### Task 17: Commit Phase 4

- [ ] **Step 1: Stage and commit**

Run:
```bash
git add nixvim-modules/lsp/default.nix nixvim-configurations/default.nix
git status  # confirm conform-nvim/ removal is staged
git commit -m "$(cat <<'EOF'
feat(lsp): drop conform-nvim, expand LSP server set

- Remove the conform-nvim module and its bundled formatter packages.
  Format-on-save now comes from LSP-side formatting (gopls / rust-
  analyzer / ruff / tinymist / nixd-via-...) where supported; for
  languages without LSP formatting, run formatters from the project's
  shell. Avoids the version-mismatch problem nixvim's wrapper PATH
  precedence makes unsolvable cleanly.
- Add LSP servers: hls (Haskell), neocmake (CMake), ansiblels (Ansible),
  ts_ls (TypeScript/JavaScript — gap), lua_ls + lazydev (Lua + nvim
  runtime types), marksman (Markdown), harper_ls (English grammar,
  scoped to markdown/text/gitcommit to avoid flagging code identifiers).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 5 — Swap completion: nvim-cmp → blink.cmp

**Phase goal:** Replace the cmp module with a new completion module backed by blink.cmp v1 (first-class in nixvim).

### Task 18: Delete the old cmp module

**Files:**
- Delete: `nixvim-modules/cmp/`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Remove the directory**

Run: `git rm -r nixvim-modules/cmp`

- [ ] **Step 2: Remove the enable flag**

Edit `nixvim-configurations/default.nix`. Delete:
```nix
nixvimcfg.cmp.enable = true;
```

- [ ] **Step 3: Verify build still works (no completion yet)**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds. Editor has no completion engine at this point — that's OK, we add blink next.

### Task 19: Create the new `completion/` module

**Files:**
- Create: `nixvim-modules/completion/default.nix`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the module**

Create `nixvim-modules/completion/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.completion;
in
{
  options.nixvimcfg.completion.enable = lib.mkEnableOption "blink.cmp + snippets";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === snippets ===
      # WHY: luasnip is the snippet engine; friendly-snippets is the
      # canonical collection of pre-made snippets. blink.cmp consumes
      # both natively via its snippets source.
      {
        plugins.luasnip.enable = true;
        plugins.friendly-snippets.enable = true;
      }

      # === blink.cmp ===
      # WHY: modern completion engine. First-class in nixvim (no
      # extraPlugins). nixpkgs ships the prebuilt Rust fuzzy-matcher
      # binary as part of the derivation.
      {
        plugins.blink-cmp.enable = true;
        plugins.blink-cmp.settings = {
          keymap.preset = "default";
          completion.documentation.auto_show = true;
          completion.documentation.auto_show_delay_ms = 200;
        };
      }

      # === sources ===
      # WHY: order matters — lazydev first so Lua files get nvim-runtime
      # completion before generic LSP fallbacks. lazydev integrates as a
      # blink source, not via lazydev.settings.integrations (which only
      # has cmp/coq keys).
      {
        plugins.blink-cmp.settings.sources.default = [
          "lazydev"
          "lsp"
          "snippets"
          "path"
          "buffer"
        ];
        plugins.blink-cmp.settings.sources.providers.lazydev = {
          name = "LazyDev";
          module = "lazydev.integrations.blink";
          score_offset = 100;
        };
      }

      # === cmdline completion ===
      # WHY: completion in : (command) and / (search) modes.
      {
        plugins.blink-cmp.settings.cmdline.enabled = true;
      }

    ]
  );
}
```

- [ ] **Step 2: Enable the module in the top-level config**

Edit `nixvim-configurations/default.nix`. Add (alphabetically-ordered with the other enables):

```nix
nixvimcfg.completion.enable = true;
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 20: Smoke test completion

- [ ] **Step 1: Test LSP completion in a Lua file**

Run:
```bash
mkdir -p /tmp/blink-smoke
echo 'vim.api.' > /tmp/blink-smoke/t.lua
nix run . -- /tmp/blink-smoke/t.lua
```

Inside nvim, position cursor after `vim.api.`. Press `i` to enter insert mode. After a moment, completion menu pops automatically (or press `<C-space>`). You see nvim API completions. Press `<Esc>:q!<CR>` to exit.

- [ ] **Step 2: Test cmdline completion**

Run: `nix run . -- flake.nix`
Inside nvim, press `:` and start typing `che`. After a moment, completion menu suggests `checkhealth` etc. `<Esc>:q<CR>`.

- [ ] **Step 3: Cleanup**

Run: `rm -rf /tmp/blink-smoke`

### Task 21: Commit Phase 5

- [ ] **Step 1: Stage and commit**

Run:
```bash
git add nixvim-modules/completion nixvim-configurations/default.nix
git status  # confirm cmp/ removal is staged
git commit -m "$(cat <<'EOF'
feat(completion): swap nvim-cmp for blink.cmp v1

- Delete nixvim-modules/cmp/ (nvim-cmp).
- Create nixvim-modules/completion/ with blink.cmp v1 (first-class
  nixvim module — no extraPlugins / extraConfigLua glue). Sources:
  lazydev, lsp, snippets, path, buffer in that priority order.
- lazydev integrates as a blink source via sources.providers.lazydev
  (lazydev's own settings.integrations only exposes cmp/coq keys).
- Cmdline completion enabled for both : and / modes.
- friendly-snippets + luasnip kept as the snippet engine + library.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 6 — Treesitter additions: textobjects + declarative parsers

**Phase goal:** Add `treesitter-textobjects` and declare the parser set explicitly via `grammarPackages`.

### Task 22: Add textobjects and declarative parsers to `treesitter/`

**Files:**
- Modify: `nixvim-modules/treesitter/default.nix`

- [ ] **Step 1: Add a `grammarPackages` block**

Edit `nixvim-modules/treesitter/default.nix`. After the existing `# === treesitter core ===` block, modify it to include parser declaration. The block should now look like:

```nix
      # === treesitter core ===
      # WHY: the main-branch nvim-treesitter rewrite. Highlighting and
      # folding configured via top-level options.
      # grammarPackages declares parsers at flake.lock time — replaces
      # the legacy ensure_installed auto-install that no longer exists
      # in the main-branch rewrite.
      {
        plugins.treesitter.enable = true;
        plugins.treesitter.highlight.enable = true;
        plugins.treesitter.folding.enable = true;

        plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
          astro
          bash
          c
          cmake
          cpp
          css
          go
          haskell
          html
          javascript
          json
          lua
          markdown
          markdown_inline
          nix
          python
          regex
          rust
          toml
          tsx
          typescript
          typst
          vim
          vimdoc
          yaml
        ];

        extraConfigLua = ''
          vim.opt.foldenable = false
        '';
      }
```

- [ ] **Step 2: Add a treesitter-textobjects block**

Append a new mkMerge block to the same file, before the existing `# === treesitter-context ===` block:

```nix
      # === treesitter-textobjects ===
      # WHY: structural motions (`af`/`if` etc.) for selecting / jumping
      # over functions, classes, parameters by syntax tree. main-branch
      # version, first-class in nixvim. Note: keymaps are wired via
      # Lua keymap API, not via configs.setup like the legacy version.
      {
        plugins.treesitter-textobjects.enable = true;
      }
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds. The treesitter package now bundles parsers for the listed languages.

### Task 23: Smoke test treesitter parsers

- [ ] **Step 1: Open a Python file (the parser wasn't auto-installed before)**

Run:
```bash
mkdir -p /tmp/ts-smoke
echo 'def foo(): return 42' > /tmp/ts-smoke/t.py
nix run . -- /tmp/ts-smoke/t.py
```

Inside nvim, you should see Python keyword highlighting (`def`, `return`). Confirm with `:TSConfigInfo` or `:checkhealth nvim-treesitter`. `<Esc>:q!<CR>`.

- [ ] **Step 2: Open a Haskell file**

Run:
```bash
echo 'main = putStrLn "hi"' > /tmp/ts-smoke/t.hs
nix run . -- /tmp/ts-smoke/t.hs
```

Inside nvim, you should see Haskell syntax highlighting. `<Esc>:q!<CR>`.

- [ ] **Step 3: Cleanup**

Run: `rm -rf /tmp/ts-smoke`

### Task 24: Commit Phase 6

- [ ] **Step 1: Stage and commit**

Run:
```bash
git add nixvim-modules/treesitter/default.nix
git commit -m "$(cat <<'EOF'
feat(treesitter): add textobjects and declarative grammarPackages

- Declare the parser set via plugins.treesitter.grammarPackages —
  replaces ensure_installed (gone in the main-branch rewrite). Parsers
  are pinned at flake.lock time; no runtime :TSInstall required.
- Add plugins.treesitter-textobjects.enable — main-branch version,
  first-class in nixvim. Provides structural motions/selections
  (`af`/`if`/`ac`/`ic` for function/class).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 7 — Swap UI primitives

**Phase goal:** lightline→lualine, bufferline→mini.tabline. Add fidget, noice, todo-comments, mini.indentscope, mini.icons, nvim-origami, quicker.nvim, trouble.nvim. Keep render-markdown. All in a new `ui/` module.

### Task 25: Create the `ui/` module skeleton

**Files:**
- Create: `nixvim-modules/ui/default.nix`
- Delete: `nixvim-modules/render-markdown/` (folded into ui)
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the new module with all 11 plugins**

Create `nixvim-modules/ui/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.ui;
in
{
  options.nixvimcfg.ui.enable = lib.mkEnableOption "ui plugins (lualine, mini.tabline, fidget, noice, etc.)";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === lualine ===
      # WHY: statusline; replaces lightline. Default sections cover
      # mode | branch+diff+diagnostics | filename | filetype+location.
      {
        plugins.lualine.enable = true;
        plugins.lualine.settings.options.theme = "auto";
        plugins.lualine.settings.options.globalstatus = true;
      }

      # === mini.icons + mini.tabline + mini.indentscope ===
      # WHY: declared on plugins.mini.modules so all mini submodules
      # share one runtimepath entry (avoids the closure footgun where
      # mixing plugins.mini.modules with plugins.mini-tabline would
      # double-register mini.nvim).
      # mini.icons.mock_nvim_web_devicons makes telescope/oil etc. find
      # mini.icons when they require 'nvim-web-devicons'.
      {
        plugins.mini.enable = true;
        plugins.mini.modules.icons = {
          mock_nvim_web_devicons = true;
        };
        plugins.mini.modules.tabline = { };
        plugins.mini.modules.indentscope = { };

        # Force-disable plugins.web-devicons so it doesn't double-load
        # alongside mini.icons. mini.icons' shim covers everything.
        plugins.web-devicons.enable = lib.mkForce false;
      }

      # === noice ===
      # WHY: cmdline / messages overlay UI. lsp.progress explicitly
      # disabled so it doesn't overlap fidget's corner spinner.
      {
        plugins.noice.enable = true;
        plugins.noice.settings.lsp.progress.enabled = false;
      }

      # === fidget ===
      # WHY: LSP progress indicator in the corner. Owns the LSP-progress
      # surface since we disabled it in noice.
      { plugins.fidget.enable = true; }

      # === todo-comments ===
      # WHY: highlight TODO/FIXME/HACK/NOTE keywords; pairs with
      # :TodoTelescope picker.
      { plugins.todo-comments.enable = true; }

      # === render-markdown ===
      # WHY: inline markdown rendering (decorates headings, code blocks,
      # lists, tables in-buffer). External preview deliberately not
      # added — use `glow` / `pandoc` from the shell when fidelity needed.
      { plugins.render-markdown.enable = true; }

      # === nvim-origami ===
      # WHY: LSP-aware folding (with treesitter fallback). Lighter
      # replacement for nvim-ufo. The README explicitly says it provides
      # folding, not just decoration.
      { plugins.origami.enable = true; }

      # === quicker.nvim ===
      # WHY: editable quickfix buffer UI; modern replacement for the
      # default :copen experience.
      { plugins.quicker.enable = true; }

      # === trouble.nvim ===
      # WHY: diagnostics/references/quickfix list with collapsible UI.
      # Required — referenced by <leader>x in the which-key registry.
      { plugins.trouble.enable = true; }

      # === which-key leaves ===
      # WHY: ui-owned <leader>x (Trouble), <leader>m (Markdown),
      # <leader>n (Notifications) keymaps.
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          # Trouble
          { __unkeyed-1 = "<leader>xx"; __unkeyed-2 = "<cmd>Trouble diagnostics toggle<cr>"; desc = "Diagnostics (Trouble)"; }
          { __unkeyed-1 = "<leader>xd"; __unkeyed-2 = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"; desc = "Document Diagnostics"; }
          { __unkeyed-1 = "<leader>xl"; __unkeyed-2 = "<cmd>Trouble loclist toggle<cr>"; desc = "Location List"; }
          { __unkeyed-1 = "<leader>xq"; __unkeyed-2 = "<cmd>Trouble qflist toggle<cr>"; desc = "Quickfix List"; }
          # Markdown
          { __unkeyed-1 = "<leader>me"; __unkeyed-2 = "<cmd>RenderMarkdown enable<cr>"; desc = "Render Enable"; }
          { __unkeyed-1 = "<leader>md"; __unkeyed-2 = "<cmd>RenderMarkdown disable<cr>"; desc = "Render Disable"; }
          # Notifications (noice history)
          { __unkeyed-1 = "<leader>nh"; __unkeyed-2 = "<cmd>Noice history<cr>"; desc = "Noice History"; }
          { __unkeyed-1 = "<leader>nd"; __unkeyed-2 = "<cmd>Noice dismiss<cr>"; desc = "Dismiss"; }
          # Todo (under Trouble group — TODO items behave like diagnostics)
          { __unkeyed-1 = "<leader>xt"; __unkeyed-2 = "<cmd>TodoTelescope<cr>"; desc = "TODOs (Telescope)"; }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Delete the old `render-markdown/` module**

Run: `git rm -r nixvim-modules/render-markdown`

- [ ] **Step 3: Update top-level config**

Edit `nixvim-configurations/default.nix`. Remove:
```nix
nixvimcfg.render-markdown.enable = true;
```
Replace with (alphabetical order with other enables):
```nix
nixvimcfg.ui.enable = true;
```

Also remove these loose plugin lines (they're now handled by `ui/`):
```nix
plugins.bufferline.enable = true;
plugins.lightline.enable = true;
```

- [ ] **Step 4: Verify build**

Run: `nix flake check 2>&1 | tail -20`
Expected: succeeds. If you see option-conflict warnings, it's likely the leftover `plugins.web-devicons.enable = true;` from the picker module being overridden by `lib.mkForce false` here — that's the intended behavior.

### Task 26: Smoke test UI

- [ ] **Step 1: Launch and verify statusline + tabline**

Run: `nix run . -- flake.nix`
Confirm:
- Statusline at bottom shows mode, filename, position (lualine, not lightline).
- Tabline at top shows buffer name (mini.tabline).
- Indent guides visible on indented lines (mini.indentscope).
- TODO/FIXME comments (if any in the file) are highlighted.

- [ ] **Step 2: Test trouble**

Inside the same nvim, press `<leader>xx`. Trouble diagnostics window opens at the bottom. `<Esc>` to close.

- [ ] **Step 3: Test render-markdown**

Run: `echo '# Hello\n\n- item 1\n- item 2' > /tmp/r.md && nix run . -- /tmp/r.md`
Heading and bullets render with styling. `:q!`.

### Task 27: Commit Phase 7

- [ ] **Step 1: Stage and commit**

Run:
```bash
git add nixvim-modules/ui nixvim-configurations/default.nix
git status  # confirm render-markdown/ removal is staged
git commit -m "$(cat <<'EOF'
feat(ui): consolidate UI plugins into ui/ module; swap lightline+bufferline

- Create nixvim-modules/ui/ with 11 plugins: lualine, mini.tabline,
  mini.icons, mini.indentscope, fidget, noice, todo-comments,
  render-markdown, nvim-origami, quicker.nvim, trouble.nvim.
- mini submodules declared via plugins.mini.modules (single mini.nvim
  runtimepath entry).
- mini.icons.mock_nvim_web_devicons=true + plugins.web-devicons forced
  off, so telescope/oil find mini.icons when they require 'nvim-web-devicons'.
- noice.lsp.progress disabled — fidget owns LSP progress surface.
- Delete nixvim-modules/render-markdown/ (folded into ui).
- Drop loose plugins.{bufferline,lightline}.enable from top-level config.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 8 — Swap editing primitives + add navigation module

**Phase goal:** Replace vim-surround / Comment / nvim-autopairs with mini equivalents and add mini.ai, mini.move, guess-indent, nvim-ts-autotag in a new `editing/` module. Create a separate `navigation/` module for fast-jumping/searching plugins: flash, harpoon (first-class with package=harpoon2), aerial, grug-far.

### Task 28: Create `editing/` module

**Files:**
- Create: `nixvim-modules/editing/default.nix`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the module**

Create `nixvim-modules/editing/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.editing;
in
{
  options.nixvimcfg.editing.enable = lib.mkEnableOption "editing primitives (mini suite, guess-indent, ts-autotag)";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === mini editing primitives ===
      # WHY: replaces vim-surround / Comment.nvim / nvim-autopairs with
      # mini equivalents under one ecosystem. Note: mini.comment lacks
      # ts_context_commentstring integration for JSX-in-TSX nested
      # commentstring switching — accept this trade for mini-suite
      # consistency. If JSX commenting feels wrong in practice, add
      # nvim-ts-context-commentstring later.
      # mini.surround default mappings (sa/sd/sr) differ from
      # vim-surround (ys/cs/ds) — accepted; mini's are more orthogonal.
      {
        plugins.mini.enable = true;
        plugins.mini.modules.surround = { };
        plugins.mini.modules.comment = { };
        plugins.mini.modules.pairs = { };
        plugins.mini.modules.ai = { };       # better textobjects
        plugins.mini.modules.move = { };     # alt-j/k line move
      }

      # === guess-indent ===
      # WHY: Lua-native indent detection. Replaces vim-sleuth.
      { plugins.guess-indent.enable = true; }

      # === nvim-ts-autotag ===
      # WHY: auto-close/rename HTML/JSX/Astro tags. Treesitter-aware;
      # works with the new main-branch nvim-treesitter.
      { plugins.ts-autotag.enable = true; }

    ]
  );
}
```

- [ ] **Step 2: Remove the loose plugin enables from top-level config**

Edit `nixvim-configurations/default.nix`. Remove these lines (they're now handled by `editing/`):

```nix
plugins.comment.enable = true;
plugins.nvim-autopairs.enable = true;
plugins.vim-surround.enable = true;
```

Add (alphabetically):

```nix
nixvimcfg.editing.enable = true;
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 28b: Create `navigation/` module

**Files:**
- Create: `nixvim-modules/navigation/default.nix`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the module**

Create `nixvim-modules/navigation/default.nix` with:

```nix
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.nixvimcfg.navigation;
in
{
  options.nixvimcfg.navigation.enable = lib.mkEnableOption "navigation (flash, harpoon, aerial, grug-far)";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === flash.nvim ===
      # WHY: jump-anywhere motion. `s` enters jump mode, type 2 chars
      # to see labels, type the label to jump.
      { plugins.flash.enable = true; }

      # === harpoon (v2 via package override) ===
      # WHY: marked-file quick navigation. First-class nixvim module;
      # package set to vimPlugins.harpoon2 (the recommended branch).
      # enableTelescope wires the :Telescope harpoon marks integration.
      {
        plugins.harpoon.enable = true;
        plugins.harpoon.package = pkgs.vimPlugins.harpoon2;
        plugins.harpoon.enableTelescope = true;
      }

      # === aerial ===
      # WHY: symbol outline sidebar. Persistent view of functions /
      # classes / sections in the current file.
      { plugins.aerial.enable = true; }

      # === grug-far ===
      # WHY: project-wide find/replace with editable-buffer UX. Replaces
      # nvim-spectre.
      { plugins.grug-far.enable = true; }

      # === which-key leaves: <leader>h (Harpoon), <leader>a (Aerial), <leader>s (Search) ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          # Harpoon
          { __unkeyed-1 = "<leader>ha"; __unkeyed-2.__raw = "function() require('harpoon'):list():add() end"; desc = "Add to Harpoon"; }
          { __unkeyed-1 = "<leader>hh"; __unkeyed-2.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end"; desc = "Toggle Harpoon menu"; }
          { __unkeyed-1 = "<leader>h1"; __unkeyed-2.__raw = "function() require('harpoon'):list():select(1) end"; desc = "Slot 1"; }
          { __unkeyed-1 = "<leader>h2"; __unkeyed-2.__raw = "function() require('harpoon'):list():select(2) end"; desc = "Slot 2"; }
          { __unkeyed-1 = "<leader>h3"; __unkeyed-2.__raw = "function() require('harpoon'):list():select(3) end"; desc = "Slot 3"; }
          { __unkeyed-1 = "<leader>h4"; __unkeyed-2.__raw = "function() require('harpoon'):list():select(4) end"; desc = "Slot 4"; }
          { __unkeyed-1 = "<leader>hn"; __unkeyed-2.__raw = "function() require('harpoon'):list():next() end"; desc = "Next slot"; }
          { __unkeyed-1 = "<leader>hp"; __unkeyed-2.__raw = "function() require('harpoon'):list():prev() end"; desc = "Prev slot"; }
          # Aerial
          { __unkeyed-1 = "<leader>aa"; __unkeyed-2 = "<cmd>AerialToggle<cr>"; desc = "Toggle Aerial"; }
          { __unkeyed-1 = "<leader>an"; __unkeyed-2 = "<cmd>AerialNext<cr>"; desc = "Aerial Next"; }
          { __unkeyed-1 = "<leader>ap"; __unkeyed-2 = "<cmd>AerialPrev<cr>"; desc = "Aerial Prev"; }
          # Search/Replace (grug-far)
          { __unkeyed-1 = "<leader>ss"; __unkeyed-2.__raw = "function() require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } }) end"; desc = "Search word"; }
          { __unkeyed-1 = "<leader>sg"; __unkeyed-2.__raw = "function() require('grug-far').open() end"; desc = "Search (global)"; }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Update top-level config**

Edit `nixvim-configurations/default.nix`. Add (alphabetical):
```nix
nixvimcfg.navigation.enable = true;
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 29: Smoke test editing + navigation

- [ ] **Step 1: Test mini.surround**

Run: `nix run . -- flake.nix`
Inside nvim, on a word in a string, press `saiw"` (surround-add inner-word with `"`). The word gets quoted. `u` to undo. `<Esc>:q<CR>`.

- [ ] **Step 2: Test mini.comment**

Run: `nix run . -- nixvim-modules/which-key/default.nix`
Position on a line, press `gcc` (comment line). The line gets commented with `#`. `gcc` again to uncomment. `<Esc>:q<CR>`.

- [ ] **Step 3: Test flash motion**

Run: `nix run . -- flake.nix`
Press `s`, type 2 chars matching text on screen — see labels. Type the label to jump. `<Esc>:q<CR>`.

- [ ] **Step 4: Test harpoon**

Run: `nix run . -- flake.nix`
Press `<leader>ha` to add the file to harpoon. Press `<leader>hh` — harpoon menu shows the file. `<Esc><Esc>:q<CR>`.

- [ ] **Step 5: Test aerial**

Run: `nix run . -- nixvim-modules/lsp/default.nix`
Press `<leader>aa`. Aerial sidebar opens showing symbol outline. `<leader>aa` again to close. `<Esc>:q<CR>`.

- [ ] **Step 6: Test grug-far**

Run: `nix run . -- flake.nix`
Press `<leader>sg`. Grug-far opens with an editable search/replace buffer. `<Esc>:q!<CR>:q<CR>` to exit.

### Task 30: Commit Phase 8

- [ ] **Step 1: Stage and commit**

Run:
```bash
git add nixvim-modules/editing nixvim-modules/navigation nixvim-configurations/default.nix
git commit -m "$(cat <<'EOF'
feat(editing, navigation): swap to mini suite + add nav module

editing/:
- mini.surround / mini.comment / mini.pairs / mini.ai / mini.move
  under plugins.mini.modules (consistent with ui module's mini
  submodules — single mini.nvim runtimepath entry).
- guess-indent (Lua-native indent detection).
- nvim-ts-autotag (treesitter-aware HTML/JSX tag close).
- Removes loose plugins.{comment,nvim-autopairs,vim-surround}.enable.

navigation/:
- flash.nvim (jump motion via `s`).
- harpoon — first-class plugins.harpoon with package=harpoon2 +
  enableTelescope=true.
- aerial.nvim (symbol outline sidebar).
- grug-far.nvim (project-wide editable-buffer find/replace; replaces
  nvim-spectre).
- 8 <leader>h (harpoon) + 3 <leader>a (aerial) + 2 <leader>s (search)
  leaf keymaps.

Notes on regressions:
- mini.surround mappings (sa/sd/sr) differ from vim-surround's
  (ys/cs/ds). Accepted for mini-suite consistency.
- mini.comment lacks ts_context_commentstring for JSX-in-TSX. Accepted;
  add nvim-ts-context-commentstring later if it bites.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

### Validation gate

**Stop here.** Daily-drive the editor for at least a week before continuing to phase 9+. The editing-primitive swaps have the highest muscle-memory cost; getting feedback from real use should inform whether to keep going or reverse course. Phases 9-13 can resume anytime after.

---

## Phase 9 — File explorer (oil.nvim)

**Phase goal:** Add oil.nvim; remove the disabled chadtree line.

### Task 31: Create `files/` module

**Files:**
- Create: `nixvim-modules/files/default.nix`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the module**

Create `nixvim-modules/files/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.files;
in
{
  options.nixvimcfg.files.enable = lib.mkEnableOption "oil.nvim buffer-as-fs file explorer";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === oil.nvim ===
      # WHY: edit the filesystem as a buffer. Replaces chadtree (which
      # was already disabled in the previous config). `<leader>e` opens
      # oil at the current buffer's directory.
      {
        plugins.oil.enable = true;
        plugins.oil.settings.default_file_explorer = true;
      }

      # === which-key leaves ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>e"; __unkeyed-2 = "<cmd>Oil<cr>"; desc = "Explore (oil)"; }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Update top-level config**

Edit `nixvim-configurations/default.nix`. Remove:
```nix
plugins.chadtree.enable = false;
```
Add:
```nix
nixvimcfg.files.enable = true;
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

- [ ] **Step 4: Smoke test**

Run: `nix run . -- flake.nix`
Press `<leader>e`. Oil opens with the directory listing. Press `<Esc>:q<CR>`.

- [ ] **Step 5: Commit**

Run:
```bash
git add nixvim-modules/files nixvim-configurations/default.nix
git commit -m "$(cat <<'EOF'
feat(files): add oil.nvim file explorer

- Create nixvim-modules/files/ with plugins.oil. `<leader>e` opens
  oil at current buffer's directory.
- Remove plugins.chadtree.enable = false; from top-level config
  (replaced by oil).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 10 — Git overhaul: drop fugitive, add neogit + gitsigns + diffview

**Phase goal:** Delete the fugitive module; create a new `git/` module with neogit + gitsigns + diffview. Wire the 24-binding `<leader>g` keymap layout from the spec.

### Task 32: Delete the fugitive module

**Files:**
- Delete: `nixvim-modules/fugitive/`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Remove the directory**

Run: `git rm -r nixvim-modules/fugitive`

- [ ] **Step 2: Remove the enable flag**

Edit `nixvim-configurations/default.nix`. Delete:
```nix
nixvimcfg.fugitive.enable = true;
```

- [ ] **Step 3: Verify build (no git plugins yet)**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds. No git porcelain in editor right now.

### Task 33: Create the new `git/` module

**Files:**
- Create: `nixvim-modules/git/default.nix`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the module**

Create `nixvim-modules/git/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.git;
in
{
  options.nixvimcfg.git.enable = lib.mkEnableOption "git plugins (neogit, gitsigns, diffview)";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === gitsigns ===
      # WHY: gutter signs for add/change/delete, inline hunk staging,
      # inline blame on current line.
      {
        plugins.gitsigns.enable = true;
        plugins.gitsigns.settings.current_line_blame = false;
      }

      # === diffview ===
      # WHY: full-screen diff browser + file history (replaces
      # fugitive's :Gedit HEAD~N:%).
      { plugins.diffview.enable = true; }

      # === neogit ===
      # WHY: Magit-style interactive porcelain. Replaces fugitive
      # entirely. Integrates with diffview for diff popups.
      {
        plugins.neogit.enable = true;
        plugins.neogit.settings.integrations.diffview = true;
      }

      # === which-key leaves: 24 git bindings ===
      # WHY: each plugin owns its slice — neogit popups, gitsigns hunks
      # under <leader>gh, diffview ops under <leader>gv/V/w.
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          # neogit porcelain
          { __unkeyed-1 = "<leader>gg"; __unkeyed-2 = "<cmd>Neogit<cr>"; desc = "Status (neogit)"; }
          { __unkeyed-1 = "<leader>gc"; __unkeyed-2 = "<cmd>Neogit commit<cr>"; desc = "Commit"; }
          { __unkeyed-1 = "<leader>gC"; __unkeyed-2 = "<cmd>Neogit commit --amend<cr>"; desc = "Commit --amend"; }
          { __unkeyed-1 = "<leader>gp"; __unkeyed-2 = "<cmd>Neogit push<cr>"; desc = "Push"; }
          { __unkeyed-1 = "<leader>gP"; __unkeyed-2 = "<cmd>Neogit pull<cr>"; desc = "Pull"; }
          { __unkeyed-1 = "<leader>gf"; __unkeyed-2 = "<cmd>Neogit fetch<cr>"; desc = "Fetch"; }
          { __unkeyed-1 = "<leader>gb"; __unkeyed-2 = "<cmd>Neogit branch<cr>"; desc = "Branch"; }
          { __unkeyed-1 = "<leader>gs"; __unkeyed-2 = "<cmd>Neogit stash<cr>"; desc = "Stash"; }
          { __unkeyed-1 = "<leader>gm"; __unkeyed-2 = "<cmd>Neogit merge<cr>"; desc = "Merge"; }
          { __unkeyed-1 = "<leader>gr"; __unkeyed-2 = "<cmd>Neogit rebase<cr>"; desc = "Rebase"; }
          { __unkeyed-1 = "<leader>gx"; __unkeyed-2 = "<cmd>Neogit cherry_pick<cr>"; desc = "Cherry-pick"; }
          { __unkeyed-1 = "<leader>gz"; __unkeyed-2 = "<cmd>Neogit reset<cr>"; desc = "Reset"; }
          { __unkeyed-1 = "<leader>gl"; __unkeyed-2 = "<cmd>Neogit log<cr>"; desc = "Log"; }
          # diffview
          { __unkeyed-1 = "<leader>gv"; __unkeyed-2 = "<cmd>DiffviewOpen<cr>"; desc = "Diffview open"; }
          { __unkeyed-1 = "<leader>gV"; __unkeyed-2 = "<cmd>DiffviewClose<cr>"; desc = "Diffview close"; }
          { __unkeyed-1 = "<leader>gw"; __unkeyed-2 = "<cmd>DiffviewFileHistory %<cr>"; desc = "File history"; }
          # gitsigns hunks (under <leader>gh group prefix declared in which-key registry)
          { __unkeyed-1 = "<leader>ghs"; __unkeyed-2 = "<cmd>Gitsigns stage_hunk<cr>"; desc = "Stage hunk"; }
          { __unkeyed-1 = "<leader>ghr"; __unkeyed-2 = "<cmd>Gitsigns reset_hunk<cr>"; desc = "Reset hunk"; }
          { __unkeyed-1 = "<leader>ghp"; __unkeyed-2 = "<cmd>Gitsigns preview_hunk<cr>"; desc = "Preview hunk"; }
          { __unkeyed-1 = "<leader>ghu"; __unkeyed-2 = "<cmd>Gitsigns undo_stage_hunk<cr>"; desc = "Undo stage hunk"; }
          { __unkeyed-1 = "<leader>ghd"; __unkeyed-2 = "<cmd>Gitsigns diffthis<cr>"; desc = "Diff vs index"; }
          # blame
          { __unkeyed-1 = "<leader>gB"; __unkeyed-2 = "<cmd>Gitsigns toggle_current_line_blame<cr>"; desc = "Toggle line blame"; }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Update top-level config**

Edit `nixvim-configurations/default.nix`. Add (alphabetical):
```nix
nixvimcfg.git.enable = true;
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 34: Smoke test git

- [ ] **Step 1: Launch in this repo and test neogit**

Run: `nix run . -- flake.nix`
Press `<leader>gg`. Neogit status buffer opens with staged/unstaged/untracked sections. Press `q` to close the neogit buffer, then `<Esc>:q<CR>` to exit nvim.

- [ ] **Step 2: Test gitsigns**

Run: `nix run . -- nixvim-modules/lsp/default.nix`
The gutter shows colored signs (∼ for change) on lines that differ from HEAD if any. Press `<leader>ghp` to preview. `<Esc>:q<CR>`.

- [ ] **Step 3: Test diffview**

Run: `nix run . -- flake.nix`
Press `<leader>gv`. Diffview opens showing working-tree-vs-HEAD diff (or empty if no diff). Press `:DiffviewClose<CR>:q<CR>`.

### Task 35: Commit Phase 10

- [ ] **Step 1: Stage and commit**

Run:
```bash
git add nixvim-modules/git nixvim-configurations/default.nix
git status  # confirm fugitive/ removal is staged
git commit -m "$(cat <<'EOF'
feat(git): drop fugitive; add neogit + gitsigns + diffview

- Delete nixvim-modules/fugitive/ entirely.
- Create nixvim-modules/git/ with neogit (Magit-style porcelain),
  gitsigns (gutter signs + inline hunks + blame), diffview (diff
  browser + file history).
- Wire 24 <leader>g bindings — each plugin owns its slice:
  - <leader>g{g,c,C,p,P,f,b,s,m,r,x,z,l} neogit popups
  - <leader>gv/V/w diffview open/close/file-history
  - <leader>gh{s,r,p,u,d} gitsigns hunks
  - <leader>gB gitsigns line blame toggle

Acknowledged trade: lose :Git <anything> raw passthrough. For rare
arbitrary git, use :terminal or external shell. Every other fugitive
feature has a replacement (verified during spec review).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 11 — DAP + neotest

**Phase goal:** Add `dap/` and `neotest/` modules with all language adapters. Declare the cross-module `nixvimcfg.dap.pythonPath` option.

### Task 36: Create `dap/` module

**Files:**
- Create: `nixvim-modules/dap/default.nix`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the module**

Create `nixvim-modules/dap/default.nix` with:

```nix
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.nixvimcfg.dap;
in
{
  options.nixvimcfg.dap.enable = lib.mkEnableOption "DAP debugger + adapters + UI";

  # WHY: cross-module option — neotest's python adapter reads this so
  # the same debugpy python is shared. This is the one exception to
  # the .enable-only module convention.
  options.nixvimcfg.dap.pythonPath = lib.mkOption {
    type = lib.types.str;
    default = "${pkgs.python3.withPackages (ps: [ps.debugpy])}/bin/python";
    description = "Path to a Python interpreter with debugpy installed. Shared with neotest.";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === dap core ===
      # WHY: the debug adapter protocol client itself.
      { plugins.dap.enable = true; }

      # === dap-ui ===
      # WHY: panes for variables / stacks / breakpoints / watches /
      # console. First-class nixvim option.
      { plugins.dap-ui.enable = true; }

      # === dap-virtual-text ===
      # WHY: inline value display next to variables during a session.
      { plugins.dap-virtual-text.enable = true; }

      # === dap-go ===
      # WHY: delve adapter wiring for Go. First-class nixvim.
      { plugins.dap-go.enable = true; }

      # === dap-python ===
      # WHY: debugpy adapter wiring for Python. adapterPythonPath is the
      # python that RUNS debugpy (pinned at flake.lock time, ABI-stable);
      # resolvePython picks the DEBUGGEE python per-session from
      # $VIRTUAL_ENV or PATH.
      {
        plugins.dap-python.enable = true;
        plugins.dap-python.adapterPythonPath = cfg.pythonPath;
        plugins.dap-python.resolvePython = ''
          function()
            if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
              return vim.env.VIRTUAL_ENV .. '/bin/python'
            end
            return vim.fn.exepath('python3')
          end
        '';
      }

      # === which-key leaves: <leader>d ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>db"; __unkeyed-2 = "<cmd>DapToggleBreakpoint<cr>"; desc = "Toggle breakpoint"; }
          { __unkeyed-1 = "<leader>dB"; __unkeyed-2.__raw = "function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end"; desc = "Conditional breakpoint"; }
          { __unkeyed-1 = "<leader>dc"; __unkeyed-2 = "<cmd>DapContinue<cr>"; desc = "Continue / start"; }
          { __unkeyed-1 = "<leader>do"; __unkeyed-2 = "<cmd>DapStepOver<cr>"; desc = "Step over"; }
          { __unkeyed-1 = "<leader>di"; __unkeyed-2 = "<cmd>DapStepInto<cr>"; desc = "Step into"; }
          { __unkeyed-1 = "<leader>dO"; __unkeyed-2 = "<cmd>DapStepOut<cr>"; desc = "Step out"; }
          { __unkeyed-1 = "<leader>dr"; __unkeyed-2 = "<cmd>DapToggleRepl<cr>"; desc = "REPL"; }
          { __unkeyed-1 = "<leader>du"; __unkeyed-2.__raw = "function() require('dapui').toggle() end"; desc = "Toggle dap-ui"; }
          { __unkeyed-1 = "<leader>dq"; __unkeyed-2 = "<cmd>DapTerminate<cr>"; desc = "Terminate"; }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Update top-level config**

Edit `nixvim-configurations/default.nix`. Add:
```nix
nixvimcfg.dap.enable = true;
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 37: Create `neotest/` module

**Files:**
- Create: `nixvim-modules/neotest/default.nix`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the module**

Create `nixvim-modules/neotest/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.neotest;
in
{
  options.nixvimcfg.neotest.enable = lib.mkEnableOption "neotest test runner + adapters";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === neotest core + adapters ===
      # WHY: test runner with per-language adapters. All five adapters
      # first-class in nixvim under plugins.neotest.adapters.<name>.
      {
        plugins.neotest.enable = true;
        plugins.neotest.adapters.golang.enable = true;
        plugins.neotest.adapters.rust.enable = true;
        plugins.neotest.adapters.jest.enable = true;
        plugins.neotest.adapters.vitest.enable = true;
      }

      # === python adapter (gated on dap so debugpy python is shared) ===
      # WHY: avoids creating two separate debugpy pythons.
      (lib.mkIf config.nixvimcfg.dap.enable {
        plugins.neotest.adapters.python.enable = true;
        plugins.neotest.adapters.python.settings.dap = {
          justMyCode = false;
        };
        plugins.neotest.adapters.python.settings.python = config.nixvimcfg.dap.pythonPath;
      })

      # === which-key leaves: <leader>t ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>tr"; __unkeyed-2.__raw = "function() require('neotest').run.run() end"; desc = "Run nearest"; }
          { __unkeyed-1 = "<leader>tf"; __unkeyed-2.__raw = "function() require('neotest').run.run(vim.fn.expand('%')) end"; desc = "Run file"; }
          { __unkeyed-1 = "<leader>tl"; __unkeyed-2.__raw = "function() require('neotest').run.run_last() end"; desc = "Run last"; }
          { __unkeyed-1 = "<leader>tt"; __unkeyed-2.__raw = "function() require('neotest').run.run(vim.fn.getcwd()) end"; desc = "Run dir"; }
          { __unkeyed-1 = "<leader>ts"; __unkeyed-2.__raw = "function() require('neotest').summary.toggle() end"; desc = "Summary toggle"; }
          { __unkeyed-1 = "<leader>to"; __unkeyed-2.__raw = "function() require('neotest').output.open() end"; desc = "Output toggle"; }
          { __unkeyed-1 = "<leader>tq"; __unkeyed-2.__raw = "function() require('neotest').run.stop() end"; desc = "Stop"; }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Update top-level config**

Edit `nixvim-configurations/default.nix`. Add:
```nix
nixvimcfg.neotest.enable = true;
```

**Note:** the treesitter module's old `<leader>tc` (Context Toggle) will now collide with the new `<leader>t` (Test) group. Move that keymap.

- [ ] **Step 3: Fix the `<leader>tc` conflict in `treesitter/`**

Edit `nixvim-modules/treesitter/default.nix`. In the which-key spec, change:

```nix
{
  __unkeyed-1 = "<leader>tc";
  __unkeyed-2 = "<cmd>TSContextToggle<cr>";
  desc = "Context Toggle";
}
```

to (moving under `<leader>o` Toggle group):

```nix
{
  __unkeyed-1 = "<leader>oc";
  __unkeyed-2 = "<cmd>TSContextToggle<cr>";
  desc = "TS Context Toggle";
}
```

- [ ] **Step 4: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 38: Smoke test DAP + neotest

- [ ] **Step 1: Test breakpoint toggle**

Run: `nix run . -- flake.nix`
Press `<leader>db` on any line — a breakpoint sign appears in the gutter. Press `<leader>db` again — sign disappears. `<Esc>:q<CR>`.

- [ ] **Step 2: Test neotest summary**

Run: `nix run . -- flake.nix`
Press `<leader>ts` — neotest summary panel opens (empty since flake.nix has no tests). Press `<leader>ts` again to close. `<Esc>:q<CR>`.

### Task 39: Commit Phase 11

- [ ] **Step 1: Stage and commit**

Run:
```bash
git add nixvim-modules/dap nixvim-modules/neotest nixvim-modules/treesitter/default.nix nixvim-configurations/default.nix
git commit -m "$(cat <<'EOF'
feat(dap, neotest): add debug + test integration

- Create nixvim-modules/dap/ with first-class plugins.dap +
  dap-ui + dap-virtual-text + dap-go + dap-python (all in nixvim's
  option schema — no extraPlugins).
- Declare nixvimcfg.dap.pythonPath as a cross-module option (one
  exception to .enable-only convention). neotest python adapter
  reads it so debugpy python is shared.
- dap-python: adapterPythonPath = bundled python3+debugpy (pinned at
  flake.lock); resolvePython = lua fn that picks $VIRTUAL_ENV or
  PATH python for the debuggee.
- Create nixvim-modules/neotest/ with adapters: golang, python (gated
  on dap), rust, jest, vitest. All first-class.
- 9 <leader>d bindings (dap) + 7 <leader>t bindings (neotest).
- Move <leader>tc TSContextToggle to <leader>oc (under Toggle group)
  to free up <leader>t for neotest.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 12 — Snacks adoption (10 submodules)

**Phase goal:** Create `snacks/` module enabling 10 selected submodules: bigfile, statuscolumn, scratch, words, toggle, profiler, bufdelete, rename, gitbrowse, quickfile.

### Task 40: Create `snacks/` module

**Files:**
- Create: `nixvim-modules/snacks/default.nix`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the module**

Create `nixvim-modules/snacks/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.snacks;
in
{
  options.nixvimcfg.snacks.enable = lib.mkEnableOption "snacks.nvim with selected submodules";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === bigfile ===
      # WHY: disable expensive features on large files. Near-zero
      # config; real perf win for logs / generated code.
      {
        plugins.snacks.enable = true;
        plugins.snacks.settings.bigfile.enabled = true;
      }

      # === statuscolumn ===
      # WHY: unified gutter (signs / numbers / git). folds.open = false
      # so nvim-origami owns the fold UI; statuscolumn handles only
      # signs and numbers.
      {
        plugins.snacks.settings.statuscolumn.enabled = true;
        plugins.snacks.settings.statuscolumn.folds.open = false;
      }

      # === quickfile ===
      # WHY: renders the file before plugins fully load. Perceptible
      # startup feel improvement.
      { plugins.snacks.settings.quickfile.enabled = true; }

      # === words ===
      # WHY: LSP-reference auto-highlight + ]]/[[ navigation. Closest
      # replacement for the lost treesitter-refactor.highlightDefinitions.
      { plugins.snacks.settings.words.enabled = true; }

      # === toggle ===
      # WHY: auto-registers per-option toggles (spell, wrap,
      # diagnostics, inlay hints, line numbers) into which-key under
      # <leader>o. Concrete discoverability win.
      { plugins.snacks.settings.toggle.enabled = true; }

      # === bufdelete ===
      # WHY: close buffers without destroying window layout. Trivially
      # better than :bd with mini.tabline.
      { plugins.snacks.settings.bufdelete.enabled = true; }

      # === rename ===
      # WHY: LSP-aware file rename that updates imports. Complements
      # oil's buffer-only rename.
      { plugins.snacks.settings.rename.enabled = true; }

      # === gitbrowse ===
      # WHY: "open in GitHub" without vim-rhubarb. Replaces fugitive's
      # :GBrowse.
      { plugins.snacks.settings.gitbrowse.enabled = true; }

      # === scratch ===
      # WHY: per-cwd persistent scratch buffers — genuinely missing.
      { plugins.snacks.settings.scratch.enabled = true; }

      # === profiler ===
      # WHY: built-in Lua profiler with flame UI. For diagnosing
      # startup / lag issues.
      { plugins.snacks.settings.profiler.enabled = true; }

      # === which-key leaves ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>bd"; __unkeyed-2.__raw = "function() Snacks.bufdelete() end"; desc = "Delete buffer"; }
          { __unkeyed-1 = "<leader>cs"; __unkeyed-2.__raw = "function() Snacks.scratch() end"; desc = "Scratch buffer"; }
          { __unkeyed-1 = "<leader>cp"; __unkeyed-2.__raw = "function() Snacks.profiler.start() end"; desc = "Profiler start"; }
          { __unkeyed-1 = "<leader>cP"; __unkeyed-2.__raw = "function() Snacks.profiler.stop() end"; desc = "Profiler stop"; }
          { __unkeyed-1 = "<leader>gho"; __unkeyed-2.__raw = "function() Snacks.gitbrowse() end"; desc = "Open in GitHub"; }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Update top-level config**

Edit `nixvim-configurations/default.nix`. Add:
```nix
nixvimcfg.snacks.enable = true;
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

### Task 41: Smoke test snacks

- [ ] **Step 1: Verify statuscolumn shows numbers + signs**

Run: `nix run . -- flake.nix`
The leftmost column shows line numbers and (in a git-tracked file with changes) git signs. Press `<leader>oc` to toggle the treesitter context indicator (folding-related markers don't appear in the statuscolumn since `folds.open = false`).

- [ ] **Step 2: Test snacks.toggle**

Inside the same nvim, press `<leader>o`. After ~200ms which-key shows toggle entries auto-registered by snacks (spell, wrap, line numbers, etc.).

- [ ] **Step 3: Test scratch buffer**

Press `<leader>cs`. A floating scratch buffer opens. `<Esc>:q<CR>` to close.

- [ ] **Step 4: Exit**

`<Esc>:q<CR>`.

### Task 42: Commit Phase 12

- [ ] **Step 1: Stage and commit**

Run:
```bash
git add nixvim-modules/snacks nixvim-configurations/default.nix
git commit -m "$(cat <<'EOF'
feat(snacks): adopt 10 snacks.nvim submodules

- Create nixvim-modules/snacks/ with bigfile, statuscolumn, quickfile,
  words, toggle, bufdelete, rename, gitbrowse, scratch, profiler.
- statuscolumn.folds.open = false so nvim-origami owns the fold UI;
  statuscolumn handles signs and numbers only.
- words replaces the lost treesitter-refactor.highlightDefinitions.
- toggle auto-registers per-option toggles into which-key under
  <leader>o (discoverability win).
- 5 <leader>{b,c,g} leaf keymaps for buffer-delete / scratch /
  profiler / gitbrowse.

snacks.lazygit deliberately not adopted — user doesn't use the lazygit
binary.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 13 — Typst preview

**Phase goal:** Add `typst/` module with typst-preview.nvim.

### Task 43: Create `typst/` module

**Files:**
- Create: `nixvim-modules/typst/default.nix`
- Modify: `nixvim-configurations/default.nix`

- [ ] **Step 1: Create the module**

Create `nixvim-modules/typst/default.nix` with:

```nix
{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.typst;
in
{
  options.nixvimcfg.typst.enable = lib.mkEnableOption "typst-preview.nvim";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === typst-preview ===
      # WHY: live preview for typst documents. Pairs with the tinymist
      # LSP (enabled in the lsp module).
      { plugins.typst-preview.enable = true; }

      # === which-key leaves (filetype-conditional) ===
      # WHY: bind <leader>mp under <leader>m (Markdown group; typst
      # is a markdown-adjacent typesetting format, so share the prefix).
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>mp"; __unkeyed-2 = "<cmd>TypstPreview<cr>"; desc = "Typst Preview"; }
          { __unkeyed-1 = "<leader>mP"; __unkeyed-2 = "<cmd>TypstPreviewStop<cr>"; desc = "Typst Preview Stop"; }
        ];
      })

    ]
  );
}
```

- [ ] **Step 2: Update top-level config**

Edit `nixvim-configurations/default.nix`. Add:
```nix
nixvimcfg.typst.enable = true;
```

- [ ] **Step 3: Verify build**

Run: `nix flake check 2>&1 | tail -10`
Expected: succeeds.

- [ ] **Step 4: Smoke test**

Run:
```bash
echo '= Hello' > /tmp/t.typ
nix run . -- /tmp/t.typ
```

Inside nvim: `:TypstPreview` opens preview (in a browser window or the configured viewer). `:TypstPreviewStop` closes it. `<Esc>:q<CR>`. `rm /tmp/t.typ`.

- [ ] **Step 5: Commit**

Run:
```bash
git add nixvim-modules/typst nixvim-configurations/default.nix
git commit -m "$(cat <<'EOF'
feat(typst): add typst-preview.nvim

Live preview pairs with tinymist LSP (already enabled in lsp module).
<leader>mp / <leader>mP start/stop preview.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Final verification

### Task 44: Full smoke test of the migrated config

- [ ] **Step 1: Launch and verify all modules attached**

Run: `nix run . -- flake.nix`
Confirm:
- Statusline (lualine) visible at bottom
- Tabline (mini.tabline) visible at top
- Gitsigns gutter visible (if file has changes)
- Indent guides (mini.indentscope) visible
- `:LspInfo` shows nixd attached
- `:Telescope` opens picker; `<Esc>` closes
- `<leader>?k` opens telescope keymaps picker
- `<leader>gg` opens neogit
- `<leader>e` opens oil
- `<leader>ha` adds to harpoon
- `<leader>db` toggles breakpoint
- `<leader>ts` toggles neotest summary

`<Esc>:q<CR>` when done.

- [ ] **Step 2: Verify clean shutdown**

Run: `nix run . -- --version | head -3`
Expected: `NVIM v0.12.x` with no error output.

### Task 45: Final state check

- [ ] **Step 1: Confirm 14 modules**

Run: `ls nixvim-modules/`
Expected:
```
completion  dap  editing  files  git  lsp  navigation  neotest  picker  snacks  treesitter  typst  ui  which-key
```

- [ ] **Step 2: Confirm deleted modules are gone**

Run: `ls nixvim-modules/ | grep -E 'coq-nvim|conform-nvim|cmp|fugitive|render-markdown|telescope'`
Expected: empty output.

- [ ] **Step 3: Confirm git log**

Run: `git log --oneline major-upgrade ^main | head -20`
Expected: 13 commits matching the phases plus the original 3 doc commits.

---

## Outstanding follow-ups (after the plan completes)

These were left out of the plan because they're dependent on real usage feedback or marked out-of-scope in the spec, but are worth tracking:

1. **mini.surround vim-surround compat mappings** — if muscle memory fights you for more than a week, add `plugins.mini.modules.surround.mappings = { add = "ys"; delete = "ds"; replace = "cs"; };` to the editing module.
2. **nvim-ts-context-commentstring** — if mini.comment fails on JSX-in-TSX, add this plugin alongside.
3. **harper_ls noise tuning** — if defaults are still too chatty, narrow filetype list further or disable additional rules.
4. **kanagawa highlight gaps** — if mini.indentscope / render-markdown / noice show wrong colors, either patch with `vim.api.nvim_set_hl` overrides or swap to tokyonight/catppuccin (both have explicit support for these plugins).
5. **`indent-blankline.nvim`** — if you want full indent guides (not just current scope from mini.indentscope), add it.
6. **External markdown preview** — `glow file.md` or `pandoc -o out.html` from the shell handles the 20% case where fidelity matters. If images/Mermaid/KaTeX become important, consider `image.nvim` (requires Kitty-graphics terminal + ImageMagick).
7. **`<leader>tc` → `<leader>oc` migration** — phase 11 moves treesitter context toggle from `<leader>tc` to `<leader>oc`. Muscle memory may take a session or two to adjust.

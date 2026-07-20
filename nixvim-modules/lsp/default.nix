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

      # === diagnostic display ===
      # WHY: neovim's default only shows diagnostics as gutter signs +
      # underline (virtual_text off), so the message stays hidden until
      # you hover. Turn on virtual_text so the message shows inline at
      # end of line. If it feels noisy under basedpyright's strict mode,
      # swap to `virtual_lines = { current_line = true; }` for the full
      # message on just the cursor's line instead.
      { diagnostic.settings.virtual_text = true; }

      # === web ===
      # WHY: front-end stack — astro file framework, eslint linter,
      # CSS, HTML, tailwind classes.
      # NOTE: eslint.packageFallback expresses "prefer the repo's eslint
      # server", but eslint/cssls/html/jsonls all share the
      # vscode-langservers-extracted package; since those siblings stay
      # bundled (PATH prefix), the shared binary still resolves to the
      # pinned copy. Harmless — the eslint LSP lints with the project's
      # own eslint from node_modules regardless, so the eslint *engine*
      # version is already repo-driven. Flip cssls/html/jsonls too if you
      # ever want the shared server binary itself to be env-first.
      {
        plugins.lsp.servers.astro.enable = true;
        plugins.lsp.servers.cssls.enable = true;
        plugins.lsp.servers.eslint.enable = true;
        plugins.lsp.servers.eslint.packageFallback = true;
        plugins.lsp.servers.html.enable = true;
        plugins.lsp.servers.tailwindcss.enable = true;
      }

      # === scripts and config ===
      # WHY: bash + structured-data formats the user works in daily.
      {
        plugins.lsp.servers.bashls.enable = true;
        plugins.lsp.servers.jsonls.enable = true;
        plugins.lsp.servers.taplo.enable = true;   # TOML
        plugins.lsp.servers.taplo.packageFallback = true;
        plugins.lsp.servers.yamlls.enable = true;
      }

      # === Go ===
      # WHY: gopls + golangci-lint LSP, preferring the repo's own toolchain.
      # packageFallback moves the bundled servers to the end of PATH, and
      # golangci-lint (which golangci_lint_ls invokes as a CLI) is supplied
      # via extraPackagesAfter (also a suffix), so a devShell's version
      # wins; the pinned versions are only fallbacks outside a Go project.
      {
        plugins.lsp.servers.gopls.enable = true;
        plugins.lsp.servers.gopls.packageFallback = true;
        plugins.lsp.servers.golangci_lint_ls.enable = true;
        plugins.lsp.servers.golangci_lint_ls.packageFallback = true;
        extraPackagesAfter = [ pkgs.golangci-lint ];
      }

      # === Rust ===
      # WHY: rust-analyzer, but toolchain-agnostic. packageFallback moves
      # the bundled rust-analyzer + cargo/rustc/rustfmt to the END of PATH
      # (suffix), so each repo's own toolchain (devshell / rustup) — and
      # its matching clippy version — takes precedence; the nixvim-pinned
      # toolchain is only a fallback when editing outside a Rust project.
      # check.command = "clippy" makes rust-analyzer lint with clippy
      # instead of plain `cargo check`. clippy is intentionally NOT bundled
      # so its version always matches whichever toolchain the repo provides
      # (clippy is version-locked to its rustc).
      # NOTE: launch nvim from inside the repo's environment (direnv /
      # nix develop / rustup shims) so that toolchain is on PATH.
      {
        plugins.lsp.servers.rust_analyzer.enable = true;
        plugins.lsp.servers.rust_analyzer.installCargo = true;
        plugins.lsp.servers.rust_analyzer.installRustc = true;
        plugins.lsp.servers.rust_analyzer.installRustfmt = true;
        plugins.lsp.servers.rust_analyzer.packageFallback = true;
        plugins.lsp.servers.rust_analyzer.settings.check.command = "clippy";
      }

      # === Python ===
      # WHY: ruff is the modern combined linter/formatter for Python;
      # basedpyright is the type-checker + navigation/hover LSP that ruff
      # doesn't provide. basedpyright is a fork of Microsoft's pyright
      # that re-implements the LSP features pyright reserves for the
      # proprietary Pylance extension (inlay hints, semantic tokens,
      # import code-actions, go-to-implementation), so they work in nvim.
      # Swap to plugins.lsp.servers.pyright if you want Microsoft's build.
      {
        plugins.lsp.servers.ruff.enable = true;
        plugins.lsp.servers.ruff.packageFallback = true;
        plugins.lsp.servers.basedpyright.enable = true;
      }

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

      # === Haskell ===
      # WHY: user is starting Haskell. hls is the only real option.
      # installGhc bundles the compiler so the editor is self-contained
      # (mirrors the rust-analyzer pattern above).
      {
        plugins.lsp.servers.hls.enable = true;
        plugins.lsp.servers.hls.installGhc = true;
      }

      # === CMake ===
      # WHY: occasional reading of CMake files. neocmake is the modern
      # successor to the older cmake LSP.
      { plugins.lsp.servers.neocmake.enable = true; }

      # === Ansible ===
      # WHY: occasional playbook editing. Catches YAML schema errors.
      # Nixvim doesn't auto-wire a package for ansiblels; supply it
      # from nixpkgs.
      {
        plugins.lsp.servers.ansiblels.enable = true;
        plugins.lsp.servers.ansiblels.package = pkgs.ansible-language-server;
      }

      # === TypeScript / JavaScript ===
      # WHY: gap in current setup — eslint LSP is a linter, not a
      # navigation/hover language server. ts_ls covers plain .ts/.tsx/.js.
      {
        plugins.lsp.servers.ts_ls.enable = true;
        plugins.lsp.servers.ts_ls.packageFallback = true;
      }

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
        # SpellCheck only attaches harper to these filetypes; code
        # files won't be touched so identifiers aren't flagged.
        plugins.lsp.servers.harper_ls.filetypes = [ "markdown" "text" "gitcommit" ];
        plugins.lsp.servers.harper_ls.settings = {
          "harper-ls" = {
            linters.SentenceCapitalization = false;
            fileDictPath = null;
          };
        };
      }

      # === conform (formatter framework) ===
      # WHY: LSP servers cover formatting for most languages, but markdown
      # and MDX have no LSP formatter. conform runs prettier for those —
      # prettier is the only common formatter that handles MDX at all
      # (dprint/mdformat are CommonMark-only). conform resolves prettier
      # from the repo's node_modules first, then PATH, so each project's
      # own prettier (and its MDX/plugin setup) is used; the nixpkgs
      # prettier bundled via extraPackagesAfter (PATH suffix) is only a
      # last-resort fallback (covers MDX v1 out of the box).
      # .astro is intentionally NOT routed here — it's left to the astro
      # LSP, which formats via the project's prettier-plugin-astro; the
      # bundled prettier lacks that plugin.
      {
        plugins.conform-nvim.enable = true;
        plugins.conform-nvim.settings.formatters_by_ft = {
          markdown = [ "prettier" ];
          mdx = [ "prettier" ];
        };
        # neovim guesses .mdx as `conf`, so conform never matched it. Map
        # .mdx to the compound `markdown.mdx`: markdown tooling still fires
        # (compound FileType events) and conform — which splits compound
        # filetypes on "." — matches the mdx/markdown keys.
        filetype.extension.mdx = "markdown.mdx";
        extraPackagesAfter = [ pkgs.prettier ];
      }

      # === <leader>l LSP keymap leaves ===
      # WHY: lsp module owns <leader>l prefix. These mirror Neovim 0.11's
      # built-in LSP maps (gra/K/grn) under a discoverable which-key
      # group so they surface when you press <leader>l. The built-ins
      # still work; these are the labelled equivalents.
      {
        keymaps = [
          {
            mode = [ "n" "x" ];
            key = "<leader>la";
            action.__raw = "function() vim.lsp.buf.code_action() end";
            options.desc = "Code action / quick fix";
          }
          {
            mode = "n";
            key = "<leader>ld";
            action.__raw = "function() vim.diagnostic.open_float() end";
            options.desc = "Line diagnostics";
          }
          {
            mode = "n";
            key = "<leader>lf";
            # conform for md/mdx (prettier); LSP formatter (ruff, rustfmt,
            # taplo, …) for every other filetype via the fallback.
            action.__raw = "function() require('conform').format({ lsp_format = 'fallback' }) end";
            options.desc = "Format buffer";
          }
          {
            mode = "n";
            key = "<leader>lk";
            action.__raw = "function() vim.lsp.buf.hover() end";
            options.desc = "Hover docs";
          }
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

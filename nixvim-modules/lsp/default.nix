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

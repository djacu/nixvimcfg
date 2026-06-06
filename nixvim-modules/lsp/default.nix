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

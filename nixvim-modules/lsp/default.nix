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

  config = lib.mkIf cfg.enable {

    plugins.lsp.enable = true;

    plugins.lsp.servers.astro.enable = true;

    plugins.lsp.servers.bashls.enable = true;

    plugins.lsp.servers.cssls.enable = true;

    plugins.lsp.servers.eslint.enable = true;

    plugins.lsp.servers.html.enable = true;

    plugins.lsp.servers.gopls.enable = true;
    plugins.lsp.servers.golangci_lint_ls.enable = true;
    extraPackages = [
      pkgs.golangci-lint
    ];

    plugins.lsp.servers.jsonls.enable = true;

    plugins.lsp.servers.nil_ls.enable = false;

    plugins.lsp.servers.nixd.enable = true;

    plugins.lsp.servers.ruff.enable = true;

    lsp.servers.rust_analyzer.enable = true;
    lsp.servers.rust_analyzer.packageFallback = true;
    plugins.lsp.servers.rust_analyzer.enable = true;
    plugins.lsp.servers.rust_analyzer.installCargo = true;
    plugins.lsp.servers.rust_analyzer.installRustc = true;
    plugins.lsp.servers.rust_analyzer.installRustfmt = true;

    plugins.lsp.servers.tailwindcss.enable = true;

    plugins.lsp.servers.taplo.enable = true;

    plugins.lsp.servers.texlab.enable = true;

    plugins.lsp.servers.typos_lsp.enable = true;

    plugins.lsp.servers.tinymist.enable = true;

    plugins.lsp.servers.yamlls.enable = true;

  };
}

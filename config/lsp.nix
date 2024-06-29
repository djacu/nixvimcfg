{ lib, config, ... }:
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
    plugins.lsp.servers.jsonls.enable = true;
    plugins.lsp.servers.nil-ls.enable = false;
    plugins.lsp.servers.nixd.enable = true;
    plugins.lsp.servers.ruff.enable = true;
    plugins.lsp.servers.ruff-lsp.enable = true;
    plugins.lsp.servers.rust-analyzer.enable = true;
    plugins.lsp.servers.rust-analyzer.installCargo = true;
    plugins.lsp.servers.rust-analyzer.installRustc = true;
    plugins.lsp.servers.tailwindcss.enable = true;
    plugins.lsp.servers.texlab.enable = true;
    plugins.lsp.servers.typos-lsp.enable = true;
    plugins.lsp.servers.typst-lsp.enable = true;
    plugins.lsp.servers.yamlls.enable = true;

  };
}

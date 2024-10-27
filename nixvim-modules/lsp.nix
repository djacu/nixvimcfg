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
    plugins.lsp.servers.nil_ls.enable = false;
    plugins.lsp.servers.nixd.enable = true;
    plugins.lsp.servers.ruff.enable = true;
    plugins.lsp.servers.ruff_lsp.enable = true;
    plugins.lsp.servers.rust_analyzer.enable = true;
    plugins.lsp.servers.rust_analyzer.installCargo = true;
    plugins.lsp.servers.rust_analyzer.installRustc = true;
    plugins.lsp.servers.tailwindcss.enable = true;
    plugins.lsp.servers.texlab.enable = true;
    plugins.lsp.servers.typos_lsp.enable = true;
    plugins.lsp.servers.typst_lsp.enable = true;
    plugins.lsp.servers.yamlls.enable = true;
  };
}

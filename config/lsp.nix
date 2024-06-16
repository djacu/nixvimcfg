{ pkgs, ... }:
{
  plugins.coq-nvim.enable = true;
  plugins.coq-nvim.installArtifacts = true;
  plugins.coq-nvim.settings.auto_start = "shut-up";
  plugins.coq-nvim.settings.xdg = true;
  plugins.coq-nvim.settings.completion.always = true;
  plugins.coq-nvim.settings.keymap.recommended = true;

  plugins.lsp.enable = true;
  plugins.lsp.servers.astro.enable = true;
  plugins.lsp.servers.bashls.enable = true;
  plugins.lsp.servers.cssls.enable = true;
  plugins.lsp.servers.eslint.enable = true;
  plugins.lsp.servers.html.enable = true;
  plugins.lsp.servers.jsonls.enable = true;
  plugins.lsp.servers.nil-ls.enable = true;
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

  plugins.conform-nvim =
    let
      pretty = [
        "prettierd"
        "prettier"
      ];
    in
    {
      enable = true;
      formattersByFt = {
        css = pretty;
        html = pretty;
        javascript = pretty;
        json = [ "prettier" ];
        markdown = [ "prettier" ];
        nix = [ "nixfmt" ];
        python = [ "ruff" ];
        rust = [ "rustfmt" ];
        sh = [ "shfmt" ];
        typescript = pretty;
        typst = [ "typstfmt" ];
        yaml = pretty;
      };
    };

  extraPackages = with pkgs; [
    #ruff
    nixfmt-rfc-style
    nodePackages.prettier
    prettierd
    rustfmt
    shfmt
    typstfmt
  ];

  plugins.treesitter.enable = true;
  plugins.treesitter-context.enable = true;
  plugins.treesitter-refactor.enable = true;
  #plugins.treesitter-refactor.highlightCurrentScope.enable = true;
  plugins.treesitter-refactor.highlightDefinitions.enable = true;
  plugins.treesitter-refactor.navigation.enable = true;
  plugins.treesitter-refactor.smartRename.enable = true;
}

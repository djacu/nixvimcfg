{ ... }:
{
  imports = [
    ./conform-nvim.nix
    ./coq-nvim.nix
    ./fugitive.nix
    ./lsp.nix
    ./telescope.nix
    ./treesitter.nix
    ./which-key.nix
  ];

  config = {

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      spell = true;
      spelllang = "en_us";
    };

    globals.mapleader = " ";

    colorschemes.kanagawa.enable = true;

    plugins.bufferline.enable = true;
    plugins.chadtree.enable = true;
    plugins.comment.enable = true;
    plugins.lightline.enable = true;
    plugins.nvim-autopairs.enable = true;
    plugins.surround.enable = true;

    nixvimcfg.conform-nvim.enable = true;
    nixvimcfg.coq-nvim.enable = true;
    nixvimcfg.fugitive.enable = true;
    nixvimcfg.lsp.enable = true;
    nixvimcfg.telescope.enable = true;
    nixvimcfg.treesitter.enable = true;
    nixvimcfg.which-key.enable = true;

  };
}

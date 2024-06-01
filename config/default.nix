{ pkgs, ... }:
{
  imports = [
    ./lsp.nix
    ./telescope.nix
    ./which-key.nix
  ];

  config = {
    globals.mapleader = " ";

    colorschemes.kanagawa.enable = true;

    plugins.bufferline.enable = true;
    plugins.comment.enable = true;
    plugins.chadtree.enable = true;
    plugins.fugitive.enable = true;
    plugins.lightline.enable = true;
    plugins.nvim-autopairs.enable = true;
    plugins.surround.enable = true;
  };
}

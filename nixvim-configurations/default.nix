inputs: {
  default =
    { ... }:
    {
      imports = [
        ../nixvim-modules/cmp.nix
        ../nixvim-modules/conform-nvim.nix
        ../nixvim-modules/coq-nvim.nix
        ../nixvim-modules/fugitive.nix
        ../nixvim-modules/lsp.nix
        ../nixvim-modules/render-markdown.nix
        ../nixvim-modules/telescope.nix
        ../nixvim-modules/treesitter.nix
        ../nixvim-modules/which-key.nix
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
        plugins.vim-surround.enable = true;

        nixvimcfg.cmp.enable = true;
        nixvimcfg.conform-nvim.enable = true;
        # nixvimcfg.coq-nvim.enable = true;
        nixvimcfg.fugitive.enable = true;
        nixvimcfg.lsp.enable = true;
        nixvimcfg.render-markdown.enable = true;
        nixvimcfg.telescope.enable = true;
        nixvimcfg.treesitter.enable = true;
        nixvimcfg.which-key.enable = true;
      };
    };
}

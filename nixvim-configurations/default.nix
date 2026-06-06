inputs: {
  default =
    { ... }:
    {
      imports = [
        inputs.self.nixvimModules.default
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

        plugins.chadtree.enable = false;
        plugins.comment.enable = true;
        plugins.nvim-autopairs.enable = true;
        plugins.vim-surround.enable = true;

        nixvimcfg.completion.enable = true;
        # nixvimcfg.coq-nvim.enable = true;
        nixvimcfg.fugitive.enable = true;
        nixvimcfg.lsp.enable = true;
        nixvimcfg.picker.enable = true;
        nixvimcfg.treesitter.enable = true;
        nixvimcfg.ui.enable = true;
        nixvimcfg.which-key.enable = true;
      };
    };
}

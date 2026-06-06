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

        nixvimcfg.completion.enable = true;
        # nixvimcfg.coq-nvim.enable = true;
        nixvimcfg.dap.enable = true;
        nixvimcfg.editing.enable = true;
        nixvimcfg.files.enable = true;
        nixvimcfg.git.enable = true;
        nixvimcfg.lsp.enable = true;
        nixvimcfg.navigation.enable = true;
        nixvimcfg.neotest.enable = true;
        nixvimcfg.picker.enable = true;
        nixvimcfg.snacks.enable = true;
        nixvimcfg.treesitter.enable = true;
        nixvimcfg.typst.enable = true;
        nixvimcfg.ui.enable = true;
        nixvimcfg.which-key.enable = true;
      };
    };
}

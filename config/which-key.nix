{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.which-key;
in
{
  options.nixvimcfg.which-key.enable = lib.mkEnableOption "which-key setup";

  config = lib.mkIf cfg.enable {
    plugins.which-key.enable = true;
    plugins.which-key.settings.show_keys = true;
    plugins.which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>w";
        __unkeyed-2 = "<cmd>WhichKey<cr>";
        desc = "WhichKey?!";
      }
    ];

    extraConfigLua = ''
      vim.o.timeout = true
      vim.o.timeoutlen = 100
    '';
  };
}

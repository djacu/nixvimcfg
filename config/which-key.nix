{
  lib,
  config,
  nixvimLib,
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

    extraConfigLua =
      let
        mappings = {
          w = [
            "<cmd>WhichKey<cr>"
            " WhichKey?!"
          ];
        };
        opts = {
          prefix = "<leader>";
        };
      in
      ''
        vim.o.timeout = true
        vim.o.timeoutlen = 100

        require("which-key").register(
          ${nixvimLib.helpers.toLuaObject mappings},
          ${nixvimLib.helpers.toLuaObject opts}
        )
      '';
  };
}

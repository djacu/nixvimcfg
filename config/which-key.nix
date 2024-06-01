{ nixvimLib, ... }:
{
  plugins.which-key.enable = true;
  plugins.which-key.showKeys = true;
  extraConfigLua =
    let
      mappings = {
        f = {
          name = " Telescope";
          f = [
            "<cmd>Telescope find_files<cr>"
            "Find File"
          ];
          r = [
            "<cmd>Telescope oldfiles<cr>"
            "Open Recent File"
          ];
          m = [
            "<cmd>Telescope media_files<cr>"
            "Open Media File"
          ];
          b = [
            "<cmd>Telescope file_browser<cr>"
            "File Browser"
          ];
        };
        w = [
          "<cmd>WhichKey<cr>"
          " WhichKey?!"
        ];
        l = {
          name = " LSP";
          m = [
            "<cmd>lua require(\"conform\").format()<cr>"
            "Format"
          ];
        };
      };
      opts = {
        prefix = "<leader>";
      };
    in
    ''
      require("which-key").register(${nixvimLib.helpers.toLuaObject mappings},  ${nixvimLib.helpers.toLuaObject opts})
    '';
}

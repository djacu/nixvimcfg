{
  lib,
  config,
  nixvimLib,
  ...
}:
let
  cfg = config.nixvimcfg.fugitive;
in
{
  options.nixvimcfg.fugitive.enable = lib.mkEnableOption "fugitive setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      { plugins.fugitive.enable = true; }

      (lib.mkIf config.nixvimcfg.which-key.enable {

        extraConfigLua =
          let
            mappings = {
              g = {
                name = "犯 Fugitive";
                a = [
                  "<cmd>Git add %:p<cr>"
                  "add"
                ];
                b = [
                  "<cmd>Git blame<cr>"
                  "blame"
                ];
                c = [
                  "<cmd>Git commit<cr>"
                  "commit"
                ];
                d = [
                  "<cmd>Git diff<cr>"
                  "diff"
                ];
                g = [
                  "<cmd>Git<cr>"
                  ":Git"
                ];
                l = [
                  "<cmd>Git log<cr>"
                  "log"
                ];
                pl = [
                  "<cmd>Git pull<cr>"
                  "pull"
                ];
                ps = [
                  "<cmd>Git push<cr>"
                  "push"
                ];
              };
            };
            opts = {
              prefix = "<leader>";
            };
          in
          ''
            require("which-key").register(
              ${nixvimLib.helpers.toLuaObject mappings},
              ${nixvimLib.helpers.toLuaObject opts}
            )
          '';

      })
    ]
  );
}

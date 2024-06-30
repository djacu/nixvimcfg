{
  lib,
  config,
  nixvimLib,
  ...
}:
let
  cfg = config.nixvimcfg.treesitter;
in
{
  options.nixvimcfg.treesitter.enable = lib.mkEnableOption "treesitter setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      {

        plugins.treesitter.enable = true;
        plugins.treesitter-refactor.enable = true;
        plugins.treesitter-refactor.highlightCurrentScope.enable = false;
        plugins.treesitter-refactor.highlightDefinitions.enable = true;
        plugins.treesitter-refactor.navigation.enable = true;
        plugins.treesitter-refactor.smartRename.enable = true;

      }

      {

        plugins.treesitter-context.enable = true;
        plugins.treesitter-context.settings.enable = false;
        plugins.treesitter-context.settings.trim_scope = "outer";

      }

      {

        plugins.treesitter.folding = true;

        extraConfigLua = ''
          vim.opt.foldenable = false
        '';

      }

      (lib.mkIf config.nixvimcfg.which-key.enable {

        extraConfigLua =
          let
            mappings = {

              t = {

                name = "木 Treesitter";

                c = [
                  "<cmd>TSContextToggle<cr>"
                  "Context Toggle"
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

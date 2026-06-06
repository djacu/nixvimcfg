{
  lib,
  config,
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

      }

      {

        plugins.treesitter.highlight.enable = true;

      }

      {

        plugins.treesitter-context.enable = true;
        plugins.treesitter-context.settings.enable = false;
        plugins.treesitter-context.settings.trim_scope = "outer";

      }

      {

        plugins.treesitter.folding.enable = true;

        extraConfigLua = ''
          vim.opt.foldenable = false
        '';

      }

      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>t";
            group = "木 Treesitter";
          }
          {
            __unkeyed-1 = "<leader>tc";
            __unkeyed-2 = "<cmd>TSContextToggle<cr>";
            desc = "Context Toggle";
          }
        ];
      })
    ]
  );
}

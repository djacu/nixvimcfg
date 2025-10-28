{
  lib,
  config,
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
        plugins.which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>g";
            group = "犯 Fugitive";
          }
          {
            __unkeyed-1 = "<leader>ga";
            __unkeyed-2 = "<cmd>Git add %:p<cr>";
            desc = "add";
          }
          {
            __unkeyed-1 = "<leader>gb";
            __unkeyed-2 = "<cmd>Git blame<cr>";
            desc = "blame";
          }
          {
            __unkeyed-1 = "<leader>gc";
            __unkeyed-2 = "<cmd>Git commit<cr>";
            desc = "commit";
          }
          {
            __unkeyed-1 = "<leader>gd";
            __unkeyed-2 = "<cmd>Git diff<cr>";
            desc = "diff";
          }
          {
            __unkeyed-1 = "<leader>gg";
            __unkeyed-2 = "<cmd>Git<cr>";
            desc = ":Git";
          }
          {
            __unkeyed-1 = "<leader>gl";
            __unkeyed-2 = "<cmd>Git log<cr>";
            desc = "log";
          }
          {
            __unkeyed-1 = "<leader>gpl";
            __unkeyed-2 = "<cmd>Git pull<cr>";
            desc = "pull";
          }
          {
            __unkeyed-1 = "<leader>gps";
            __unkeyed-2 = "<cmd>Git push<cr>";
            desc = "push";
          }
        ];
      })
    ]
  );
}

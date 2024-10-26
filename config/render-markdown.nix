{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.render-markdown;
in
{
  options.nixvimcfg.render-markdown.enable = lib.mkEnableOption "render-markdown setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { plugins.render-markdown.enable = true; }

      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>m";
            group = "マ Markdown";
          }
          {
            __unkeyed-1 = "<leader>me";
            __unkeyed-2 = "<cmd>RenderMarkdown enable<cr>";
            desc = "Render Enable";
          }
          {
            __unkeyed-1 = "<leader>md";
            __unkeyed-2 = "<cmd>RenderMarkdown disable<cr>";
            desc = "Render Disable";
          }
        ];
      })
    ]
  );
}

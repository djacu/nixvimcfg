{
  lib,
  config,
  nixvimLib,
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

        extraConfigLua =
          let
            mappings = {

              m = {

                name = "マ Markdown";

                e = [
                  "<cmd>RenderMarkdown enable<cr>"
                  "Render Markdown Enable"
                ];

                d = [
                  "<cmd>RenderMarkdown disable<cr>"
                  "Render Markdown Disable"
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

{
  lib,
  config,
  pkgs,
  nixvimLib,
  ...
}:
let
  cfg = config.nixvimcfg.telescope;
in
{
  options.nixvimcfg.telescope.enable = lib.mkEnableOption "telescope setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {

        plugins.telescope.enable = true;
        plugins.telescope.extensions.file-browser.enable = true;
        plugins.telescope.extensions.frecency.enable = true;
        plugins.telescope.extensions.fzf-native.enable = true;
        plugins.telescope.extensions.media-files.enable = true;
        plugins.telescope.extensions.media-files.settings.filetypes = [
          "png"
          "jpg"
          "gif"
          "mp4"
          "webm"
          "pdf"
          "svg"
        ];
        plugins.telescope.extensions.media-files.settings.find_cmd = "fd";
        plugins.telescope.extensions.media-files.dependencies.chafa.enable = true;
        plugins.telescope.extensions.media-files.dependencies.epub-thumbnailer.enable = true;
        plugins.telescope.extensions.media-files.dependencies.ffmpegthumbnailer.enable = true;
        plugins.telescope.extensions.media-files.dependencies.fontpreview.enable = true;
        plugins.telescope.extensions.media-files.dependencies.imageMagick.enable = true;
        plugins.telescope.extensions.media-files.dependencies.pdftoppm.enable = true;

        extraPackages = with pkgs; [ fd ];

      }

      (lib.mkIf config.nixvimcfg.which-key.enable {

        extraConfigLua =
          let
            mappings = {
              f = {
                name = " Telescope";
                b = [
                  "<cmd>Telescope file_browser<cr>"
                  "File Browser"
                ];
                f = [
                  "<cmd>Telescope find_files<cr>"
                  "Find File"
                ];
                l = [
                  "<cmd>Telescope live_grep<cr>"
                  "Live Grep"
                ];
                m = [
                  "<cmd>Telescope media_files<cr>"
                  "Open Media File"
                ];
                r = [
                  "<cmd>Telescope oldfiles<cr>"
                  "Open Recent File"
                ];
                t = [
                  "<cmd>Telescope<cr>"
                  "Telescope"
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

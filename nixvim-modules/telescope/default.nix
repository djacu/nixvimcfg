{
  lib,
  config,
  pkgs,
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
        plugins.mini.enable = true;
        # plugins.mini.modules.icons = true;
        plugins.web-devicons.enable = true;

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

        dependencies.poppler-utils.enable = true;
        dependencies.imagemagick.enable = true;
        dependencies.fontpreview.enable = true;
        dependencies.ffmpegthumbnailer.enable = true;
        dependencies.epub-thumbnailer.enable = true;
        dependencies.chafa.enable = true;

        extraPackages = with pkgs; [ fd ];
      }

      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = " Telescope";
          }
          {
            __unkeyed-1 = "<leader>fb";
            __unkeyed-2 = "<cmd>Telescope file_browser<cr>";
            desc = "File Browser";
          }
          {
            __unkeyed-1 = "<leader>ff";
            __unkeyed-2 = "<cmd>Telescope find_files<cr>";
            desc = "Find File";
          }
          {
            __unkeyed-1 = "<leader>fl";
            __unkeyed-2 = "<cmd>Telescope live_grep<cr>";
            desc = "Live Grep";
          }
          {
            __unkeyed-1 = "<leader>fm";
            __unkeyed-2 = "<cmd>Telescope media_files<cr>";
            desc = "Open Media File";
          }
          {
            __unkeyed-1 = "<leader>fr";
            __unkeyed-2 = "<cmd>Telescope oldfiles<cr>";
            desc = "Open Recent File";
          }
          {
            __unkeyed-1 = "<leader>ft";
            __unkeyed-2 = "<cmd>Telescope<cr>";
            desc = "Telescope";
          }
        ];
      })
    ]
  );
}

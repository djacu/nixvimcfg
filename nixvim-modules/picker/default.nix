{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.nixvimcfg.picker;
in
{
  options.nixvimcfg.picker.enable = lib.mkEnableOption "telescope picker + extensions";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === telescope core ===
      # WHY: the picker engine itself; everything else extends it.
      {
        plugins.telescope.enable = true;
        extraPackages = with pkgs; [ fd ];
      }

      # === mini.nvim + web-devicons for icons ===
      # WHY: telescope (and bufferline) expect nvim-web-devicons. mini.nvim
      # is enabled here as a placeholder; phase 7 (ui) will switch to
      # mini.icons with mockDevIcons. For now we keep web-devicons
      # explicit so the strict deprecation check passes without changing
      # the icon set in use.
      {
        plugins.mini.enable = true;
        plugins.web-devicons.enable = true;
      }

      # === extension: file-browser ===
      # WHY: file ops from inside the picker (rename/delete/create).
      {
        plugins.telescope.extensions.file-browser.enable = true;
      }

      # === extension: frecency ===
      # WHY: smart ordering of MRU + frequency.
      { plugins.telescope.extensions.frecency.enable = true; }

      # === extension: fzf-native ===
      # WHY: faster matcher (C implementation) for large repos.
      { plugins.telescope.extensions.fzf-native.enable = true; }

      # === extension: media-files ===
      # WHY: preview images/PDFs/videos inside telescope. Requires
      # poppler-utils (PDF), imagemagick (image conv), ffmpegthumbnailer
      # (video frames), epub-thumbnailer (epubs), chafa (terminal display),
      # fontpreview (font files), fd (find binary).
      {
        plugins.telescope.extensions.media-files.enable = true;
        plugins.telescope.extensions.media-files.settings.filetypes = [
          "png" "jpg" "gif" "mp4" "webm" "pdf" "svg"
        ];
        plugins.telescope.extensions.media-files.settings.find_cmd = "fd";

        dependencies.poppler-utils.enable = true;
        dependencies.imagemagick.enable = true;
        dependencies.fontpreview.enable = true;
        dependencies.ffmpegthumbnailer.enable = true;
        dependencies.epub-thumbnailer.enable = true;
        dependencies.chafa.enable = true;
      }

      # === which-key leaves under <leader>f ===
      # WHY: keymaps for the picker live with the picker; the <leader>f
      # group prefix is declared in the central which-key registry.
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>fb"; __unkeyed-2 = "<cmd>Telescope file_browser<cr>"; desc = "File Browser"; }
          { __unkeyed-1 = "<leader>ff"; __unkeyed-2 = "<cmd>Telescope find_files<cr>"; desc = "Find File"; }
          { __unkeyed-1 = "<leader>fl"; __unkeyed-2 = "<cmd>Telescope live_grep<cr>"; desc = "Live Grep"; }
          { __unkeyed-1 = "<leader>fm"; __unkeyed-2 = "<cmd>Telescope media_files<cr>"; desc = "Open Media File"; }
          { __unkeyed-1 = "<leader>fr"; __unkeyed-2 = "<cmd>Telescope oldfiles<cr>"; desc = "Open Recent File"; }
          { __unkeyed-1 = "<leader>ft"; __unkeyed-2 = "<cmd>Telescope<cr>"; desc = "Telescope (all)"; }
        ];
      })

    ]
  );
}

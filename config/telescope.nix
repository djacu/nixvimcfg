{ pkgs, ... }:
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

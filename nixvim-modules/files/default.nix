{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.files;
in
{
  options.nixvimcfg.files.enable = lib.mkEnableOption "oil.nvim buffer-as-fs file explorer";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === oil.nvim ===
      # WHY: edit the filesystem as a buffer. Replaces chadtree (which
      # was already disabled in the previous config). `<leader>e` opens
      # oil at the current buffer's directory.
      {
        plugins.oil.enable = true;
        plugins.oil.settings.default_file_explorer = true;
      }

      # === which-key leaves ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>e"; __unkeyed-2 = "<cmd>Oil<cr>"; desc = "Explore (oil)"; }
        ];
      })

    ]
  );
}

{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.nixvimcfg.navigation;
in
{
  options.nixvimcfg.navigation.enable = lib.mkEnableOption "navigation (flash, harpoon, aerial, grug-far)";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === flash.nvim ===
      # WHY: jump-anywhere motion. `s` enters jump mode, type 2 chars
      # to see labels, type the label to jump.
      { plugins.flash.enable = true; }

      # === harpoon (v2 via package override) ===
      # WHY: marked-file quick navigation. First-class nixvim module;
      # package set to vimPlugins.harpoon2 (the recommended branch).
      # enableTelescope wires the :Telescope harpoon marks integration.
      {
        plugins.harpoon.enable = true;
        plugins.harpoon.package = pkgs.vimPlugins.harpoon2;
        plugins.harpoon.enableTelescope = true;
      }

      # === aerial ===
      # WHY: symbol outline sidebar. Persistent view of functions /
      # classes / sections in the current file.
      { plugins.aerial.enable = true; }

      # === grug-far ===
      # WHY: project-wide find/replace with editable-buffer UX. Replaces
      # nvim-spectre.
      { plugins.grug-far.enable = true; }

      # === which-key leaves: <leader>h (Harpoon), <leader>a (Aerial), <leader>s (Search) ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          # Harpoon
          { __unkeyed-1 = "<leader>ha"; __unkeyed-2.__raw = "function() require('harpoon'):list():add() end"; desc = "Add to Harpoon"; }
          { __unkeyed-1 = "<leader>hh"; __unkeyed-2.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end"; desc = "Toggle Harpoon menu"; }
          { __unkeyed-1 = "<leader>h1"; __unkeyed-2.__raw = "function() require('harpoon'):list():select(1) end"; desc = "Slot 1"; }
          { __unkeyed-1 = "<leader>h2"; __unkeyed-2.__raw = "function() require('harpoon'):list():select(2) end"; desc = "Slot 2"; }
          { __unkeyed-1 = "<leader>h3"; __unkeyed-2.__raw = "function() require('harpoon'):list():select(3) end"; desc = "Slot 3"; }
          { __unkeyed-1 = "<leader>h4"; __unkeyed-2.__raw = "function() require('harpoon'):list():select(4) end"; desc = "Slot 4"; }
          { __unkeyed-1 = "<leader>hn"; __unkeyed-2.__raw = "function() require('harpoon'):list():next() end"; desc = "Next slot"; }
          { __unkeyed-1 = "<leader>hp"; __unkeyed-2.__raw = "function() require('harpoon'):list():prev() end"; desc = "Prev slot"; }
          # Aerial
          { __unkeyed-1 = "<leader>aa"; __unkeyed-2 = "<cmd>AerialToggle<cr>"; desc = "Toggle Aerial"; }
          { __unkeyed-1 = "<leader>an"; __unkeyed-2 = "<cmd>AerialNext<cr>"; desc = "Aerial Next"; }
          { __unkeyed-1 = "<leader>ap"; __unkeyed-2 = "<cmd>AerialPrev<cr>"; desc = "Aerial Prev"; }
          # Search/Replace (grug-far)
          { __unkeyed-1 = "<leader>ss"; __unkeyed-2.__raw = "function() require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } }) end"; desc = "Search word"; }
          { __unkeyed-1 = "<leader>sg"; __unkeyed-2.__raw = "function() require('grug-far').open() end"; desc = "Search (global)"; }
        ];
      })

    ]
  );
}

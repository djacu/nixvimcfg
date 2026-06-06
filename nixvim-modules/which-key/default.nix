{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.which-key;
in
{
  options.nixvimcfg.which-key.enable = lib.mkEnableOption "which-key setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === which-key core + delay tuning ===
      # WHY: 200ms popup delay (previous timeoutlen=100 fired before
      # multi-key sequences finished).
      {
        plugins.which-key.enable = true;
        plugins.which-key.settings.show_keys = true;
        plugins.which-key.settings.delay = 200;
      }

      # === presets ===
      # WHY: auto-document built-in keys (registers, marks, windows,
      # z-commands, operators, motions, text-objects).
      {
        plugins.which-key.settings.preset = "modern";
        plugins.which-key.settings.plugins = {
          marks = true;
          registers = true;
          presets = {
            operators = true;
            motions = true;
            text_objects = true;
            windows = true;
            nav = true;
            z = true;
            g = true;
          };
        };
      }

      # === central key-group registry ===
      # WHY: every <leader>X group prefix declared here exactly once.
      # Individual plugin modules append their leaf keymaps; the group
      # labels live here so there's a single grep target.
      {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>?"; group = " Discover"; }
          { __unkeyed-1 = "<leader>a"; group = " Aerial"; }
          { __unkeyed-1 = "<leader>b"; group = " Buffer"; }
          { __unkeyed-1 = "<leader>c"; group = " Code"; }
          { __unkeyed-1 = "<leader>d"; group = " Debug"; }
          { __unkeyed-1 = "<leader>f"; group = " Find"; }
          { __unkeyed-1 = "<leader>g"; group = " Git"; }
          { __unkeyed-1 = "<leader>gh"; group = " Hunks"; }
          { __unkeyed-1 = "<leader>h"; group = "ﯬ Harpoon"; }
          { __unkeyed-1 = "<leader>l"; group = " LSP"; }
          { __unkeyed-1 = "<leader>m"; group = " Markdown"; }
          { __unkeyed-1 = "<leader>n"; group = " Notifications"; }
          { __unkeyed-1 = "<leader>o"; group = " Toggle"; }
          { __unkeyed-1 = "<leader>s"; group = " Search/Replace"; }
          { __unkeyed-1 = "<leader>t"; group = " Test"; }
          { __unkeyed-1 = "<leader>x"; group = " Trouble"; }
        ];
      }

      # === <leader>? discovery namespace ===
      # WHY: this directly serves the user's stated "I always am unsure
      # how to use plugins" pain — Telescope built-ins expose every
      # registered keymap, command, and help tag.
      {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>?k"; __unkeyed-2 = "<cmd>Telescope keymaps<cr>"; desc = "Keymaps"; }
          { __unkeyed-1 = "<leader>?c"; __unkeyed-2 = "<cmd>Telescope commands<cr>"; desc = "Commands"; }
          { __unkeyed-1 = "<leader>?h"; __unkeyed-2 = "<cmd>Telescope help_tags<cr>"; desc = "Help Tags"; }
          { __unkeyed-1 = "<leader>?t"; __unkeyed-2 = "<cmd>Telescope builtin<cr>"; desc = "Telescope builtins"; }
          { __unkeyed-1 = "<leader>?p"; __unkeyed-2 = "<cmd>Telescope<cr>"; desc = "Pick a picker"; }
          { __unkeyed-1 = "<leader>w"; __unkeyed-2 = "<cmd>WhichKey<cr>"; desc = "WhichKey?!"; }
        ];
      }

    ]
  );
}

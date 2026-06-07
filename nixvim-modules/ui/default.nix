{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.ui;
in
{
  options.nixvimcfg.ui.enable = lib.mkEnableOption "ui plugins (lualine, mini.tabline, fidget, noice, etc.)";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === lualine ===
      # WHY: statusline; replaces lightline. Default sections cover
      # mode | branch+diff+diagnostics | filename | filetype+location.
      {
        plugins.lualine.enable = true;
        plugins.lualine.settings.options.theme = "auto";
        plugins.lualine.settings.options.globalstatus = true;
      }

      # === mini.icons + mini.tabline + mini.indentscope ===
      # WHY: declared on plugins.mini.modules so all mini submodules
      # share one runtimepath entry (avoids the closure footgun where
      # mixing plugins.mini.modules with plugins.mini-tabline would
      # double-register mini.nvim).
      # mini.icons.mock_nvim_web_devicons makes telescope/oil etc. find
      # mini.icons when they require 'nvim-web-devicons'.
      {
        plugins.mini.enable = true;
        plugins.mini.modules.icons = {
          mock_nvim_web_devicons = true;
        };
        plugins.mini.modules.tabline = { };
        plugins.mini.modules.indentscope = { };

        # Force-disable plugins.web-devicons so it doesn't double-load
        # alongside mini.icons. mini.icons' shim covers everything.
        plugins.web-devicons.enable = lib.mkForce false;
      }

      # === noice ===
      # WHY: cmdline / messages overlay UI. lsp.progress explicitly
      # disabled so it doesn't overlap fidget's corner spinner.
      {
        plugins.noice.enable = true;
        plugins.noice.settings.lsp.progress.enabled = false;
      }

      # === fidget ===
      # WHY: LSP progress indicator in the corner. Owns the LSP-progress
      # surface since we disabled it in noice.
      { plugins.fidget.enable = true; }

      # === todo-comments ===
      # WHY: highlight TODO/FIXME/HACK/NOTE keywords; pairs with
      # :TodoTelescope picker.
      { plugins.todo-comments.enable = true; }

      # === render-markdown ===
      # WHY: inline markdown rendering (decorates headings, code blocks,
      # lists, tables in-buffer). External preview deliberately not
      # added — use `glow` / `pandoc` from the shell when fidelity needed.
      { plugins.render-markdown.enable = true; }

      # === nvim-origami ===
      # WHY: LSP-aware folding (with treesitter fallback). Lighter
      # replacement for nvim-ufo. The README explicitly says it provides
      # folding, not just decoration.
      { plugins.origami.enable = true; }

      # === quicker.nvim ===
      # WHY: editable quickfix buffer UI; modern replacement for the
      # default :copen experience.
      { plugins.quicker.enable = true; }

      # === trouble.nvim ===
      # WHY: diagnostics/references/quickfix list with collapsible UI.
      # Required — referenced by <leader>x in the which-key registry.
      { plugins.trouble.enable = true; }

      # === which-key leaves ===
      # WHY: ui-owned <leader>x (Trouble), <leader>m (Markdown),
      # <leader>n (Notifications) keymaps.
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          # Trouble
          { __unkeyed-1 = "<leader>xx"; __unkeyed-2 = "<cmd>Trouble diagnostics toggle<cr>"; desc = "Diagnostics (Trouble)"; }
          { __unkeyed-1 = "<leader>xd"; __unkeyed-2 = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"; desc = "Document Diagnostics"; }
          { __unkeyed-1 = "<leader>xl"; __unkeyed-2 = "<cmd>Trouble loclist toggle<cr>"; desc = "Location List"; }
          { __unkeyed-1 = "<leader>xq"; __unkeyed-2 = "<cmd>Trouble qflist toggle<cr>"; desc = "Quickfix List"; }
          # Markdown
          { __unkeyed-1 = "<leader>me"; __unkeyed-2 = "<cmd>RenderMarkdown enable<cr>"; desc = "Render Enable"; }
          { __unkeyed-1 = "<leader>md"; __unkeyed-2 = "<cmd>RenderMarkdown disable<cr>"; desc = "Render Disable"; }
          # Notifications (noice history)
          { __unkeyed-1 = "<leader>nh"; __unkeyed-2 = "<cmd>Noice history<cr>"; desc = "Noice History"; }
          { __unkeyed-1 = "<leader>nd"; __unkeyed-2 = "<cmd>Noice dismiss<cr>"; desc = "Dismiss"; }
          # Todo (under Trouble group)
          { __unkeyed-1 = "<leader>xt"; __unkeyed-2 = "<cmd>TodoTelescope<cr>"; desc = "TODOs (Telescope)"; }
        ];
      })

    ]
  );
}

{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.git;
in
{
  options.nixvimcfg.git.enable = lib.mkEnableOption "git plugins (neogit, gitsigns, diffview)";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === gitsigns ===
      # WHY: gutter signs for add/change/delete, inline hunk staging,
      # inline blame on current line.
      {
        plugins.gitsigns.enable = true;
        plugins.gitsigns.settings.current_line_blame = false;
      }

      # === diffview ===
      # WHY: full-screen diff browser + file history (replaces
      # fugitive's :Gedit HEAD~N:%).
      { plugins.diffview.enable = true; }

      # === neogit ===
      # WHY: Magit-style interactive porcelain. Replaces fugitive
      # entirely. Integrates with diffview for diff popups.
      {
        plugins.neogit.enable = true;
        plugins.neogit.settings.integrations.diffview = true;
      }

      # === which-key leaves: 24 git bindings ===
      # WHY: each plugin owns its slice — neogit popups, gitsigns hunks
      # under <leader>gh, diffview ops under <leader>gv/V/w.
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          # neogit porcelain
          { __unkeyed-1 = "<leader>gg"; __unkeyed-2 = "<cmd>Neogit<cr>"; desc = "Status (neogit)"; }
          { __unkeyed-1 = "<leader>gc"; __unkeyed-2 = "<cmd>Neogit commit<cr>"; desc = "Commit"; }
          { __unkeyed-1 = "<leader>gC"; __unkeyed-2 = "<cmd>Neogit commit --amend<cr>"; desc = "Commit --amend"; }
          { __unkeyed-1 = "<leader>gp"; __unkeyed-2 = "<cmd>Neogit push<cr>"; desc = "Push"; }
          { __unkeyed-1 = "<leader>gP"; __unkeyed-2 = "<cmd>Neogit pull<cr>"; desc = "Pull"; }
          { __unkeyed-1 = "<leader>gf"; __unkeyed-2 = "<cmd>Neogit fetch<cr>"; desc = "Fetch"; }
          { __unkeyed-1 = "<leader>gb"; __unkeyed-2 = "<cmd>Gitsigns blame<cr>"; desc = "Blame (buffer)"; }
          { __unkeyed-1 = "<leader>gB"; __unkeyed-2 = "<cmd>Neogit branch<cr>"; desc = "Branch"; }
          { __unkeyed-1 = "<leader>gs"; __unkeyed-2 = "<cmd>Neogit stash<cr>"; desc = "Stash"; }
          { __unkeyed-1 = "<leader>gm"; __unkeyed-2 = "<cmd>Neogit merge<cr>"; desc = "Merge"; }
          { __unkeyed-1 = "<leader>gr"; __unkeyed-2 = "<cmd>Neogit rebase<cr>"; desc = "Rebase"; }
          { __unkeyed-1 = "<leader>gx"; __unkeyed-2 = "<cmd>Neogit cherry_pick<cr>"; desc = "Cherry-pick"; }
          { __unkeyed-1 = "<leader>gz"; __unkeyed-2 = "<cmd>Neogit reset<cr>"; desc = "Reset"; }
          { __unkeyed-1 = "<leader>gl"; __unkeyed-2 = "<cmd>Neogit log<cr>"; desc = "Log"; }
          # intent-to-add: track the current file without staging contents.
          # Useful so gitsigns starts rendering hunk signs for new files
          # without committing yet. (Neogit has no built-in equivalent.)
          {
            __unkeyed-1 = "<leader>gn";
            __unkeyed-2.__raw = ''
              function()
                local file = vim.fn.expand('%:p')
                if vim.fn.empty(file) == 1 then
                  vim.notify('No file in current buffer', vim.log.levels.WARN)
                  return
                end
                local result = vim.fn.system({ 'git', 'add', '-N', file })
                if vim.v.shell_error ~= 0 then
                  vim.notify('git add -N failed: ' .. result, vim.log.levels.ERROR)
                  return
                end
                vim.notify('Intent-to-add: ' .. vim.fn.expand('%:.'))
                pcall(function() require('gitsigns').refresh() end)
              end
            '';
            desc = "Intent-to-add (git add -N)";
          }
          # diffview
          { __unkeyed-1 = "<leader>gv"; __unkeyed-2 = "<cmd>DiffviewOpen<cr>"; desc = "Diffview open"; }
          { __unkeyed-1 = "<leader>gV"; __unkeyed-2 = "<cmd>DiffviewClose<cr>"; desc = "Diffview close"; }
          { __unkeyed-1 = "<leader>gw"; __unkeyed-2 = "<cmd>DiffviewFileHistory %<cr>"; desc = "File history"; }
          # gitsigns hunks (under <leader>gh group prefix declared in which-key registry)
          { __unkeyed-1 = "<leader>ghs"; __unkeyed-2 = "<cmd>Gitsigns stage_hunk<cr>"; desc = "Stage hunk"; }
          { __unkeyed-1 = "<leader>ghr"; __unkeyed-2 = "<cmd>Gitsigns reset_hunk<cr>"; desc = "Reset hunk"; }
          { __unkeyed-1 = "<leader>ghp"; __unkeyed-2 = "<cmd>Gitsigns preview_hunk<cr>"; desc = "Preview hunk"; }
          { __unkeyed-1 = "<leader>ghu"; __unkeyed-2 = "<cmd>Gitsigns undo_stage_hunk<cr>"; desc = "Undo stage hunk"; }
          { __unkeyed-1 = "<leader>ghd"; __unkeyed-2 = "<cmd>Gitsigns diffthis<cr>"; desc = "Diff vs index"; }
          # inline blame toggle (under Toggle group; the prime <leader>gb
          # opens the full blame buffer above)
          { __unkeyed-1 = "<leader>ob"; __unkeyed-2 = "<cmd>Gitsigns toggle_current_line_blame<cr>"; desc = "Inline git blame"; }
        ];
      })

    ]
  );
}

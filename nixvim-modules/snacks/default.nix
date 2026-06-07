{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.snacks;
in
{
  options.nixvimcfg.snacks.enable = lib.mkEnableOption "snacks.nvim with selected submodules";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === bigfile ===
      # WHY: disable expensive features on large files. Near-zero
      # config; real perf win for logs / generated code.
      {
        plugins.snacks.enable = true;
        plugins.snacks.settings.bigfile.enabled = true;
      }

      # === statuscolumn ===
      # WHY: unified gutter (signs / numbers / git). folds.open = false
      # so nvim-origami owns the fold UI; statuscolumn handles only
      # signs and numbers.
      {
        plugins.snacks.settings.statuscolumn.enabled = true;
        plugins.snacks.settings.statuscolumn.folds.open = false;
      }

      # === quickfile ===
      # WHY: renders the file before plugins fully load. Perceptible
      # startup feel improvement.
      { plugins.snacks.settings.quickfile.enabled = true; }

      # === words ===
      # WHY: LSP-reference auto-highlight + ]]/[[ navigation. Closest
      # replacement for the lost treesitter-refactor.highlightDefinitions.
      { plugins.snacks.settings.words.enabled = true; }

      # === toggle ===
      # WHY: auto-registers per-option toggles (spell, wrap,
      # diagnostics, inlay hints, line numbers) into which-key under
      # <leader>o. Concrete discoverability win.
      { plugins.snacks.settings.toggle.enabled = true; }

      # === bufdelete ===
      # WHY: close buffers without destroying window layout. Trivially
      # better than :bd with mini.tabline.
      { plugins.snacks.settings.bufdelete.enabled = true; }

      # === rename ===
      # WHY: LSP-aware file rename that updates imports. Complements
      # oil's buffer-only rename.
      { plugins.snacks.settings.rename.enabled = true; }

      # === gitbrowse ===
      # WHY: "open in GitHub" without vim-rhubarb. Replaces fugitive's
      # :GBrowse.
      { plugins.snacks.settings.gitbrowse.enabled = true; }

      # === scratch ===
      # WHY: per-cwd persistent scratch buffers — genuinely missing.
      { plugins.snacks.settings.scratch.enabled = true; }

      # === profiler ===
      # WHY: built-in Lua profiler with flame UI. For diagnosing
      # startup / lag issues.
      { plugins.snacks.settings.profiler.enabled = true; }

      # === which-key leaves ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>bd"; __unkeyed-2.__raw = "function() Snacks.bufdelete() end"; desc = "Delete buffer"; }
          { __unkeyed-1 = "<leader>cs"; __unkeyed-2.__raw = "function() Snacks.scratch() end"; desc = "Scratch buffer"; }
          { __unkeyed-1 = "<leader>cp"; __unkeyed-2.__raw = "function() Snacks.profiler.start() end"; desc = "Profiler start"; }
          { __unkeyed-1 = "<leader>cP"; __unkeyed-2.__raw = "function() Snacks.profiler.stop() end"; desc = "Profiler stop"; }
          { __unkeyed-1 = "<leader>gho"; __unkeyed-2.__raw = "function() Snacks.gitbrowse() end"; desc = "Open in GitHub"; }
        ];
      })

    ]
  );
}

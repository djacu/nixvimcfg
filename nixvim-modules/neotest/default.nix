{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.neotest;
in
{
  options.nixvimcfg.neotest.enable = lib.mkEnableOption "neotest test runner + adapters";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === neotest core + adapters ===
      # WHY: test runner with per-language adapters. All five adapters
      # first-class in nixvim under plugins.neotest.adapters.<name>.
      {
        plugins.neotest.enable = true;
        plugins.neotest.adapters.golang.enable = true;
        plugins.neotest.adapters.rust.enable = true;
        plugins.neotest.adapters.jest.enable = true;
        plugins.neotest.adapters.vitest.enable = true;
      }

      # === python adapter (gated on dap so debugpy python is shared) ===
      # WHY: avoids creating two separate debugpy pythons.
      (lib.mkIf config.nixvimcfg.dap.enable {
        plugins.neotest.adapters.python.enable = true;
        plugins.neotest.adapters.python.settings.dap = {
          justMyCode = false;
        };
        plugins.neotest.adapters.python.settings.python = config.nixvimcfg.dap.pythonPath;
      })

      # === which-key leaves: <leader>t ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>tr"; __unkeyed-2.__raw = "function() require('neotest').run.run() end"; desc = "Run nearest"; }
          { __unkeyed-1 = "<leader>tf"; __unkeyed-2.__raw = "function() require('neotest').run.run(vim.fn.expand('%')) end"; desc = "Run file"; }
          { __unkeyed-1 = "<leader>tl"; __unkeyed-2.__raw = "function() require('neotest').run.run_last() end"; desc = "Run last"; }
          { __unkeyed-1 = "<leader>tt"; __unkeyed-2.__raw = "function() require('neotest').run.run(vim.fn.getcwd()) end"; desc = "Run dir"; }
          { __unkeyed-1 = "<leader>ts"; __unkeyed-2.__raw = "function() require('neotest').summary.toggle() end"; desc = "Summary toggle"; }
          { __unkeyed-1 = "<leader>to"; __unkeyed-2.__raw = "function() require('neotest').output.open() end"; desc = "Output toggle"; }
          { __unkeyed-1 = "<leader>tq"; __unkeyed-2.__raw = "function() require('neotest').run.stop() end"; desc = "Stop"; }
        ];
      })

    ]
  );
}

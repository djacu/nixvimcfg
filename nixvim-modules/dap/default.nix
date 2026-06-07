{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.nixvimcfg.dap;
in
{
  options.nixvimcfg.dap.enable = lib.mkEnableOption "DAP debugger + adapters + UI";

  # WHY: cross-module option — neotest's python adapter reads this so
  # the same debugpy python is shared. This is the one exception to
  # the .enable-only module convention.
  options.nixvimcfg.dap.pythonPath = lib.mkOption {
    type = lib.types.str;
    default = "${pkgs.python3.withPackages (ps: [ps.debugpy])}/bin/python";
    description = "Path to a Python interpreter with debugpy installed. Shared with neotest.";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === dap core ===
      # WHY: the debug adapter protocol client itself.
      { plugins.dap.enable = true; }

      # === dap-ui ===
      # WHY: panes for variables / stacks / breakpoints / watches /
      # console. First-class nixvim option.
      { plugins.dap-ui.enable = true; }

      # === dap-virtual-text ===
      # WHY: inline value display next to variables during a session.
      { plugins.dap-virtual-text.enable = true; }

      # === dap-go ===
      # WHY: delve adapter wiring for Go. First-class nixvim.
      { plugins.dap-go.enable = true; }

      # === dap-python ===
      # WHY: debugpy adapter wiring for Python. adapterPythonPath is the
      # python that RUNS debugpy (pinned at flake.lock time, ABI-stable);
      # resolvePython picks the DEBUGGEE python per-session from
      # $VIRTUAL_ENV or PATH.
      {
        plugins.dap-python.enable = true;
        plugins.dap-python.adapterPythonPath = cfg.pythonPath;
        plugins.dap-python.resolvePython = ''
          function()
            if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
              return vim.env.VIRTUAL_ENV .. '/bin/python'
            end
            return vim.fn.exepath('python3')
          end
        '';
      }

      # === which-key leaves: <leader>d ===
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>db"; __unkeyed-2 = "<cmd>DapToggleBreakpoint<cr>"; desc = "Toggle breakpoint"; }
          { __unkeyed-1 = "<leader>dB"; __unkeyed-2.__raw = "function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end"; desc = "Conditional breakpoint"; }
          { __unkeyed-1 = "<leader>dc"; __unkeyed-2 = "<cmd>DapContinue<cr>"; desc = "Continue / start"; }
          { __unkeyed-1 = "<leader>do"; __unkeyed-2 = "<cmd>DapStepOver<cr>"; desc = "Step over"; }
          { __unkeyed-1 = "<leader>di"; __unkeyed-2 = "<cmd>DapStepInto<cr>"; desc = "Step into"; }
          { __unkeyed-1 = "<leader>dO"; __unkeyed-2 = "<cmd>DapStepOut<cr>"; desc = "Step out"; }
          { __unkeyed-1 = "<leader>dr"; __unkeyed-2 = "<cmd>DapToggleRepl<cr>"; desc = "REPL"; }
          { __unkeyed-1 = "<leader>du"; __unkeyed-2.__raw = "function() require('dapui').toggle() end"; desc = "Toggle dap-ui"; }
          { __unkeyed-1 = "<leader>dq"; __unkeyed-2 = "<cmd>DapTerminate<cr>"; desc = "Terminate"; }
        ];
      })

    ]
  );
}

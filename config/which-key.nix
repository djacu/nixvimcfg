{ nixvimLib, ... }:
{
  plugins.which-key.enable = true;
  plugins.which-key.showKeys = true;
  extraConfigLua =
    let
      mappings = {
        f = {
          name = " Telescope";
          b = [
            "<cmd>Telescope file_browser<cr>"
            "File Browser"
          ];
          f = [
            "<cmd>Telescope find_files<cr>"
            "Find File"
          ];
          l = [
            "<cmd>Telescope live_grep<cr>"
            "Live Grep"
          ];
          m = [
            "<cmd>Telescope media_files<cr>"
            "Open Media File"
          ];
          r = [
            "<cmd>Telescope oldfiles<cr>"
            "Open Recent File"
          ];
          t = [
            "<cmd>Telescope<cr>"
            "Telescope"
          ];
        };
        w = [
          "<cmd>WhichKey<cr>"
          " WhichKey?!"
        ];
        l = {
          name = " LSP";
          m = [
            "<cmd>lua require(\"conform\").format()<cr>"
            "Format"
          ];
        };
        g = {
          name = "💾 Fugitive";
	  a = [
	    "<cmd>Git add %:p<cr>"
	    "add"
	  ];
	  b = [
	    "<cmd>Git blame<cr>"
	    "blame"
	  ];
	  c = [
	    "<cmd>Git commit<cr>"
	    "commit"
	  ];
	  d = [
	    "<cmd>Git diff<cr>"
	    "diff"
	  ];
	  g = [
	    "<cmd>Git<cr>"
	    ":Git"
	  ];
	  l = [
	    "<cmd>Git log<cr>"
	    "log"
	  ];
	  pl = [
	    "<cmd>Git pull<cr>"
	    "pull"
	  ];
	  ps = [
	    "<cmd>Git push<cr>"
	    "push"
	  ];
        };
      };
      opts = {
        prefix = "<leader>";
      };
    in
    ''
      require("which-key").register(${nixvimLib.helpers.toLuaObject mappings},  ${nixvimLib.helpers.toLuaObject opts})
    '';
}

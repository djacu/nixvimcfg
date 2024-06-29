{ lib, config, ... }:
let
  cfg = config.nixvimcfg.treesitter;
in
{
  options.nixvimcfg.treesitter.enable = lib.mkEnableOption "treesitter setup";

  config = lib.mkIf cfg.enable {

    plugins.treesitter.enable = true;
    plugins.treesitter-context.enable = true;
    plugins.treesitter-refactor.enable = true;
    #plugins.treesitter-refactor.highlightCurrentScope.enable = true;
    plugins.treesitter-refactor.highlightDefinitions.enable = true;
    plugins.treesitter-refactor.navigation.enable = true;
    plugins.treesitter-refactor.smartRename.enable = true;

  };
}

{ lib, config, ... }:
let
  cfg = config.nixvimcfg.coq-nvim;
in
{
  options.nixvimcfg.coq-nvim.enable = lib.mkEnableOption "coq-nvim setup";

  config = lib.mkIf cfg.enable {

    plugins.coq-nvim.enable = true;
    plugins.coq-nvim.installArtifacts = true;
    plugins.coq-nvim.settings.auto_start = "shut-up";
    plugins.coq-nvim.settings.xdg = true;
    plugins.coq-nvim.settings.completion.always = true;
    plugins.coq-nvim.settings.keymap.recommended = true;

  };
}

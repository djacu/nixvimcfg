{
  lib,
  config,
  pkgs,
  nixvimLib,
  ...
}:
let
  cfg = config.nixvimcfg.conform-nvim;
in
{
  options.nixvimcfg.conform-nvim.enable = lib.mkEnableOption "conform-nvim setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      {

        plugins.conform-nvim =
          let
            pretty = [
              "prettierd"
              "prettier"
            ];
          in
          {
            enable = true;
            formattersByFt = {
              css = pretty;
              html = pretty;
              javascript = pretty;
              json = [ "prettier" ];
              markdown = [ "prettier" ];
              nix = [ "nixfmt" ];
              python = [ "ruff" ];
              rust = [ "rustfmt" ];
              sh = [ "shfmt" ];
              typescript = pretty;
              typst = [ "typstfmt" ];
              yaml = pretty;
            };
          };

        extraPackages = with pkgs; [
          #ruff
          nixfmt-rfc-style
          nodePackages.prettier
          prettierd
          rustfmt
          shfmt
          typstfmt
        ];

      }

      (lib.mkIf config.nixvimcfg.which-key.enable {

        extraConfigLua =
          let
            mappings = {
              l = {
                name = " LSP";
                m = [
                  "<cmd>lua require(\"conform\").format()<cr>"
                  "Format"
                ];
              };
            };
            opts = {
              prefix = "<leader>";
            };
          in
          ''
            require("which-key").register(
              ${nixvimLib.helpers.toLuaObject mappings},
              ${nixvimLib.helpers.toLuaObject opts}
            )
          '';

      })

    ]
  );
}

{
  lib,
  config,
  pkgs,
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
            settings.formatters_by_ft = {
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
        plugins.which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>l";
            group = " LSP";
          }
          {
            __unkeyed-1 = "<leader>lm";
            __unkeyed-2 = "<cmd>lua require(\"conform\").format()<cr>";
            desc = "Format";
          }
        ];
      })
    ]
  );
}

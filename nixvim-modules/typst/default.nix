{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.typst;
in
{
  options.nixvimcfg.typst.enable = lib.mkEnableOption "typst-preview.nvim";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === typst-preview ===
      # WHY: live preview for typst documents. Pairs with the tinymist
      # LSP (enabled in the lsp module).
      { plugins.typst-preview.enable = true; }

      # === which-key leaves (filetype-conditional) ===
      # WHY: bind <leader>mp under <leader>m (Markdown group; typst
      # is a markdown-adjacent typesetting format, so share the prefix).
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          { __unkeyed-1 = "<leader>mp"; __unkeyed-2 = "<cmd>TypstPreview<cr>"; desc = "Typst Preview"; }
          { __unkeyed-1 = "<leader>mP"; __unkeyed-2 = "<cmd>TypstPreviewStop<cr>"; desc = "Typst Preview Stop"; }
        ];
      })

    ]
  );
}

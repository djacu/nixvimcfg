{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.editing;
in
{
  options.nixvimcfg.editing.enable = lib.mkEnableOption "editing primitives (mini suite, guess-indent, ts-autotag)";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === mini editing primitives ===
      # WHY: replaces vim-surround / Comment.nvim / nvim-autopairs with
      # mini equivalents under one ecosystem. Note: mini.comment lacks
      # ts_context_commentstring integration for JSX-in-TSX nested
      # commentstring switching — accept this trade for mini-suite
      # consistency. If JSX commenting feels wrong in practice, add
      # nvim-ts-context-commentstring later.
      # mini.surround default mappings (sa/sd/sr) differ from
      # vim-surround (ys/cs/ds) — accepted; mini's are more orthogonal.
      {
        plugins.mini.enable = true;
        plugins.mini.modules.surround = { };
        plugins.mini.modules.comment = { };
        plugins.mini.modules.pairs = { };
        plugins.mini.modules.ai = { };       # better textobjects
        plugins.mini.modules.move = { };     # alt-j/k line move
      }

      # === guess-indent ===
      # WHY: Lua-native indent detection. Replaces vim-sleuth.
      { plugins.guess-indent.enable = true; }

      # === nvim-ts-autotag ===
      # WHY: auto-close/rename HTML/JSX/Astro tags. Treesitter-aware;
      # works with the new main-branch nvim-treesitter.
      { plugins.ts-autotag.enable = true; }

    ]
  );
}

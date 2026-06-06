{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.completion;
in
{
  options.nixvimcfg.completion.enable = lib.mkEnableOption "blink.cmp + snippets";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === snippets ===
      # WHY: luasnip is the snippet engine; friendly-snippets is the
      # canonical collection of pre-made snippets. blink.cmp consumes
      # both natively via its snippets source.
      {
        plugins.luasnip.enable = true;
        plugins.friendly-snippets.enable = true;
      }

      # === blink.cmp ===
      # WHY: modern completion engine. First-class in nixvim (no
      # extraPlugins). nixpkgs ships the prebuilt Rust fuzzy-matcher
      # binary as part of the derivation.
      {
        plugins.blink-cmp.enable = true;
        plugins.blink-cmp.settings = {
          keymap.preset = "default";
          completion.documentation.auto_show = true;
          completion.documentation.auto_show_delay_ms = 200;
        };
      }

      # === sources ===
      # WHY: order matters — lazydev first so Lua files get nvim-runtime
      # completion before generic LSP fallbacks. lazydev integrates as a
      # blink source, not via lazydev.settings.integrations (which only
      # has cmp/coq keys).
      {
        plugins.blink-cmp.settings.sources.default = [
          "lazydev"
          "lsp"
          "snippets"
          "path"
          "buffer"
        ];
        plugins.blink-cmp.settings.sources.providers.lazydev = {
          name = "LazyDev";
          module = "lazydev.integrations.blink";
          score_offset = 100;
        };
      }

      # === cmdline completion ===
      # WHY: completion in : (command) and / (search) modes.
      {
        plugins.blink-cmp.settings.cmdline.enabled = true;
      }

    ]
  );
}

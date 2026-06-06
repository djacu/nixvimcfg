{
  lib,
  config,
  ...
}:
let
  cfg = config.nixvimcfg.treesitter;
in
{
  options.nixvimcfg.treesitter.enable = lib.mkEnableOption "treesitter setup";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # === treesitter core ===
      # WHY: the main-branch nvim-treesitter rewrite. Highlighting and
      # folding configured via top-level options.
      # grammarPackages declares parsers at flake.lock time — replaces
      # the legacy ensure_installed auto-install that no longer exists
      # in the main-branch rewrite.
      {
        plugins.treesitter.enable = true;
        plugins.treesitter.highlight.enable = true;
        plugins.treesitter.folding.enable = true;

        plugins.treesitter.grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
          astro
          bash
          c
          cmake
          cpp
          css
          go
          haskell
          html
          javascript
          json
          lua
          markdown
          markdown_inline
          nix
          python
          regex
          rust
          toml
          tsx
          typescript
          typst
          vim
          vimdoc
          yaml
        ];

        extraConfigLua = ''
          vim.opt.foldenable = false
        '';
      }

      # === treesitter-textobjects ===
      # WHY: structural motions (`af`/`if` etc.) for selecting / jumping
      # over functions, classes, parameters by syntax tree. main-branch
      # version ships zero default keymaps — wire them via nixvim's
      # keymap API. Bindings:
      #   af/if   around/inside function (select)
      #   ac/ic   around/inside class (select)
      #   aa/ia   around/inside parameter (select)
      #   ]f/[f   next/prev function start (move)
      #   ]c/[c   next/prev class start (move)
      {
        plugins.treesitter-textobjects.enable = true;

        keymaps = [
          # --- selection (visual / operator-pending modes) ---
          {
            mode = [ "x" "o" ];
            key = "af";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
              end
            '';
            options.desc = "around function";
          }
          {
            mode = [ "x" "o" ];
            key = "if";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
              end
            '';
            options.desc = "inside function";
          }
          {
            mode = [ "x" "o" ];
            key = "ac";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
              end
            '';
            options.desc = "around class";
          }
          {
            mode = [ "x" "o" ];
            key = "ic";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
              end
            '';
            options.desc = "inside class";
          }
          {
            mode = [ "x" "o" ];
            key = "aa";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects')
              end
            '';
            options.desc = "around parameter";
          }
          {
            mode = [ "x" "o" ];
            key = "ia";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects')
              end
            '';
            options.desc = "inside parameter";
          }
          # --- movement (normal / visual / operator-pending) ---
          {
            mode = [ "n" "x" "o" ];
            key = "]f";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
              end
            '';
            options.desc = "next function start";
          }
          {
            mode = [ "n" "x" "o" ];
            key = "[f";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
              end
            '';
            options.desc = "prev function start";
          }
          {
            mode = [ "n" "x" "o" ];
            key = "]c";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
              end
            '';
            options.desc = "next class start";
          }
          {
            mode = [ "n" "x" "o" ];
            key = "[c";
            action.__raw = ''
              function()
                require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
              end
            '';
            options.desc = "prev class start";
          }
        ];
      }

      # === treesitter-context ===
      # WHY: sticky scope display at top of buffer. Branch-agnostic, no
      # dependency on legacy treesitter. Previous config disabled this
      # via settings.enable = false (made the plugin inert) — fixed here.
      {
        plugins.treesitter-context.enable = true;
        plugins.treesitter-context.settings.trim_scope = "outer";
      }

      # === which-key leaves under <leader>t ===
      # WHY: treesitter context toggle keymap. (<leader>t group prefix
      # is registered in the which-key module — and yes, <leader>t will
      # be reassigned to "Test" in phase 11; that's a planned future
      # collision we'll resolve there. For now this is what current
      # config has.)
      (lib.mkIf config.nixvimcfg.which-key.enable {
        plugins.which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>tc";
            __unkeyed-2 = "<cmd>TSContextToggle<cr>";
            desc = "Context Toggle";
          }
        ];
      })

    ]
  );
}

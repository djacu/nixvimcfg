# nixvimcfg

A personal Neovim configuration built with [nixvim](https://github.com/nix-community/nixvim).
Declarative, reproducible, every plugin and LSP server pinned by flake.lock.

## Run it

```bash
nix run github:djacu/nixvimcfg
# or, if cloned:
nix run .
```

The wrapped Neovim binary is also available at `./result/bin/nvim` after
`nix build .#packages.x86_64-linux.default` (use `nix build` over `nix run`
when you just want to verify evaluation without launching the editor).

## How it's organized

```
flake.nix
nixvim-configurations/default.nix   ← top-level switchboard
nixvim-modules/<feature>/default.nix ← one module per concern
docs/
  cheatsheet.md                     ← keymap reference + workflow walkthroughs
  superpowers/specs/...             ← design history
  superpowers/plans/...             ← implementation plan
```

`nixvim-configurations/default.nix` is a flat list of `nixvimcfg.<name>.enable`
toggles — enable a module, the plugins and keymaps it owns get wired in. To
disable something for a session, flip its toggle to `false` and rebuild.

Each module under `nixvim-modules/` uses `mkMerge` intent blocks with
`# === name ===` + `# WHY:` headers — open any module and you can see what
each block does and why it's there.

## Modules

| Module | What |
|---|---|
| `completion/` | [blink.cmp](https://github.com/Saghen/blink.cmp) + luasnip + friendly-snippets, with lazydev as a source |
| `dap/` | [nvim-dap](https://github.com/mfussenegger/nvim-dap) + dap-ui + virtual-text + Go and Python adapters |
| `editing/` | mini.surround, mini.comment, mini.pairs, mini.ai, mini.move, guess-indent, nvim-ts-autotag |
| `files/` | [oil.nvim](https://github.com/stevearc/oil.nvim) (edit the filesystem as a buffer) |
| `git/` | [neogit](https://github.com/NeogitOrg/neogit) + [gitsigns](https://github.com/lewis6991/gitsigns.nvim) + [diffview](https://github.com/sindrets/diffview.nvim) + snacks.gitbrowse |
| `lsp/` | LSPs for Go, Rust, Python, TypeScript, Lua, Nix (nixd), Bash, JSON/YAML/TOML, Astro, CSS, HTML, Tailwind, Haskell, CMake, Ansible, Markdown, Typst, LaTeX, English grammar, typos, eslint |
| `navigation/` | [flash](https://github.com/folke/flash.nvim) + [harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2) + [aerial](https://github.com/stevearc/aerial.nvim) + [grug-far](https://github.com/MagicDuck/grug-far.nvim) |
| `neotest/` | [neotest](https://github.com/nvim-neotest/neotest) + adapters for Go, Python, Rust, Jest, Vitest |
| `picker/` | [telescope](https://github.com/nvim-telescope/telescope.nvim) + extensions (file-browser, frecency, fzf-native, media-files) |
| `snacks/` | [snacks.nvim](https://github.com/folke/snacks.nvim) submodules: bigfile, statuscolumn, quickfile, words, toggle, bufdelete, rename, gitbrowse, scratch, profiler |
| `treesitter/` | nvim-treesitter (main branch) + context + textobjects + declarative grammar packages |
| `typst/` | [typst-preview.nvim](https://github.com/chomosuke/typst-preview.nvim) |
| `ui/` | [lualine](https://github.com/nvim-lualine/lualine.nvim), mini.tabline, fidget, noice, todo-comments, render-markdown, nvim-origami, quicker, trouble |
| `which-key/` | [which-key v3](https://github.com/folke/which-key.nvim) with a central key-group registry and `<leader>?` Telescope-based discovery |

## Using it

See [`docs/cheatsheet.md`](./docs/cheatsheet.md) — keymaps organized by domain,
plus detailed walkthroughs for oil, harpoon, and neogit.

The "I forgot how to do X" button: **`<leader>?k`** opens a fuzzy-searchable
list of every active keymap with descriptions.

## Customizing

Three common shapes of change, in order of frequency:

1. **Toggle a feature off**: edit `nixvim-configurations/default.nix`, set the
   relevant `nixvimcfg.<name>.enable = false;`, rebuild.
2. **Tweak a plugin's config**: edit its `mkMerge` block in
   `nixvim-modules/<name>/default.nix`. Each block has a `# WHY:` comment so
   you know what it's doing before you touch it.
3. **Add a new plugin**: either extend an existing module's `mkMerge` list
   with a new intent block, or create a new module under `nixvim-modules/`
   and wire its `enable` flag into `nixvim-configurations/default.nix`. The
   directory is auto-imported via `readDir` in `nixvim-modules/default.nix`,
   so new module dirs are picked up automatically.

To verify changes:

```bash
nix flake check                              # eval + checks
nix build .#packages.x86_64-linux.default    # full build
./result/bin/nvim --version                  # confirm version
```

Don't use `nix run .` for verification — it opens the interactive editor and
blocks the shell. `nix build` does the same evaluation without launching.

## Reference docs

- [`docs/cheatsheet.md`](./docs/cheatsheet.md) — keymap reference + workflow walkthroughs
- [`docs/superpowers/specs/2026-06-06-nixvim-revamp-design.md`](./docs/superpowers/specs/2026-06-06-nixvim-revamp-design.md) — design history for the modular restructure
- [`docs/superpowers/plans/2026-06-06-nixvim-revamp.md`](./docs/superpowers/plans/2026-06-06-nixvim-revamp.md) — implementation plan that landed it

## Updating

```bash
nix flake update                             # bump every input
nix flake update nixvim nixpkgs              # bump specific inputs
nix flake check                              # validate after bump
```

Nixvim's option schema changes between releases; if a bump triggers
deprecation warnings or errors, the fix is usually a small option-rename
in one module.

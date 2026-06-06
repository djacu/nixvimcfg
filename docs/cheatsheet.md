# nixvim cheatsheet

Leader key is `<space>`. Hold leader for ~200ms to see the which-key popup
of available bindings under your current prefix.

## The meta-tip — your "I forgot how to do X" button

| Key | What |
|---|---|
| **`<leader>?k`** | Telescope-search every active keymap with descriptions. **Use this constantly.** |
| `<leader>?c` | Telescope-search every command |
| `<leader>?h` | Telescope-search `:help` |
| `<leader>?t` | Pick from telescope's built-in pickers |
| `<leader>?p` | "Pick a picker" — opens telescope's master picker list |
| `<leader>w` | Open which-key index |

## Folds

| Key | What |
|---|---|
| `zR` | Open ALL folds in buffer |
| `zM` | Close ALL folds |
| `za` | Toggle fold under cursor |
| `zo` / `zc` | Open / close current fold |
| `zj` / `zk` | Jump to next / previous fold |
| `l` at end of folded line | Open fold (nvim-origami) |
| `h` at start of folded line | Close fold |

## Files & buffers

| Key | What |
|---|---|
| `<leader>e` | Open oil (edit filesystem as a buffer — `:w` applies renames/creates/deletes) |
| `<leader>ff` | Find file (telescope) |
| `<leader>fl` | Live grep across project |
| `<leader>fb` | File browser |
| `<leader>fr` | Recent files |
| `<leader>ft` | Browse all telescope pickers |
| `<leader>fm` | Open a media file (images/PDFs/videos) |
| `<leader>bd` | Delete buffer without breaking window layout |

## Navigation

| Key | What |
|---|---|
| `s{char}{char}` | Flash jump — type 2 chars, see labels, press a label to teleport |
| `<leader>aa` | Toggle aerial (symbol outline sidebar) |
| `<leader>an` / `<leader>ap` | Aerial next / prev symbol |
| `<leader>ha` | Add file to harpoon |
| `<leader>hh` | Toggle harpoon menu |
| `<leader>h1` .. `<leader>h4` | Jump to harpoon slot 1–4 |
| `<leader>hn` / `<leader>hp` | Next / prev harpoon slot |
| `]f` / `[f` | Next / prev function start (treesitter) |
| `]c` / `[c` | Next / prev class start (treesitter) |

## LSP

| Key | What |
|---|---|
| `gd` | Goto definition |
| `gD` | Goto declaration |
| `gr` | References (lists) |
| `gi` | Goto implementation |
| `K` | Hover docs |
| `<leader>lr` | Rename symbol |
| `]d` / `[d` | Next / prev diagnostic |

## Diagnostics, TODOs, quickfix

| Key | What |
|---|---|
| `<leader>xx` | Trouble — all diagnostics |
| `<leader>xd` | Document diagnostics only |
| `<leader>xl` | Location list (in Trouble UI) |
| `<leader>xq` | Quickfix list (in Trouble UI) |
| `<leader>xt` | TodoTelescope (TODO/FIXME/HACK/NOTE) |
| `:copen` | Native quickfix (editable via quicker.nvim — `:w` writes back) |

## Git

**Neogit porcelain (Magit-style):**

| Key | What |
|---|---|
| `<leader>gg` | Neogit status (start here for most git work) |
| `<leader>gc` / `<leader>gC` | Commit / commit --amend |
| `<leader>gp` / `<leader>gP` | Push / Pull |
| `<leader>gf` | Fetch |
| `<leader>gB` | Branch (checkout/create/delete) |
| `<leader>gl` | Log |
| `<leader>gs` | Stash |
| `<leader>gm` | Merge |
| `<leader>gr` | Rebase |
| `<leader>gx` | Cherry-pick |
| `<leader>gz` | Reset |

**Blame:**

| Key | What |
|---|---|
| `<leader>gb` | Open the full blame buffer (fugitive `:Git blame` equivalent) |
| `<leader>ob` | Toggle inline blame on cursor line (under Toggle group) |

Inside the blame buffer:

| Key | What |
|---|---|
| `<CR>` | Open the blame action menu |
| `r` | Reblame from this commit |
| `R` | Reblame from this commit's parent |
| `s` | Show commit in vertical split |
| `S` | Show commit in new tab |
| `d` | Diff in tab |
| `:q` / `<C-w>c` | Close the blame buffer (no `q` keymap is bound) |

**Hunks (gitsigns):**

| Key | What |
|---|---|
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghd` | Diff vs index |
| `<leader>gho` | Open in GitHub (snacks.gitbrowse) |

**Diff browser (diffview):**

| Key | What |
|---|---|
| `<leader>gv` | Diffview open |
| `<leader>gV` | Diffview close |
| `<leader>gw` | File history (replaces fugitive's `:Gedit HEAD~N:%`) |

## Editing primitives (mini suite)

| Key | What |
|---|---|
| `sa{motion}{char}` | Surround add — e.g., `saiw"` quotes the word under cursor |
| `sd{char}` | Surround delete — e.g., `sd"` removes surrounding quotes |
| `sr{old}{new}` | Surround replace — e.g., `sr"'` changes `"foo"` to `'foo'` |
| `gcc` | Comment current line |
| `gc{motion}` | Comment a motion — e.g., `gcap` for a paragraph |
| `<M-j>` / `<M-k>` | Move line / selection up or down (alt+j/k) |

Treesitter textobjects (work with `d`, `y`, `c`, `v`, etc.):

| Key | What |
|---|---|
| `af` / `if` | Around / inside function |
| `ac` / `ic` | Around / inside class |
| `aa` / `ia` | Around / inside parameter |

Examples: `daf` deletes the function, `vif` selects function body, `cic` re-types a class body.

## Completion (blink.cmp)

| Key | What |
|---|---|
| `<CR>` | Accept selected completion |
| `<C-space>` | Open completion menu manually |
| `<C-n>` / `<C-p>` | Next / prev item |
| `<Tab>` / `<S-Tab>` | Jump snippet placeholder forward / back |

## Debug (DAP)

| Key | What |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint (prompts) |
| `<leader>dc` | Continue / start session |
| `<leader>do` | Step over |
| `<leader>di` | Step into |
| `<leader>dO` | Step out |
| `<leader>dr` | Open REPL |
| `<leader>du` | Toggle dap-ui panels |
| `<leader>dq` | Terminate session |

## Test (neotest)

| Key | What |
|---|---|
| `<leader>tr` | Run nearest test |
| `<leader>tf` | Run file |
| `<leader>tl` | Run last |
| `<leader>tt` | Run dir |
| `<leader>ts` | Summary toggle |
| `<leader>to` | Output toggle |
| `<leader>tq` | Stop |

## Toggles (`<leader>o` — auto-registered by snacks.toggle)

Press `<leader>o`, wait, see the list. Includes spell, wrap, line numbers,
relative numbers, diagnostics, inlay hints, conceal, treesitter, and more —
discover them by holding `<leader>o`.

| Key | What |
|---|---|
| `<leader>oc` | Toggle treesitter context (sticky scope at top of buffer) |
| `<leader>ob` | Toggle inline git blame |

## Code / snacks utilities (`<leader>c`)

| Key | What |
|---|---|
| `<leader>cs` | Scratch buffer (per-cwd, persistent) |
| `<leader>cp` / `<leader>cP` | Profiler start / stop |

## Markdown / Typst

| Key | What |
|---|---|
| `<leader>me` / `<leader>md` | render-markdown enable / disable |
| `<leader>mp` / `<leader>mP` | Typst preview start / stop (in `.typ` files) |

## Search / replace

| Key | What |
|---|---|
| `<leader>ss` | Search the word under cursor across project (grug-far) |
| `<leader>sg` | Open empty grug-far for project-wide search/replace |

---

## Survival shortlist

Memorize these and you'll get through most days:

1. **`<leader>?k`** — search every keymap (always start here when stuck)
2. **`<leader>ff`** — find a file
3. **`<leader>fl`** — live grep
4. **`<leader>gg`** — open neogit
5. **`zR`** — open all folds in buffer

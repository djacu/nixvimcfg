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
| `<leader>gn` | Intent-to-add current file (`git add -N`) — track without staging contents |

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

---

## Detailed: oil.nvim (file explorer)

Oil treats a directory as a normal Neovim buffer. Each line is a file or
subdirectory name. You navigate with regular vim motions, **edit the buffer
to make filesystem changes**, then `:w` to apply them. Renames, creates,
deletes, even moves between directories — all become text edits.

### Opening

| Key / cmd | What |
|---|---|
| `<leader>e` | Open oil at the current buffer's directory |
| `:Oil` | Same as above |
| `:Oil /some/path` | Open oil at a specific path |
| `:Oil --float` | Open in a floating window |

### Navigating inside the oil buffer

| Key | What |
|---|---|
| `<CR>` | Open the file/directory under cursor (replaces current window) |
| `-` | Go up one directory |
| `_` | Open oil at your cwd |
| `<C-s>` | Open in vertical split |
| `<C-h>` | Open in horizontal split |
| `<C-t>` | Open in new tab |
| `<C-p>` | Preview the file (no open) |
| `<C-l>` | Refresh the listing |
| `g.` | Toggle showing hidden files (dotfiles) |
| `g\` | Toggle trash view |
| `gs` | Change sort order |
| `gx` | Open with the system handler (e.g. an image in your image viewer) |
| `g?` | Show oil's help inside the buffer |
| `<C-c>` | Close the oil buffer |

### Filesystem operations — edit the buffer, then `:w`

This is the part that feels strange at first but becomes second nature:

| Operation | How |
|---|---|
| **Create a file** | Add a new line with the filename. `:w` creates it (empty). |
| **Create a directory** | Add a new line ending in `/` (e.g. `newdir/`). `:w` creates it. |
| **Rename** | Edit the filename in place. `:w` renames. |
| **Delete** | Delete the line (`dd`). `:w` deletes the file. |
| **Move (single file)** | `dd` to cut the line, navigate to the destination oil buffer, `p` to paste, `:w`. |
| **Copy** | Yank the line (`yy`), navigate to the destination, `p`, `:w`. To copy in place under a new name, `yy` then `p` then edit the duplicate filename. |
| **Bulk rename** | Use any normal vim editing — `:%s/\.txt$/.md/`, visual block edit, macros, etc. `:w` applies all renames atomically. |

**Important:** changes are not applied until `:w`. Before saving, oil shows
you a confirmation prompt listing every CREATE/DELETE/RENAME/MOVE/COPY it's
about to execute. Hit `y` to confirm, `n` to abort, `Esc` to cancel and keep
editing.

### Tips

- **`g?` is your friend** — it shows the in-buffer help with every keymap.
- **Oil and harpoon play well together** — open oil with `<leader>e`, `<CR>`
  into a file, `<leader>ha` to mark it.
- **Yanking files across the system**: `yy` in one oil buffer, open oil
  somewhere else (`:Oil /target/path`), `p`, `:w`. Cross-directory move/copy
  in two motions.
- **No undo for the filesystem**: once you `:w`, the operation runs. Use the
  confirmation prompt as your safety net. The `g\` trash view shows
  recently-deleted entries if trash mode is configured.

### Walkthrough: renaming three test files

```
1. <leader>e             open oil in current dir
2. /test_                find first test file
3. cgn                   change next match, type new name
4. .                     repeat for next match (or use n + cgn)
5. (repeat)
6. :w                    see confirmation, hit y to apply
```

Three renames, one save, atomic.

---

## Detailed: harpoon

**Mental model:** "pinned files you teleport between." Mark 1–4 files you're
actively working in; jump between them with single keystrokes. Beats
bufferline cycling when you're rotating between 2–3 known files (e.g.
test + impl + spec).

### Workflow

1. Open the file you want to mark.
2. Press **`<leader>ha`** to add it to the harpoon list. Silent — no confirmation.
3. Repeat in 2–3 other files you'll bounce between.
4. Jump between them with **`<leader>h1`**, **`<leader>h2`**, **`<leader>h3`**,
   **`<leader>h4`** — instant teleport, no fuzzy search.
5. **`<leader>hn`** / **`<leader>hp`** cycle forward/back through the list
   (useful if you forget which slot is which).

### Managing the list

Press **`<leader>hh`** to open the harpoon quick menu. This is a small floating
buffer showing your marks, one per line. You can:

- Reorder marks by moving lines (`dd`/`p` to swap)
- Delete marks by deleting their lines (`dd`)
- Add a new mark by typing its path on a new line (relative to project root)
- Press `<CR>` on a line to jump to that file
- `:q` to close the menu — changes are saved on close

### When harpoon shines vs telescope

- **Telescope** (`<leader>ff`/`<leader>fl`): when you don't know where the file
  is, or it's a one-off lookup.
- **Harpoon**: when you'll touch a specific small set of files repeatedly over
  the next hour. Mark them once, teleport for the rest of the session.

### Tip

Harpoon's list is per-project (keyed by cwd). Switching to a different repo
gives you a fresh list. The list persists across nvim restarts.

---

## Detailed: neogit

**Mental model:** Magit-style — the status view *is* the workspace. You
stage/unstage/commit/push by pressing single keys on items in the status
buffer, not by typing `:Git ...` commands.

### Typical edit-stage-commit-push session

1. **`<leader>gg`** — opens status. You see sections: Untracked, Unstaged,
   Staged, etc. (folded by default; `<Tab>` to expand a section).
2. **Move cursor to a file** in "Unstaged" or "Untracked". Press **`s`** to
   stage it. The file moves to the "Staged" section.
3. **Or stage a single hunk**: with cursor on a file, press **`<Tab>`** to
   expand its diff. Cursor onto a hunk, press **`s`**. Just that hunk stages.
4. **Made a mistake?** **`u`** unstages (file or hunk under cursor). **`x`**
   discards (irreversible — it asks first).
5. **Commit**: press **`c`** to open the commit popup. The popup shows a menu
   of commit variants:
   - `c` again → normal commit
   - `a` → amend the last commit
   - `e` → extend (amend without changing the message)
   - `f` → fixup
6. Press your choice. A commit buffer opens. Type your message. Press
   **`<C-c><C-c>`** to confirm (or `<C-c><C-k>` to abort).
7. **Push**: back in status (you'll auto-return), press **`p`** for push popup.
   Then **`p`** again to push to upstream. (Capital letters do force-push
   variants — see the popup.)

### Status-buffer keymap reference

**Toggling sections** (Untracked / Unstaged / Staged / Stashes / Unpulled /
Unmerged / Recent commits are all collapsible "folds"):

| Key | What |
|---|---|
| `<Tab>` | Toggle the section under cursor (open ↔ closed) |
| `za` | Same as `<Tab>` |
| `zo` | Open fold explicitly |
| `<C-n>` | Jump to next section |
| `<C-p>` | Jump to previous section |

**Acting on the file or hunk under cursor:**

| Key | What |
|---|---|
| `s` | Stage (file under cursor, or selected hunk) |
| `u` | Unstage |
| `x` | Discard (irreversible — confirms first) |
| `n` | Intent-to-add (`git add -N`) — track an untracked file without staging its contents. Custom binding; not stock neogit. |
| `<CR>` | Open the file (or expand the hunk) |
| `<Tab>` | Toggle diff visibility for the file under cursor |

**Popups** (all from the status buffer; they open menus of related actions):

| Key | What |
|---|---|
| `c` | Commit popup |
| `p` | Push popup |
| `F` | Pull popup (note: capital — `<leader>gP` from outside also works) |
| `f` | Fetch popup |
| `b` | Branch popup |
| `m` | Merge popup |
| `r` | Rebase popup |
| `Z` | Stash popup |
| `l` | Log popup |
| `?` | Help popup (lists everything available — your in-buffer cheatsheet) |

**Tip:** `?` is the magit-style help — it surfaces every popup and every
action available in the current view. Use it instead of trying to memorize
the popups.

### Closing

| Key | What |
|---|---|
| `q` | Close neogit |
| `:q` | Also works |

### Worked example: stage one hunk + commit

```
1. <leader>gg              open neogit
2. <Tab> on a file         expand diff
3. j j j (cursor onto hunk)
4. s                       stage just that hunk
5. c                       open commit popup
6. c                       confirm "commit"
7. (type message)
8. <C-c><C-c>              save & commit
```

Six keystrokes after navigation. Try doing that in fugitive.

### When neogit vs gitsigns

- **Gitsigns** (`<leader>gh*`): single-file, in-place hunk operations while
  you're editing. You don't leave your file — stage/reset/preview from the
  gutter signs without context-switching.
- **Neogit**: whole-repo workflow. Reviewing all changes, building up a commit
  across multiple files, branch management, complex rebases.

You'll use both in the same session — gitsigns for quick "ship this one hunk"
moves, neogit for "let me review and craft a real commit."

# Telescope Advanced Git Search

## 🖥️ Usage

[![Demo](https://img.youtube.com/vi/bO0uYLlHtYo/0.jpg)](https://www.youtube.com/watch?v=bO0uYLlHtYo)

### 📖 Open a picker

```vim
:Telescope advanced_git_search {function_name}
```

or in lua

```lua
require('telescope').extensions.advanced_git_search.{function_name}()
```

### 🔎 Enter a query

Your usual telescope experience. See the individual commands for the grep behaviour.

### ✏️ Further search on commit author with `@`

The prompt is split on `@`. Everything following the `@` is the pattern for
the author name.

## ⚡️Commands

### 1. diff_branch_file

Opens a Telescope window with a list of local branches

_Grep behaviour_: filter on branch name.

#### _Keymaps_

- `<CR>` opens a diff for the current file with the selected branch

### 2. diff_commit_line

Opens a Telescope window with a list of previous commit logs with respect to
selected lines

_Grep behaviour_: filter on commit message.

Note: First you have to select the lines in visual mode, then go back to normal
mode and execute this command.
To make this a bit easier, you can wrap it in a user command and define a keybind:

```lua
vim.api.nvim_create_user_command(
    "DiffCommitLine",
    "lua require('telescope').extensions.advanced_git_search.diff_commit_line()",
    { range = true }
)

vim.api.nvim_set_keymap(
    "v",
    "<leader>dcl",
    ":DiffCommitLine<CR>",
    { noremap = true }
)
```

#### _Keymaps_

- `<CR>` opens a diff for the current file with the selected commit
- `<C-o>` opens a the selected commit in the browser

### 3. diff_commit_file

Opens a Telescope window with a list of git commits that changed the
current file (renames included).

_Grep behaviour_: filter on commit message.

#### _Keymaps_

- `<CR>` Opens a diff of the current file with the selected commit
- `<C-e>` Opens an entire git diff of the selected commit
- `<C-o>` Open the selected commit in the browser

### 4. search_log_content

Opens a Telescope window with a list of all previous commit.

_Grep behaviour_: filter on added, updated or removed code (log content: `-G` option in git).

#### _Keymaps_

- `<CR>` opens a diff for the current file with the selected commit
- `<C-o>` opens the selected commit in the browser

### 5. search_log_content_file

Opens a Telescope window with a list of git commits that changed the
current file (renames included).

_Grep behaviour_: filter on added, updated or removed code (log content: `-G` option in git).

#### _Keymaps_

- `<CR>` opens a diff for the current file with the selected commit
- `<C-o>` opens the selected commit in the browser

### 6. changed_on_branch

Opens a Telescope window with a list of changed files on the current branch (including staged files).
The fork point of the current branch is determined with the following command:

```sh
git show-branch | \
    sed "s/].*//" | \
    grep "*" | \
    grep -v "$(git rev-parse --abbrev-ref HEAD)" | \
    head -n1 | \
    sed "s/^.*\\[//"
```

Note: this only works if there is already a commit on the current branch, otherwise the base branch can not be detected.

_Grep behaviour_: filter on filename.

#### _Keymaps_

- `<CR>` opens the selected file.
- `<C-e>` opens diff of the selected file with base branch.

### 7. checkout_reflog

Opens a Telescope window with all reflog entries

#### _Keymaps_

- `<CR>` checkout the reflog entry

### 8. show_custom_functions

A telescope picker for all functions above.

## ⚙️ Installation

With Lazy

```lua
    {
        "aaronhallaert/advanced-git-search.nvim",
        config = function()
            require("telescope").load_extension("advanced_git_search")

            require("telescope").setup{
                -- move this to the place where you call the telescope setup function
                extensions = {
                    advanced_git_search = {
                        -- fugitive or diffview
                        diff_plugin = "fugitive",
                    }
                }
            }
        end,
        dependencies = {
            "nvim-telescope/telescope.nvim",
            -- to show diff splits and open commits in browser
            "tpope/vim-fugitive",
            -- OPTIONAL: to replace the diff from fugitive with diffview.nvim
            -- (fugitive is still needed to open in browser)
            -- "sindrets/diffview.nvim",
        },
    }
```

With Packer

```lua
    use({
        "aaronhallaert/advanced-git-search.nvim",
        config = function()
            require("telescope").load_extension("advanced_git_search")

            require("telescope").setup{
                -- move this to the place where you call the telescope setup function
                extensions = {
                    advanced_git_search = {
                        -- fugitive or diffview
                        diff_plugin = "fugitive",
                    }
                }
            }
        end,
        requires = {
            "nvim-telescope/telescope.nvim",
            -- to show diff splits and open commits in browser
            "tpope/vim-fugitive",
            -- OPTIONAL: to replace the diff from fugitive with diffview.nvim
            -- (fugitive is still needed to open in browser)
            -- "sindrets/diffview.nvim",
        },
    })
```

### Prerequisites

- git
- vim-fugitive
- sindrets/diffview.nvim
- telescope.nvim

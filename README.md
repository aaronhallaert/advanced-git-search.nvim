# Telescope Advanced Git Search

## 🖥️ Usage

[![Demo](https://img.youtube.com/vi/bO0uYLlHtYo/0.jpg)](https://www.youtube.com/watch?v=bO0uYLlHtYo)

### 📖 Open a picker

```vim
:Telescope advanced_git_search {function_name}
```

#### or in lua

```lua
require('telescope').extensions.advanced_git_search.{function_name}()
```

#### or through another Telescope picker

execute `:AdvancedGitSearch`, choose your picker and press `<CR>`

### 🔎 Enter a query

Your usual telescope experience. See the individual commands for the grep behaviour.

### ✏️ Further search on commit author with `@`

The prompt is split on `@`. Everything following the `@` is the pattern for
the author name.

## ⚡️Commands

### 1. search_log_content -- Search in repo log content

Opens a Telescope window with a list of all previous commit.

_Grep behaviour_: filter on added, updated or removed code (log content: `-G` option in git).

#### _Keymaps_

- `<CR>` Opens a diff of the current file with the selected commit
- `<C-e>` show the entire commit for all files in neovim with diff plugin
- `<C-o>` Open the selected commit in the browser
- `<C-y>` copy the commit hash to clipboard

### 2. search_log_content_file -- Search in file log content

Opens a Telescope window with a list of git commits that changed the
current file (renames included).

_Grep behaviour_: filter on added, updated or removed code (log content: `-G` option in git).

#### _Keymaps_

- `<CR>` Opens a diff of the current file with the selected commit
- `<C-e>` show the entire commit for all files in neovim with diff plugin
- `<C-o>` Open the selected commit in the browser
- `<C-y>` copy the commit hash to clipboard

### 3. diff_commit_file -- Diff current file with commit

Opens a Telescope window with a list of git commits that changed the
current file (renames included).

_Grep behaviour_: filter on commit message.

#### _Keymaps_

- `<CR>` Opens a diff of the current file with the selected commit
- `<C-e>` show the entire commit for all files in neovim with diff plugin
- `<C-o>` Open the selected commit in the browser
- `<C-y>` copy the commit hash to clipboard

### 4. diff_commit_line -- Diff current file with selected line history

Opens a Telescope window with a list of previous commit logs with respect to
selected lines

_Grep behaviour_: filter on commit message.

#### How to use

_The following only applies when you use one of the commands below._

```vim
:Telescope advanced_git_search diff_commit_line
:lua require('telescope').extensions.advanced_git_search.diff_commit_line()
```

First you have to select the lines in visual mode, then go back to normal
mode and execute this command.
To make a bit easier, you can wrap it in a user command and define a keybind:

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

No extra setup is needed when you use `:AdvancedGitSearch`.

#### _Keymaps_

- `<CR>` opens a diff for the current file with the corresponding file on the selected commit
- `<C-e>` show the entire commit for all files in neovim with diff plugin
- `<C-o>` opens a the selected commit in the browser
- `<C-y>` copy the commit hash to clipboard

### 5. diff_branch_file -- Diff file with branch

Opens a Telescope window with a list of local branches

_Grep behaviour_: filter on branch name.

#### _Keymaps_

- `<CR>` opens a diff for the current file with the selected branch

### 6. changed_on_branch -- Changed on current branch (experimental)

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

### 7. checkout_reflog -- Checkout from reflog

Opens a Telescope window with all reflog entries

#### _Keymaps_

- `<CR>` checkout the reflog entry

### 8. show_custom_functions

A telescope picker for all functions above.
Enable `show_builtin_git_pickers` to additionally show Telescopes builtin git pickers.

## ⚙️ Installation

With Lazy

```lua
    {
        "aaronhallaert/advanced-git-search.nvim",
        config = function()
            -- optional: setup telescope before loading the extension
            require("telescope").setup{
                -- move this to the place where you call the telescope setup function
                extensions = {
                    advanced_git_search = {
                        -- fugitive or diffview
                        diff_plugin = "fugitive",
                        -- customize git in previewer
                        -- e.g. flags such as { "--no-pager" }, or { "-c", "delta.side-by-side=false" }
                        git_flags = {},
                        -- customize git diff in previewer
                        -- e.g. flags such as { "--raw" }
                        git_diff_flags = {},
                        -- Show builtin git pickers when executing "show_custom_functions" or :AdvancedGitSearch
                        show_builtin_git_pickers = false,
                    }
                }
            }

            require("telescope").load_extension("advanced_git_search")
        end,
        dependencies = {
            "nvim-telescope/telescope.nvim",
            -- to show diff splits and open commits in browser
            "tpope/vim-fugitive",
            -- to open commits in browser with fugitive
            "tpope/vim-rhubarb",
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
            -- optional: setup telescope before loading the extension
            require("telescope").setup{
                -- move this to the place where you call the telescope setup function
                extensions = {
                    advanced_git_search = {
                        -- Fugitive or diffview
                        diff_plugin = "fugitive",
                        -- Customize git in previewer
                        -- e.g. flags such as { "--no-pager" }, or { "-c", "delta.side-by-side=false" }
                        git_flags = {},
                        -- Customize git diff in previewer
                        -- e.g. flags such as { "--raw" }
                        git_diff_flags = {},
                        -- Show builtin git pickers when executing "show_custom_functions" or :AdvancedGitSearch
                        show_builtin_git_pickers = false,
                    }
                }
            }

            require("telescope").load_extension("advanced_git_search")
        end,
        requires = {
            "nvim-telescope/telescope.nvim",
            -- to show diff splits and open commits in browser
            "tpope/vim-fugitive",
            -- to open commits in browser with fugitive
            "tpope/vim-rhubarb",
            -- optional: to replace the diff from fugitive with diffview.nvim
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

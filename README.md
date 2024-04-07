# 🍃 Advanced Git Search

An advanced git search extension for `Telescope` and `fzf-lua`.

Search your git history by commit message, content and author in Neovim

## 🚀 Usage

[Demo](https://www.youtube.com/watch?v=bO0uYLlHtYo)

- __📖 Open a picker__

    `:AdvancedGitSearch` or `:AdvancedGitSearch {command}`

- __🔎 Enter a query__

    Your usual search experience. See the individual commands for the grep behaviour.

- __✏️ Further search on commit author with `@`__

    The prompt is split on `@`. Everything following the `@` is the pattern for
the author name.

## ⚡️ Commands

### 1. search_log_content -- Search in repo log content

Opens a window with a list of all previous commit.

_Grep behaviour_: filter on added, updated or removed code (log content: `-G` option in git).

#### _Keymaps_

- `<CR>` Opens a diff of the current file with the selected commit
- `<C-e>` show the entire commit for all files in neovim with diff plugin
- `<C-o>` Open the selected commit in the browser
- `<C-y>` copy the commit hash to clipboard
- `<C-w>` toggle date and author in entry

### 2. search_log_content_file -- Search in file log content

Opens a window with a list of git commits that changed the
current file (renames included).

_Grep behaviour_: filter on added, updated or removed code (log content: `-G` option in git).

#### _Keymaps_

- `<CR>` Opens a diff of the current file with the selected commit
- `<C-e>` show the entire commit for all files in neovim with diff plugin
- `<C-o>` Open the selected commit in the browser
- `<C-y>` copy the commit hash to clipboard
- `<C-w>` toggle date and author in entry

### 3. diff_commit_file -- Diff current file with commit

Opens a window with a list of git commits that changed the
current file (renames included).

_Grep behaviour_: filter on commit message.

#### _Keymaps_

- `<CR>` Opens a diff of the current file with the selected commit
- `<C-e>` show the entire commit for all files in neovim with diff plugin
- `<C-o>` Open the selected commit in the browser
- `<C-y>` copy the commit hash to clipboard
- `<C-w>` toggle date and author in entry

### 4. diff_commit_line -- Diff current file with selected line history

Opens a window with a list of previous commit logs with respect to
selected lines

_Grep behaviour_: filter on commit message.

> Use `:'<,'>AdvancedGitSearch diff_commit_line` (with a visual range).

#### _Keymaps_

- `<CR>` opens a diff for the current file with the corresponding file on the selected commit
- `<C-e>` show the entire commit for all files in neovim with diff plugin
- `<C-o>` opens a the selected commit in the browser
- `<C-y>` copy the commit hash to clipboard
- `<C-w>` toggle date and author in entry

### 5. diff_branch_file -- Diff file with branch

Opens a window with a list of local branches

_Grep behaviour_: filter on branch name.

#### _Keymaps_

- `<CR>` opens a diff for the current file with the selected branch

### 6. changed_on_branch -- Changed on current branch (experimental)

Opens a window with a list of changed files on the current branch (including staged files).
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

Opens a window with all reflog entries

#### _Keymaps_

- `<CR>` checkout the reflog entry

### 8. show_custom_functions

A telescope picker for all functions above.
Enable `show_builtin_git_pickers` to additionally show builtin git pickers.

## ⚙️ Installation

### Config

```lua
{
    -- Browse command to open commits in browser. Default fugitive GBrowse.
    browse_command = "GBrowse",
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
    entry_default_author_or_date = "author", -- one of "author" or "date"
    keymaps = {
        -- following keymaps can be overridden
        toggle_date_author = "<C-w>",
        open_commit_in_browser = "<C-o>",
        copy_commit_hash = "<C-y>",
        show_entire_commit = "<C-e>",
    }

    -- Telescope layout setup
    telescope_theme = {
        function_name_1 = {
            -- Theme options
        },
        function_name_2 = "dropdown"
        -- e.g. realistic example
        show_custom_functions = {
            layout_config = { width = 0.4, height = 0.4 },
        },

    }
}
```

### Dependencies

```lua
{
    "nvim-telescope/telescope.nvim",
    -- to show diff splits and open commits in browser
    "tpope/vim-fugitive",
    -- to open commits in browser with fugitive
    "tpope/vim-rhubarb",
    -- optional: to replace the diff from fugitive with diffview.nvim
    -- (fugitive is still needed to open in browser)
    -- "sindrets/diffview.nvim",
}
```


### Telescope

<details>
<summary>Lazy</summary>
To complete this snippet, see [Config](#Config) and [Dependencies](#Dependencies).

```lua
{
    "aaronhallaert/advanced-git-search.nvim",
    cmd = { "AdvancedGitSearch" },
    config = function()
        -- optional: setup telescope before loading the extension
        require("telescope").setup{
            -- move this to the place where you call the telescope setup function
            extensions = {
                advanced_git_search = {
                        -- See Config
                    }
            }
        }

        require("telescope").load_extension("advanced_git_search")
    end,
    dependencies = {
        --- See dependencies
    },
}
```
</details>

<details>
<summary>Packer</summary>

To complete this snippet, see [Config](#Config) and [Dependencies](#Dependencies).

```lua
use({
    "aaronhallaert/advanced-git-search.nvim",
    config = function()
        -- optional: setup telescope before loading the extension
        require("telescope").setup{
            -- move this to the place where you call the telescope setup function
            extensions = {
                advanced_git_search = {
                    -- Insert Config here
                }
            }
        }

        require("telescope").load_extension("advanced_git_search")
    end,
    requires = {
        -- Insert Dependencies here
    },
})
```
</details>

### Fzf-lua

<details>
<summary>Lazy</summary>
To complete this snippet, see [Config](#Config) and [Dependencies](#Dependencies).

```lua
{
    "aaronhallaert/advanced-git-search.nvim",
    cmd = { "AdvancedGitSearch" },
    config = function()
        require("advanced_git_search.fzf").setup{
            -- Insert Config here
        }
    end,
    dependencies = {
        -- Insert Dependencies here
    },
}
```
  
</details>

<details>
<summary>Packer</summary>

To complete this snippet, see [Config](#Config) and [Dependencies](#Dependencies).

```lua
use({
    "aaronhallaert/advanced-git-search.nvim",
    config = function()
        require("advanced_git_search.fzf").setup{
                -- Insert Config here
            }
        }
    end,
    requires = {
        -- Insert Dependencies here
    },
})
```
</details>


### Prerequisites

- git
- vim-fugitive
- sindrets/diffview.nvim
- telescope.nvim

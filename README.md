# Telescope Advanced Git Search

## Summary

Usage
```
:Telescope advanced_git_search {function_name}
```


### `diff_file_branch`

Opens a Telescope window with a list of local branches

#### Keymaps

- `<CR>` opens a diff for the current file with the selected branch

### `diff_file_log`

Opens a Telescope window with a list of previous commit logs with respect to selected lines

Note: First you have to select the lines in visual mode, then go back to normal 
mode and execute this command.


- `<CR>` opens a diff for the current file with the selected commit
- `<C-o>` opens a the selected commit in the browser

### `search_git_log`

Opens a Telescope window with a list of previous commit logs filtered on the
`content` of the commits.

#### Keymaps

- `<CR>` opens a diff for the current file with the selected commit
- `<C-o>` opens a the selected commit in the browser

### `diff_file_commit`

Opens a Telescope window with a list of git commits which changed the current file (renames included)

#### Keymaps

- `<CR>` Opens a diff of the current file with the selected commit
- `<C-e>` Opens an entire git diff of the selected commit
- `<C-o>` Open the selected commit in the browser

### `checkout_reflog`

Opens a Telescope window with all reflog entries

#### Keymaps

- `<CR>` checkout on the reflog entry

### `show_custom_functions`

A telescope picker for all functions above.

## Installation

With packer

```lua
    {
        "aaronhallaert/ts-advanced-git-search.nvim",
        config = function()
            -- load the extension in telescope
            require("telescope").load_extension("advanced_git_search")
        end,
    }
```

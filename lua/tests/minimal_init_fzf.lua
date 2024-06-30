#

function M.setup()
    vim.opt.runtimepath:remove(vim.fn.expand("~/.config/nvim"))
    vim.opt.packpath:remove(vim.fn.expand("~/.local/share/nvim/site"))
    vim.opt.runtimepath:append(M.root())
    vim.opt.runtimepath:append("./")

    vim.fn.delete(M.root(".tests"), "rf")
    vim.opt.packpath = { M.root(".tests/site") }

    -- dependencies

    vim.env.XDG_CONFIG_HOME = M.root(".tests/config")
    vim.env.XDG_DATA_HOME = M.root(".tests/data")
    vim.env.XDG_STATE_HOME = M.root(".tests/state")
    vim.env.XDG_CACHE_HOME = M.root(".tests/cache")

    print("Setup complete...\n")
    require("fzf-lua").setup({
        "telescope",
        winopts = {
            hl_border = "Normal",
        },
        fzf_layout = "default",
    })

    require("advanced_git_search.fzf").setup({
        git_flags = { "-c", "delta.side-by-side=false" },
        git_diff_flags = {},
        show_builtin_git_pickers = true,
        diff_plugin = "diffview",
        entry_default_author_or_date = "author",
    })

    print("Config complete...\n")
end


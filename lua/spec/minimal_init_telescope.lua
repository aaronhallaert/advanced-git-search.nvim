local M = {}

function M.root(root)
    local f = debug.getinfo(1, "S").source:sub(2)
    return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

---@param plugin string
function M.load(plugin)
    local name = plugin:match(".*/(.*)")
    local package_root = M.root(".tests/site/pack/deps/start/")
    if not vim.loop.fs_stat(package_root .. name) then
        print("Installing " .. plugin)
        vim.fn.mkdir(package_root, "p")
        vim.fn.system({
            "git",
            "clone",
            "--depth=1",
            "https://github.com/" .. plugin .. ".git",
            package_root .. "/" .. name,
        })
    end
end

function M.setup()
    vim.opt.runtimepath:remove(vim.fn.expand("~/.config/nvim"))
    vim.opt.packpath:remove(vim.fn.expand("~/.local/share/nvim/site"))
    vim.opt.runtimepath:append(M.root())
    vim.opt.runtimepath:append("./")

    vim.fn.delete(M.root(".tests"), "rf")

    vim.opt.packpath = { M.root(".tests/site") }

    -- dependencies
    M.load("nvim-lua/plenary.nvim")
    M.load("nvim-telescope/telescope.nvim")
    M.load("tpope/vim-fugitive")
    M.load("tpope/vim-rhubarb")
    M.load("sindrest/diffview.nvim")

    vim.env.XDG_CONFIG_HOME = M.root(".tests/config")
    vim.env.XDG_DATA_HOME = M.root(".tests/data")
    vim.env.XDG_STATE_HOME = M.root(".tests/state")
    vim.env.XDG_CACHE_HOME = M.root(".tests/cache")

    print("Setup complete...\n")

    require("telescope").setup({
        extensions = {
            advanced_git_search = {
                git_flags = { "-c", "delta.side-by-side=false" },
                git_diff_flags = {},
                git_log_flags = {},
                show_builtin_git_pickers = true,
                diff_plugin = "diffview",
            },
        },
    })
    require("telescope").load_extension("advanced_git_search")

    print("Config complete...\n")
end

M.setup()

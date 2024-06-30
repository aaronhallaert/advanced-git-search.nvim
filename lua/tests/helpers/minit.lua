local M = {}

local root = function(root)
    local f = debug.getinfo(1, "S").source:sub(2)
    return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

---@param plugin string
local load = function(plugin)
    local name = plugin:match(".*/(.*)")
    local package_root = root(".tests/site/pack/deps/start/")
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

---@class MiniOpts
---@field dependencies Plugin[]
---@field config function

---@class Plugin
---@field path string
---@field config function

---@param opts MiniOpts
function M.setup(opts)
    vim.opt.runtimepath:remove(vim.fn.expand("~/.config/nvim"))
    vim.opt.packpath:remove(vim.fn.expand("~/.local/share/nvim/site"))
    vim.opt.runtimepath:append(root())
    vim.opt.runtimepath:append("./")

    vim.fn.delete(root(".tests"), "rf")
    vim.opt.packpath = { root(".tests/site") }

    vim.env.XDG_CONFIG_HOME = root(".tests/config")
    vim.env.XDG_DATA_HOME = root(".tests/data")
    vim.env.XDG_STATE_HOME = root(".tests/state")
    vim.env.XDG_CACHE_HOME = root(".tests/cache")

    for dependency in opts.dependencies do
        load(dependency.path)
        M.config()
    end

    opts.config()
end

return M

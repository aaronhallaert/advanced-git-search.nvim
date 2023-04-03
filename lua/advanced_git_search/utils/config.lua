local M = {}

local config = {}

M.setup = function(ext_config)
    ext_config = ext_config or {}

    ext_config.diff_plugin = ext_config.diff_plugin or "fugitive"
    ext_config.git_diff_flags = ext_config.git_diff_flags or {}

    config = ext_config
end

M.get_config = function()
    return config
end

M.git_diff_flags = function()
    local git_diff_flags = config["git_diff_flags"] or {}

    if type(git_diff_flags) ~= "table" then
        vim.notify(
            "git_diff_flags must be a table",
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
        return nil
    end

    return git_diff_flags
end

M.git_flags = function()
    local git_flags = config["git_flags"] or {}

    if type(git_flags) ~= "table" then
        vim.notify(
            "git_flags must be a table",
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
        return nil
    end

    return git_flags
end

M.diff_plugin = function()
    local diff_plugin = config["diff_plugin"]

    if diff_plugin == "fugitive" and vim.fn.exists(":Gvdiffsplit") == 0 then
        vim.notify(
            "fugitive configured but git-fugitive is not installed",
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
        return nil
    elseif
        diff_plugin == "diffview" and vim.fn.exists(":DiffviewOpen") == 0
    then
        vim.notify(
            "diffview configured but diffview.nvim is not installed",
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
        return nil
    elseif diff_plugin == nil then
        vim.notify(
            "No diff plugin configured",
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
        return nil
    end

    return diff_plugin
end

return M

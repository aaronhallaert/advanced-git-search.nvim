local M = {}

local config = {}

M.setup = function(ext_config)
    ext_config = ext_config or {}

    ext_config.diff_plugin = ext_config.diff_plugin or "fugitive"

    config = ext_config
end

M.get_config = function()
    return config
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

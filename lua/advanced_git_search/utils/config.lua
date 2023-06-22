local M = {}

local config = {}

M.setup = function(ext_config)
    ext_config = ext_config or {}

    ext_config.diff_plugin = ext_config.diff_plugin or "fugitive"
    ext_config.git_diff_flags = ext_config.git_diff_flags or {}
    ext_config.show_builtin_git_pickers = ext_config.show_builtin_git_pickers
        or false

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

M.telescope_theme = function(function_name)
    local themes = require("telescope.themes")
    local telescope_theme_config = config["telescope_theme"] or {}
    local theme = telescope_theme_config[function_name] or {}

    local theme_opts = {}
    -- apply theme
    if type(theme) == "table" then
        theme_opts = vim.tbl_extend("force", theme_opts, theme)
    elseif type(theme) == "string" then
        if themes["get_" .. theme] == nil then
            vim.notify_once(
                "advanced git search theme »" .. theme .. "« not found",
                vim.log.levels.WARN
            )
        else
            theme_opts = themes["get_" .. theme](theme_opts)
        end
    end

    return theme_opts
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

M.show_builtin_git_pickers = function()
    return config["show_builtin_git_pickers"]
end

return M

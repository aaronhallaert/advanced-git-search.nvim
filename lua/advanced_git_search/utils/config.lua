local M = {}

local config = {}

M.setup = function(ext_config)
    ext_config = ext_config or {}

    ext_config.browse_command = ext_config.browse_command
        or "GBrowse {commit_hash}"
    ext_config.diff_plugin = ext_config.diff_plugin or "fugitive"
    ext_config.git_diff_flags = ext_config.git_diff_flags or {}
    ext_config.git_log_flags = ext_config.git_log_flags or {}
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

M.git_log_flags = function()
    local git_log_flags = config["git_log_flags"] or {}

    if type(git_log_flags) ~= "table" then
        vim.notify(
            "git_log_flags must be a table",
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
        return nil
    end

    return git_log_flags
end

local function get_keymaps()
    local keymaps = {
        toggle_date_author = "<C-w>",
        open_commit_in_browser = "<C-o>",
        copy_commit_hash = "<C-y>",
        copy_commit_patch = "<C-p>",
        show_entire_commit = "<C-e>",
    }
    keymaps = vim.tbl_extend("force", keymaps, config["keymaps"] or {})

    if type(keymaps) ~= "table" then
        vim.notify(
            "keymaps config must be a table",
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
        return nil
    end

    return keymaps
end

---@param entry string
---@param format string|nil "C", "ctrl" (default: "C")
---@return string "<C-key>" or "ctrl-key"
M.get_keymap = function(entry, format)
    format = format or "C"

    if get_keymaps()[entry] == nil then
        vim.notify(
            "No keymap defined for " .. entry,
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
        return ""
    end

    if type(get_keymaps()[entry]) ~= "string" then
        vim.notify(
            "Keymap for " .. entry .. " must be a string",
            vim.log.levels.ERROR,
            { title = "Advanced Git Search" }
        )
        return ""
    end

    if format == "ctrl" then
        local configured_keymap = get_keymaps()[entry]
        local keymap, _ =
            string.gsub(configured_keymap, "%<C%-(.)%>", "ctrl-%1")
        return keymap
    end

    return get_keymaps()[entry]
end

M.entry_default_author_or_date = function()
    return config["entry_default_author_or_date"] or "author"
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

M.get_browse_command = function(commit_hash)
    local cmd = config["browse_command"]
    local commit_pattern = "%{commit_hash%}"

    if string.find(config["browse_command"], commit_pattern) == nil then
        return cmd .. " " .. commit_hash
    end

    return string.gsub(cmd, commit_pattern, commit_hash)
end

return M

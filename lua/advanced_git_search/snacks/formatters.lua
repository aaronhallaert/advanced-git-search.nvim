local M = {}
local config = require("advanced_git_search.utils.config")

---@return snacks.picker.format
M.git_log = function()
    return function(item, picker)
        local a = Snacks.picker.util.align
        local mode = config.entry_default_author_or_date()

        local ret = {} ---@type snacks.picker.Highlight[]
        ret[#ret + 1] =
            { picker.opts.icons.git.commit, "SnacksPickerGitCommit" }
        ret[#ret + 1] = {
            a(item.commit, 8, { truncate = true }),
            "SnacksPickerGitCommit",
        }
        ret[#ret + 1] = { " " }
        if mode == "date" then
            ret[#ret + 1] = {
                a(item.date, 10, { truncate = true }),
                "SnacksPickerGitDate",
            }
            ret[#ret + 1] = { " " }
        elseif mode == "both" then
            ret[#ret + 1] = {
                a(item.date, 10, { truncate = true }),
                "SnacksPickerGitDate",
            }
            ret[#ret + 1] = { " " }
            ret[#ret + 1] = {
                a(item.author, 15, { truncate = true }),
                "SnacksPickerGitDate",
            }
            ret[#ret + 1] = { " " }
        else
            ret[#ret + 1] = {
                a(item.author, 15, { truncate = true }),
                "SnacksPickerGitDate",
            }
            ret[#ret + 1] = { " " }
        end
        ret[#ret + 1] = { item.msg, "SnacksPickerGitMsg" }
        return ret
    end
end

---@return snacks.picker.format
M.git_branches = function()
    return function(item, _)
        local ret = {} ---@type snacks.picker.Highlight[]
        ret[#ret + 1] = { item.text, "SnacksPickerGitCommit" }
        return ret
    end
end

return M

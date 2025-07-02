local M = {}

---@return snacks.picker.format
M.git_log = function()
    return function(item, picker)
        local a = Snacks.picker.util.align

        local ret = {} ---@type snacks.picker.Highlight[]
        ret[#ret + 1] =
            { picker.opts.icons.git.commit, "SnacksPickerGitCommit" }
        ret[#ret + 1] = {
            a(item.commit, 8, { truncate = true }),
            "SnacksPickerGitCommit",
        }
        ret[#ret + 1] = { " " }
        ret[#ret + 1] = {
            a(item.author, 15, { truncate = true }),
            "SnacksPickerGitDate",
        }
        ret[#ret + 1] = { " " }
        ret[#ret + 1] = { item.msg, "SnacksPickerGitMsg" }
        return ret
    end
end

return M

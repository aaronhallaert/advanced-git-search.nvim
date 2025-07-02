local M = {}

---@return snacks.picker.transform
M.git_log = function()
    return function(item)
        -- "--format='%h %as %an _ %s'",

        local commit, date, author, subject =
            item.text:match("^'(%S+) (%S+) (%S.-%S) _ (.+)'$")

        if not commit then
            vim.print(("failed to parse log item:\n%q"):format(item.text))
            return false
        end
        item.commit = commit
        item.msg = subject
        item.date = date
        item.author = author
        return item
    end
end

return M

local color = require("fzf-lua").utils.ansi_codes
local utils = require("advanced_git_search.utils")

local M = {}

M.make_entry = function(entry)
    if entry == "" or entry == nil then
        return
    end
    -- dce3b0743 2022-09-09 author _ message
    -- FIXME: will break if author contains _
    local cleaned = string.gsub(entry, "'", "")
    local split = utils.split_string(cleaned, "_")
    local attrs = utils.split_string(split[1])
    local hash = attrs[1]
    -- local date = attrs[2]
    local author = ""
    for i = 3, #attrs do
        author = author .. attrs[i] .. " "
    end
    -- join split from second element
    local message = split[2]
    if #split > 2 then
        for i = 3, #split do
            message = message .. "_" .. split[i]
        end
    end

    -- NOTE: make sure the first value is the commit hash
    return color.magenta(hash)
        .. color.cyan(" @" .. author)
        .. color.yellow(message)
end

M.make_reflog_entry = function(entry)
    if entry == "" or entry == nil then
        return
    end

    local cleaned = string.gsub(entry, "'", "")
    local split = utils.split_string(cleaned, " ")
    local hash = split[1]

    local rest = split[2]
    for i = 3, #split do
        rest = rest .. " " .. split[i]
    end

    local split_on_double = utils.split_string(rest, ":")
    local description = ""
    for i = 4, #split_on_double do
        description = description .. split_on_double[i]
    end

    local meta = ""
    for i = 1, 3 do
        meta = meta .. split_on_double[i]
    end

    -- NOTE: make sure the first value is the commit hash
    return color.magenta(hash) .. " " .. meta .. "" .. color.yellow(description)
end

return M

local utils = require("advanced_git_search.utils")
local entry_display = require("telescope.pickers.entry_display")
local config = require("advanced_git_search.utils.config")

local show_date_instead_of_author = (
    config.entry_default_author_or_date() == "date"
)

local M = {}
local last_prompt = nil

M.toggle_show_date_instead_of_author = function()
    show_date_instead_of_author = not show_date_instead_of_author
end

--- Parse "--format=%C(auto)%h %as %C(green)%an _ %Creset %s" to table
--- with opts: commit_hash, date, author, message, prompt
--- @param entry string
M.git_log_entry_maker = function(entry)
    -- dce3b0743 2022-09-09 author _ message
    -- FIXME: will break if author contains _
    local cleaned = string.gsub(entry, "'", "")
    local split = utils.split_string(cleaned, "_")
    local attrs = utils.split_string(split[1])
    local hash = string.sub(attrs[1], 1, 7)
    local date = attrs[2]
    local author = attrs[3]
    for i = 4, #attrs do
        author = author .. " " .. attrs[i]
    end

    -- join split from second element
    local message = split[2]
    if #split > 2 then
        for i = 3, #split do
            message = message .. " " .. split[i]
        end
    end

    local second_width
    if show_date_instead_of_author then
        second_width = 10
    else
        second_width = #author
    end

    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = 7 },
            { width = second_width },
            { remaining = true },
        },
    })

    local make_display = function(display_entry)
        if show_date_instead_of_author then
            return displayer({
                {
                    display_entry.opts.commit_hash,
                    "TelescopeResultsIdentifier",
                },
                { display_entry.opts.date, "TelescopeResultsVariable" },
                { display_entry.opts.message, "TelescopeResultsConstant" },
            })
        else
            return displayer({
                {
                    display_entry.opts.commit_hash,
                    "TelescopeResultsIdentifier",
                },
                { display_entry.opts.author, "TelescopeResultsVariable" },
                { display_entry.opts.message, "TelescopeResultsConstant" },
            })
        end
    end

    return {
        value = entry,
        -- display = date .. " by " .. author .. " --" .. message,
        display = make_display,
        ordinal = author .. " " .. message,
        preview_title = hash .. " -- " .. message,
        opts = {
            commit_hash = hash,
            date = date,
            author = author,
            message = message,
            prompt = last_prompt,
        },
    }
end

M.set_last_prompt = function(prompt)
    last_prompt = prompt
end

return M

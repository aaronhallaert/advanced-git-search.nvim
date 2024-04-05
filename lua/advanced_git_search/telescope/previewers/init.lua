local previewers = require("telescope.previewers")
local file_utils = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")
local preview_commands = require("advanced_git_search.commands.preview")
local putils = require("telescope.previewers.utils")

local M = {}

--- Shows a diff of the commit in the finder entry, filtered on the file of the current buffer
M.git_diff_commit_file_previewer = function(opts)
    opts = opts or {}

    return previewers.new_buffer_previewer({
        title = "Changes on selected commit for: "
            .. file_utils.file_name(opts.bufnr),
        -- teardown = search_teardown,
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,

        define_preview = function(self, entry, _status)
            local commit_hash = entry.opts.commit_hash
            local prev_commit = git_utils.previous_commit_hash(commit_hash)
            local cmd = preview_commands.git_diff_file(
                prev_commit,
                commit_hash,
                opts.bufnr,
                { color = false }
            )

            putils.job_maker(cmd, self.state.bufnr, {
                value = entry.value,
                bufname = self.state.bufname,
                callback = function(callback_bufnr)
                    if vim.api.nvim_buf_is_valid(callback_bufnr) then
                        putils.regex_highlighter(callback_bufnr, "diff")
                    end
                end,
            })
        end,
    })
end

local function highlight_occurrences(bufnr, target)
    if target == "" then
        return
    end
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local pattern = target:gsub("%p", "%%%0") -- escape special characters in the target string
    local highlight_group = "Search" -- you can change this to a highlight group of your choice

    for i, line in ipairs(lines) do
        -- match and return start and end index of the match
        local match_start, match_end = string.find(line, pattern)
        if match_start == nil or match_end == nil then
            goto continue
        end
        local line_nr = i - 1
        local col_start = match_start - 1
        local col_end = match_end
        -- highlight the match
        vim.api.nvim_buf_add_highlight(
            bufnr,
            -1,
            highlight_group,
            line_nr,
            col_start,
            col_end
        )
        ::continue::
    end
end

--- Shows a diff of the commit in the finder entry, filtered on the prompt string for the commit content
M.git_diff_content_previewer = function()
    return previewers.new_buffer_previewer({
        title = "Changes including prompt string",
        define_preview = function(self, entry, _status)
            local commit_hash = entry.opts.commit_hash
            local prompt = entry.opts.prompt
            local prev_commit = git_utils.previous_commit_hash(commit_hash)
            local cmd = preview_commands.git_diff_content(
                prev_commit,
                commit_hash,
                prompt
            )

            putils.job_maker(cmd, self.state.bufnr, {
                value = entry.value,
                bufname = self.state.bufname,
                callback = function(callback_bufnr)
                    if vim.api.nvim_buf_is_valid(callback_bufnr) then
                        putils.regex_highlighter(callback_bufnr, "diff")
                        highlight_occurrences(callback_bufnr, prompt)
                    end
                end,
            })
        end,
    })
end

--- Shows a diff of the file in the finder entry and the fork point of the current branch
M.changed_files_on_current_branch_previewer = function()
    return previewers.new_termopen_previewer({
        title = "Diff of selected file and fork point",
        get_command = function(entry)
            return preview_commands.git_diff_base_branch(entry.value)
        end,
    })
end

--- Shows a diff of the branch in the finder entry relative to the passed filename
M.git_diff_branch_file_previewer = function(bufnr)
    local filename = file_utils.file_name(bufnr)
    return previewers.new_termopen_previewer({
        title = "Diff of current buffer and selected branch for: " .. filename,
        get_command = function(entry)
            local branch = entry.value
            return preview_commands.git_diff_branch(branch, bufnr)
        end,
    })
end

return M

local previewers = require("telescope.previewers")
local file_utils = require("advanced_git_search.utils.file")
local git_utils = require("advanced_git_search.utils.git")
local preview_commands = require("advanced_git_search.commands.preview")
local putils = require("telescope.previewers.utils")

local search_teardown = function(self)
    if self.state and self.state.hl_id then
        pcall(vim.fn.matchdelete, self.state.hl_id, self.state.hl_win)
        self.state.hl_id = nil
    end
end

local search_cb_jump = function(self, bufnr, query)
    if not query or query == "" then
        return
    end

    vim.print("query: ", query)
    vim.api.nvim_buf_call(bufnr, function()
        pcall(vim.fn.matchdelete, self.state.hl_id, self.state.winid)
        vim.cmd("keepjumps norm! gg")
        vim.fn.search(query, "W")
        vim.cmd("norm! zz")

        self.state.hl_id = vim.fn.matchadd("TelescopePreviewMatch", query)
    end)
end

local make_whitespace_regex = function(str)
    local new = str:gsub("\n", "\\(.*\\n\\)*.*")
    return new:gsub("%s+", "\\s*")
end

local M = {}

---@class DiffCommitFilePreviewerOpts
---@field bufnr number
---@field preview_query string|nil

--- Shows a diff of the commit in the finder entry, filtered on the file of the current buffer
---
--- @param opts DiffCommitFilePreviewerOpts
M.git_diff_commit_file_previewer = function(opts)
    return previewers.new_buffer_previewer({
        title = "Changes on selected commit for: "
            .. file_utils.file_name(opts.bufnr),
        teardown = search_teardown,
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,
        define_preview = function(self, entry, _)
            local commit_hash = entry.opts.commit_hash
            local prev_commit = git_utils.previous_commit_hash(commit_hash)
            local cmd = preview_commands.git_diff_file(
                prev_commit,
                commit_hash,
                opts.bufnr
            )

            putils.job_maker(cmd, self.state.bufnr, {
                value = entry.value,
                bufname = self.state.bufname,
                callback = function(preview_bufnr)
                    if vim.api.nvim_buf_is_valid(preview_bufnr) then
                        if opts.preview_query then
                            search_cb_jump(
                                self,
                                preview_bufnr,
                                make_whitespace_regex(opts.preview_query)
                            )
                        end
                        putils.regex_highlighter(preview_bufnr, "diff")
                    end
                end,
            })
        end,
    })
end

--- Shows a diff of the commit in the finder entry, filtered on the prompt string for the commit content
---@param opts table|nil
---@return table
M.git_diff_content_previewer = function(opts)
    opts = opts or {}

    return previewers.new_buffer_previewer({
        title = "Changes including prompt string",
        teardown = search_teardown,
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,
        define_preview = function(self, entry, _)
            local commit_hash = entry.opts.commit_hash
            local prompt = entry.opts.prompt
            local prev_commit = git_utils.previous_commit_hash(commit_hash)
            local cmd = preview_commands.git_diff_content(
                prev_commit,
                commit_hash,
                prompt,
                { bufnr = opts.bufnr }
            )

            putils.job_maker(cmd, self.state.bufnr, {
                value = entry.value,
                bufname = self.state.bufname,
                cwd = opts.cwd,
                callback = function(bufnr)
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        search_cb_jump(self, bufnr, entry.opts.prompt)
                        putils.regex_highlighter(bufnr, "diff")
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

    return previewers.new_buffer_previewer({
        title = "Diff of current buffer and selected branch for: " .. filename,
        get_buffer_by_name = function(_, entry)
            return entry.value
        end,
        define_preview = function(self, entry, _)
            local branch = entry.value

            local cmd = preview_commands.git_diff_branch(branch, bufnr)

            putils.job_maker(cmd, self.state.bufnr, {
                value = entry.value,
                bufname = self.state.bufname,
                callback = function(pbufnr)
                    if vim.api.nvim_buf_is_valid(pbufnr) then
                        putils.regex_highlighter(pbufnr, "diff")
                    end
                end,
            })
        end,
    })
end

return M

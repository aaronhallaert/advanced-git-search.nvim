local utils = require("advanced_git_search.utils")
local git_utils = require("advanced_git_search.utils.git")
local preview_commands = require("advanced_git_search.commands.preview")
local ns = vim.api.nvim_create_namespace("ags_snacks_preview")

local M = {}

---@param opts? {bufnr?: number}
---@return snacks.picker.preview
M.git_diff_content = function(opts)
    opts = opts or { bufnr = nil }

    return function(preview_ctx)
        local prompt = preview_ctx.picker.input:get()

        local search_content, _ = prompt:match("^(.*) @(.*)")

        local prev_commit =
            git_utils.previous_commit_hash(preview_ctx.item.commit)
        local git_log_preview = preview_commands.git_diff_content(
            prev_commit,
            preview_ctx.item.commit,
            string.format("%s", utils.escape_term(search_content)),
            { bufnr = opts.bufnr }
        )

        require("snacks.picker.preview").cmd(git_log_preview, preview_ctx, {
            ft = "diff",
            add = function(text, l)
                vim.api.nvim_buf_set_lines(
                    preview_ctx.buf,
                    l - 1,
                    l,
                    false,
                    { text }
                )
                local col = string.find(text, utils.escape_chars(prompt))
                if prompt and prompt ~= "" and prompt ~= '""' and col then
                    vim.api.nvim_buf_set_extmark(
                        preview_ctx.buf,
                        ns,
                        l - 1,
                        col - 1,
                        {
                            end_row = l - 1,
                            end_col = col - 1 + string.len(prompt),
                            hl_group = "SnacksPickerSearch",
                        }
                    )
                end
            end,
        })
    end
end

---@param opts? {bufnr?: number}
---@return snacks.picker.preview
M.git_diff_file = function(opts)
    opts = opts or { bufnr = nil }

    return function(preview_ctx)
        local prev_commit =
            git_utils.previous_commit_hash(preview_ctx.item.commit)
        local git_diff_file_preview = preview_commands.git_diff_file(
            prev_commit,
            preview_ctx.item.commit,
            opts.bufnr
        )

        require("snacks.picker.preview").cmd(
            git_diff_file_preview,
            preview_ctx,
            {
                ft = "diff",
            }
        )
    end
end

---@param opts? {bufnr?: number}
---@return snacks.picker.preview
M.git_diff_branch = function(opts)
    opts = opts or { bufnr = nil }

    return function(preview_ctx)
        require("snacks.picker.preview").cmd(
            preview_commands.git_diff_branch(preview_ctx.item.text, opts.bufnr),
            preview_ctx,
            {
                ft = "diff",
            }
        )
    end
end

return M

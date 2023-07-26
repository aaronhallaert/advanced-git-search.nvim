-- Custom git previewer that takes in a diff command and a root commit
local builtin = require("fzf-lua.previewer.builtin")
local append_data =
    require("advanced_git_search.fzf.previewers.utils").append_data

local M = {}

---Create an FZF previewer
---@param generate_preview_command function args: entry_str
---@param generate_context function args: entry_str
---@param callback function|nil args: tmpbuf
---@return unknown FZFPreviewer
M.create = function(generate_preview_command, generate_context, callback)
    local Previewer = builtin.base:extend()

    function Previewer:new(o, opts, fzf_win)
        Previewer.super.new(self, o, opts, fzf_win)
        setmetatable(self, Previewer)
        return self
    end

    function Previewer:populate_preview_buf(entry_str)
        local tmpbuf = self:get_tmp_buffer()

        vim.api.nvim_buf_set_lines(
            tmpbuf,
            0,
            -1,
            false,
            generate_context(entry_str)
        )

        local preview_command = generate_preview_command(entry_str)

        -- execute the preview command and append to the buffer
        local channel_id = vim.fn.jobstart(preview_command, {
            -- use pty to enable git pager
            pty = true,
            height = -1,
            on_stdout = append_data(tmpbuf, function()
                if callback ~= nil then
                    return callback(tmpbuf)()
                end
            end),
        })

        -- set hook on buffer exit
        vim.api.nvim_buf_attach(tmpbuf, false, {
            on_detach = function()
                vim.fn.jobstop(channel_id)
            end,
        })

        self:set_preview_buf(tmpbuf)
        self.win:update_scrollbar()
    end

    -- Disable line numbering and word wrap
    function Previewer:gen_winopts()
        local new_winopts = {
            wrap = false,
            number = false,
        }
        return vim.tbl_extend("force", self.winopts, new_winopts)
    end

    return Previewer
end

return M

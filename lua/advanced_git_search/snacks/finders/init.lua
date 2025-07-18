local finder_commands = require("advanced_git_search.commands.find")
local snack_transformers = require("advanced_git_search.snacks.transformers")
local prompt_utils = require("advanced_git_search.utils.prompt")
local utils = require("advanced_git_search.utils")

local M = {}

---@param f_opts? {bufnr?: number}
---@return snacks.picker.finder
M.git_log_content = function(f_opts)
    f_opts = f_opts or { bufnr = nil }

    return function(opts, ctx)
        local prompt = prompt_utils.parse(ctx.picker.input:get())

        local git_log = finder_commands.git_log_content(
            string.format("%s", utils.escape_term(prompt.query)),
            prompt.author,
            f_opts.bufnr
        )
        local args = { unpack(git_log, 2) }
        return require("snacks.picker.source.proc").proc({
            opts,
            {
                cmd = git_log[1],
                args = args,
                transform = snack_transformers.git_log(),
            },
        }, ctx)
    end
end

---@param bufnr number
---@param s_start number
---@param s_end number
---@return snacks.picker.finder
M.git_log_location = function(bufnr, s_start, s_end)
    return function(opts, ctx)
        local prompt = prompt_utils.parse(ctx.picker.input:get())

        local git_log = finder_commands.git_log_location(
            string.format("%s", utils.escape_term(prompt.query)),
            prompt.author,
            bufnr,
            s_start,
            s_end
        )
        return require("snacks.picker.source.proc").proc({
            opts,
            {
                cmd = git_log[1],
                args = { unpack(git_log, 2) },
                transform = snack_transformers.git_log(),
            },
        }, ctx)
    end
end

---@param bufnr number
---@return snacks.picker.finder
M.git_log_file = function(bufnr)
    return function(opts, ctx)
        local prompt = prompt_utils.parse(ctx.picker.input:get())

        local git_log = finder_commands.git_log_file(
            string.format("%s", utils.escape_term(prompt.query)),
            prompt.author,
            bufnr
        )
        return require("snacks.picker.source.proc").proc({
            opts,
            {
                cmd = git_log[1],
                args = { unpack(git_log, 2) },
                transform = snack_transformers.git_log(),
            },
        }, ctx)
    end
end

---@return snacks.picker.finder
M.git_branches = function()
    return function(opts, ctx)
        local git_branches = finder_commands.git_branches()
        return require("snacks.picker.source.proc").proc({
            opts,
            {
                cmd = git_branches[1],
                args = { unpack(git_branches, 2) },
            },
        }, ctx)
    end
end

return M

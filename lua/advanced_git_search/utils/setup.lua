local M = {}

M.setup_user_command = function(pickers)
    vim.api.nvim_create_user_command("AdvancedGitSearch", function(opt)
        local f = opt.fargs[1]

        if f == nil then
            pickers.show_custom_functions()
        else
            pickers[f]()
        end
    end, {
        range = true,
        nargs = "?",
        complete = function(_)
            local completion_list = {}
            local n = 0
            for k, _ in pairs(pickers) do
                if k ~= "show_custom_functions" then
                    n = n + 1
                    completion_list[n] = k
                end
            end
            return completion_list
        end,
    })
end

return M

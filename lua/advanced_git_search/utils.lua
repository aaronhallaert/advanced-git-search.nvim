local M = {}

M.lsp_format_async = function()
    if type(vim.lsp.buf.format) == "function" then
        vim.lsp.buf.format({ async = true })
    elseif type(vim.lsp.buf.formatting) == "function" then
        vim.lsp.buf.formatting()
    end
end

M.lsp_format = function()
    if type(vim.lsp.buf.format) == "function" then
        vim.lsp.buf.format()
    elseif type(vim.lsp.buf.formatting_sync) == "function" then
        vim.lsp.buf.formatting_sync()
    end
end

M.split_string = function(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return M

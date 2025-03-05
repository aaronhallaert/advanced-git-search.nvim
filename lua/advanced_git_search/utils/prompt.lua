local M = {}

---@param prompt string
---@return table {query: string, author?: string}
M.parse = function(prompt)
    local query, author = prompt:match("^(.-)%s*@(%S*)$")

    if query then
        return {
            query = query ~= "" and query or nil,
            author = author ~= "" and author or nil,
        }
    end

    -- there is only an author specified
    local author_only = prompt:match("^.*@(%S*)$")

    if author_only then
        return {
            query = nil,
            author = author,
        }
    end

    -- there is only an @ symbol
    if prompt:match("^%s*@%s*$") then
        return { query = nil, author = nil }
    end

    return {
        query = prompt,
        author = nil,
    }
end

return M

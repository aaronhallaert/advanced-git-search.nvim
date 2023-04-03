local uv = vim.loop
local validate = vim.validate
local utils = require("advanced_git_search.utils")

local M = {}

M.relative_path = function(bufnr)
    return vim.fn.expand("#" .. bufnr .. ":~:.")
end

M.git_dir = function()
    return M.find_first_ancestor_dir_or_file(vim.fn.getcwd(), ".git")
end

M.file_name = function(bufnr)
    return vim.fn.expand("#" .. bufnr .. ":t")
end

M.absolute_path = function(bufnr)
    return vim.fn.expand("#" .. bufnr .. ":p")
end

M.extension = function(bufnr)
    return vim.fn.expand("#" .. bufnr .. ":e")
end

M.get_json_table = function(path)
    local file = io.open(path, "r")

    if file then
        -- read all contents of file into a string
        local contents = file:read("*a")
        local myTable = vim.json.decode(contents)
        io.close(file)
        return myTable
    end
    return nil
end

M.git_relative_path = function(bufnr)
    local abs_filename = M.absolute_path(bufnr)
    local git_dir = M.find_first_ancestor_dir_or_file(abs_filename, ".git")

    if git_dir and git_dir ~= "" then
        git_dir = utils.escape_chars(git_dir .. "/")
        return string.gsub(abs_filename, git_dir, "")
    else
        -- try with current cwd (normally a git repo)
        git_dir = utils.escape_chars(vim.fn.getcwd() .. "/")
        return string.gsub(abs_filename, git_dir, "")
    end
end

M.git_relative_path_to_relative_path = function(git_relative_path)
    local git_dir = M.find_first_ancestor_dir_or_file(vim.fn.getcwd(), ".git")
    local project_dir = vim.fn.getcwd()

    local absolute_path = git_dir .. "/" .. git_relative_path
    project_dir = utils.escape_chars(project_dir .. "/")
    return string.gsub(absolute_path, project_dir, "")
end

M.path = (function()
    local is_windows = uv.os_uname().version:match("Windows")

    local function sanitize(path)
        if is_windows then
            path = path:sub(1, 1):upper() .. path:sub(2)
            path = path:gsub("\\", "/")
        end
        return path
    end

    local function exists(filename)
        local stat = uv.fs_stat(filename)
        return stat and stat.type or false
    end

    local function is_dir(filename)
        return exists(filename) == "directory"
    end

    local function is_file(filename)
        return exists(filename) == "file"
    end

    local function is_fs_root(path)
        if is_windows then
            return path:match("^%a:$")
        else
            return path == "/"
        end
    end

    local function is_absolute(filename)
        if is_windows then
            return filename:match("^%a:") or filename:match("^\\\\")
        else
            return filename:match("^/")
        end
    end

    local function dirname(path)
        local strip_dir_pat = "/([^/]+)$"
        local strip_sep_pat = "/$"
        if not path or #path == 0 then
            return
        end
        local result = path:gsub(strip_sep_pat, ""):gsub(strip_dir_pat, "")
        if #result == 0 then
            if is_windows then
                return path:sub(1, 2):upper()
            else
                return "/"
            end
        end
        return result
    end

    local function path_join(...)
        return table.concat(vim.tbl_flatten({ ... }), "/")
    end

    -- Traverse the path calling cb along the way.
    local function traverse_parents(path, cb)
        path = uv.fs_realpath(path)
        local dir = path
        -- Just in case our algo is buggy, don't infinite loop.
        for _ = 1, 100 do
            dir = dirname(dir)
            if not dir then
                return
            end
            -- If we can't ascend further, then stop looking.
            if cb(dir, path) then
                return dir, path
            end
            if is_fs_root(dir) then
                break
            end
        end
    end

    -- Iterate the path until we find the rootdir.
    local function iterate_parents(path)
        local function it(_, v)
            if v and not is_fs_root(v) then
                v = dirname(v)
            else
                return
            end
            if v and uv.fs_realpath(v) then
                return v, path
            else
                return
            end
        end

        return it, path, path
    end

    local function is_descendant(root, path)
        if not path then
            return false
        end

        local function cb(dir, _)
            return dir == root
        end

        local dir, _ = traverse_parents(path, cb)

        return dir == root
    end

    local path_separator = is_windows and ";" or ":"

    return {
        is_dir = is_dir,
        is_file = is_file,
        is_absolute = is_absolute,
        exists = exists,
        dirname = dirname,
        join = path_join,
        sanitize = sanitize,
        traverse_parents = traverse_parents,
        iterate_parents = iterate_parents,
        is_descendant = is_descendant,
        path_separator = path_separator,
    }
end)()

function M.search_ancestors(startpath, func)
    validate({ func = { func, "f" } })
    if func(startpath) then
        return startpath
    end
    local guard = 100
    for path in M.path.iterate_parents(startpath) do
        -- Prevent infinite recursion if our algorithm breaks
        guard = guard - 1
        if guard == 0 then
            return
        end

        if func(path) then
            return path
        end
    end
end

function M.root_pattern(...)
    local patterns = vim.tbl_flatten({ ... })
    local function matcher(path)
        for _, pattern in ipairs(patterns) do
            for _, p in
                ipairs(vim.fn.glob(M.path.join(path, pattern), true, true))
            do
                if M.path.exists(p) then
                    return path
                end
            end
        end
    end

    return function(startpath)
        return M.search_ancestors(startpath, matcher)
    end
end

function M.find_node_modules_ancestor(startpath)
    return M.search_ancestors(startpath, function(path)
        if M.path.is_dir(M.path.join(path, "node_modules")) then
            return path
        end
    end)
end

function M.find_package_json_ancestor(startpath)
    return M.search_ancestors(startpath, function(path)
        if M.path.is_file(M.path.join(path, "package.json")) then
            return path
        end
    end)
end

function M.find_first_ancestor(startpath, pattern)
    return M.search_ancestors(startpath, function(path)
        if M.path.is_file(M.path.join(path, pattern)) then
            return path
        end
    end)
end

function M.find_first_ancestor_dir_or_file(startpath, pattern)
    return M.search_ancestors(startpath, function(path)
        if
            M.path.is_file(M.path.join(path, pattern))
            or M.path.is_dir(M.path.join(path, pattern))
        then
            return path
        end
    end)
end

return M

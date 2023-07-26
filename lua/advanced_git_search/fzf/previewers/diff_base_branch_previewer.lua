local fzf_previewer =
    require("advanced_git_search.fzf.previewers.fzf_previewer")
local git_utils = require("advanced_git_search.utils.git")
local preview_commands = require("advanced_git_search.commands.preview")

local generate_context = function(filename)
    return {
        "Preview of selected file compared to base branch",
        string.format("\t Selected: %s", filename),
        string.format("\t Base branch: %s", git_utils.base_branch()),
    }
end

local generate_preview_command = function()
    return function(filename)
        return table.concat(
            preview_commands.git_diff_base_branch(filename),
            " "
        )
    end
end

return fzf_previewer.create(generate_preview_command(), generate_context, nil)

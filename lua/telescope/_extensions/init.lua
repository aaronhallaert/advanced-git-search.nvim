local func = require("functions")

return require("telescope").register_extension({
    exports = {
        diff_file_branch = func.diff_file_branch,
        diff_file_log = func.diff_file_log,
        search_git_log = func.search_git_log,
        diff_file_commit = func.diff_file_commit,
        checkout_reflog = func.checkout_reflog,
        show_custom_functions = func.show_custom_functions,
    },
})

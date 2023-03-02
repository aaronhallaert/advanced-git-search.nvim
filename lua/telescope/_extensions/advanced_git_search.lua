local func = require("advanced_git_search")

return require("telescope").register_extension({
    exports = {
        checkout_reflog = func.checkout_reflog,
        diff_branch_file = func.diff_branch_file,
        diff_commit_file = func.diff_commit_file,
        diff_commit_line = func.diff_commit_line,
        search_log_content = func.search_log_content,
        search_log_content_file = func.search_log_content_file,
        show_custom_functions = func.show_custom_functions,
    },
})

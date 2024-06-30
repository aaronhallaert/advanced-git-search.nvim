-- #!/usr/bin/env -S nvim -l

local minit = require("tests.helpers.minit")

minit.setup({
    dependencies = {
        { "ibhagwan/fzf-lua" },
        { "tpope/vim-fugitive" },
        { "tpope/vim-rhubarb" },
        { "sindrest/diffview.nvim" },
    },
})

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

require("neo-tree").setup({
    enable_git_status = true,
    sort_case_insensitive = true,
    window = {
        width = 40
    },
    filesystem = {
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true,
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = false
        }
    }
})


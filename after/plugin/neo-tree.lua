vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

require("neo-tree").setup({
    enable_git_status = true,
    close_if_last_window = true,
    window = {
        width = 40
    },
    filesystem = {
        hijack_netrw_behavior = "open_default",
        use_libuv_file_watcher = true
    }
})


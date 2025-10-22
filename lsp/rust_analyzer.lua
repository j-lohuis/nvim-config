return {
  cmd = { 'rust-analyzer' },
  settings = {
    ['rust-analyzer'] = {
      -- completion = {
      --   callable = {
      --     snippets = 'none',
      --   },
      -- },
      checkOnSave = true,
      check = {
        allTargets = true,
        command = "clippy",
        -- extraArgs = {"--all-features"},
      },
      cargo = {
        features = "all",
      },
    }
  },
}

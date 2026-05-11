local default = {
  cmd = { 'rust-analyzer' },
  settings = {
    ['rust-analyzer'] = {
      files = {
        watcher = "server",
        exclude = {
          "**/target/**",
          "**/node_modules/**",
        }
      },
      checkOnSave = true,
      check = {
        allTargets = true,
        command = "clippy",
      },
      cargo = {
        targetDir = "target/ra",
        allTargets = true,
        features = "all",
      },
    }
  },
}

return require('lsplocal.nvim').maybe_load_local('rust_analyzer', default)

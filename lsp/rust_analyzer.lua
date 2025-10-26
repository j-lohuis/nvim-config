local default = {
  cmd = { 'rust-analyzer' },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        allTargets = true,
        command = "clippy",
      },
      cargo = {
        features = "all",
      },
    }
  },
}

return require('lsplocal.nvim').maybe_load_local('rust_analyzer', default)

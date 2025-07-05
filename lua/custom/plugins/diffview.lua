return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local actions = require('diffview.actions')
    
    require('diffview').setup({
      diff_binaries = false,
      enhanced_diff_hl = true,
      git_cmd = { 'git' },
      hg_cmd = { 'hg' },
      use_icons = true,
      show_help_hints = true,
      watch_index = true,
      
      icons = {
        folder_closed = '',
        folder_open = '',
      },
      
      signs = {
        fold_closed = '',
        fold_open = '',
        done = '✓',
      },
      
      view = {
        default = {
          layout = 'diff2_horizontal',
          disable_diagnostics = true,
        },
        merge_tool = {
          layout = 'diff3_horizontal',
          disable_diagnostics = true,
        },
        file_history = {
          layout = 'diff2_horizontal',
          disable_diagnostics = true,
        },
      },
      
      file_panel = {
        listing_style = 'tree',
        tree_options = {
          flatten_dirs = true,
          folder_statuses = 'only_folded',
        },
        win_config = {
          position = 'left',
          width = 35,
          win_opts = {}
        },
      },
      
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = 'combined',
            },
            multi_file = {
              diff_merges = 'first-parent',
            },
          },
        },
        win_config = {
          position = 'bottom',
          height = 16,
          win_opts = {}
        },
      },
      
      commit_log_panel = {
        win_config = {
          position = 'bottom',
          height = 16,
          win_opts = {}
        }
      },
      
      default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },
      
      hooks = {
        diff_buf_read = function(bufnr)
          vim.opt_local.wrap = false
          vim.opt_local.list = false
          vim.opt_local.colorcolumn = '80'
        end,
        diff_buf_win_enter = function(bufnr, winid, ctx)
          if ctx.layout_name:match('^diff2') then
            if ctx.symbol == 'a' then
              vim.opt_local.winhl = table.concat({
                'DiffText:DiffviewDiffTextLeft',
                'DiffAdd:DiffviewDiffAddLeft',
                'DiffChange:DiffviewDiffChangeLeft',
                'DiffDelete:DiffviewDiffDeleteLeft',
              }, ',')
            elseif ctx.symbol == 'b' then
              vim.opt_local.winhl = table.concat({
                'DiffText:DiffviewDiffTextRight',
                'DiffAdd:DiffviewDiffAddRight',
                'DiffChange:DiffviewDiffChangeRight',
                'DiffDelete:DiffviewDiffDeleteRight',
              }, ',')
            end
          end
        end,
      },
      
      keymaps = {
        disable_defaults = false,
        view = {
          -- Vim-style merge conflict resolution keybindings
          ['<S-Left>']     = actions.conflict_choose('ours'),   -- Accept left (OURS)
          ['<S-Right>']    = actions.conflict_choose('theirs'), -- Accept right (THEIRS)
          ['<M-Left>']     = actions.conflict_choose('ours'),   -- Alternative: Alt+Left
          ['<M-Right>']    = actions.conflict_choose('theirs'), -- Alternative: Alt+Right
          ['<leader>co']   = actions.conflict_choose('ours'),   -- Accept ours
          ['<leader>ct']   = actions.conflict_choose('theirs'), -- Accept theirs
          ['<leader>cb']   = actions.conflict_choose('base'),   -- Accept base
          ['<leader>ca']   = actions.conflict_choose('all'),    -- Accept all
          ['<leader>cn']   = actions.conflict_choose('none'),   -- Accept none
          
          -- Navigation
          [']c']           = actions.next_conflict,             -- Next conflict
          ['[c']           = actions.prev_conflict,             -- Previous conflict
          
          -- Standard diff operations
          ['do']           = actions.diffget('ours'),
          ['dp']           = actions.diffput('ours'),
          ['dO']           = actions.diffget('theirs'),
          ['dP']           = actions.diffput('theirs'),
          
          -- View controls
          ['<tab>']        = actions.select_next_entry,
          ['<s-tab>']      = actions.select_prev_entry,
          ['gf']           = actions.goto_file,
          ['<C-w><C-f>']   = actions.goto_file_split,
          ['<C-w>gf']      = actions.goto_file_tab,
          ['<leader>e']    = actions.focus_files,
          ['<leader>b']    = actions.toggle_files,
          ['g<C-x>']       = actions.cycle_layout,
          ['[x]']          = actions.prev_conflict,
          [']x']           = actions.next_conflict,
        },
        
        diff1 = {
          ['g?'] = actions.help('view'),
        },
        
        diff2 = {
          ['g?'] = actions.help('view'),
        },
        
        diff3 = {
          ['g?'] = actions.help('view'),
        },
        
        diff4 = {
          ['g?'] = actions.help('view'),
        },
        
        file_panel = {
          ['j']             = actions.next_entry,
          ['<down>']        = actions.next_entry,
          ['k']             = actions.prev_entry,
          ['<up>']          = actions.prev_entry,
          ['<cr>']          = actions.select_entry,
          ['o']             = actions.select_entry,
          ['<2-LeftMouse>'] = actions.select_entry,
          ['-']             = actions.toggle_stage_entry,
          ['S']             = actions.stage_all,
          ['U']             = actions.unstage_all,
          ['X']             = actions.restore_entry,
          ['L']             = actions.open_commit_log,
          ['<tab>']         = actions.select_next_entry,
          ['<s-tab>']       = actions.select_prev_entry,
          ['gf']            = actions.goto_file,
          ['<C-w><C-f>']    = actions.goto_file_split,
          ['<C-w>gf']       = actions.goto_file_tab,
          ['R']             = actions.refresh_files,
          ['<leader>e']     = actions.focus_files,
          ['<leader>b']     = actions.toggle_files,
          ['g<C-x>']        = actions.cycle_layout,
          ['g?']            = actions.help('file_panel'),
        },
        
        file_history_panel = {
          ['g!']            = actions.options,
          ['<C-A-d>']       = actions.open_in_diffview,
          ['g?']            = actions.help('file_history_panel'),
        },
        
        option_panel = {
          ['<tab>']         = actions.select_entry,
          ['q']             = actions.close,
        },
        
        help_panel = {
          ['q']             = actions.close,
        },
      },
    })
    
    -- Global keymaps for diffview
    vim.keymap.set('n', '<leader>do', '<cmd>DiffviewOpen<cr>', { desc = 'Open diffview' })
    vim.keymap.set('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = 'Close diffview' })
    vim.keymap.set('n', '<leader>dr', '<cmd>DiffviewRefresh<cr>', { desc = 'Refresh diffview' })
    vim.keymap.set('n', '<leader>dh', '<cmd>DiffviewFileHistory<cr>', { desc = 'File history' })
    vim.keymap.set('n', '<leader>dm', '<cmd>DiffviewOpen HEAD~1<cr>', { desc = 'Diff with previous commit' })
    
    -- Merge resolution specific commands
    vim.keymap.set('n', '<leader>mr', '<cmd>DiffviewOpen<cr>', { desc = 'Open merge resolution' })
    vim.keymap.set('n', '<leader>mc', '<cmd>DiffviewClose<cr>', { desc = 'Close merge resolution' })
  end,
}
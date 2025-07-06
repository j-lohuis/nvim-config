return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function() return vim.fn.executable 'make' == 1 end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
  },
  config = function()
    require('telescope').setup {
      defaults = {
        -- Window layout: bottom 3/8 of screen
        layout_strategy = 'bottom_pane',
        layout_config = {
          bottom_pane = {
            height = 0.375, -- 3/8 of screen height
            preview_cutoff = 120,
          },
        },

        -- Remove rounded borders
        borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },

        -- Safe preview settings
        preview = {
          filesize_limit = 0.5, -- 0.5 MB limit
          timeout = 250,
          treesitter = false, -- Disable treesitter in preview for performance
        },

        -- Use safe file previewer
        file_previewer = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,

        -- Performance optimizations and safety
        file_ignore_patterns = {
          "%.git/",
          "node_modules/",
          "%.cache/",
          "%.tmp/",
          "%.DS_Store$",
          -- Binary files
          "%.o$", "%.a$", "%.out$", "%.class$", "%.pyc$",
          "%.so$", "%.dll$", "%.exe$", "%.bin$",
          -- Archives
          "%.pdf$", "%.zip$", "%.tar$", "%.tar%.gz$", "%.rar$", "%.7z$",
          "%.gz$", "%.bz2$", "%.xz$",
          -- Media files
          "%.mkv$", "%.mp4$", "%.avi$", "%.mov$", "%.wmv$",
          "%.mp3$", "%.wav$", "%.flac$", "%.ogg$",
          "%.jpg$", "%.jpeg$", "%.png$", "%.gif$", "%.bmp$",
          "%.svg$", "%.ico$", "%.tiff$", "%.psd$", "%.webp$",
          -- Large data files
          "%.db$", "%.sqlite$", "%.sqlite3$",
          "%.log$", "%.logs$"
        },


        -- Reduce entry display for performance
        results_title = false,
        sorting_strategy = 'ascending',
        scroll_strategy = 'limit',
      },

      pickers = {
        find_files = {
          hidden = true,
          follow = true,
        },
        live_grep = {
          disable_coordinates = true,
        },
        buffers = {
          previewer = false, -- Disable preview for buffers
          mappings = {
            i = {
              ['<c-d>'] = require('telescope.actions').delete_buffer,
            },
          },
        },
      },

      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}

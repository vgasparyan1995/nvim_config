-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
        on_highlights = function(hl, c)
          local line_nr_color = "#767d9c"
          hl.LineNr = {
            fg = line_nr_color
          }
          hl.LineNrAbove = {
            fg = line_nr_color
          }
          hl.LineNrBelow = {
            fg = line_nr_color
          }
        end
      },
    },

    {
      "nvim-neo-tree/neo-tree.nvim",
      lazy = false,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      keys = {
        { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
      },
      config = function()
        require("neo-tree").setup({
          close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
          popup_border_style = "rounded",
          enable_git_status = true,
          enable_diagnostics = true,
          open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
          sort_case_insensitive = false, -- used when sorting files and directories in the tree
          sort_function = nil , -- use a custom function for sorting files and directories in the tree 
          -- sort_function = function (a,b)
            --       if a.type == b.type then
            --           return a.path > b.path
            --       else
            --           return a.type > b.type
            --       end
            --   end , -- this sorts files and directories descendantly
            default_component_configs = {
              container = {
                enable_character_fade = true
              },
              indent = {
                indent_size = 2,
                padding = 1, -- extra padding on left hand side
                -- indent guides
                with_markers = true,
                indent_marker = "│",
                last_indent_marker = "└",
                highlight = "NeoTreeIndentMarker",
                -- expander config, needed for nesting files
                with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
                expander_collapsed = "",
                expander_expanded = "",
                expander_highlight = "NeoTreeExpander",
              },
              icon = {
                folder_closed = "",
                folder_open = "",
                folder_empty = "󰜌",
                provider = function(icon, node, state) -- default icon provider utilizes nvim-web-devicons if available
                  if node.type == "file" or node.type == "terminal" then
                    local success, web_devicons = pcall(require, "nvim-web-devicons")
                    local name = node.type == "terminal" and "terminal" or node.name
                    if success then
                      local devicon, hl = web_devicons.get_icon(name)
                      icon.text = devicon or icon.text
                      icon.highlight = hl or icon.highlight
                    end
                  end
                end,
                -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
                -- then these will never be used.
                default = "*",
                highlight = "NeoTreeFileIcon"
              },
              modified = {
                symbol = "[+]",
                highlight = "NeoTreeModified",
              },
              name = {
                trailing_slash = false,
                use_git_status_colors = true,
                highlight = "NeoTreeFileName",
              },
              git_status = {
                symbols = {
                  -- Change type
                  added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
                  modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
                  deleted   = "✖",-- this can only be used in the git_status source
                  renamed   = "󰁕",-- this can only be used in the git_status source
                  -- Status type
                  untracked = "",
                  ignored   = "",
                  unstaged  = "󰄱",
                  staged    = "",
                  conflict  = "",
                }
              },
              -- If you don't want to use these columns, you can set `enabled = false` for each of them individually
              file_size = {
                enabled = true,
                required_width = 64, -- min width of window required to show this column
              },
              type = {
                enabled = true,
                required_width = 122, -- min width of window required to show this column
              },
              last_modified = {
                enabled = true,
                required_width = 88, -- min width of window required to show this column
              },
              created = {
                enabled = true,
                required_width = 110, -- min width of window required to show this column
              },
              symlink_target = {
                enabled = false,
              },
            },
            -- A list of functions, each representing a global custom command
            -- that will be available in all sources (if not overridden in `opts[source_name].commands`)
            -- see `:h neo-tree-custom-commands-global`
            commands = {},
            window = {
              position = "left",
              width = 40,
              mapping_options = {
                noremap = true,
                nowait = true,
              },
              mappings = {
                ["<space>"] = { 
                  "toggle_node", 
                  nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use 
                },
                ["<2-LeftMouse>"] = "open",
                ["<cr>"] = "open",
                ["<esc>"] = "cancel", -- close preview or floating neo-tree window
                ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
                -- Read `# Preview Mode` for more information
                ["l"] = "focus_preview",
                ["S"] = "open_split",
                ["s"] = "open_vsplit",
                -- ["S"] = "split_with_window_picker",
                -- ["s"] = "vsplit_with_window_picker",
                ["t"] = "open_tabnew",
                -- ["<cr>"] = "open_drop",
                -- ["t"] = "open_tab_drop",
                ["w"] = "open_with_window_picker",
                --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
                ["C"] = "close_node",
                -- ['C'] = 'close_all_subnodes',
                ["z"] = "close_all_nodes",
                --["Z"] = "expand_all_nodes",
                ["a"] = { 
                  "add",
                  -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
                  -- some commands may take optional config options, see `:h neo-tree-mappings` for details
                  config = {
                    show_path = "none" -- "none", "relative", "absolute"
                  }
                },
                ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
                ["d"] = "delete",
                ["r"] = "rename",
                ["y"] = "copy_to_clipboard",
                ["x"] = "cut_to_clipboard",
                ["p"] = "paste_from_clipboard",
                ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
                -- ["c"] = {
                  --  "copy",
                  --  config = {
                    --    show_path = "none" -- "none", "relative", "absolute"
                    --  }
                    --}
                    ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
                    ["q"] = "close_window",
                    ["R"] = "refresh",
                    ["?"] = "show_help",
                    ["<"] = "prev_source",
                    [">"] = "next_source",
                    ["i"] = "show_file_details",
                  }
                },
                nesting_rules = {},
                filesystem = {
                  filtered_items = {
                    visible = false, -- when true, they will just be displayed differently than normal items
                    hide_dotfiles = true,
                    hide_gitignored = true,
                    hide_hidden = true, -- only works on Windows for hidden files/directories
                    hide_by_name = {
                      --"node_modules"
                    },
                    hide_by_pattern = { -- uses glob style patterns
                      --"*.meta",
                      --"*/src/*/tsconfig.json",
                    },
                    always_show = { -- remains visible even if other settings would normally hide it
                      --".gitignored",
                    },
                    always_show_by_pattern = { -- uses glob style patterns
                      --".env*",
                    },
                    never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
                      --".DS_Store",
                      --"thumbs.db"
                    },
                    never_show_by_pattern = { -- uses glob style patterns
                      --".null-ls_*",
                    },
                  },
                  follow_current_file = {
                    enabled = false, -- This will find and focus the file in the active buffer every time
                    --               -- the current file is changed while the tree is open.
                    leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
                  },
                  group_empty_dirs = false, -- when true, empty folders will be grouped together
                  hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                  -- in whatever position is specified in window.position
                  -- "open_current",  -- netrw disabled, opening a directory opens within the
                  -- window like netrw would, regardless of window.position
                  -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
                  use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
                  -- instead of relying on nvim autocmd events.
                  window = {
                    mappings = {
                      ["<bs>"] = "navigate_up",
                      ["."] = "set_root",
                      ["H"] = "toggle_hidden",
                      ["/"] = "noop",
                      ["D"] = "noop",
                      ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
                      ["D"] = "noop",
                      ["f"] = "filter_on_submit",
                      ["<c-x>"] = "clear_filter",
                      ["[g"] = "prev_git_modified",
                      ["]g"] = "next_git_modified",
                      ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                      ["oc"] = { "order_by_created", nowait = false },
                      ["od"] = { "order_by_diagnostics", nowait = false },
                      ["og"] = { "order_by_git_status", nowait = false },
                      ["om"] = { "order_by_modified", nowait = false },
                      ["on"] = { "order_by_name", nowait = false },
                      ["os"] = { "order_by_size", nowait = false },
                      ["ot"] = { "order_by_type", nowait = false },
                      -- ['<key>'] = function(state) ... end,
                    },
                    fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
                      ["<down>"] = "move_cursor_down",
                      ["<C-n>"] = "move_cursor_down",
                      ["<up>"] = "move_cursor_up",
                      ["<C-p>"] = "move_cursor_up",
                      -- ['<key>'] = function(state, scroll_padding) ... end,
                    },
                  },

                  commands = {} -- Add a custom command or override a global one using the same function name
                },
                buffers = {
                  follow_current_file = {
                    enabled = true, -- This will find and focus the file in the active buffer every time
                    --              -- the current file is changed while the tree is open.
                    leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
                  },
                  group_empty_dirs = true, -- when true, empty folders will be grouped together
                  show_unloaded = true,
                  window = {
                    mappings = {
                      ["bd"] = "buffer_delete",
                      ["<bs>"] = "navigate_up",
                      ["."] = "set_root",
                      ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                      ["oc"] = { "order_by_created", nowait = false },
                      ["od"] = { "order_by_diagnostics", nowait = false },
                      ["om"] = { "order_by_modified", nowait = false },
                      ["on"] = { "order_by_name", nowait = false },
                      ["os"] = { "order_by_size", nowait = false },
                      ["ot"] = { "order_by_type", nowait = false },
                    }
                  },
                },
                git_status = {
                  window = {
                    position = "float",
                    mappings = {
                      ["A"]  = "git_add_all",
                      ["gu"] = "git_unstage_file",
                      ["ga"] = "git_add_file",
                      ["gr"] = "git_revert_file",
                      ["gc"] = "git_commit",
                      ["gp"] = "git_push",
                      ["gg"] = "git_commit_and_push",
                      ["o"] = { "show_help", nowait=false, config = { title = "Order by", prefix_key = "o" }},
                      ["oc"] = { "order_by_created", nowait = false },
                      ["od"] = { "order_by_diagnostics", nowait = false },
                      ["om"] = { "order_by_modified", nowait = false },
                      ["on"] = { "order_by_name", nowait = false },
                      ["os"] = { "order_by_size", nowait = false },
                      ["ot"] = { "order_by_type", nowait = false },
                    }
                  }
                }
              })
      end,
    },

    -- LSP stuff
    {'VonHeikemen/lsp-zero.nvim', branch = 'v4.x'},
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/nvim-cmp'},
    {
      'neovim/nvim-lspconfig',
      lazy = false,
      dependencies = {
        -- main one
        { "ms-jpq/coq_nvim", branch = "coq" },

        -- 9000+ Snippets
        { "ms-jpq/coq.artifacts", branch = "artifacts" },

        -- lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
        -- Need to **configure separately**
        { 'ms-jpq/coq.thirdparty', branch = "3p" }
        -- - shell repl
        -- - nvim lua api
        -- - scientific calculator
        -- - comment banner
        -- - etc
      },
      init = function()
        vim.g.coq_settings = {
          auto_start = "shut-up", -- if you want to start COQ at startup
          -- Your COQ settings here
        }
      end,
      config = function()
        -- Your LSP settings here
      end,
    },

  },

  -- automatically check for plugin updates
  checker = { enabled = true },
})

vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.guicursor = {
  "i-n-v-c-sm:block-Cursor/lCursor",
}

vim.api.nvim_set_keymap('n', 'j', "gj", { noremap = true })
vim.api.nvim_set_keymap('n', 'k', "gk", { noremap = true })
vim.api.nvim_set_keymap('v', '<S-j>', ":m '>+1<cr>gv=gv", { noremap = true })
vim.api.nvim_set_keymap('v', '<S-k>', ":m '<-2<cr>gv=gv", { noremap = true })
vim.api.nvim_set_keymap('t', '<Esc>', "<C-\\><C-n>", { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>tt', ":botright split | term<cr>i", { noremap = true })

vim.cmd[[colorscheme tokyonight-night]]

-----------------------
----- LSP stuff -------
-----------------------
local lsp_zero = require('lsp-zero')

-- lsp_attach is where you enable features that only work
-- if there is a language server active in the file
local lsp_attach = function(client, bufnr)
  local opts = {buffer = bufnr}

  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
  vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
  vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  vim.keymap.set('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float(0, {scope="line"})<cr>', opts)
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({})
    end,
  },
})
-----------------------
-----------------------
-----------------------

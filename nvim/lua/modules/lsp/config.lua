local config = {}

function config.nvim_lspconfig()
  local lspconfig = require("lspconfig")
  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

  local signs = {
    Error = " ",
    Warn = " ",
    Info = " ",
    Hint = " ",
  }

  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.diagnostic.config({
    virtual_text = false,
    float = false,
    update_in_insert = false,
    underline = true,
    signs = true,
  })

  vim.o.updatetime = 250
  local on_attach = function(client, bufnr)
    vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'
    client.server_capabilities.semanticTokensProvider = nil
    local orignal = vim.notify
    local mynotify = function(msg, level, opts)
      if msg == "No code actions available" or msg:find("overly") then
        return
      end
      orignal(msg, level, opts)
    end
    vim.notify = mynotify

    local ok, err = pcall(vim.lsp.inlay_hint, bufnr, true)
    if not ok then
      vim.notify("lsp err: " .. err)
    end

    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      callback = function()
        local opts = {
          focusable = false,
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          border = "rounded",
          source = "always",
          prefix = " ",
          scope = "cursor",
        }
        vim.diagnostic.open_float(nil, opts)
      end
    })
  end

  local servers = {
    clangd = require("modules.lsp.lsp_server_config.clangd"),
    lua_ls = require("modules.lsp.lsp_server_config.lua_ls"),
    gopls = require("modules.lsp.lsp_server_config.gopls"),
    rust_analyzer = require("modules.lsp.lsp_server_config.rust_analyzer"),
    pyright = require("modules.lsp.lsp_server_config.comm"),
  }
  for server, serv_options in pairs(servers) do
    serv_options.on_attach = on_attach
    serv_options.flags = {
      debounce_text_changes = 150
    }
    -- serv_options.capabilities = capabilities
    lspconfig[server].setup(serv_options)
  end

  vim.lsp.handlers["workspace/diagnostic/refresh"] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.diagnostic.reset(ns, bufnr)
    return true
  end
end

function config.lspsaga()
  local saga = require("lspsaga")

  saga.setup({
    ui = {
      theme = "round",
      title = true,
      border = "rounded",
    },
    symbol_in_winbar = {
      enable = true,
    },
    outline = {
      win_position = "right",
      keys = {
        jump = "<CR>",
        quit = "q",
        toggle_or_jump = "o"
      },
    },
    rename = {
      in_select = true,
      auto_save = false,
      keys = {
        quit = "<C-c>",
        exec = "<CR>",
        mark = "x",
        confirm = "<CR>",
        in_select = true,
        whole_project = true,
      }
    },
    diagnostic = {
      keys = {
        exec_action = "<CR>",
        quit = "q",
        go_action = "g"
      },
    },
    code_action = {
      keys = {
        quit = "q",
        exec = "<CR>",
      },
    },
    finder = {
      keys = {
        quit = { "q", "<ESC>" },
        toggle_or_open = { "<CR>" },
        vsplit = "s",
        split = "i",
        tabe = "t",
      }
    },
    definition = {
      keys = {
        quit = "q",
        edit = "<CR>",
        vsplit = "<C-c>v",
        split = "<C-c>i",
        tabe = "<C-c>t",
      }
    },
  })

  local keymap = vim.keymap.set
  keymap("n", "gf", "<cmd>Lspsaga finder def+ref+imp<CR>")
  keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true })
  keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { silent = true })
  keymap("n", "go", "<cmd>Lspsaga code_action<CR>", { silent = true })
  keymap("v", "<leader>go", "<cmd><C-U>Lspsaga range_code_action<CR>", { silent = true })

  keymap("n", "gr", "<cmd>Lspsaga rename<CR>", { silent = true })
  keymap("v", "gr", "<cmd>Lspsaga rename<CR>", { silent = true })

  keymap("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", { silent = true })

  keymap("n", "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", { silent = true })

  keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { silent = true })
  keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", { silent = true })

  -- Outline
  --keymap("n","<F2>", "<cmd>LSoutlineToggle<CR>",{ silent = true })

  -- terminal
  keymap({"n", "t"}, "<A-d>", "<cmd>Lspsaga term_toggle<CR>", { silent = true })
end

function config.nvim_cmp()
  local cmp = require("cmp")
  local luasnip = require("luasnip")

  local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  local kind_icons = {
    Text = "",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰇽",
    Variable = "󰂡",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "󰅲",
  }

  cmp.setup({
    preselect = cmp.PreselectMode.Item,
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    -- formatting = {
    --   fields = { 'abbr', 'kind', 'menu' },
    -- },
    formatting = {
      format = function(entry, vim_item)
        vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
        vim_item.menu = ({
          buffer = "[Buffer]",
          nvim_lsp = "[LSP]",
          luasnip = "[LuaSnip]",
          nvim_lua = "[Lua]",
          latex_symbols = "[LaTeX]",
        })[entry.source.name]
        return vim_item
      end
    },
    sorting =  {
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      }
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-e>"] = cmp.config.disable,
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      -- ["<s-Tab>"] = cmp.mapping.select_prev_item(),
      -- ["<Tab>"] = cmp.mapping.select_next_item(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<C-c>"] = cmp.mapping({
           i = function()
             if cmp.visible() then
              cmp.abort()
             else
               cmp.complete()
             end
           end,
           c = function()
             if cmp.visible() then
               cmp.close()
             else
               cmp.complete()
             end
           end
      }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable() 
        -- they way you will only jump inside the snippet region
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),

    }),
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
    },
  })
end

function config.lua_snip()
  local ls = require("luasnip")
  ls.config.set_config({
    history = false,
    updateevents = 'TextChanged,TextChangedI',
  })
  require("luasnip.loaders.from_vscode").lazy_load({
    paths = { "./snippets" },
  })

  require("modules.lsp.snippets")
end

return config

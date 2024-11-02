local env = require("core.env")
local config = {}
local api = vim.api

function config.nvim_lspconfig()
  local lspconfig = require("lspconfig")
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

  vim.lsp.set_log_level(vim.lsp.log_levels.OFF)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_clients({ id = args.data.client_id })[1]
      client.server_capabilities.semanticTokensProvider = nil

      -- TODO hint
      -- if vim.lsp.inlay_hint then
      --   if client.server_capabilities.inlayHintProvider then
      --     vim.lsp.inlay_hint.enable(true)
      --   end
      -- end
    end,
  })

  local signs = {}
  if env.enable_icons then
    signs = {
      Error = "✘",
      Warn = "",
      Info = "◉",
      Hint = "",
    }
  else
    signs = {
      Error = "E ",
      Warn = "W ",
      Info = "I ",
      Hint = "H ",
    }
  end

  vim.diagnostic.config({
    virtual_text = false,
    float = false,
    update_in_insert = false,
    underline = true,
    signs = {
      text = {
        [vim.diagnostic.severity.HINT]  = signs["Hint"],
        [vim.diagnostic.severity.ERROR] = signs["Error"],
        [vim.diagnostic.severity.INFO]  = signs["Info"],
        [vim.diagnostic.severity.WARN]  = signs["Warn"],
      }
    },
  })

  vim.o.updatetime = 250
  local servers = {
    clangd = require("modules.lsp.lsp_server_config.clangd"),
    lua_ls = require("modules.lsp.lsp_server_config.lua_ls"),
    gopls = require("modules.lsp.lsp_server_config.gopls"),
    rust_analyzer = require("modules.lsp.lsp_server_config.rust_analyzer"),
    pyright = require("modules.lsp.lsp_server_config.comm"),
    cmake = require("modules.lsp.lsp_server_config.comm"),
  }

  for server, serv_options in pairs(servers) do
    serv_options.on_attach = on_attach
    serv_options.flags = {
      debounce_text_changes = 150
    }
    serv_options.capabilities = capabilities
    lspconfig[server].setup(serv_options)
  end

  vim.lsp.handlers["workspace/diagnostic/refresh"] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    local bufnr = api.nvim_get_current_buf()
    vim.diagnostic.reset(ns, bufnr)
    return true
  end
end

function config.lspsaga()
  local saga = require("lspsaga")

  saga.setup({
    ui = {
      use_nerd = env.enable_icons,
      theme = "round",
      title = true,
      border = "rounded",
      devicon = env.enable_icons,
    },
    symbol_in_winbar = {
      enable = true,
    },
    lightbulb = {
      enable = false,
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
end


function config.nvim_cmp()
  local cmp = require("cmp")
  local luasnip = require("luasnip")

  local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(api.nvim_win_get_cursor(0))
    return col ~= 0 and api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
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
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "buffer" },
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

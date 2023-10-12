local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

return {
  settings = {
    Lua = {
      diagnostics = {
        enable = true,
        envs = { 'vim' },
        disable = {
          'missing-fields',
          'no-unknown',
        },
      },
      runtime = {
        version = "LuaJIT",
        path = runtime_path
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
        },
        checkThirdParty = false,
      },
      completion = {
        callSnippet = 'Replace',
      },
    },
  },
}

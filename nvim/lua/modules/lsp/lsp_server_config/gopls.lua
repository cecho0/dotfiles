return {
  cmd = { "gopls", "serve" },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
  },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      -- semanticTokens = true,
      staticcheck = true,
    },
  },
}

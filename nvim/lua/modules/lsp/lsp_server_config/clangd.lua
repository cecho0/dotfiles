return {
  cmd = { "clangd", "--background-index" },
  init_options = {
    fallbackFlags = { '-std=c++20' }
  },
  -- root_dir = function(fname)
  --   return lspconfig.util.root_pattern(unpack({
  --     --reorder
  --     'compile_commands.json',
  --     '.clangd',
  --     '.clang-tidy',
  --     '.clang-format',
  --     'compile_flags.txt',
  --     'configure.ac', -- AutoTools
  --   }))(fname) or lspconfig.util.find_git_ancestor(fname)
  -- end,
}

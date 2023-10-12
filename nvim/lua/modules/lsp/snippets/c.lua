local snippets = require("modules.lsp.snippets.tools")

local function c_func(args, _, old_state)
  local nodes = {
    snippets.t({ "/**", " * " }),
    snippets.t({ "Function Name", " * " }),
    snippets.t({ "\t" }),
    snippets.i(1, "A Short Description"),
    snippets.t({ "", "" }),
  }

  local param_nodes = {}

  if args[2][1] then
    nodes[2] = snippets.t({ args[2][1] , " * " })
  end

  local idx = 4
  if old_state then
    nodes[idx] = snippets.i(1, old_state.descr:get_text())
  end
  param_nodes.descr = nodes[idx]

  if string.find(args[3][1], ", ") then
    vim.list_extend(nodes, { snippets.t({ " * ", "" }) })
  end

  local insert = 2
  for indx, arg in ipairs(vim.split(args[3][1], ", ", true)) do
    arg = vim.split(arg, " ", true)[2]
    if arg then
      local inode
      if old_state and old_state[arg] then
        inode = snippets.i(insert, old_state["arg" .. arg]:get_text())
      else
        inode = snippets.i(insert)
      end
      vim.list_extend(
        nodes,
        { snippets.t({ " * @param " .. arg .. ": " }), inode, snippets.t({ "", "" }) }
      )
      param_nodes["arg" .. arg] = inode

      insert = insert + 1
    end
  end

  if args[1][1] ~= "void" then
    local inode
    if old_state and old_state.ret then
      inode = snippets.i(insert, old_state.ret:get_text())
    else
      inode = snippets.i(insert)
    end

    vim.list_extend(
      nodes,
      { snippets.t({ " * ", " * @return " }), inode, snippets.t({ "", "" }) }
    )
    param_nodes.ret = inode
    insert = insert + 1
  end

  vim.list_extend(nodes, { snippets.t({ " */" }) })

  local snip = snippets.sn(nil, nodes)
  snip.old_state = param_nodes
  return snip
end

snippets.ls.add_snippets("c", {
  snippets.s("fn", {
    snippets.d(4, c_func, { 1, 2, 3 }),
    snippets.t({ "", "" }),
    snippets.c(1, {
      snippets.t("void"),
      snippets.t("char"),
      snippets.t("int"),
      snippets.t("double"),
      snippets.i(nil, ""),
    }),
    snippets.t(" "),
    snippets.i(2, "my_func"),
    snippets.t("("),
    snippets.i(3),
    snippets.t(")"),
    snippets.t({ " {", "\t" }),
    snippets.i(0),
    snippets.t({ "", "}" }),
  }),
}, {
  key = "c",
})

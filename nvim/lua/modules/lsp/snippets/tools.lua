local M = {}

M.ls = require("luasnip")
M.s = M.ls.snippet
M.sn = M.ls.snippet_node
M.t = M.ls.text_node
M.i = M.ls.insert_node
M.f = M.ls.function_node
M.c = M.ls.choice_node
M.d = M.ls.dynamic_node
M.r = M.ls.restore_node
M.l = require("luasnip.extras").lambda
M.rep = require("luasnip.extras").rep
M.p = require("luasnip.extras").partial
M.m = require("luasnip.extras").match
M.n = require("luasnip.extras").nonempty
M.dl = require("luasnip.extras").dynamic_lambda
M.fmt = require("luasnip.extras.fmt").fmt
M.fmta = require("luasnip.extras.fmt").fmta
M.types = require("luasnip.util.types")
M.conds = require("luasnip.extras.conditions")
M.conds_expand = require("luasnip.extras.conditions.expand")

return M

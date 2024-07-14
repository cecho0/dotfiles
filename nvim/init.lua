-- load core module
require("core")

-- vim.api.nvim_create_autocmd("LspProgress", {
--   pattern = pattern,
--   callback = function(args)
--         if args.data and args.data.params then
--         local val = args.data.params.value
--         if val.message and val.kind ~= 'end' then
--             vim.print(val.message)
--           -- idx = idx + 1 > #spinner and 1 or idx + 1
--           -- return ('%s'):format(spinner[idx - 1 > 0 and idx - 1 or 1])
--         end
--       end
--   end,
-- })


local M = {}

M.fetch_todos = function ()
  vim.api.nvim_command(':lua require("telescope.builtin").grep_string({search="TODO"})')
end

return M


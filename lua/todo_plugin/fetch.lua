
local sqlite = require("ljsqlite3")
local utils = require("utils")

local M = {}


function M.fetch_todos()
  local root_dir = utils.get_root_dir()
  if root_dir == nil then
    print("Root directory not found.")
    return
  end
  local db = sqlite.open(root_dir .. "todo.db")
  local db_results = db:exec("SELECT * FROM todo_list WHERE completed == 'no';")
  for _, item in ipairs(db_results[2]) do
    print(item)
  end
  db:close()
end

return M


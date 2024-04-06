
local sqlite = require("ljsqlite3")
local utils = require("utils")

local M = {}

function M.create_todo()
  local root_dir = utils.get_root_dir()
  if root_dir == nil then
    print("Root directory not found.")
    return
  end
  local todo_desc = ""
  repeat
    todo_desc = vim.fn.input("Enter a description: ")
    print("")
  until (todo_desc ~= "") and (string.len(todo_desc) <= 150)
  local db = sqlite.open(root_dir .. "todo.db")
  db:exec("INSERT INTO todo_list (description) VALUES ('" .. todo_desc .. "');")
  db:close()
end

function M.complete_todo()
  local root_dir = utils.get_root_dir()
  if root_dir == nil then
    print("Root directory not found.")
    return
  end
  local db = sqlite.open(root_dir .. "todo.db")
  local todo_completed = -1
  local todo_selected = -1
  repeat
    local results = db:exec("SELECT * FROM todo_list WHERE completed == 'no';")
    for i, item in ipairs(results[2]) do
      print(tostring(results[1][i]) .. ': ' .. item)
    end
    todo_selected = tonumber(vim.fn.input("Enter the ID of the TODO: "))
    for _, id in ipairs(results[1]) do
      if (id == todo_selected) then
        todo_completed = todo_selected
      end
    end
    print("")
  until todo_completed >= 0
  db:exec("UPDATE todo_list SET completed = 'yes' WHERE id = " .. todo_completed .. " AND completed = 'no';")
  db:close()
end

return M


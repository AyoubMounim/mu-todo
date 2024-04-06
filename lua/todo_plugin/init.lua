
local fetch = require("todo_plugin.fetch")
local update = require("todo_plugin.update")

local M = {}

M.fetch_todos = fetch.fetch_todos
M.create_todo = update.create_todo
M.complete_todo = update.complete_todo

return M


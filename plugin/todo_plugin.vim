
if exists("g:loaded_todo_plugin")
  finish
endif
let g:loaded_todo_plugin = 1

let s:lua_rocks_deps_loc = expand("<sfile>:h:r") . "/../lua/todo_plugin/deps"
exe "lua package.path = package.path .. ';" . s:lua_rocks_deps_loc . "/lua-?/init.lua'"

command! -nargs=0 FetchTodos lua require("todo_plugin").fetch_todos()
command! -nargs=0 CreateTodo lua require("todo_plugin").create_todo()
command! -nargs=0 CompleteTodos lua require("todo_plugin").complete_todo()


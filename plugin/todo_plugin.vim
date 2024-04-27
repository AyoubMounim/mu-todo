
if exists("g:loaded_todo_plugin")
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 FetchTODOs lua require("todo_plugin").todos()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_todo_plugin = 1



local main_win, main_buf

local TODOS = nil

local function get_window_center(win)
  local height = vim.api.nvim_win_get_height(win)
  local width = vim.api.nvim_win_get_width(win)
  return width/2, height/2
end

local function get_centered_pos(child_win_width, child_win_height, parent_win)
  local x_center, y_center = get_window_center(parent_win)
  local x = x_center - child_win_width/2
  local y = y_center - child_win_height/2
  return x, y
end

local function on_enter()
  if not TODOS then
    print("No todos found\n")
    return
  end
  local index = vim.api.nvim_win_get_cursor(0)[1]
  local todo = TODOS[index]
  if not todo then
    print("Index out of bounds\n")
    return
  end
  vim.api.nvim_win_close(0, true)
  vim.api.nvim_command(":vne "..todo.file)
end

local function set_mappings()
  vim.api.nvim_buf_set_keymap(0, 'n', '<cr>', ':lua require("todo_plugin").on_enter()<cr>', {})
end


---@return string
local function get_root_dir()
  local root = vim.fn.system("git rev-parse --show-toplevel")
  if vim.v.shell_error ~= 0 then
    root = vim.fn.system("pwd")
  end
  root, _ = string.gsub(root, "\n", "")
  return root
end


---@param todo string
---@return table?
local function parse_todo(todo)
  local attributes = {"file", 'row', 'col', 'body'}
  local parsed_todo = {}
  local i = 1
  for w in todo:gmatch("([^:]+)") do
    if i < 5 then
      parsed_todo[attributes[i]] = w
      i = i + 1
    else
      parsed_todo[attributes[i-1]] = parsed_todo[attributes[i-1]]..':'..w
    end
  end
  if i < 5 then
    parsed_todo = nil
  end
  return parsed_todo
end


---@return table?
local function fetch_todos()
  local root_dir = get_root_dir()
  -- TODO: implement.
  local res = vim.fn.system("rg --vimgrep 'TODO: ' "..root_dir)
  if res == "" then
    return nil
  end
  local todos = {}
  local parsed_todos = 0
  for w in res:gmatch("([^\n]+)") do
    ::continue::
    local parsed_todo = parse_todo(w)
    if not parsed_todo then goto continue end
    table.insert(todos, parsed_todo)
    parsed_todos = parsed_todos + 1
  end
  if parsed_todos == 0 then
    todos = nil
  end
  return todos
end


---@param todo table
---@return string?
local function render_todo(todo)
  local todos_found = {}
  local index = 1
  for t in todo.body:gmatch("(TODO:.*)") do
    todos_found[index] = t
    index = index + 1
  end
  if #todos_found ~= 1 then
    return nil
  end
  return todos_found[1]
end


local M = {}

---@param todos table?
---@return number, number
local function make_window(todos)
  main_buf = vim.api.nvim_get_current_buf()
  main_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  if buf == 0 then
    print("Buffer creation failed.")
  end
  local current_win = vim.api.nvim_get_current_win()
  local aspect_ratio = 0.8
  local win_height = math.ceil(aspect_ratio*vim.api.nvim_win_get_height(current_win))
  local win_width = math.ceil(aspect_ratio*vim.api.nvim_win_get_width(current_win))
  local win_col, win_row = get_centered_pos(win_width, win_height, vim.api.nvim_get_current_win())
  local win = vim.api.nvim_open_win(
    buf,
    false,
    {
      relative='win',
      row=win_row,
      col=win_col,
      width=win_width,
      height=win_height,
      style='minimal',
      border='single',
      title='Hello There!',
      title_pos='center'
    }
  )
  if win == 0 then
    print("Window creation failed.")
  end
  local rendered_todos = {}
  if not todos then
    rendered_todos = {"No todos found."}
  else
    for _, todo in pairs(todos) do
      local rendered_todo = render_todo(todo)
      if rendered_todo then
        table.insert(rendered_todos, rendered_todo)
      end
    end
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, rendered_todos)
  vim.api.nvim_set_current_win(win)
--  vim.api.nvim_set_option_value("modifiable", false, {win = 0})
  return buf, win
end
-- TODO: finish.

---@return nil
M.todos = function ()
  TODOS = fetch_todos()
  local buf, win = make_window(TODOS)
  set_mappings()
end

M.on_enter = on_enter

return M


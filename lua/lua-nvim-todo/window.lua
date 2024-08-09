local api = vim.api
local todo = require('lua-nvim-todo.todo')

local M = {}

local win = nil
local buf = nil

local function create_window()
  -- Create a scratch buffer
  buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- Get dimensions
  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  -- Calculate floating window size
  local win_height = math.ceil(height * 0.6 - 4)
  local win_width = math.ceil(width * 0.6)

  -- Calculate starting position
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  -- Set some options
  local opts = {
    style = "minimal",
    title = "Todo List",
    title_pos = "center",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = "rounded"
  }

  -- Create the floating window
  win = api.nvim_open_win(buf, true, opts)

  -- Set buffer options
  api.nvim_buf_set_option(buf, 'modifiable', false)
  api.nvim_buf_set_option(buf, 'filetype', 'todo-app')

  -- Set buffer keymaps
  local function set_keymap(key, action)
    api.nvim_buf_set_keymap(buf, 'n', key, action, { noremap = true, silent = true })
  end

  set_keymap('q', ':lua require("lua-nvim-todo.window").close()<CR>')
  set_keymap('a', ':lua require("lua-nvim-todo.window").add_todo()<CR>')
  set_keymap('t', ':lua require("lua-nvim-todo.window").toggle_todo_line()<CR>')
  set_keymap('d', ':lua require("lua-nvim-todo.window").remove_todo_line()<CR>')
  set_keymap('<CR>', ':lua require("lua-nvim-todo.window").toggle_todo_line()<CR>')
end

function M.toggle()
  if win and api.nvim_win_is_valid(win) then
    M.close()
  else
    create_window()
    M.update()
  end
end

function M.toggle_todo_line()
  local cur_line = api.nvim_win_get_cursor(win)[1]
  local line = api.nvim_buf_get_lines(buf, cur_line - 1, cur_line, false)[1]
  local id = tonumber(line:match("%[[ xX]%]%s*(%d+)%.%s+")) -- <- Don't touch this
  if id then
    todo.toggle_todo(id)
    M.update()
  end
end

function M.remove_todo_line()
  local cur_line = api.nvim_win_get_cursor(win)[1]
  local line = api.nvim_buf_get_lines(buf, cur_line - 1, cur_line, false)[1]
  local id = tonumber(line:match("%[[ xX]%]%s*(%d+)%.%s+")) -- <- Don't touch this
  if id then
    todo.remove_todo(id)
    M.update()
  end
end

function M.update()
  if win and api.nvim_win_is_valid(win) then
    local lines = todo.get_todos_text()
    api.nvim_buf_set_option(buf, 'modifiable', true)
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    api.nvim_buf_set_option(buf, 'modifiable', false)
  end
end

function M.close()
  if win and api.nvim_win_is_valid(win) then
    api.nvim_win_close(win, true)
    win = nil
    buf = nil
  end
end

function M.add_todo()
  local title = vim.fn.input("Enter todo: ")
  if title ~= "" then
    todo.add_todo(title)
    M.update()
  end
end

return M

local M = {}

M.todos = {}
M.next_id = 1

local function serialize(data)
  local result = "return {"
  result = result .. "todos={"
  for _, todo in ipairs(data.todos) do
    result = result .. string.format("{id=%d,title=%q,completed=%s},", todo.id, todo.title, tostring(todo.completed))
  end
  result = result .. "},"
  result = result .. string.format("next_id=%d", data.next_id)
  result = result .. "}"
  return result
end

local function deserialize(str)
  local chunk = loadstring(str)
  if chunk then
    return chunk()
  end
  return nil
end

local function get_save_path()
  return vim.fn.stdpath('data') .. 'lua-nvim-todo-data.json'
end

function M.add_todo(title)
  local todo = {
    id = M.next_id,
    title = title,
    completed = false
  }
  table.insert(M.todos, todo)
  M.next_id = M.next_id + 1
  M.save_todos()
  print("Todo added successfully!")
end

function M.list_todos()
  if #M.todos == 0 then
    print("No todos found.")
  else
    for _, todo in ipairs(M.todos) do
      local status = todo.completed and "[x]" or "[ ]"
      print(string.format("%s %d. %s", status, todo.id, todo.title))
    end
  end
end

function M.toggle_todo(id)
  for _, todo in ipairs(M.todos) do
    if todo.id == id then
      todo.completed = not todo.completed
      M.save_todos()
      print(" Todo toggled successfully!")
      return
    end
  end
  print("Todo not found.")
end

function M.remove_todo(id)
  for i, todo in ipairs(M.todos) do
    if todo.id == id then
      table.remove(M.todos, i)
      M.save_todos()
      print(" Todo removed successfully!")
      return
    end
  end
  print("Todo not found.")
end

function M.get_todos_text()
  local lines = {"=== Todo List ==="}
  if #M.todos == 0 then
    table.insert(lines, "No todos found.")
  else
    for _, todo in ipairs(M.todos) do
      local status = todo.completed and "[x]" or "[ ]"
      table.insert(lines, string.format("%s %d. %s", status, todo.id, todo.title))
    end
  end
  table.insert(lines, "")
  table.insert(lines, "Press 'a' to add, 't' to toggle, 'd' to delete, 'q' to quit")
  return lines
end

function M.save_todos()
  local file = io.open(get_save_path(), 'w')
  if file then
    file:write(serialize({ todos = M.todos, next_id = M.next_id}))
    file:close()
  end
end

function M.load_todos()
  local file = io.open(get_save_path(), 'r')
  if file then
    local content = file:read('*all')
    file:close()
    if content and content ~= "" then
      local data = deserialize(content)
      M.todos = data.todos or {}
      M.next_id = data.next_id or 1
    end
  end
end

return M

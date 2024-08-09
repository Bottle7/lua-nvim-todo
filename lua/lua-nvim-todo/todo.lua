local M = {}

M.todos = {}
M.next_id = 1

function M.add_todo(title)
  local todo = {
    id = M.next_id,
    title = title,
    completed = false
  }
  table.insert(M.todos, todo)
  M.next_id = M.next_id + 1
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
      print("Todo toggled successfully!")
      return
    end
  end
  print("Todo not found.")
end

function M.remove_todo(id)
  for i, todo in ipairs(M.todos) do
    if todo.id == id then
      table.remove(M.todos, i)
      print("Todo removed successfully!")
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

return M

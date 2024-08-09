local todo = require('lua-nvim-todo.todo')
local window = require('lua-nvim-todo.window')

local function create_commands()
  vim.api.nvim_create_user_command('TodoAdd', function(opts)
    todo.add_todo(opts.args)
  end, { nargs = 1 })

  vim.api.nvim_create_user_command('TodoList', function()
    todo.list_todos()
  end, {})

  vim.api.nvim_create_user_command('TodoToggle', function(opts)
    todo.toggle_todo(tonumber(opts.args))
  end, { nargs = 1 })

  vim.api.nvim_create_user_command('TodoRemove', function(opts)
    todo.remove_todo(tonumber(opts.args))
  end, { nargs = 1 })

  vim.api.nvim_create_user_command('TodoToggleWindow', function()
    window.toggle()
  end, {})
end

local function setup()
  todo.load_todos()
  create_commands()
end

return {
  setup = setup
}

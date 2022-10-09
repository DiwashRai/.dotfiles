local dap = require('dap')
local dapui = require('dapui')

dap.adapters.cppdbg = {
  id = 'cppdbg',
  type = 'executable',
  command = '/home/diwash/.local/cpptools-linux/extension/debugAdapters/bin/OpenDebugAD7',
}

dap.configurations.cpp = {
  {
    name = "Launch prev file",
    type = "cppdbg",
    request = "launch",
    program = function()
      if not DAP_EXE then
        DAP_EXE = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end
      return DAP_EXE
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = true,
  },
  {
    name = "Set and Launch file",
    type = "cppdbg",
    request = "launch",
    program = function()
      DAP_EXE = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      return DAP_EXE
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = true,
  },
}

require('dapui').setup()
require("nvim-dap-virtual-text").setup()
require('telescope').load_extension('dap')

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

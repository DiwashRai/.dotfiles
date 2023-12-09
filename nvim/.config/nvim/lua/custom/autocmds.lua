
local cmake_group = vim.api.nvim_create_augroup("CMake", { clear = true })
vim.api.nvim_create_autocmd("User", {
  pattern = "CMakeBuildSucceeded",
  command = "CMakeClose",
  group = cmake_group,
})


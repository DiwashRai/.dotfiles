
return {
  'cdelledonne/vim-cmake',
  init = function()
    vim.g.cmake_generate_options = {'-DCMAKE_TOOLCHAIN_FILE=~/code/vcpkg/scripts/buildsystems/vcpkg.cmake'}
    vim.g.cmake_link_compile_commands = 1
  end,
}

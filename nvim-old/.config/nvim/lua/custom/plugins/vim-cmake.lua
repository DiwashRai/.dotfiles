local MY_C_COMPILER = os.getenv("MY_C_COMPILER")
local MY_CXX_COMPILER = os.getenv("MY_CXX_COMPILER")
local MY_TOOLCHAIN_FILE = os.getenv("MY_TOOLCHAIN_FILE")

return {
	"cdelledonne/vim-cmake",
	init = function()
		vim.g.cmake_generate_options = {
			"-DCMAKE_TOOLCHAIN_FILE=" .. MY_TOOLCHAIN_FILE,
			"-DCMAKE_C_COMPILER=" .. MY_C_COMPILER,
			"-DCMAKE_CXX_COMPILER=" .. MY_CXX_COMPILER,
		}
		vim.g.cmake_link_compile_commands = 1
	end,
}

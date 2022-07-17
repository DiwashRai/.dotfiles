local local_options = {
  shiftwidth = 4,
  tabstop = 4,
  softtabstop = 4,
}

for k, v in pairs(local_options) do
    vim.opt_local[k] = v
end

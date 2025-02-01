local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- Dernière version stable
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Charger les plugins
require("remaps")
require("set")
require("lazy").setup("plugins")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "arduino",
  callback = function()
    require("arduino")
  end,
})

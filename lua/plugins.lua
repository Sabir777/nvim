-- lua/plugins.lua
-- Менеджер плагинов: lazy.nvim (ставится сам при первом запуске)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Не удалось склонировать lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- ys / cs / ds: обрамление текста
  { "tpope/vim-surround" },

  -- <leader>cc, <leader>cu, <leader>cs ...: комментирование
  {
    "preservim/nerdcommenter",
    -- переменные NERDCommenter нужно задать ДО загрузки плагина
    init = function()
      -- пробел после символа комментария
      vim.g.NERDSpaceDelims = 1
      -- убирать лишние пробелы при раскомментировании
      vim.g.NERDRemoveExtraSpaces = 1
      -- свои разделители
      vim.g.NERDCustomDelimiters = {
        c = { left = "//", right = "" },
        javascript = { left = "//", right = "" },
        python = { left = "#", right = "" },
      }
    end,
  },
}, {
  -- не проверять обновления плагинов автоматически
  checker = { enabled = false },
})

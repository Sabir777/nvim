-- init.lua
-- Точка входа Neovim.
-- Порядок загрузки имеет значение:
--   1) settings  — опции, leader, clipboard (до плагинов)
--   2) keymaps   — маппинги (используют leader из settings)
--   3) plugins   — lazy.nvim и список плагинов

require("settings")
require("keymaps")
require("plugins")

-- init.lua
-- Точка входа Neovim.
-- Порядок загрузки имеет значение:
--   1) settings  — опции, leader, clipboard (до плагинов)
--   2) keymaps   — маппинги (используют leader из settings)
--   3) plugins   — lazy.nvim и список плагинов

require("settings")
require("keymaps")

-- plugins.lua пока не создан; подключаем безопасно, чтобы nvim не падал.
pcall(require, "plugins")
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
  -- Статусная строка (замена vim-airline)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        icons_enabled = true,
        theme = "powerline", -- вместо "auto"
        section_separators = {
          left = vim.fn.nr2char(0xe0b0),
          right = vim.fn.nr2char(0xe0b2),
        },
        component_separators = {
          left = vim.fn.nr2char(0xe0b1),
          right = vim.fn.nr2char(0xe0b3),
        },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            -- в узком окне показывать одну букву: N, I, V
            fmt = function(s)
              return vim.o.columns < 100 and s:sub(1, 1) or s
            end,
          },
        },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 0 } },
        lualine_x = {
          -- кодировку показывать только если она не utf-8
          {
            "encoding",
            cond = function()
              local enc = vim.bo.fileencoding
              return enc ~= "" and enc ~= "utf-8"
            end,
          },
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
  -- ИИ-автодополнение (ghost text)
  {
    "supermaven-inc/supermaven-nvim",
    opts = {
      keymaps = {
        accept_suggestion = "<A-e>",
        accept_word = "<A-w>",
      },
      disable_inline_completion = false,
      disable_keymaps = false,
    },
  },
  -- LSP: конфигурация серверов
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright" },
      })
      vim.lsp.config("pyright", {
        root_markers = {
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json",
          ".git",
        },
        capabilities = {
          textDocument = {
            diagnostic = { dynamicRegistration = false },
          },
        },
      })
      vim.lsp.enable("pyright")
    end,
  },
}, {
  -- не проверять обновления плагинов автоматически
  checker = { enabled = false },
})

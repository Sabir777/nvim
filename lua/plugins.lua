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
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ruff" },
      })

      -- Mason-tool-installer: ставит debugpy и другие инструменты автоматически
      require("mason-tool-installer").setup({
        ensure_installed = { "debugpy" },
        auto_update = false,
        run_on_start = true,
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

      -- Ruff: линтер + форматтер (замена ruff-lsp)
      vim.lsp.config("ruff", {
        root_markers = {
          "pyproject.toml",
          "ruff.toml",
          ".ruff.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          ".git",
        },
        capabilities = {
          textDocument = {
            diagnostic = { dynamicRegistration = false },
          },
        },
      })
      vim.lsp.enable("ruff")
    end,
  },
  -- Дебаггер: nvim-dap + UI + python-адаптер (замена vimspector)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Иконки брейкпоинтов: красный кружок
      vim.fn.sign_define("DapBreakpoint", {
        text = "🔴",
        texthl = "DapBreakpoint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "🟡",
        texthl = "DapBreakpointCondition",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "▶",
        texthl = "DapStopped",
        linehl = "DapStoppedLine",
        numhl = "",
      })

      -- debugpy ставится через Mason, не засоряет систему/venv проекта
      local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      local debugpy_python = vim.fn.executable(mason_debugpy) == 1 and mason_debugpy or "python3"
      require("dap-python").setup(debugpy_python)

      -- Конфигурации запуска по умолчанию
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Запустить файл",
          program = "${file}",
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              return venv .. "/bin/python"
            end
            return debugpy_python
          end,
        },
        {
          type = "python",
          request = "launch",
          name = "Запустить файл с аргументами",
          program = "${file}",
          args = function()
            local args = vim.fn.input("Аргументы: ")
            return vim.split(args, " +")
          end,
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              return venv .. "/bin/python"
            end
            return debugpy_python
          end,
        },
        {
          type = "python",
          request = "attach",
          name = "Attach к процессу",
          processId = function()
            return tonumber(vim.fn.input("PID процесса: "))
          end,
          pythonPath = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              return venv .. "/bin/python"
            end
            return debugpy_python
          end,
        },
      }

      -- Авто-открытие/закрытие UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Маппинги дебаггера
      vim.keymap.set("n", "<F5>", dap.continue, { silent = true })
      vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { silent = true })
      vim.keymap.set("n", "<F10>", dap.step_over, { silent = true })
      vim.keymap.set("n", "<F11>", dap.step_into, { silent = true })
      vim.keymap.set("n", "<S-F11>", dap.step_out, { silent = true })
      vim.keymap.set("n", "<F3>", dap.terminate, { silent = true })
      vim.keymap.set("n", "<F4>", dap.restart, { silent = true })
      vim.keymap.set("n", "<leader>di", dapui.eval, { silent = true })
      vim.keymap.set("n", "<leader><F3>", function()
        dap.terminate()
        dapui.close()
      end, { silent = true })
    end,
  },
  -- Проводник файлов (замена NERDTree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      view = { width = 30 },
      renderer = {
        group_empty = true,
        icons = { show = { git = true, folder = true, file = true, folder_arrow = true } },
      },
      filters = { dotfiles = false },
      actions = {
        open_file = { quit_on_open = false },
      },
    },
  },
  -- Список всех ошибок проекта (LazyVim-like)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
}, {
  -- не проверять обновления плагинов автоматически
  checker = { enabled = false },
})

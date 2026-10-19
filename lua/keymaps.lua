-- lua/keymaps.lua
-- ВАЖНО: mapleader должен быть задан ДО загрузки плагинов (lazy.nvim и т.п.).
-- Поэтому в init.lua сначала require("keymaps") или хотя бы vim.g.mapleader, потом require("plugins").

vim.g.mapleader = ","

---------------------------------------------------------------------------
-- Помощники
---------------------------------------------------------------------------
local function map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- <leader>key + дубль для русской раскладки: б + ru
-- (',' на русской раскладке это 'б')
local function lmap(mode, key, ru, rhs, opts)
  map(mode, "<leader>" .. key, rhs, opts)
  if ru then
    map(mode, "б" .. ru, rhs, opts)
  end
end

---------------------------------------------------------------------------
-- Сохраниться
---------------------------------------------------------------------------
map("n", "<C-s>", "<Cmd>w<CR>")
map("i", "<C-s>", "<Esc><Cmd>w<CR>")

---------------------------------------------------------------------------
-- Выделить все
---------------------------------------------------------------------------
lmap("n", "a", "ф", "ggVG")

---------------------------------------------------------------------------
-- Глобальный буфер обмена (нативный регистр "+, без xclip)
-- Требует vim.opt.clipboard = "unnamedplus" в settings.lua
map("v", "<C-c>", '"+y')
lmap("n", "v", "м", '"+p')
lmap("v", "v", "м", '"+p')

-- Копировать от текущего символа до конца строки
map("n", "Y", "y$")
map("n", "Н", "y$")

-- Терминал (выход: exit)
map("n", "<C-q>", "<Cmd>terminal<CR>")

---------------------------------------------------------------------------
-- Навигация по строке
---------------------------------------------------------------------------
-- По логическим (экранным) строкам
map({ "n", "x", "o" }, "j", "gj")
map({ "n", "x", "o" }, "k", "gk")

-- Начало / конец строки
map({ "n", "v" }, "H", "^")
map({ "n", "v" }, "L", "$")
map({ "n", "v" }, "Р", "^")
map({ "n", "v" }, "Д", "$")

---------------------------------------------------------------------------
-- Отступы
---------------------------------------------------------------------------
-- Нормализовать отступы во всем документе
map("n", "<leader>=", "<Cmd>normal! ggVG=<CR>")

---------------------------------------------------------------------------
-- Вкладки и буферы
---------------------------------------------------------------------------
map("n", "<leader>j", "<Cmd>tabprevious<CR>")
map("n", "<leader>k", "<Cmd>tabnext<CR>")

lmap("n", "i", "ш", "<Cmd>bprevious<CR>")
lmap("n", "o", "щ", "<Cmd>bnext<CR>")

-- Меняю местами Ctrl-i и Ctrl-o в jumplist
-- (в терминале <C-i> == <Tab>; без kitty keyboard protocol может не работать)
map("n", "<C-i>", "<C-o>")
map("n", "<C-o>", "<C-i>")

---------------------------------------------------------------------------
-- Метки
---------------------------------------------------------------------------
-- mm - метка 'm' + запись позиции в jumplist
map("n", "mm", "mm`m")

for i = 1, 9 do
  -- m1..m9: поставить метку и добавить в jumplist
  map("n", "m" .. i, ("m%d`%d"):format(i, i))
  -- <leader>1..9: перейти к метке
  map("n", "<leader>" .. i, ("`%dzz"):format(i))
end

---------------------------------------------------------------------------
-- Поиск
---------------------------------------------------------------------------
-- Вкл/выкл подсветку найденного
map("n", "<leader>h", "<Cmd>set hlsearch!<CR>")

-- Подсветка перед каждым поиском + very magic
map("n", "/", ":set hlsearch<CR>:noh<CR>/\\v", { silent = false })
map("n", "?", ":set hlsearch<CR>:noh<CR>?\\v", { silent = false })


---------------------------------------------------------------------------
-- Конфиг: перечитать, открыть, выполнить скрипт
---------------------------------------------------------------------------
-- Для Lua-конфига :source $MYVIMRC перечитает только init.lua;
-- уже загруженные require-модули кэшируются, поэтому сбрасываем их.
map("n", "<F1>", function()
  vim.cmd("write")
  for name in pairs(package.loaded) do
    if name == "keymaps" or name == "settings" then
      package.loaded[name] = nil
    end
  end
  vim.cmd("source $MYVIMRC")
  vim.notify("Конфиг перечитан")
end)

map("n", "<leader><F1>", "<Cmd>redraw!<CR>")


---------------------------------------------------------------------------
-- Номера строк
---------------------------------------------------------------------------
lmap("n", "n", "т", "<Cmd>set invnumber<CR>")

---------------------------------------------------------------------------
-- Панели (окна)
---------------------------------------------------------------------------
-- Перемещение между панелями: Alt + h/j/k/l
-- (в оригинальном .vimrc здесь были литеральные ^[ - в вставленном тексте они потерялись,
--  поэтому используем <A-...>)
map("n", "<A-h>", "<C-w>h")
map("n", "<A-р>", "<C-w>h")
map("n", "<A-l>", "<C-w>l")
map("n", "<A-д>", "<C-w>l")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-о>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-л>", "<C-w>k")

-- Создать панель: Alt + \ (справа), Alt + - (снизу)
map("n", "<A-\\>", "<C-w>v")
map("n", "<A-->", "<C-w>s")

-- Двигать панели
map("n", "<C-h>", "<C-w>h<C-w>x")
map("n", "<C-l>", "<C-w>x<C-w>l")

-- Открыть все буферы в отдельных панелях
lmap("n", "b", "и", "<Cmd>bufdo vert sbnext<CR><Cmd>q<CR>")

-- Закрыть панель
lmap("n", "q", "й", "<Cmd>q<CR>")


---------------------------------------------------------------------------
-- Автодополнение (нативное меню)
---------------------------------------------------------------------------
-- Если будешь использовать blink.cmp / nvim-cmp - эти четыре маппинга лучше
-- убрать и настроить клавиши в самом плагине.
map("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })
map("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })
map("i", "<C-j>", "<C-n>")
map("i", "<C-k>", "<C-p>")

---------------------------------------------------------------------------
-- Форматирование через ruff
---------------------------------------------------------------------------
-- Ruff: автоисправление линт-ошибок и форматирование
local function ruff_fix_and_format()
  vim.cmd("update")
  local bufnr = vim.api.nvim_get_current_buf()

  local ruff_client = nil
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.name == "ruff" then ruff_client = c; break end
  end

  if not ruff_client then
    vim.lsp.buf.format({ async = false })
    return
  end

  local pending = 0

  local function maybe_format()
    if pending == 0 then
      vim.defer_fn(function()
        vim.lsp.buf.format({ async = false })
      end, 100)
    end
  end

  -- Запрашиваем code actions от ruff
  ruff_client:request("textDocument/codeAction", {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
    },
    context = { only = { "quickfix", "source" }, diagnostics = {} },
  }, function(err, actions)
    if err or not actions then
      maybe_format()
      return
    end
    for _, action in ipairs(actions) do
      local title = action.title or ""
      if title:match("[Ff]ix all") or title:match("[Oo]rganize [Ii]mports") then
        pending = pending + 1
        -- Ruff возвращает action без edit/command — нужен resolve
        ruff_client:request("codeAction/resolve", action, function(e, resolved)
          if e or not resolved then
            pending = pending - 1
            maybe_format()
            return
          end
          if resolved.edit then
            vim.lsp.util.apply_workspace_edit(resolved.edit, ruff_client.offset_encoding)
          elseif resolved.command then
            ruff_client:exec_cmd(resolved.command, { bufnr = bufnr })
          end
          pending = pending - 1
          maybe_format()
        end)
      end
    end
    if pending == 0 then
      maybe_format()
    end
  end)
end

map("n", "<leader>f", ruff_fix_and_format)

---------------------------------------------------------------------------
-- Аббревиатуры командной строки (русская раскладка)
---------------------------------------------------------------------------
vim.cmd([[
  cabbrev цй wq
  cabbrev ц w
  cabbrev й q
]])

---------------------------------------------------------------------------
-- LSP (встроенный клиент Neovim вместо vim-lsp)
---------------------------------------------------------------------------
local function diag_jump(count)
  return function()
    if vim.diagnostic.jump then -- nvim 0.11+
      vim.diagnostic.jump({ count = count, float = true })
    elseif count > 0 then
      vim.diagnostic.goto_next()
    else
      vim.diagnostic.goto_prev()
    end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_keymaps", { clear = true }),
  callback = function(ev)
    local o = { buffer = ev.buf }
    map("n", "gd", vim.lsp.buf.definition, o)
    map("n", "gr", vim.lsp.buf.references, o)
    map("n", "K", vim.lsp.buf.hover, o)
    map("n", "<leader>rn", vim.lsp.buf.rename, o)
    map("n", "[g", diag_jump(-1), o)
    map("n", "]g", diag_jump(1), o)
  end,
})

---------------------------------------------------------------------------
-- Проводник файлов (nvim-tree)
---------------------------------------------------------------------------
lmap("n", "p", "з", "<Cmd>NvimTreeToggle<CR>")
map("n", "<leader>P", "<Cmd>NvimTreeFindFile<CR>")

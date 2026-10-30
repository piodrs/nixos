local config = vim.fn.stdpath('config')

vim.g.mapleader = ' '

vim.g.coc_data_home = vim.fn.stdpath('data') .. '/coc'
vim.g.coc_start_at_startup = 0

local function with_direnv(callback)
    if vim.fn.executable('direnv') == 0 then
        return callback()
    end

    vim.system({ 'direnv', 'export', 'json' }, { text = true }, vim.schedule_wrap(function(result)
        if result.code ~= 0 then
            vim.notify('direnv: ' .. vim.trim(result.stderr or ''), vim.log.levels.WARN)
        elseif result.stdout ~= '' then
            for key, value in pairs(vim.json.decode(result.stdout)) do
                vim.env[key] = value ~= vim.NIL and value or nil
            end
        end
        callback()
    end))
end

with_direnv(function() vim.cmd.CocStart() end)

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.scrolloff = 8
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.updatetime = 250
vim.opt.autoread = true
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.pumheight = 8
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.statusline = "%f %m%r%=%{get(g:,'coc_status','')} %y %l:%c %p%%"

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
    group = vim.api.nvim_create_augroup('nvim_reload', { clear = true }),
    command = 'checktime',
})

vim.cmd.colorscheme('gruber-darker')

local luasnip = require('luasnip')
luasnip.add_snippets('python', dofile(config .. '/snippets/python.lua'))

local map = vim.keymap.set
local silent = { silent = true }

require('dired').setup({
    path_separator = '/',
    show_banner = false,
    show_icons = false,
    show_hidden = true,
    show_dot_dirs = true,
    show_colors = true,
})

map('n', '<leader>ff', '<Cmd>Dired<CR>', silent)

local git = require('gitsigns')
git.setup()

map('n', '<leader>gs', '<Cmd>Git<CR>', silent)
map('n', '<leader>gc', '<Cmd>Git log --oneline --decorate --graph<CR>', silent)
map('n', '<leader>gb', '<Cmd>Git branch<CR>', silent)
map('n', '<leader>gd', '<Cmd>Gdiffsplit<CR>', silent)
map('n', '[h', '<Cmd>Gitsigns nav_hunk prev<CR>', silent)
map('n', ']h', '<Cmd>Gitsigns nav_hunk next<CR>', silent)
map('n', '<leader>hp', git.preview_hunk, silent)
map('n', '<leader>hs', git.stage_hunk, silent)
map('n', '<leader>hu', git.undo_stage_hunk, silent)

map('n', '<leader>cd', '<Cmd>Ex<CR>', silent)
map('n', '<leader>u', '<Cmd>undolist<CR>', silent)
map('n', '<leader>rl', function() dofile(config .. '/init.lua') end, silent)

map('n', 'J', 'mzJ`z')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

map('x', 'J', ":move '>+1<CR>gv=gv")
map('x', 'K', ":move '<-2<CR>gv=gv")
map('x', '<leader>p', '"_dP')
map({ 'n', 'x' }, '<leader>y', '"+y')

vim.api.nvim_create_user_command('VTerm', 'vertical terminal', {})

map('n', '<leader>tt', '<Cmd>VTerm<CR>', silent)
map('t', '<Esc>', '<C-\\><C-n>', silent)

map('n', 'gd', '<Plug>(coc-definition)', silent)
map('n', 'gD', '<Plug>(coc-declaration)', silent)
map('n', 'gi', '<Plug>(coc-implementation)', silent)
map('n', 'go', '<Plug>(coc-type-definition)', silent)
map('n', 'gr', '<Plug>(coc-references)', silent)
map('n', '[d', '<Plug>(coc-diagnostic-prev)', silent)
map('n', ']d', '<Plug>(coc-diagnostic-next)', silent)
map('n', '<leader>ld', '<Cmd>CocList diagnostics<CR>', silent)

map('n', 'gl', function() vim.fn.CocActionAsync('diagnosticInfo') end, silent)
map('n', 'K', function() vim.fn.CocActionAsync('doHover') end, silent)
map('n', 'gs', function() vim.fn.CocActionAsync('showSignatureHelp') end, silent)

map('n', '<F2>', '<Plug>(coc-rename)', silent)
map('n', '<F3>', function() vim.fn.CocActionAsync('format') end, silent)
map('x', '<F3>', '<Plug>(coc-format-selected)', silent)
map('n', '<F4>', '<Plug>(coc-codeaction-cursor)', silent)

local expr = { expr = true, silent = true }

map('i', '<Tab>', function()
    if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
        return ''
    end

    if vim.fn['coc#pum#visible']() == 1 then
        return vim.fn['coc#pum#next'](1)
    end

    local before = vim.fn.getline('.'):sub(1, vim.fn.col('.') - 1)
    return (before == '' or before:match('%s$')) and '<Tab>' or vim.fn['coc#refresh']()
end, expr)

map('i', '<S-Tab>', function()
    if luasnip.jumpable(-1) then
        luasnip.jump(-1)
        return ''
    end

    return vim.fn['coc#pum#visible']() == 1 and vim.fn['coc#pum#prev'](1) or '<C-h>'
end, expr)

map('i', '<CR>', function()
    return vim.fn['coc#pum#visible']() == 1 and vim.fn['coc#pum#confirm']() or '<CR>'
end, expr)

map('i', '<C-Space>', function() return vim.fn['coc#refresh']() end, expr)

local treesitter = require('nvim-treesitter')
local parsers = { 'c', 'cpp', 'javascript', 'nim', 'nix', 'python', 'typescript' }
local indentation = {
    c = 4,
    cpp = 4,
    javascript = 2,
    nim = 2,
    nix = 2,
    python = 4,
    typescript = 2,
}

local languages = vim.api.nvim_create_augroup('nvim_languages', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
    group = languages,
    pattern = parsers,
    callback = function(event)
        local width = indentation[event.match]

        pcall(vim.treesitter.start, event.buf)
        vim.bo[event.buf].expandtab = true
        vim.bo[event.buf].shiftwidth = width
        vim.bo[event.buf].softtabstop = width
        vim.bo[event.buf].tabstop = width
        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

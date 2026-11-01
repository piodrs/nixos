local config = vim.fn.stdpath('config')

vim.g.mapleader = ' '
vim.g.direnv_silent_load = 1

for name, value in pairs({
    number = true,
    relativenumber = true,
    signcolumn = 'yes',
    scrolloff = 8,
    wrap = true,
    linebreak = true,
    breakindent = true,
    tabstop = 4,
    shiftwidth = 4,
    softtabstop = 4,
    expandtab = true,
    smartindent = true,
    ignorecase = true,
    smartcase = true,
    hlsearch = false,
    splitbelow = true,
    splitright = true,
    updatetime = 250,
    autoread = true,
    completeopt = { 'menuone', 'noselect' },
    pumheight = 8,
    swapfile = false,
    undofile = true,
    termguicolors = true,
    statusline = '%f %m%r%=%{v:lua.vim.lsp.status()} %y %l:%c %p%%',
}) do
    vim.opt[name] = value
end

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
    group = vim.api.nvim_create_augroup('nvim_reload', { clear = true }),
    command = 'checktime',
})

vim.api.nvim_create_user_command('VTerm', 'vertical terminal', {})

vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('nvim_startup', { clear = true }),
    callback = function()
        if vim.fn.argc() ~= 0 then return end

        local fortune = vim.fn.system({ 'fortune' })
        if vim.v.shell_error ~= 0 then return end

        local cow = vim.fn.systemlist({ 'cowsay' }, fortune)
        if vim.v.shell_error ~= 0 then return end

        vim.bo.buftype = 'nofile'
        vim.bo.bufhidden = 'wipe'
        vim.bo.swapfile = false
        vim.api.nvim_buf_set_lines(0, 0, -1, false, cow)
        vim.bo.modified = false
        vim.bo.modifiable = false
    end,
})

vim.cmd.colorscheme('gruber-darker')

local luasnip = require('luasnip')
luasnip.add_snippets('python', dofile(config .. '/snippets/python.lua'))

require('nvim-autopairs').setup()

local gitsigns = require('gitsigns')
gitsigns.setup()

require('dired').setup({
    path_separator = '/',
    show_banner = false,
    show_icons = false,
    show_hidden = true,
    show_dot_dirs = true,
    show_colors = true,
})

local function map(mode, lhs, rhs, desc, buffer)
    vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = buffer })
end

require('blink.cmp').setup({
    keymap = {
        preset = 'none',
        ['<Tab>'] = {
            function()
                if luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                    return true
                end
            end,
            'select_next',
            'fallback',
        },
        ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-Space>'] = { 'show' },
    },
    completion = {
        list = { selection = { preselect = false } },
        documentation = { auto_show = true },
        menu = {
            draw = {
                columns = {
                    { 'label', 'label_description', gap = 1 },
                    { 'kind' },
                },
            },
        },
    },
    snippets = { preset = 'luasnip' },
    signature = { enabled = true },
})

vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
vim.lsp.config('clangd', { cmd = { 'clangd', '--background-index', '--clang-tidy' } })
vim.lsp.config('basedpyright', {
    settings = { basedpyright = { analysis = { typeCheckingMode = 'basic' } } },
})
vim.lsp.config('ruff', {
    on_attach = function(client) client.server_capabilities.hoverProvider = false end,
})
vim.lsp.config('nil_ls', {
    settings = { ['nil'] = { formatting = { command = { 'nixfmt' } } } },
})

vim.diagnostic.config({ virtual_text = true, severity_sort = true })

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('nvim_lsp', { clear = true }),
    callback = function(event)
        local buf = event.buf

        map('n', 'gd', vim.lsp.buf.definition, 'Definition', buf)
        map('n', 'gD', vim.lsp.buf.declaration, 'Declaration', buf)
        map('n', 'gi', vim.lsp.buf.implementation, 'Implementation', buf)
        map('n', 'go', vim.lsp.buf.type_definition, 'Type definition', buf)
        map('n', 'gr', vim.lsp.buf.references, 'References', buf)
        map('n', 'K', vim.lsp.buf.hover, 'Hover', buf)
        map('n', 'gs', vim.lsp.buf.signature_help, 'Signature help', buf)
        map('n', '<F2>', vim.lsp.buf.rename, 'Rename', buf)
        map('n', '<F3>', vim.lsp.buf.format, 'Format buffer', buf)
        map('x', '<F3>', 'gq', 'Format selection', buf)
        map('n', '<F4>', vim.lsp.buf.code_action, 'Code action', buf)
    end,
})

vim.api.nvim_create_autocmd('User', {
    group = vim.api.nvim_create_augroup('nvim_direnv', { clear = true }),
    pattern = 'DirenvLoaded',
    callback = function()
        if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
            vim.cmd('lsp restart')
        end
    end,
})

map('n', '<leader>cd', '<Cmd>Ex<CR>', 'Netrw')
map('n', '<leader>ff', '<Cmd>Dired<CR>', 'Dired')
map('n', '<leader>u', '<Cmd>undolist<CR>', 'Undo list')
map('n', '<leader>rl', function() dofile(config .. '/init.lua') end, 'Reload config')
map('n', '<leader>tt', '<Cmd>VTerm<CR>', 'Vertical terminal')
map('t', '<Esc>', '<C-\\><C-n>', 'Leave terminal mode')

map('n', 'J', 'mzJ`z', 'Join lines')
map('n', '<C-d>', '<C-d>zz', 'Half page down')
map('n', '<C-u>', '<C-u>zz', 'Half page up')
map('n', 'n', 'nzzzv', 'Next match')
map('n', 'N', 'Nzzzv', 'Previous match')
map('x', 'J', ":move '>+1<CR>gv=gv", 'Move selection down')
map('x', 'K', ":move '<-2<CR>gv=gv", 'Move selection up')
map('x', '<leader>p', '"_dP', 'Paste without yanking')
map({ 'n', 'x' }, '<leader>y', '"+y', 'Yank to clipboard')

map('n', '<leader>gs', '<Cmd>Git<CR>', 'Git status')
map('n', '<leader>gc', '<Cmd>Git log --oneline --decorate --graph<CR>', 'Git log')
map('n', '<leader>gb', '<Cmd>Git branch<CR>', 'Git branch')
map('n', '<leader>gd', '<Cmd>Gdiffsplit<CR>', 'Git diff')
map('n', '[h', '<Cmd>Gitsigns nav_hunk prev<CR>', 'Previous hunk')
map('n', ']h', '<Cmd>Gitsigns nav_hunk next<CR>', 'Next hunk')
map('n', '<leader>hp', gitsigns.preview_hunk, 'Preview hunk')
map('n', '<leader>hs', gitsigns.stage_hunk, 'Stage hunk')
map('n', '<leader>hu', gitsigns.undo_stage_hunk, 'Undo stage hunk')

map('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic')
map('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic')
map('n', 'gl', vim.diagnostic.open_float, 'Diagnostic info')
map('n', '<leader>ld', vim.diagnostic.setqflist, 'Diagnostics list')

local indentation = {
    c = 4,
    cpp = 4,
    go = 4,
    javascript = 2,
    nix = 2,
    python = 4,
    typescript = 2,
    zig = 4,
}

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('nvim_languages', { clear = true }),
    pattern = vim.tbl_keys(indentation),
    callback = function(event)
        local width = indentation[event.match]

        pcall(vim.treesitter.start, event.buf)
        vim.bo[event.buf].expandtab = event.match ~= 'go'
        vim.bo[event.buf].shiftwidth = width
        vim.bo[event.buf].softtabstop = width
        vim.bo[event.buf].tabstop = width
        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

vim.lsp.enable({ 'ts_ls', 'clangd', 'gopls', 'zls', 'basedpyright', 'ruff', 'nil_ls' })

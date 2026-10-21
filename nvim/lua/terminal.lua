local terminal = {}
local api = vim.api

local function layout()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.7)

    return {
        relative = 'editor',
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width - 2) / 2),
        row = math.floor((vim.o.lines - height - 2) / 2),
        style = 'minimal',
        border = 'rounded',
    }
end

local function toggle()
    if terminal.window and api.nvim_win_is_valid(terminal.window) then
        api.nvim_win_close(terminal.window, true)
        return
    end

    local running = terminal.buffer and api.nvim_buf_is_valid(terminal.buffer)
        and vim.fn.jobwait({ terminal.job }, 0)[1] == -1

    if not running then
        if terminal.buffer and api.nvim_buf_is_valid(terminal.buffer) then
            api.nvim_buf_delete(terminal.buffer, { force = true })
        end

        terminal.buffer = api.nvim_create_buf(false, true)
        vim.bo[terminal.buffer].bufhidden = 'hide'
    end

    terminal.window = api.nvim_open_win(terminal.buffer, true, layout())

    if not running then
        terminal.job = vim.fn.jobstart({ vim.o.shell }, { term = true })
    end

    vim.cmd.startinsert()
end

api.nvim_create_autocmd('VimResized', {
    group = api.nvim_create_augroup('nvim_terminal', { clear = true }),
    callback = function()
        if terminal.window and api.nvim_win_is_valid(terminal.window) then
            api.nvim_win_set_config(terminal.window, layout())
        end
    end,
})

vim.keymap.set({ 'n', 't' }, '<leader>tt', toggle, { silent = true })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

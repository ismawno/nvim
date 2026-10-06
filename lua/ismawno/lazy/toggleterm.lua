local shell = vim.o.shell
if vim.fn.has('win32') == 1 then
    shell = require('ismawno.win32').shell
end

return {
    'akinsho/toggleterm.nvim',
    config = true,
    opts = {
        open_mapping = false,
        shell = shell,
        -- hide number column in terminals
        hide_numbers = true,
        -- persist size/dir between opens
        persist_size = true,
        persist_mode = true,
        start_in_insert = false,
    },
}

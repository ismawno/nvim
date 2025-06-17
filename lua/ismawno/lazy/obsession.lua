return {
    'tpope/vim-obsession',
    lazy = false,
    config = function()
        local utils = require('ismawno.utils')
        local session_file = utils.find_root() .. '/Session.vim'
        if vim.fn.filereadable(session_file) == 1 then
            vim.cmd('source ' .. session_file)
        end
    end,
}

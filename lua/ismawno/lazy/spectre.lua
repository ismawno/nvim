return {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        if vim.loop.os_uname().sysname == 'Darwin' then
            require('spectre').setup({
                replace_engine = {
                    ['sed'] = {
                        cmd = 'sed',
                        args = {
                            '-i',
                            '',
                            '-E',
                        },
                    },
                },
            })
        else
            require('spectre').setup()
        end
        vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
            desc = 'Toggle Spectre',
        })
        vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
            desc = 'Search current word',
        })
        vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
            desc = 'Search current word',
        })
        vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
            desc = 'Search on current file',
        })
    end,
}

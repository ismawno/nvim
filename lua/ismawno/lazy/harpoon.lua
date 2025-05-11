return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
        local harpoon = require('harpoon')
        local utils = require('ismawno.utils')
        -- REQUIRED
        harpoon:setup()
        -- REQUIRED
        utils.mapkey('n', '<leader>q', function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = 'Open harpoon quick menu' })
        utils.mapkey('n', '<leader>a', function()
            harpoon:list():add()
        end, { desc = 'Add current file to harpoon' })
        utils.mapkey('n', '<leader>h', function()
            harpoon:list():select(1)
        end, { desc = 'Go to first harpoon file' })
        utils.mapkey('n', '<leader>j', function()
            harpoon:list():select(2)
        end, { desc = 'Go to second harpoon file' })
        utils.mapkey('n', '<leader>k', function()
            harpoon:list():select(3)
        end, { desc = 'Go to third harpoon file' })
        utils.mapkey('n', '<leader>l', function()
            harpoon:list():select(4)
        end, { desc = 'Go to fourth harpoon file' })

        -- Toggle previous & next buffers stored within Harpoon list
        utils.mapkey('n', '<C-q>', function()
            harpoon:list():prev()
        end, { desc = 'Go to the previous harpoon file' })
        utils.mapkey('n', '<C-e>', function()
            harpoon:list():next()
        end, { desc = 'Go to the next harpoon file' })
        -- basic telescope configuration
        local conf = require('telescope.config').values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            require('telescope.pickers')
                .new({}, {
                    prompt_title = 'Harpoon',
                    finder = require('telescope.finders').new_table({
                        results = file_paths,
                    }),
                    previewer = conf.file_previewer({}),
                    sorter = conf.generic_sorter({}),
                })
                :find()
        end

        utils.mapkey('n', '<leader>e', function()
            toggle_telescope(harpoon:list())
        end, { desc = 'Open harpoon window with telescope' })
    end,
}

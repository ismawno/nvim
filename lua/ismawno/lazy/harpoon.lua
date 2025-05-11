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

        utils.mapkey('n', '<leader>a', function()
            harpoon:list():add()
        end)
        utils.mapkey('n', '<leader>h', function()
            harpoon:list():select(1)
        end)
        utils.mapkey('n', '<leader>j', function()
            harpoon:list():select(2)
        end)
        utils.mapkey('n', '<leader>k', function()
            harpoon:list():select(3)
        end)
        utils.mapkey('n', '<leader>l', function()
            harpoon:list():select(4)
        end)

        -- Toggle previous & next buffers stored within Harpoon list
        utils.mapkey('n', '<C-q>', function()
            harpoon:list():prev()
        end)
        utils.mapkey('n', '<C-e>', function()
            harpoon:list():next()
        end)
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
        end, { desc = 'Open harpoon window' })
    end,
}

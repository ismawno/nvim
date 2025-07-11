return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
        local harpoon = require('harpoon')
        local utils = require('ismawno.utils')
        local root = utils.find_root()
        local pname = utils.find_project_name()

        local files = nil
        harpoon:setup({
            exec = {
                create_list_item = function()
                    local path = vim.fn.input('Path to executable: ', root, 'file')
                    if not path then
                        return nil
                    end

                    local noargs = string.match(path, '%S+')
                    if vim.fn.filereadable(noargs) == 0 then
                        return nil
                    end
                    return { value = path }
                end,

                select = function(item, _, dbg)
                    local trm = utils.get_a_terminal()
                    local exec = item.value

                    if dbg then
                        local path = string.match(exec, '%S+')
                        local args = {}
                        for arg in string.gmatch(exec, '%S+') do
                            if arg ~= path then
                                table.insert(args, arg)
                            end
                        end
                        require('dap').run({
                            type = 'lldb',
                            request = 'launch',
                            name = 'Custom launch',
                            program = path,
                            args = args,
                            justMyCode = false,
                            cwd = root,
                        })
                    else
                        trm:send(exec)
                    end
                end,
            },
            metalist = {
                create_list_item = function()
                    local mlist = harpoon:list('metalist')
                    local length = #mlist.items + 1
                    local name = pname .. '-file-list-' .. length

                    vim.notify('Added new meta-list: ' .. pname)

                    return { value = name }
                end,
                select = function(item)
                    files = harpoon:list(item.value)
                end,
            },
        })

        local mlist = harpoon:list('metalist')
        if #mlist.items == 0 then
            mlist:add()
        end
        mlist:select(1)

        local exec = harpoon:list('exec')
        local exec_index = 1

        utils.mapkey('n', '<leader>x', function()
            exec:select(exec_index)
        end, { desc = 'Run last executable' })

        utils.mapkey('n', '<leader>dx', function()
            exec:select(exec_index, true)
        end, { desc = 'Run last executable with a debugger' })

        for i = 1, 9 do
            local lhs = utils.termcodes('<leader>' .. i .. 'l')
            utils.mapkey('n', lhs, function()
                mlist:select(i)
            end, { desc = 'Select file list ' .. i })

            lhs = utils.termcodes('<leader>' .. i .. 'x')
            utils.mapkey('n', lhs, function()
                exec:select(i)
                exec_index = i
            end, { desc = 'Run executable ' .. i })
        end

        utils.mapkey('n', '<leader>al', function()
            mlist:add()
        end, { desc = 'Add a file list' })

        utils.mapkey('n', '<leader>ax', function()
            exec:add()
        end, { desc = 'Add a project executable' })

        utils.mapkey('n', '<leader>af', function()
            if files then
                files:add()
                vim.notify('File added to current file list')
            end
        end, { desc = 'Add current file to harpoon for the current file list' })

        utils.mapkey('n', '<leader>ml', function()
            harpoon.ui:toggle_quick_menu(mlist, { title = 'Meta-list' })
        end, { desc = 'Open harpoon quick menu for the current file list' })

        utils.mapkey('n', '<leader>mx', function()
            harpoon.ui:toggle_quick_menu(exec, { title = 'Executables' })
        end, { desc = 'Open harpoon quick menu for the current file list' })

        utils.mapkey('n', '<leader>mf', function()
            harpoon.ui:toggle_quick_menu(files, { title = 'Files' })
        end, { desc = 'Open harpoon quick menu for the current file list' })

        utils.mapkey('n', '<leader>H', function()
            mlist:select(1)
        end, { desc = 'Go to first harpoon list for the current meta list' })

        utils.mapkey('n', '<leader>J', function()
            mlist:select(2)
        end, { desc = 'Go to second harpoon list for the current meta list' })

        utils.mapkey('n', '<leader>K', function()
            mlist:select(3)
        end, { desc = 'Go to third harpoon list for the current meta list' })

        utils.mapkey('n', '<leader>L', function()
            mlist:select(4)
        end, { desc = 'Go to fourth harpoon list for the current meta list' })

        utils.mapkey('n', '<leader>h', function()
            if files then
                files:select(1)
            end
        end, { desc = 'Go to first harpoon file for the current file list' })

        utils.mapkey('n', '<leader>j', function()
            if files then
                files:select(2)
            end
        end, { desc = 'Go to second harpoon file for the current file list' })

        utils.mapkey('n', '<leader>k', function()
            if files then
                files:select(3)
            end
        end, { desc = 'Go to third harpoon file for the current file list' })

        utils.mapkey('n', '<leader>l', function()
            if files then
                files:select(4)
            end
        end, { desc = 'Go to fourth harpoon file for the current file list' })

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

        utils.mapkey('n', '<leader>tf', function()
            if files then
                toggle_telescope(files)
            end
        end, { desc = 'Open current harpoon file list with telescope' })
    end,
}

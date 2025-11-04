local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local nvim_path = os.getenv('WNO_NVIM_PATH')
local lockfile = nil
if nvim_path then
    lockfile = nvim_path .. '/lazy-lock.json'
end
require('lazy').setup({
    lockfile = lockfile,
    spec = 'ismawno.lazy',
    change_detection = { notify = false },
    ui = {
        border = 'rounded',
        size = {
            width = 0.8,
            height = 0.8,
        },
    },
})

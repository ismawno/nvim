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

require('lazy').setup({
    lockfile = os.getenv('WNO_NVIM_PATH'),
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

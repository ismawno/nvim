local ffi = require('ffi')

pcall(
    ffi.cdef,
    [[
void *GetConsoleWindow(void);
int IsWindowVisible(void *hwnd);
unsigned int GetDpiForWindow(void *hwnd);
int GetWindowRect(void *hwnd, void *rect);
intptr_t GetWindowLongPtrW(void *hwnd, int index);
intptr_t SetWindowLongPtrW(void *hwnd, int index, intptr_t value);
int SetWindowPos(void *hwnd, void *after, int x, int y, int cx, int cy, unsigned int flags);
int SystemParametersInfoW(unsigned int action, unsigned int param, void *data, unsigned int ini);
void *CreateFileA(const char *name, unsigned long access, unsigned long share, void *security, unsigned long disposition, unsigned long flags, void *template);
int CloseHandle(void *handle);
int GetCurrentConsoleFontEx(void *output, int maximum, void *info);
int SetCurrentConsoleFontEx(void *output, int maximum, void *info);
int MultiByteToWideChar(unsigned int page, unsigned long flags, const char *text, int length, unsigned short *wide, int capacity);
]]
)

local Rect = ffi.typeof('struct { long left; long top; long right; long bottom; }')
local FontInfo = ffi.typeof([[
struct {
    unsigned long cbSize;
    unsigned long nFont;
    struct { short X; short Y; } dwFontSize;
    unsigned int FontFamily;
    unsigned int FontWeight;
    unsigned short FaceName[32];
}
]])

local GWL_STYLE = -16
local WS_CAPTION_AND_THICKFRAME = 0x00C40000
local SPI_GETWORKAREA = 0x0030
local SWP_NOSIZE = 0x0001
local SWP_NOMOVE = 0x0002
local SWP_NOZORDER = 0x0004
local SWP_FRAMECHANGED = 0x0020
local GENERIC_READ_WRITE = 0xC0000000
local FILE_SHARE_READ_WRITE = 0x3
local OPEN_EXISTING = 3
local CP_UTF8 = 65001
local TRUETYPE_FIXED_FAMILY = 54
local FW_NORMAL = 400
local MAX_FACE_LENGTH = 31
local DEFAULT_DPI = 96
local MIN_FONT_HEIGHT = 8
local MAX_FONT_HEIGHT = 72
local VS_ARCH = { x64 = 'amd64', arm64 = 'arm64', x86 = 'x86' }

local M = {}

local saved = nil
local original_font = nil
local configured_height = nil
local dev_shell = nil

local function clamp_height(height)
    return math.max(MIN_FONT_HEIGHT, math.min(MAX_FONT_HEIGHT, height))
end

local function place(console, style, left, top, width, height)
    ffi.C.SetWindowLongPtrW(console, GWL_STYLE, style)
    ffi.C.SetWindowPos(console, nil, 0, 0, 0, 0, bit.bor(SWP_NOMOVE, SWP_NOSIZE, SWP_NOZORDER, SWP_FRAMECHANGED))
    ffi.C.SetWindowPos(console, nil, left, top, 0, 0, bit.bor(SWP_NOSIZE, SWP_NOZORDER))
    ffi.C.SetWindowPos(console, nil, 0, 0, width, height - 1, bit.bor(SWP_NOMOVE, SWP_NOZORDER))
    ffi.C.SetWindowPos(console, nil, 0, 0, width, height, bit.bor(SWP_NOMOVE, SWP_NOZORDER))
end

local function with_console_output(action)
    local output = ffi.C.CreateFileA('CONOUT$', GENERIC_READ_WRITE, FILE_SHARE_READ_WRITE, nil, OPEN_EXISTING, 0, nil)
    if output == nil or ffi.cast('intptr_t', output) == -1 then
        return nil
    end
    local result = action(output)
    ffi.C.CloseHandle(output)
    return result
end

local function read_font()
    return with_console_output(function(output)
        local info = FontInfo()
        info.cbSize = ffi.sizeof(FontInfo)
        if ffi.C.GetCurrentConsoleFontEx(output, 0, info) == 0 then
            return nil
        end
        return info
    end)
end

local function write_font(info)
    return with_console_output(function(output)
        return ffi.C.SetCurrentConsoleFontEx(output, 0, info) ~= 0
    end)
end

local function fill_work_area()
    if not saved then
        return
    end
    local area = Rect()
    if ffi.C.SystemParametersInfoW(SPI_GETWORKAREA, 0, area, 0) == 0 then
        return
    end
    place(
        saved.console,
        bit.band(saved.style, bit.bnot(WS_CAPTION_AND_THICKFRAME)),
        area.left,
        area.top,
        area.right - area.left,
        area.bottom - area.top
    )
end

local function set_font_height(height)
    local info = read_font()
    if not info then
        return
    end
    info.dwFontSize.X = 0
    info.dwFontSize.Y = clamp_height(height)
    if write_font(info) then
        fill_work_area()
    end
end

local function zoom(delta)
    local info = read_font()
    if info then
        set_font_height(info.dwFontSize.Y + delta)
    end
end

local function apply_guifont()
    configured_height = original_font.dwFontSize.Y
    local fields = vim.split(vim.split(vim.o.guifont, ',', { plain = true })[1], ':', { plain = true })
    local face = vim.trim((fields[1]:gsub('\\ ', ' ')))
    if face == '' or face == '*' then
        write_font(original_font)
        return
    end
    local length = ffi.C.MultiByteToWideChar(CP_UTF8, 0, face, #face, nil, 0)
    if length == 0 or length > MAX_FACE_LENGTH then
        vim.notify(string.format('Console font "%s" has an invalid name', face), vim.log.levels.WARN)
        return
    end
    local info = FontInfo(original_font)
    ffi.fill(info.FaceName, ffi.sizeof(info.FaceName))
    ffi.C.MultiByteToWideChar(CP_UTF8, 0, face, #face, info.FaceName, length)
    info.nFont = 0
    info.FontFamily = TRUETYPE_FIXED_FAMILY
    info.FontWeight = FW_NORMAL
    info.dwFontSize.X = 0
    for i = 2, #fields do
        local points = tonumber(fields[i]:match('^h([%d%.]+)$'))
        if points then
            local ok, dpi = pcall(function()
                return ffi.C.GetDpiForWindow(ffi.C.GetConsoleWindow())
            end)
            if not ok or dpi == 0 then
                dpi = DEFAULT_DPI
            end
            info.dwFontSize.Y = clamp_height(math.floor(points * dpi / 72 + 0.5))
        end
    end
    local applied = write_font(info) and read_font() or nil
    local has_face = applied ~= nil
    for i = 0, length do
        has_face = has_face and applied.FaceName[i] == info.FaceName[i]
    end
    if not has_face then
        write_font(original_font)
        vim.notify(string.format('Console font "%s" is not available', face), vim.log.levels.WARN)
        return
    end
    configured_height = applied.dwFontSize.Y
end

local function start()
    local console = ffi.C.GetConsoleWindow()
    local current = Rect()
    if console ~= nil and ffi.C.GetWindowRect(console, current) ~= 0 then
        saved = {
            console = console,
            style = tonumber(ffi.C.GetWindowLongPtrW(console, GWL_STYLE)),
            left = current.left,
            top = current.top,
            width = current.right - current.left,
            height = current.bottom - current.top,
        }
    end
    original_font = read_font()
    if original_font then
        apply_guifont()
    end
    fill_work_area()
end

function M.shell()
    if dev_shell then
        return dev_shell
    end
    dev_shell = 'powershell.exe -NoLogo'
    local program_files = os.getenv('ProgramFiles(x86)')
    if not program_files then
        return dev_shell
    end
    local installer = program_files .. '\\Microsoft Visual Studio\\Installer'
    local vswhere = installer .. '\\vswhere.exe'
    if vim.fn.executable(vswhere) == 0 then
        return dev_shell
    end
    local vs =
        vim.trim(vim.fn.systemlist({ vswhere, '-latest', '-products', '*', '-property', 'installationPath' })[1] or '')
    if vs == '' then
        return dev_shell
    end
    local arch = VS_ARCH[jit.arch] or 'amd64'
    dev_shell = string.format(
        [[powershell.exe -NoExit -Command "& { $env:Path = '%s;' + $env:Path; Import-Module '%s\Common7\Tools\Microsoft.VisualStudio.DevShell.dll'; Enter-VsDevShell -VsInstallPath '%s' -SkipAutomaticLocation -Arch %s -HostArch %s; Set-Location ([Environment]::CurrentDirectory) }"]],
        installer,
        vs,
        vs,
        arch,
        arch
    )
    return dev_shell
end

function M.setup()
    local group = vim.api.nvim_create_augroup('IsmawnoWin32', {})
    vim.api.nvim_create_autocmd('BufEnter', {
        group = group,
        callback = function(e)
            if vim.fs.root(vim.fn.getcwd(), '.git') then
                return
            end
            local path = vim.api.nvim_buf_get_name(e.buf)
            if vim.bo[e.buf].filetype == 'oil' then
                path = require('oil').get_current_dir(e.buf) or ''
            end
            if path == '' or path:find('://') then
                return
            end
            local root = vim.fs.root(path, '.git')
            if root then
                vim.cmd.cd(root)
            end
        end,
    })

    local console = ffi.C.GetConsoleWindow()
    if console == nil or ffi.C.IsWindowVisible(console) == 0 then
        return
    end

    local modes = { 'n', 'i', 'v', 't' }
    for _, lhs in ipairs({ '<M-+>', '<M-ScrollWheelUp>', '<C-ScrollWheelUp>' }) do
        vim.keymap.set(modes, lhs, function()
            zoom(1)
        end, { desc = 'Enlarge the console font' })
    end
    for _, lhs in ipairs({ '<M-->', '<M-ScrollWheelDown>', '<C-ScrollWheelDown>' }) do
        vim.keymap.set(modes, lhs, function()
            zoom(-1)
        end, { desc = 'Shrink the console font' })
    end
    vim.keymap.set(modes, '<M-0>', function()
        if configured_height then
            set_font_height(configured_height)
        end
    end, { desc = 'Reset the console font to guifont' })

    vim.api.nvim_create_autocmd('OptionSet', {
        group = group,
        pattern = 'guifont',
        callback = function()
            if original_font then
                apply_guifont()
                fill_work_area()
            end
        end,
    })
    vim.api.nvim_create_autocmd('VimLeavePre', {
        group = group,
        callback = function()
            if original_font then
                write_font(original_font)
                original_font = nil
            end
            if saved then
                place(saved.console, saved.style, saved.left, saved.top, saved.width, saved.height)
                saved = nil
            end
        end,
    })

    if #vim.api.nvim_list_uis() > 0 then
        vim.schedule(start)
    else
        vim.api.nvim_create_autocmd('UIEnter', {
            group = group,
            once = true,
            callback = function()
                vim.schedule(start)
            end,
        })
    end
end

return M

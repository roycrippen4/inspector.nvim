local util = require('inspector.util')

local M = {}

local win = nil
local width = 34
local uses_mousemoveevent = vim.o.mousemoveevent
local buf = vim.api.nvim_create_buf(false, true)
vim.bo[buf].ft = 'inspector'

local function update_float()
  vim.schedule(function()
    --- Early exit if no window, the winid is 0, or the window is invalid
    if not win or win == 0 or not vim.api.nvim_win_is_valid(win) then
      return
    end

    local pos = vim.fn.getmousepos()
    local info = util.format_inspect_info(vim.inspect_pos(vim.api.nvim_win_get_buf(pos.winid), pos.line - 1, pos.column - 1))

    if #info == 0 and vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1] ~= ' No information found ' then
      width = 22
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { ' No information found ' })
      vim.api.nvim_win_set_height(win, 1)
      vim.api.nvim_win_set_width(win, width)
      return
    end

    if #info > 0 then
      util.put_lines_in_buf(buf, info)
      width = util.find_max_width(buf)
      vim.api.nvim_win_set_height(win, #info - 2)
      vim.api.nvim_win_set_width(win, width)
    end

    local row, col = pos.screenrow, pos.screencol
    if vim.o.lines - row <= 4 then
      row = row - 4
    end

    if vim.o.columns - col - width <= 0 then
      col = col - width - 2
    end

    vim.api.nvim_win_set_config(win, { relative = 'editor', row = row, col = col })
  end)

  return '<MouseMove>'
end

function M.inspect_in_float()
  if not vim.o.mousemoveevent then
    vim.o.mousemoveevent = true
  end

  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    width = 22,
    height = 1,
    row = 1,
    col = 1,
    style = 'minimal',
    focusable = false,
    border = 'rounded',
    zindex = 1000,
  })
  vim.api.nvim_set_option_value('winblend', 0, { win = win })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { ' No information found ' })
  vim.api.nvim_win_set_buf(win, buf)

  if vim.api.nvim_get_current_win() == win then
    vim.api.nvim_set_current_win(current_win)
  end
end

vim.keymap.set({ '', 'i' }, '<MouseMove>', update_float, { expr = true })

vim.api.nvim_create_autocmd('WinClosed', {
  pattern = 'inspector',
  callback = function()
    win = nil
    vim.o.mousemoveevent = uses_mousemoveevent
  end,
})

return M

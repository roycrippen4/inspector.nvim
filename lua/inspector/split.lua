local util = require('inspector.util')

local M = {}
local buf = vim.api.nvim_create_buf(false, true)
vim.bo[buf].ft = 'inspector'

function M.inspect_in_split()
  local pos = vim.api.nvim_win_get_cursor(0)
  local info = util.format_inspect_info(vim.inspect_pos(0, pos[1] - 1, pos[2]))

  if #info == 0 then
    vim.notify('No information found', vim.log.levels.WARN)
    return
  end

  util.put_lines_in_buf(buf, info)
  vim.cmd('botright split')
  vim.cmd('set nonumber')
  vim.cmd('set norelativenumber')
  vim.api.nvim_win_set_buf(0, buf)
  vim.api.nvim_win_set_height(0, #info)
  vim.api.nvim_set_option_value('foldcolumn', '0', { win = 0 })
  local quit = '<cmd>q<cr><c-w>l'

  vim.keymap.set('n', 'q', quit, { buffer = buf })
  vim.api.nvim_buf_set_extmark(buf, util.ns, #info - 1, 0, {
    virt_text = { { 'q', '@keyword' }, { ' - Exit the window' } },
  })
end

return M

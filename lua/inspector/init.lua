local float = require('inspector.float')
local split = require('inspector.split')

local M = {}

M.inspect_in_split = split.inspect_in_split
M.inspect_in_float = float.inspect_in_float

vim.api.nvim_create_user_command('InspectFloat', float.inspect_in_float, { desc = ':Inspect, but in a float that follows the mouse' })
vim.api.nvim_create_user_command('InspectSplit', split.inspect_in_split, { desc = 'Improved `:Inspect` command' })

function M.setup() end

return M

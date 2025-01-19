local float = require('inspector.float')
local split = require('inspector.split')

local M = {}

M.inspect_in_split = split.inspect_in_split
M.inspect_in_float = float.inspect_in_float

function M.setup() end

return M

-- require('which-key').add({
--   {
--     mode = 'n',
--     { '<leader>iw', inspect_in_split, desc = '[I]nspect word', icon = '' },
--     { '<leader>if', inspect_in_float, desc = '[I]nspect in float', icon = '' },
--   },
-- })


---@class InspectionTableOpts
---@field end_col integer
---@field end_right_gravity boolean
---@field end_row integer
---@field hl_eol boolean
---@field hl_group string
---@field hl_group_link string
---@field ns_id integer
---@field priority integer
---@field right_gravity boolean

---@class TreesitterTable
---@field capture string
---@field hl_group string
---@field hl_group_link string
---@field lang string
---@field metadata table

---@class LspExtTable
---@field col integer
---@field end_col integer
---@field end_row integer
---@field id integer
---@field ns string
---@field ns_id integer
---@field opts InspectionTableOpts
---@field row integer

---@class InspectInfo
---@field buffer integer
---@field col integer
---@field extmarks LspExtTable[]
---@field row integer
---@field semantic_tokens LspExtTable[]
---@field syntax SyntaxTable[]
---@field treesitter TreesitterTable[]

---@class SyntaxTable
---@field hl_group string
---@field hl_group_link string

---@class FormattedLinePart
---@field text string The text to display
---@field col_start integer The start column. Used for highlighting
---@field col_end integer The start column. Used for highlighting
---@field hl_group string The highlight group to use

---@alias FormattedLine FormattedLinePart[]

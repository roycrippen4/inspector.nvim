local M = {}

M.ns = vim.api.nvim_create_namespace('inspect_word')

---@param buf integer
---@param info FormattedLine[]
function M.put_lines_in_buf(buf, info)
  if #info == 0 then
    return
  end

  ---@param acc string
  ---@param part FormattedLinePart
  local concatenate = function(acc, part)
    return acc .. part.text
  end

  ---@param idx integer
  ---@param parts FormattedLine
  local insert_lines = function(idx, parts)
    local it = vim.iter(parts)
    vim.api.nvim_buf_set_lines(buf, idx - 1, idx, false, { it:fold('', concatenate) })

    it:each(
      ---@param part FormattedLinePart
      function(part)
        vim.api.nvim_buf_set_extmark(buf, M.ns, idx - 1, part.col_start, {
          end_row = idx - 1,
          end_col = part.col_end + 1,
          hl_group = part.hl_group,
          strict = false,
        })
      end
    )
  end

  vim.iter(ipairs(info)):each(insert_lines)
end

---@param inspect_info InspectInfo
---@return FormattedLine[]
function M.format_inspect_info(inspect_info)
  ---@type FormattedLine[]
  local result = {}
  local idx = 1
  local has_ts = #vim.tbl_keys(inspect_info.treesitter) and #inspect_info.treesitter > 0 or false
  local has_lsp = #vim.tbl_keys(inspect_info.semantic_tokens) and #inspect_info.semantic_tokens > 0 or false
  local has_extmarks = #vim.tbl_keys(inspect_info.extmarks) and #inspect_info.extmarks > 0 or false
  local has_syntax = #vim.tbl_keys(inspect_info.syntax) and #inspect_info.syntax > 0 or false

  ---@param ... FormattedLinePart
  local function insert(...)
    local parts = { ... }
    result[idx] = result[idx] or {}

    for _, part in ipairs(parts) do
      table.insert(result[idx], part)
    end
  end

  local function newline()
    table.insert(result, {})
    idx = idx + 1
  end

  if has_ts then
    insert({ text = 'Treesitter', col_start = 0, col_end = 9, hl_group = '@function.call.lua' })
    vim.iter(inspect_info.treesitter):each(function(entry) ---@param entry TreesitterTable
      newline()
      local hl_group = {
        text = '  - ' .. entry.hl_group,
        col_start = 4,
        col_end = #entry.hl_group + 4,
        hl_group = entry.hl_group,
      }
      local links_to = {
        text = ' links to ',
        col_start = hl_group.col_end,
        col_end = hl_group.col_end + #' links to ',
        hl_group = '@function.call.lua',
      }
      local hl_link = {
        text = entry.hl_group_link,
        col_start = links_to.col_end,
        col_end = #entry.hl_group_link + links_to.col_end,
        hl_group = entry.hl_group_link,
      }
      local lang = {
        text = ' ' .. entry.lang,
        col_start = hl_link.col_end,
        col_end = #entry.lang + hl_link.col_end,
        hl_group = '@comment',
      }
      insert(hl_group, links_to, hl_link, lang)
    end)
    newline()
  end

  if has_lsp then
    if has_ts then
      newline()
    end
    insert({ text = 'Semantic Tokens', col_start = 0, col_end = 15, hl_group = '@function.lua' })
    vim.iter(inspect_info.semantic_tokens):each(function(entry) ---@param entry LspExtTable
      newline()
      local hl_group = {
        text = '  - ' .. entry.opts.hl_group,
        col_start = 4,
        col_end = #entry.opts.hl_group + 4,
        hl_group = entry.opts.hl_group,
      }
      local links_to = {
        text = ' links to ',
        col_start = hl_group.col_end,
        col_end = hl_group.col_end + #' links to ',
        hl_group = '@function.call.lua',
      }
      local hl_link = {
        text = entry.opts.hl_group_link,
        col_start = links_to.col_end,
        col_end = #entry.opts.hl_group_link + links_to.col_end,
        hl_group = entry.opts.hl_group_link,
      }
      local priority_str = ' priority: ' .. entry.opts.priority
      local priority = {
        text = priority_str,
        col_start = hl_link.col_end,
        col_end = #priority_str + hl_link.col_end,
        hl_group = '@comment',
      }
      insert(hl_group, links_to, hl_link, priority)
    end)
    newline()
  end

  if has_extmarks then
    if has_ts or has_lsp then
      newline()
    end
    insert({ text = 'Extmarks', col_start = 0, col_end = 8, hl_group = '@function.lua' })
    vim.iter(inspect_info.extmarks):each(function(entry) ---@param entry LspExtTable
      newline()
      insert({
        text = '  - ' .. entry.opts.hl_group,
        col_start = 4,
        col_end = #entry.opts.hl_group + 4,
        hl_group = entry.opts.hl_group,
      })
      if #entry.ns ~= 0 then
        insert({
          text = ' ' .. entry.ns,
          col_start = #entry.opts.hl_group + 4,
          col_end = #entry.opts.hl_group + 4 + #entry.ns,
          hl_group = '@comment',
        })
      end
    end)
    newline()
  end

  if has_syntax then
    if has_ts or has_lsp or has_extmarks then
      newline()
    end
    insert({ text = 'Syntax', col_start = 0, col_end = 6, hl_group = '@function.lua' })
    vim.iter(inspect_info.syntax):each(function(entry) --- @param entry SyntaxTable
      newline()
      local hl_group = {
        text = '  - ' .. entry.hl_group,
        col_start = 4,
        col_end = #entry.hl_group + 4,
        hl_group = entry.hl_group,
      }
      local links_to = {
        text = ' links to ',
        col_start = hl_group.col_end,
        col_end = hl_group.col_end + #' links to ',
        hl_group = '@function.call.lua',
      }
      local hl_link = {
        text = entry.hl_group_link,
        col_start = links_to.col_end,
        col_end = #entry.hl_group_link + links_to.col_end,
        hl_group = entry.hl_group_link,
      }
      insert(hl_group, links_to, hl_link)
    end)
    newline()
  end

  if #result > 0 then
    newline()
  end

  return result
end

---@param buf integer
---@return integer
function M.find_max_width(buf)
  local longest = 0

  ---@param line string
  local function compare_and_set(line)
    if #line > longest then
      longest = #line
    end
  end

  vim.iter(vim.api.nvim_buf_get_lines(buf, 0, -1, false)):each(compare_and_set)

  return longest
end

return M

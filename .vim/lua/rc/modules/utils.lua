local M = {}

function M.list_concat(arys)
  local tbl = {}
  for _, ary in ipairs(arys) do
    vim.list_extend(tbl, ary)
  end
  return tbl
end

-- Usage:
--   local variable = 'var'
--   let('g:foo.bar', variable)
function M.let(path, obj)
  vim.g['LuaTemp'] = obj
  vim.cmd(([[
    if exists('g:LuaTemp')
      let %s = g:LuaTemp
      unlet g:LuaTemp
    else
      silent! unlet %s
    endif
  ]]):format(path, path))
end

function M.merge(base, extend)
  local merged = {}
  for k, v in pairs(base) do
    merged[k] = v
  end
  for k, v in pairs(extend) do
    merged[k] = v
  end
  return merged
end

function M.dedent(text)
  local lines = {}
  for line in text:gmatch('([^\n]*)\n?') do
    table.insert(lines, line)
  end
  if #lines == 0 then
    return text
  end
  local min_indent = math.huge
  for _, line in ipairs(lines) do
    if not line:match("^%s*$") then
      local indent = line:match('^(%s*)') or ''
      local indent_count = #indent
      if indent_count < min_indent then
        min_indent = indent_count
      end
    end
  end
  if min_indent == math.huge then
    min_indent = 0
  end
  for i, line in ipairs(lines) do
    if line:match("^%s*$") then
      lines[i] = ""
    else
      lines[i] = line:sub(min_indent + 1)
    end
  end
  return table.concat(lines, '\n')
end

return M

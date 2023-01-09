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

return M

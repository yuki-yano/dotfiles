local M = {}

function M.is_editprompt()
  return vim.env.EDITPROMPT == '1' or vim.g.editprompt == 1
end

function M.is_quick_ime()
  return false
end

function M.is_ime()
  return M.is_editprompt() or M.is_quick_ime()
end

return M

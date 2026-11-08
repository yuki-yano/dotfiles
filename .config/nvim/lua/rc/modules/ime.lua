local M = {}

--- vde-term の ⌘I（`vte prompt open`）で開いた editor
function M.is_vte_prompt()
  return vim.env.VDE_TERM ~= nil and vim.env.VDE_PROMPT_TARGET ~= nil
end

function M.is_editprompt()
  return vim.env.EDITPROMPT == '1' or vim.g.editprompt == 1 or M.is_vte_prompt()
end

function M.is_quick_ime()
  return false
end

function M.is_ime()
  return M.is_editprompt() or M.is_quick_ime()
end

return M

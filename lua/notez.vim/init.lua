-- nvim_create_user_command- Title: Notez
-- Description: Managing notes
-- Last Change: now
-- Maintainer: mshiltonj@gmail.com




local M = {}


function M.setup()
  print("setup called")
  vim.api.nvim_create_user_command("Notez", function()
    print("notez called")
    Notez()
  end, {})
end


return M

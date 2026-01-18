local function sync_notez_markdown()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal"})
  local todo = vim.api.nvim_get_hl(0, { name = "Todo", link = false })
  -- print("todo.bg ", todo.bg)
  -- print("normal.bg ", normal.bg)

  local todo_tag_hl = {}
  todo_tag_hl.bg = todo.bg or normal.bg
  todo_tag_hl.fg = todo.fg or normal.fg

  todo_tag_hl.ctermfg = todo.ctermbg and todo.ctermbg or normal.ctermbg
  todo_tag_hl.ctermbg = todo.ctermfg and todo.ctermfg or normal.ctermfg

  -- print("todo_tag.fg ", todo_tag_hl.fg)

  -- print("todo.fg ", todo.fg)
  vim.api.nvim_set_hl(0, "MarkdownTag", todo_tag_hl)

  -- now do Special => MarkdownProject
  local normal = vim.api.nvim_get_hl(0, { name = "Normal"})
  local special = vim.api.nvim_get_hl(0, { name = "Special", link = false })
  -- print("special.bg ", special.bg)
  -- print("normal.bg ", normal.bg)

  local project_tag_hl = {}
  project_tag_hl.fg = special.bg or normal.bg
  project_tag_hl.bg = special.fg or normal.fg

  project_tag_hl.ctermfg = special.ctermbg and special.ctermbg or normal.ctermbg
  project_tag_hl.ctermbg = special.ctermfg and special.ctermfg or normal.ctermfg

  -- print("project_tag.fg ", project_tag_hl.fg)
  -- print("special.fg ", special.fg)
  vim.api.nvim_set_hl(0, "MarkdownProject", project_tag_hl)
end

-- TODO: maybe have autocmds to add/remove this color coding so it only
-- applys for "notez-specific" markdown files?
vim.api.nvim_create_autocmd("ColorScheme", { callback = sync_notez_markdown })
sync_notez_markdown()



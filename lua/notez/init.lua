-- nvim_create_user_command- Title: Notez
-- Description: Managing notes
-- Last Change: now
-- Maintainer: mshiltonj@gmail.com



-- Daily Note
-- Weekly Note
-- Meeting Note
-- Project Note
local modpath = (...)


local function get_time(offset)
  offset = offset or 0
  local theTime = os.time()
  theTime = theTime + offset
  return theTime
end


local delim = package.config:sub(1,1)

local M = {
  template_dir = delim .. "_templates",
	opts = {
	  notez_directory = vim.fn.getcwd(),
    week_starts_on = 1
	}
}

function M.token_replacement(text, token, value)
  local token_format = "{{" .. token .. "}}"
  text = string.gsub(text, token_format, value)
  return text
end


-- we have a small number of date-base tokens
function M.render_template(template_text, time_to_use)
  local tokens = {
    CURRENT_YEAR = os.date("%Y", time_to_use),
    CURRENT_MONTH = os.date("%m", time_to_use),
    CURRENT_DAY = os.date("%d", time_to_use),
    CURRENT_MINUTE = os.date("%M", time_to_use),
    CURRENT_HOUR = os.date("%H", time_to_use),
    CURRENT_SECOND = os.date("%S", time_to_use),
    CURRENT_DAY_OF_WEEK = os.date("%A", time_to_use),
    CURRENT_DAY_OF_WEEK_SHORT = os.date("%a", time_to_use),
    CURRENT_MONTH_NAME = os.date("%B", time_to_use),
    CURRENT_MONTH_NAME_SHORT = os.date("%b", time_to_use)
  }

  for token_key, token_value in pairs(tokens) do
    template_text = M.token_replacement(template_text, token_key, token_value)
  end

  return template_text
end

function M.template_path_with_file(template_type)
  return "_templates" .. delim .. template_type .. "_note.tmpl"
end


function M.open_template_file(template_type)
  local template_path_with_file = M.template_path_with_file(template_type)

  -- user can define their own, check there first

  local f = io.open(M.notez_home .. template_path_with_file , 'r')


  if f == nil then
    -- fall back to the default plugin template
    -- print(M.plugin_home  )
    -- print(M.plugin_home .. template_path_with_file )
    f = io.open(M.plugin_home .. template_path_with_file , 'r')
  end

  if f == nil then
    -- no template found! WAT
    print("ERROR: " .. template_type .. " template could not be loaded")

    return nil
  end

  return f
end

function M.load_template_text(template_type)
  local f = M.open_template_file(template_type)
  
  if f == nil then
    return ""
  end

  local template_text = ""

  template_text = template_text .. f:read("*all")

  io.close(f)

  return template_text
end

-- print(os.date("%Y/%m/%d", theTime))




-- list of commands
-- ex:
--  :Notez today

local function Notez(opts)
  local cmd = opts.fargs[1]

  if cmd == nil then
    cmd = "today"
  end

  local command_table = {
    today = M.todayNote,
    yesterday = M.yesterdayNote,
    tomorrow = M.tomorrowNote,
    week = M.weeklyNote,
    lastWeek = M.lastWeeklyNote,
    nextWeek = M.nextWeeklyNote,
    inbox = M.inboxNote,
    todo = M.todoNote,
    config = M.config,
    tokens = M.tokensTest
  }

  if command_table[cmd] then
    command_table[cmd]()
  end
end


function M.config()
  print("modpath: ", modpath)
end

function M.ensureDatePath(path_part)
 local full_date_path = M.notez_home .. delim .. "daily" .. delim .. path_part
 vim.fn.mkdir(full_date_path, 'p')
 return full_date_path
end


function M.dayNote(the_time)
  local full_date_path = M.ensureDatePath(os.date("%Y/%m", the_time))

  local day = os.date("%d", the_time)
  local full_file_path = full_date_path .. delim .. day .. ".md"
  vim.cmd.edit(full_file_path)

  local current_buffer = vim.api.nvim_get_current_buf()


  local buf_lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)


  local is_empty_file = true
  if #buf_lines == 1 then
    local only_line = ""
    if buf_lines[0] == nil then
      only_line =  buf_lines[1]
    else
      only_line =  buf_lines[0]
    end
    if string.len(only_line) > 0 then
      is_empty_file = false
    end
  elseif #buf_lines > 1 then
    is_empty_file = false
  end



  if is_empty_file then
    local template_text = M.load_template_text("daily")
    local new_note_text = M.render_template(template_text, the_time)
    new_note_text_lines = vim.split(new_note_text, "\n")
    vim.api.nvim_buf_set_lines(current_buffer, 0, -1,true, new_note_text_lines)
  end
end

function M.token_test()
    local template_text = M.load_template_text("tokens/{{CURRENT_MONTH}}/{{CURRENT_DAY}}")
end

function M.todayNote()
  local the_time = get_time()
  M.dayNote(the_time)
end

function M.yesterdayNote()
  local the_time = get_time() - 86400
  M.dayNote(the_time)
end

function M.tomorrowNote()
  local the_time = get_time() + 86400
  M.dayNote(the_time)
end




function M.setup(opts)
  opts = opts or {}
  M.notez_home = opts.notez_home or vim.env.HOME .. delim .. "Notez"
  M.plugin_home = debug.getinfo(1).source:match("@?(.*" .. delim .. ")")
  vim.api.nvim_create_user_command("Notez", Notez, {nargs = "?"})
end

M.setup()


return M

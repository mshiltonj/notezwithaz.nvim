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
function M.render_template(template_text, time_to_use, title)
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
    CURRENT_MONTH_NAME_SHORT = os.date("%b", time_to_use),
    TITLE = title
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
    -- no template found!
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

local static_note_types = { "project", "area", "resource", "list" }

local function Notez(opts)
  local notez_cmd = opts.fargs[1]

  if notez_cmd == nil then
    notez_cmd = "today"
  end

  local notez_cmd_ary = vim.split(notez_cmd, " ")
  local cmd = notez_cmd_ary[1]

  local command_table = {
    help = M.help,

    today = M.today_note,
    yesterday = M.yesterday_note,
    tomorrow = M.tomorrow_note,

    weekly_review = M.this_week_review_note,
    last_weekly_review = M.last_week_review_note,
    next_weekly_review = M.next_week_review_note,

    weekly_plan = M.this_week_plan_note,
    last_weekly_plan = M.last_week_plan_note,
    next_weekly_plan = M.next_week_plan_note,

    meeting = M.meeting_note,

    inbox = M.inbox_note,
    todo = M.todo_note,

    project = M.project_note,
    area = M.area_note,
    resource = M.resource_note,
    list = M.list_note,

    config = M.config,
    tokens = M.tokensTest
  }

  local rest_of_command = ""

  local idx = 0

  for key, value in pairs(notez_cmd_ary) do
    if idx ~= 0 then
      if rest_of_command ~= "" then
        rest_of_command = rest_of_command .. " "
      end
      rest_of_command = rest_of_command .. value
    end
    idx = idx + 1
  end

  if command_table[cmd] then
    if static_note_types[cmd] ~= nil then
      if notez_target == nil then
        print(cmd .. ' requires a target. Ex: ":Notes project project_name"')
        return
      else
        command_table[cmd](notez_target)
      end
    else
      if cmd == "meeting" then
        command_table[cmd](rest_of_command)
      else
        command_table[cmd]()
      end
    end
  end
end

function M.meeting_note(meeting)
  if meeting == nil then
    meeting = os.date("%H-%M")
  end

  -- TODO: Unicode characters?
  local fs_meeting = string.gsub(meeting, "(%s+)", "-")
  fs_meeting = string.gsub(fs_meeting, "[^A-z0-9-]", "")
  fs_meeting = string.lower(fs_meeting)

  local the_time = get_time()
  local note_path = M.ensure_date_path("meeting", the_time)
  local full_meeting_note_path = note_path .. delim .. "meeting-" .. fs_meeting .. ".md"

  M.display_note("meeting", full_meeting_note_path, the_time, meeting)
end

function M.project_note(project)
  local full_project_note_path = M.notez_home .. delim .. "projects" .. delim .. project .. ".md"
  M.display_note("project", full_project_note_path)
end

function M.area_note(area)
  local full_area_note_path = M.notez_home .. delim .. "areas" .. delim .. area .. ".md"
  M.display_note("areas", full_area_note_path)
end

function M.resource_note(resource)
  local full_resource_note_path = M.notez_home .. delim .. "resources" .. delim .. resource .. ".md"
  M.display_note("resources", full_resource_note_path)
end

function M.list_note(list)
  local full_list_note_path = M.notez_home .. delim .. "lists" .. delim .. list .. ".md"
  M.display_note("list", full_list_note_path)
end

function M.todo_note()
  local full_todo_path = M.notez_home .. delim .."TODO.md"
  M.display_note("todo", full_todo_path)
end

function M.inbox_note()
  local full_todo_path = M.notez_home .. delim .."INBOX.md"
  M.display_note("inbox", full_todo_path)
end

function M.config()
  print("modpath: ", modpath)
end

function M.ensure_date_path(note_type, the_time)
 local year = os.date("%Y", the_time)
 local month = os.date("%m", the_time)
 local path_part = year .. delim .. month

 local full_date_path = M.notez_home .. delim .. note_type .. delim .. path_part
 vim.fn.mkdir(full_date_path, 'p')
 return full_date_path
end

function M.display_note(note_type, note_path, the_time, title)
  vim.cmd.edit(note_path)
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
    local template_text = M.load_template_text(note_type)
    local new_note_text = M.render_template(template_text, the_time, title)
    new_note_text_lines = vim.split(new_note_text, "\n")
    vim.api.nvim_buf_set_lines(current_buffer, 0, -1,true, new_note_text_lines)
  end
end

function M.display_date_based_note(note_type, the_time)
  local full_date_path = M.ensure_date_path(note_type, the_time)
  local day = os.date("%d", the_time)
  local full_file_path = full_date_path .. delim .. day .. ".md"
  M.display_note(note_type, full_file_path, the_time)
end

function M.weekNote()
  local full_week_path = M.ensure_week_path(os.date("%Y/%m", the_time))
end

function M.ensure_weekly_review_date_path(the_time)
  return M.ensure_date_path("weekly_reivew", os.date("%Y/%m", the_time))
end

function M.day_note(the_time)
  M.display_date_based_note("daily", the_time)

  -- local full_file_path = full_date_path .. delim .. day .. ".md"
  -- vim.cmd.edit(full_file_path)
  -- local current_buffer = vim.api.nvim_get_current_buf()
  -- local buf_lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
  --
  -- local is_empty_file = true
  -- if #buf_lines == 1 then
  --   local only_line = ""
  --   if buf_lines[0] == nil then
  --     only_line =  buf_lines[1]
  --   else
  --     only_line =  buf_lines[0]
  --   end
  --   if string.len(only_line) > 0 then
  --     is_empty_file = false
  --   end
  -- elseif #buf_lines > 1 then
  --   is_empty_file = false
  -- end
  --
  --
  -- if is_empty_file then
  --   local template_text = M.load_template_text("daily")
  --   local new_note_text = M.render_template(template_text, the_time)
  --   new_note_text_lines = vim.split(new_note_text, "\n")
  --   vim.api.nvim_buf_set_lines(current_buffer, 0, -1,true, new_note_text_lines)
  -- end
end

function M.token_test()
    local template_text = M.load_template_text("tokens/{{CURRENT_MONTH}}/{{CURRENT_DAY}}")
end

function M.this_week_plan_note()
  local the_time = get_time()
  M.week_plan_note(the_time)
end


function M.this_week_review_note()
  local the_time = get_time()
  M.week_review_note(the_time)
end

function M.last_week_review_note()
  local the_time = get_time() - (86400 * 7)
  M.week_review_note(the_time)
end

function M.next_week_review_note()
  local the_time = get_time() + (86400 * 7)

  M.week_review_note(the_time)
end


function M.today_note()
  local the_time = get_time()
  M.day_note(the_time)
end

function M.yesterday_note()
  local the_time = get_time() - 86400
  M.day_note(the_time)
end

function M.tomorrow_note()
  local the_time = get_time() + 86400
  M.day_note(the_time)
end

function M.week_review_note(the_time)
  monday_time = M.get_time_on_monday(the_time)
  M.display_date_based_note("weekly_review", the_time)
end

function M.week_plan_note(the_time)
  monday_time = M.get_time_on_monday(the_time)
  M.display_date_based_note("weekly_plan", monday_time)
end

function M.get_time_on_monday(the_time)
  day_of_week = tonumber(os.date("%w", the_time))
  the_time = the_time - ( (6 - (6 - day_of_week )) * 86400)
  return the_time
end


function M.setup(opts)
  opts = opts or {}
  M.notez_home = opts.notez_home or vim.env.HOME .. delim .. "Notez"
  M.plugin_home = debug.getinfo(1).source:match("@?(.*" .. delim .. ")")
  vim.api.nvim_create_user_command("Notez", Notez, {nargs = "?"})
end

M.setup()


return M

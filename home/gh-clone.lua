local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local function start_spinner(msg)
  local idx = 1
  local timer = vim.loop.new_timer()
  timer:start(0, 100, vim.schedule_wrap(function()
    vim.api.nvim_echo({{ spinner_frames[idx] .. " " .. msg, "DiagnosticInfo" }}, false, {})
    idx = (idx % #spinner_frames) + 1
  end))
  return timer
end

local function stop_spinner(timer)
  if timer and not timer:is_closing() then
    timer:stop()
    timer:close()
    vim.api.nvim_echo({{"", "Normal"}}, false, {})
  end
end

local function open_project(dest)
  vim.cmd("cd " .. vim.fn.fnameescape(dest))
  require("telescope.builtin").find_files({ cwd = dest })
end

local function open_picker(org, cache_file, base_dir)
  local repos = {}
  for line in io.lines(cache_file) do
    table.insert(repos, line)
  end

  pickers.new({}, {
    prompt_title = "Clone from " .. org,
    finder = finders.new_table({ results = repos }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selections = {}
        for _, sel in ipairs(action_state.get_current_picker(prompt_bufnr):get_multi_selection()) do
          table.insert(selections, sel.value)
        end
        if #selections == 0 then
          table.insert(selections, action_state.get_selected_entry().value)
        end
        actions.close(prompt_bufnr)

        for _, repo in ipairs(selections) do
          local name = repo:match("([^/]+)$")
          local dest = base_dir .. "/" .. name

          if vim.loop.fs_stat(dest) then
            vim.notify("  skip  " .. repo .. " (already exists)", vim.log.levels.WARN)
            open_project(dest)
          else
            local clone_spinner = start_spinner("Cloning " .. repo .. "...")
            vim.fn.jobstart({ "gh", "repo", "clone", repo, dest }, {
              on_exit = function(_, code)
                vim.schedule(function()
                  stop_spinner(clone_spinner)
                  if code == 0 then
                    vim.notify("Cloned " .. repo, vim.log.levels.INFO)
                    open_project(dest)
                  else
                    vim.notify("Failed to clone " .. repo, vim.log.levels.ERROR)
                  end
                end)
              end,
            })
          end
        end
      end)
      return true
    end,
  }):find()
end

local function gh_clone(org)
  local cache_dir = (os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")) .. "/gh-clone"
  local cache_file = cache_dir .. "/" .. org .. ".txt"
  local base_dir = os.getenv("HOME") .. "/src/github.com/" .. org
  local ttl = 604800

  vim.fn.mkdir(cache_dir, "p")
  vim.fn.mkdir(base_dir, "p")

  local stat = vim.loop.fs_stat(cache_file)
  local now = os.time()
  local is_stale = not stat or (now - stat.mtime.sec) >= ttl

  if is_stale then
    local fetch_spinner = start_spinner("Fetching repos for " .. org .. "...")
    vim.fn.jobstart(
      { "gh", "repo", "list", org, "--limit", "10000", "--json", "nameWithOwner", "-q", ".[].nameWithOwner" },
      {
        stdout_buffered = true,
        on_stdout = function(_, data)
          local f = io.open(cache_file, "w")
          if f then
            for _, line in ipairs(data) do
              if line ~= "" then f:write(line .. "\n") end
            end
            f:close()
          end
        end,
        on_exit = function(_, code)
          vim.schedule(function()
            stop_spinner(fetch_spinner)
            if code == 0 then
              open_picker(org, cache_file, base_dir)
            else
              vim.notify("gh repo list failed", vim.log.levels.ERROR)
            end
          end)
        end,
      }
    )
  else
    open_picker(org, cache_file, base_dir)
  end
end

vim.api.nvim_create_user_command("GhClone", function(opts)
  gh_clone(opts.args)
end, { nargs = 1 })

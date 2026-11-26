-- Run: lua ~/.config/hypr/shared-workspaces.test.lua [module-to-test]
-- Uses fake monitors/dispatchers and temporary state; never touches the desktop.
local source = debug.getinfo(1, "S").source:sub(2)
local module_path = arg[1] or source:gsub("shared%-workspaces%.test%.lua$", "shared-workspaces.lua")
local state_home = os.tmpname()
os.remove(state_home)
local function quote(value) return "'" .. value:gsub("'", "'\\''") .. "'" end
assert(os.execute("mkdir -p " .. quote(state_home .. "/omarchy")))
local state_file = assert(io.open(state_home .. "/omarchy/monitor-workspaces", "w"))
state_file:write("0\tDP-1\tExternal monitor\n2\teDP-1\tLaptop panel\n")
state_file:close()
package.loaded["default.hypr.paths"] = { state_home = state_home }

local laptop = { name = "eDP-1", id = 0, description = "Laptop panel", focused = true }
local external = { name = "DP-1", id = 1, description = "External monitor" }
local monitors = { laptop }
local active_monitor = laptop
local workspaces = {
  { id = 1, name = "1", monitor = laptop, windows = 2 },
  { id = 2, name = "2", monitor = laptop, windows = 1 },
}
local dispatched, hooks = {}, {}
local function command(kind)
  return function(args) return { kind = kind, args = args } end
end
hl = {
  dsp = {
    focus = command("focus"),
    workspace = { move = command("move_workspace") },
    window = { move = command("move_window") },
  },
  on = function(name, callback) hooks[name] = callback end,
  get_monitors = function() return monitors end,
  get_workspaces = function() return workspaces end,
  get_active_monitor = function() return active_monitor end,
  get_monitor = function(name)
    for _, monitor in ipairs(monitors) do
      if monitor.name == name or (name == "r" and monitor == external) then return monitor end
    end
  end,
  get_workspace = function(id)
    for _, workspace in ipairs(workspaces) do if workspace.id == id then return workspace end end
  end,
  get_active_window = function() return { address = "terminal-fixture" } end,
  dispatch = function(action)
    if type(action) == "function" then action() else dispatched[#dispatched + 1] = action end
  end,
}
o = { bind_expressions = {}, shell_quote = quote }

local function check(condition, description)
  assert(condition, "Shared workspaces regression: " .. description)
  print("PASS " .. description)
end
local function last_command() return dispatched[#dispatched] end
local function run()
  local shared = dofile(module_path)
  check(shared.workspace_id(laptop, 1) == 1, "laptop workspace 1 stays 1, not 21")
  check(shared.workspace_id(laptop, 2) == 2, "laptop workspace 2 stays 2, not 22")
  check(shared.workspace_id(external, 1) == 1, "external display uses the same workspace IDs")
  check(next(hooks) == nil, "no monitor-change callbacks can renumber workspaces")

  hl.dispatch(shared.focus(2))
  check(last_command().kind == "focus" and last_command().args.workspace == "2", "focus uses shared workspace 2")
  hl.dispatch(shared.move_window(1, false))
  check(last_command().kind == "move_window" and last_command().args.workspace == "1"
    and last_command().args.follow == false, "silent window move keeps shared workspace 1")
  hl.dispatch(shared.move_window(2))
  check(last_command().args.follow == true, "normal window move follows the destination")

  monitors, active_monitor = { external }, external
  shared.reconcile()
  check(workspaces[1].id == 1 and workspaces[2].id == 2, "docking never renumbers the shared desktop")
  monitors, active_monitor = { laptop }, laptop
  shared.reconcile()
  check(workspaces[1].id == 1 and workspaces[2].id == 2, "undocking never renumbers the shared desktop")
  local before = #dispatched
  hl.dispatch(shared.move_to_monitor("r"))
  check(#dispatched == before, "moving toward an absent monitor is a no-op")

  monitors = { laptop, external }
  hl.dispatch(shared.move_to_monitor("r"))
  check(last_command().kind == "move_workspace" and last_command().args.monitor == "DP-1",
    "explicit monitor moves preserve the workspace ID")
  hl.dispatch(shared.move_window_to_monitor("r"))
  check(last_command().kind == "move_window" and last_command().args.monitor == "DP-1",
    "explicit window-to-monitor shortcut remains available")
  check(o.workspaces == shared and shared.shared == true, "Omarchy bindings use the shared-workspace adapter")

  local omarchy_path = os.getenv("OMARCHY_PATH") or "/usr/share/omarchy"
  local defaults_file = assert(io.open(omarchy_path .. "/default/hypr/bindings/tiling.lua", "r"))
  local defaults = defaults_file:read("*a")
  defaults_file:close()
  for method in defaults:gmatch("o%.workspaces%.([%w_]+)%(") do
    check(type(shared[method]) == "function", "installed default binding API remains available: " .. method)
  end
end
local ok, err = xpcall(run, debug.traceback)
os.execute("rm -rf -- " .. quote(state_home))
if not ok then error(err, 0) end

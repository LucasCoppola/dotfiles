-- One shared desktop for the external-only/laptop-only dock policy.
-- Loaded INSTEAD OF default.hypr.monitor-workspaces, before it registers any
-- monitor hooks. Workspace IDs never change, so personal keys, window rules,
-- and the workspace dots all keep referring to the same windows after docking.
local M = { slots = 10, shared = true }

local function shared_action(callback, expression)
  o.bind_expressions[callback] = expression
  return callback
end

-- Omarchy API: a workspace slot is the same global ID on every display.
function M.workspace_id(_monitor, slot)
  return slot
end

-- Omarchy API: focus a shared workspace; an explicitly named monitor may host it.
function M.focus(slot, monitor_name)
  return shared_action(function()
    if monitor_name then
      local monitor = hl.get_monitor(monitor_name)
      if not monitor then return end
      local workspace = hl.get_workspace(slot)
      if workspace and workspace.monitor and workspace.monitor.name ~= monitor.name then
        hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(slot), monitor = monitor.name }))
      end
      hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
    end
    hl.dispatch(hl.dsp.focus({ workspace = tostring(slot) }))
  end, "o.workspaces.focus(" .. slot .. (monitor_name and ", " .. string.format("%q", monitor_name) or "") .. ")")
end

-- Omarchy API: move the active window without translating the destination ID.
function M.move_window(slot, follow)
  return shared_action(function()
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(slot), follow = follow ~= false }))
  end, "o.workspaces.move_window(" .. slot .. (follow == false and ", false" or "") .. ")")
end

-- Omarchy API: explicitly move a workspace to another display without renumbering.
function M.move_to_monitor(direction)
  return shared_action(function()
    local monitor = hl.get_monitor(direction)
    if monitor then hl.dispatch(hl.dsp.workspace.move({ monitor = monitor.name })) end
  end, "o.workspaces.move_to_monitor(" .. string.format("%q", direction) .. ")")
end

-- Omarchy API: keep the standard window-to-monitor shortcuts working.
function M.move_window_to_monitor(direction)
  return shared_action(function()
    local monitor = hl.get_monitor(direction)
    if monitor then hl.dispatch(hl.dsp.window.move({ monitor = monitor.name })) end
  end, "o.workspaces.move_window_to_monitor(" .. string.format("%q", direction) .. ")")
end

-- Compatibility entry point: Hyprland moves unplugged workspaces itself.
-- Deliberately do not adopt, renumber, or restore monitor-specific blocks.
function M.reconcile() end

o.workspaces = M
return M

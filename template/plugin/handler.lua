-- This is generated code, DO NOT UPDATE!
-- If you have a fix, head over to https://github.com/Kong/priority-updater and
-- send a PR on the original template files

-- capture original plugin name, and new priority from filename
local plugin_name, priority = ({...})[1]:match("^kong%.plugins%.([^%.]-)_(%d+)%.handler$")
if not plugin_name or not priority then
  error("Plugin file must be named '..../kong/plugins/<name>_<priority>/handler.lua', got: " .. tostring(({...})[1]))
end

local original_handler = require("kong.plugins." .. plugin_name .. ".handler")

-- create new plugin.
-- we copy contents and metatable. So only plugins which would store something
-- in 'self' might not work properly, but these we do not have, so should be fine
local new_plugin = {}
for k,v in pairs(original_handler) do
  new_plugin[k] = v
end
setmetatable(new_plugin, getmetatable(original_handler))

-- set the new priority
new_plugin.PRIORITY = tonumber(priority)
new_plugin.VERSION = "0.4"

return new_plugin

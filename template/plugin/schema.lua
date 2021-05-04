-- This is generated code, DO NOT UPDATE!
-- If you have a fix, head over to https://github.com/Kong/priority-updater and
-- send a PR on the original template files

-- capture original plugin name, and new priority from filename
local plugin_name, priority = ({...})[1]:match("^kong%.plugins%.([^%.]-)_(%d+)%.schema$")
if not plugin_name or not priority then
  error("Plugin file must be named '..../kong/plugins/<name>_<priority>/schema.lua', got: " .. tostring(({...})[1]))
end

return require("kong.plugins." .. plugin_name .. ".schema")

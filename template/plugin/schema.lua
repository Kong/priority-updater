-- capture original plugin name, and new priority from filename
local plugin_name, priority = ({...})[1]:match("^kong%.plugins%.([^%.]-)_(%d+)%.schema$")
if not plugin_name or not priority then
  error("Plugin file must be named '..../kong/plugins/<name>_<priority>/schema.lua', got: " .. tostring(({...})[1]))
end

return require("kong.plugins." .. plugin_name .. ".schema")

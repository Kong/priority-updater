-- capture original plugin name, and new priority from filename
local plugin_name, priority = ({...})[1]:match("^kong%.plugins%.([^%.]-)_(%d+)%.daos$")
if not plugin_name or not priority then
  error("Plugin file must be named '..../kong/plugins/<name>_<priority>/daos.lua', got: " .. tostring(({...})[1]))
end

local module_name = "kong.plugins." .. plugin_name .. ".daos"

if package.loaded[module_name] then
  -- the daos file should be loaded only once, and was already loaded,
  -- so error out as if the module wasn't found
  return error("original was already loaded")
end

-- if this fails because it doesn't exist, it is identical to the original
-- failing, so the error indicates it's not there
local daos = require("kong.plugins." .. plugin_name .. ".daos")

-- what if the original plugin is loaded after this one?
package.loaded[module_name] = {}   -- make it empty! no new daos will be added, by anyone after us

return daos

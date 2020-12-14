-- capture original plugin name, and new priority from filename
local this_module_name = ({...})[1]
local plugin_name, priority = this_module_name:match("^kong%.plugins%.([^%.]-)_(%d+)%.api$")
if not plugin_name or not priority then
  error("Plugin file must be named '..../kong/plugins/<name>_<priority>/api.lua', got: " .. tostring(({...})[1]))
end

local module_name = "kong.plugins." .. plugin_name .. ".api"

if package.loaded[module_name] then
  -- the api file should be loaded only once, so error out as if the module wasn't found
  -- error must match exactly, since the loader validates it
  return error("module '" .. this_module_name .. "' not found")
end

-- if this fails the error indicates it's not there
local success, api = pcall(require, "kong.plugins." .. plugin_name .. ".api")
if not success then
  -- error must match exactly, since the loader validates it, so rethrow with adjusted name
  return error("module '" .. this_module_name .. "' not found")
end

-- what if the original plugin is loaded after this one?
package.loaded[module_name] = {}   -- make it empty! no new endpoints will be added, by anyone after us

return api

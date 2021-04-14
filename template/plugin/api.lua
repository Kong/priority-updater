-- This is generated code, DO NOT UPDATE!
-- If you have a fix, head over to https://github.com/Kong/priority-updater and
-- send a PR on the original template files

-- capture original plugin name, and new priority from filename
local this_module_name = ({...})[1]
local plugin_name, priority = this_module_name:match("^kong%.plugins%.([^%.]-)_(%d+)%.api$")
if not plugin_name or not priority then
  error("Plugin file must be named '..../kong/plugins/<name>_<priority>/api.lua', got: " .. tostring(({...})[1]))
end

local module_name = "kong.plugins." .. plugin_name .. ".api"



-- Error out indicating to the loader this module was not found
local function this_module_wasnt_found()
  -- clear LuaJIT temp userdata. If we leave the userdata, then a next call to
  -- `require` will return that userdata, and cause subsequent failures
  -- see https://www.freelists.org/post/luajit/require-not-clearing-userdata-value
  package.loaded[this_module_name] = nil
  -- error must match exactly, since the loader validates it
  return error("module '" .. this_module_name .. "' not found")
end



if package.loaded[module_name] then
  -- the api file should be loaded only once, so error out
  this_module_wasnt_found()
end

-- if this fails the error indicates the original plugin didn't have the file
local success, api = pcall(require, module_name)
if not success then
  this_module_wasnt_found()
end

-- what if the original plugin is loaded after this one?
package.loaded[module_name] = {}   -- make it empty! no new endpoints will be added, by anyone after us

return api

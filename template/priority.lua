local exec = require("pl.utils").execute
local writefile = require("pl.utils").writefile

local WRAPPER_VERSION = "0.4" -- version of the wrapper code, will reflect in the rockspec

io.stdout:setvbuf("no")
io.stderr:setvbuf("no")


local function stderr(...)
  io.stderr:write(...)
  io.stderr:write("\n")
end


local function stdout(...)
  io.stdout:write(...)
  io.stdout:write("\n")
end


local function fail(msg)
  stderr(msg)
  os.exit(1)
end


local function header(msg)
  local fill1 = math.floor((80 - 2 - #msg)/2)
  local fill2 = 80 - 2 - #msg - fill1
  stdout(
    ("*"):rep(80).."\n"..
    "*"..(" "):rep(fill1)..msg..(" "):rep(fill2).."*\n"..
    ("*"):rep(80)
  )
end


local platforms = {
  {
    check = "apk -V",         -- check for alpine
    commands = {              -- run before anything else in build container
      "apk update",
      "apk add zip",
    },
  }, {
    check = "yum --version",  -- check for CentOS
    commands = {              -- run before anything else in build container
      "yum -y install zip",
    },
  },
}


local function prep_platform()
  for _, platform in ipairs(platforms) do
    local ok = exec(platform.check)
    if not ok then
      stdout(("platform test '%s' was negative"):format(platform.check))
    else
      stdout(("platform test '%s' was positive"):format(platform.check))
      for _, cmd in ipairs(platform.commands) do
        stdout(cmd)
        local ok = exec(cmd)
        if not ok then
          fail(("failed executing '%s'"):format(cmd))
        end
      end
      return true
    end
  end
  stderr("WARNING: no platform match!")
end





-- **********************************************************
-- Do the actual work
-- **********************************************************
header("Set up platform")
assert(prep_platform())

local plugin = os.getenv("KONG_PRIORITY_NAME")
local priority = os.getenv("KONG_PRIORITY")
local plugin_name = tostring(plugin) .. "_" .. tostring(priority)
local rockspec = "kong-plugin-" .. plugin_name .. "-" .. WRAPPER_VERSION .. "-1.rockspec"

header("Building: "..plugin_name)
assert(writefile(rockspec,[[
local pluginName = "]] .. plugin_name .. [["

package = "kong-plugin-" .. pluginName
version = "]] .. WRAPPER_VERSION .. [[-1"

supported_platforms = {"linux", "macosx"}
source = {
  url = "http://github.com/not/really/used.git",
  tag = "0.1"
}

description = {
  summary = "Kong is a scalable and customizable API Management platform",
  homepage = "http://konghq.com",
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "./handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "./schema.lua",
    ["kong.plugins."..pluginName..".daos"] = "./daos.lua",
    ["kong.plugins."..pluginName..".api"] = "./api.lua",
  }
}
]]))

assert(exec("luarocks make"))

header("Packing: "..plugin_name)
assert(exec("luarocks pack kong-plugin-" .. plugin_name))
os.remove(rockspec)

header("Done creating: " .. "kong-plugin-" .. plugin_name .. "-" .. WRAPPER_VERSION .. "-1.all.rock")




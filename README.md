# priority-updater

Tool to quickly create a plugin with an updated priority.

# Status

> early development

# Description

Kong plugin priorities are static, in source. Occasionally there is a use-case
for a different priority setting, in which case the user is advised to create a
copy of the original plugin and modify the source.

This utility makes this process a lot easier. It creates a wrapper plugin that
takes the original plugin and adjusts the priority.

There are two main uses:

1. Executing plugins in a different order
2. Running the same plugin functionality twice or more (create indentical
   plugins with slightly different priorities)

# WARNING!

_Do NOT upload the generated plugins to LuaRocks since that would pollute
the LuaRocks repository with loads of useless/duplicate plugins._

# Usage

1. Create a wrapper for the 'request-transformer' with priority '999':
    ```shell
    ./create.sh "request-transformer" 999
    ```
    New rock is generated: `kong-plugin-request-transformer_999-0.1-1.all.rock`.
    The new plugin name is `request-transformer_999` (the old name with the
    appended new priority)

2. Copy the resulting `.rock` file to the target system. Or use the
   [docker tools](https://github.com/Kong/docker-kong/tree/master/customize)
   to inject it into a Kong docker image.

3. Install the plugin on your Kong system using LuaRocks

    ```shell
    luarocks install kong-plugin-request-transformer_999-0.1-1.all.rock
    ```

4. Use your new plugin with Kong (use the NEW name with priority!)


    ```shell
    curl -X POST http://kong:8001/plugins \
        --data "name=request-transformer_999"  \
        --data "config.remove.headers=x-toremove, x-another-one"
    ```

## note

You can pass a 3rd argument to the `create.sh` script if you want to chage the
   version of the docker container that is used. e.g.

 ``` bash
     ./create.sh "request-transformer" 999 kong:2.3.2
 ```

# Requirements/Prerequisites

The utility is a `bash` script that uses a `docker` build container. Hence only
those are required to run it.

# Implementation details

- The plugin does not contain any functional code, but shares everything with
  the original:
    - if the original code gets updated, the wrapper will use the updated code.
    - the new plugin shares the same management API endpoints and data (DAO's).
- There is no performance penalty for using the wrapper.
- One caveat: If a plugin uses its own table to store state (eg. updates
  values in `self`), then that is the only part that is NOT shared. Afaik there
  are currently no such plugins.

# History/Changelog

Note: the version is the version of the generated wrapper code, and independent
of the original code. If the Lua code of the wrapper changes, then also change
the version of the generated wrapper in `priority.lua`, the `WRAPPER_VERSION`
constant at the top.

### 0.3 14-Dec-2020
- Fix: fix in version 0.2 was incomplete, the new error could be the existing
  plugins name, instead of the new name.

### 0.2 04-Dec-2020
- Fix: plugins with `daos.lua` or `api.lua` would fail on more recent versions
  of Kong because it checks the exact error message.

### 0.1 12-Jun-2019
- Initial version

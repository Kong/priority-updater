# priority-updater

Tool to quickly create a plugin with an updated priority.

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

2. Copy the resulting `.rock` file to the target system

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


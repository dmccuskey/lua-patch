# lua-patch

Add a few Python-style conveniences to Lua: `%` for string formatting, `table.pop()`, and `pnotice()`/`pwarn()` for marked-up log lines.

Each is a patch you turn on (and off) by name. They change Lua's global environment, not a single module: after `addPatch( 'string-format' )`, every string in the program has the `%` operator. lua-patch was written for the DMC Solar2D (formerly Corona SDK) libraries, which turn on the patches they use, but it's plain Lua 5.1 and runs anywhere:

```lua
local Patch = require 'lua_patch'
Patch.addPatch( 'string-format' )

print( "http://%s:%d/" % { 'server.com', 9034 } )  --> http://server.com:9034/
```

## Features

- `string-format`: `fmt % value` or `fmt % { values }` is `string.format()`, as in Python
- `table-pop`: `table.pop( t, key )` returns a value and removes it from the table
- `print-output`: global `pnotice()` and `pwarn()` print a message marked `[NOTICE]` or `[WARNING]`
- Turn patches on and off by name, one at a time or all at once
- Pure Lua 5.1, one file, no dependencies; MIT licensed

## Quick Start

The following steps will get you up and running in about 5 minutes with Lua 5.1 on macOS or Linux. You will turn on the patches and use each of them.

Prerequisites: Lua 5.1 (`lua -v` shows `Lua 5.1.x`) and git.

### 1. Get the Code

In an empty folder:

```sh
git clone https://github.com/dmccuskey/lua-patch.git
```

The module is `lua-patch/dmc_lua/lua_patch.lua`.

### 2. Use It

Create `main.lua` in the same folder:

```lua
package.path = './lua-patch/dmc_lua/?.lua;' .. package.path
local Patch = require 'lua_patch'

Patch.addAllPatches()

print( "we rode %s %s horses" % { 4, 'big' } )
print( "http://%s:%d/" % { 'server.com', 9034 } )

local pending = { id_12='one', id_45='two' }
print( table.pop( pending, 'id_12' ), pending.id_12 )

pwarn( "disk almost full", { newline=false } )

Patch.removePatch( 'string-format' )
```

Run it:

```sh
lua main.lua
```

```text
Lua Patch::activating patch 'table-pop'
Lua Patch::activating patch 'string-format'
we rode 4 big horses
http://server.com:9034/
one	nil
[WARNING] disk almost full
Lua Patch::deactivating patch 'string-format'
```

The module prints a line each time it turns `string-format` or `table-pop` on or off. If it shows `module 'lua_patch' not found`, run it from the folder that holds `lua-patch/`.

To update, pull the repository again (`git -C lua-patch pull`).

## Reference

### The Module

| member | does |
|---|---|
| `addPatch( name )` | Turns on a patch, or each patch in an array of names. With no argument, all three. Turning on a patch that's already on does nothing. |
| `addAllPatches()` | Turns on all three. |
| `removePatch( name )` | Turns off a patch, or each in an array. With no argument, all three. |
| `removeAllPatches()` | Turns off all three. |
| `PATCH_STRING_FORMAT`, `PATCH_TABLE_POP`, `PATCH_PRINT_OUTPUT` | The names: `'string-format'`, `'table-pop'`, `'print-output'`. |
| `__version` | The module's version, `'0.4.0'`. |

An unknown name (`unknown patch name 'x'`), or an argument that isn't a string, an array or `nil`, raises an error.

### `string-format`

Sets the `__mod` metamethod that all strings share, so `fmt % v` calls `string.format( fmt, v )`, and `fmt % { v1, v2 }` calls `string.format( fmt, v1, v2 )`. Any format of `string.format()` works:

```lua
print( "%X" % 2049043 )           --> 1F4413
print( "%-6s|" % 'ab' )           --> ab    |
```

`fmt % nil` returns `fmt` unchanged. A `nil` in the array is passed on, not the end of it (though Lua 5.1's `string.format()` rejects a `nil` value). Strings that hold numbers keep their arithmetic: `'100' % 7` is `2`, not a format.

### `table-pop`

Adds `table.pop( t, key )`: returns `t[key]` and sets it to `nil`. Errors when `t` isn't a table or `key` is `nil`.

### `print-output`

Adds two globals, `pnotice( message, params )` and `pwarn( message, params )`, which print `[NOTICE] message` or `[WARNING] message` with a blank line before and after. `params.newline=false` leaves out the blank lines. `message` goes through `tostring()`.

## In Solar2D

[dmc-patch](https://github.com/dmccuskey/dmc-patch) is the Solar2D package of this module. The DMC Solar2D libraries load lua-patch as `lib.dmc_lua.lua_patch` from their `dmc_corona/lib/dmc_lua/` folder, part of [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library), and turn on the patches they need when they load, so an app that uses one of them has those patches on everywhere.

## Known Issues

- **Patches are global, and nothing counts who uses them.** `removePatch()` turns a patch off for the whole program, including libraries that turned it on and still need it.
- **The on/off lines can't be silenced**: `string-format` and `table-pop` always print `Lua Patch::activating patch ...`. `print-output` prints nothing.

## Development

Only `dmc_lua/lua_patch.lua` is written here. [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies it into its `dmc_lua/` with its Snakemake build (the `Snakefile` here registers it), and the DMC Solar2D libraries copy it from there into `dmc_corona/lib/dmc_lua/`.

The `%` operator's function, `stringFormatting()`, is a copy of [lua-utils](https://github.com/dmccuskey/lua-utils)' function of that name, between `--== Start: copy from lua_utils ==--` and `--== End: copy from lua_utils ==--`, so lua-patch loads on its own. A fix to one goes into the other.

The tests are in `spec/lua_patch_spec.lua`, for [busted](https://lunarmodules.github.io/busted/) under Lua 5.1. From the repository's root folder:

```sh
busted spec
```

It ends with:

```text
11 successes / 0 failures / 0 errors / 0 pending : 0.002275 seconds
```

(The progress line is mixed with the patches' on/off lines.) The tests cover each patch and the module's functions.

## License

lua-patch is released under the [MIT License](LICENSE).

# lua-patch
adds various patches to Lua to enable cooler functionality (a la Python)


```lua
local Patch = require 'lua_patch'

Patch.addPatch( 'table-pop' )
Patch.addPatch( 'string-format' )

-- or
Patch.addAllPatches()

Patch.removePatch( 'table-pop' )
Patch.removePatch( 'string-format' )

-- or
Patch.removeAllPatches()
```

### Table.pop ###

simultaneously retrieves and removes item from table

```lua
local Patch = require 'lua_patch'
Patch.addPatch( 'table-pop' )

local process_vals = { id_12="one", id_45="two" }
local val

-- instead of this:
val = process_vals['id_12']
process_vals['id_12'] = nil

-- do this:
val = table.pop( process_vals, 'id_12' )
print( process_vals['id_12'] ) -- nil

```


### String.format ###

inserts data into string. can use any format operator

```lua
local Patch = require 'lua_patch'
Patch.addPatch( 'string-format' )

print( "we rode %s %s horses" % {4,"big"} ) -- "we rode 4 big horses"
print( "http://%s:%d/" % { 'server.com', 9034 } ) -- "http://server.com:9034"
print( "%X" % 2049043 ) -- "1F4413"

```

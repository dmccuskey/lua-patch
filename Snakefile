# lua-patch

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "lua-patch"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "lua-patch",
	"module": {
		"dir": "dmc_lua",
		"files": [
			"lua_patch.lua"
		],
		"requires": []
	},
	"tests": {
		"dir": "spec",
		"files": [],
		"requires": []
	}
}

register( "lua-patch", module_config )



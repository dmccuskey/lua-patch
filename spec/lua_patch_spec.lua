--====================================================================--
-- spec/lua_patch_spec.lua
--
-- Testing for lua-patch using Busted
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path


--====================================================================--
--== Test: Lua Patch
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.1.0"



--====================================================================--
--== Imports


local Patch = require('lua_patch')



--====================================================================--
--== Testing Setup
--====================================================================--


describe( "Module Test: lua_patch.lua", function()


	describe( "Tests for Table Pop", function()

		before_each( function()
		end)

		after_each( function()
			Patch.removePatch( 'table-pop' )
		end)

		it( "Patch.table-pop", function()

			local t = { hello=3, orange="two" }
			local v

			assert( table.pop == nil, "pop already on table" )
			assert( t['hello'] == 3, "table value should there" )

			Patch.addPatch( 'table-pop' )

			v = table.pop( t, 'hello' )

			assert( v == 3, "incorrect value for pop" )
			assert( t['hello'] == nil, "table value should be absent" )

			Patch.removePatch( 'table-pop' )

			assert( table.pop == nil, "pop already on table" )

		end)

		it( "Patch.table-pop errors", function()

			Patch.addPatch( 'table-pop' )

			assert.has.errors( function() table.pop( "table", 'hello' ) end )
			assert.has.errors( function() table.pop( {}, nil ) end )

		end)

	end)



	describe( "Tests for String Mod", function()

		before_each( function()
		end)

		after_each( function()
			Patch.removePatch( 'string-format' )
		end)

		it( "Patch.string-format strings", function()

			Patch.addPatch( 'string-format' )

			assert.are.equal( "hello %s, do you like %s?" % { "John", "ice cream" }, "hello John, do you like ice cream?" )
			assert.are.equal( "we rode %s %s horses" % {4,"big"}, "we rode 4 big horses" )
			assert.are.equal( "%s %s" % {4,"big","cars"}, "4 big" )

		end)

		it( "Patch.string-format numbers", function()

			Patch.addPatch( 'string-format' )

			assert.are.equal( "%f" % math.pi, "3.141593" )
			assert.are.equal( "%X" % 2049043, "1F4413" )
			assert.are.equal( "%f, %g" % {math.pi,math.pi}, "3.141593, 3.14159" )

		end)

		it( "Patch.string-format errors", function()

			-- not patched yet
			assert.error( function() local var = "%f" % math.pi end )

			Patch.addPatch( 'string-format' )

			-- not enough args
			assert.error( function() local var = "hello %s big %s" % {"one"} end )
			-- wrong type of arg
			assert.error( function() local var = "%f" % { "hello" } end )

			Patch.removePatch( 'string-format' )

			assert.error( function() local var = "%f" % { "hello" } end )

		end)

	end)


end)

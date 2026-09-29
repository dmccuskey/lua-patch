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



	describe( "Tests for the module", function()

		after_each( function()
			Patch.removeAllPatches()
		end)

		it( "exports its version", function()
			assert.are.equal( '0.4.0', Patch.__version )
		end)

		it( "removeAllPatches() turns every patch off", function()
			Patch.addAllPatches()
			assert.is_function( table.pop )
			assert.is_function( pnotice )

			Patch.removeAllPatches()

			assert.is_nil( table.pop )
			assert.is_nil( rawget( _G, 'pnotice' ) )
			assert.is_nil( rawget( _G, 'pwarn' ) )
			assert.error( function() local var = "%s" % 'x' end )
		end)

		it( "removePatch() with no argument turns off print-output too", function()
			Patch.addPatch()
			Patch.removePatch()
			assert.is_nil( rawget( _G, 'pwarn' ) )
		end)

		it( "names an unknown patch in the error", function()
			assert.has_error( function() Patch.addPatch( 'no-such' ) end,
				"Lua Patch:: unknown patch name 'no-such'" )
			assert.has_error( function() Patch.removePatch( { 'no-such' } ) end,
				"Lua Patch:: unknown patch name 'no-such'" )
			assert.has_error( function() Patch.addPatch( 42 ) end,
				"Lua Patch:: unknown patch type 'number'" )
		end)

		it( "string-format passes the values after a nil", function()
			Patch.addPatch( 'string-format' )
			local values = {}
			values[1], values[3] = 1, 3 -- #values is 1
			local format, count = string.format, nil
			string.format = function( fmt, ... ) count = select( '#', ... ) return fmt end
			local _ = "%s %s %s" % values
			string.format = format
			assert.are.equal( 3, count )
		end)

		it( "print-output marks the message", function()
			local print, lines = _G.print, {}
			_G.print = function( s ) lines[#lines+1] = s end
			Patch.addPatch( 'print-output' )
			pnotice( "hi" )
			pwarn( 42, { newline=false } )
			_G.print = print
			assert.are.same( { "\n\n[NOTICE] hi\n\n", "[WARNING] 42" }, lines )
		end)

	end)


end)

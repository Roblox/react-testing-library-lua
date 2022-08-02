-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/src/index.js
-- ROBLOX comment: wrap in function to pass afterEach function
return function(afterEach)
	local Packages = script.Parent

	local LuauPolyfill = require(Packages.LuauPolyfill)
	local Object = LuauPolyfill.Object

	local exports = {} :: { [string]: any }

	local cleanup = require(script.pure).cleanup
	-- if we're running in a test runner that supports afterEach
	-- or teardown then we'll automatically run cleanup afterEach test
	-- this ensures that tests run in isolation from each other
	-- if you don't like this then either import the `pure` module
	-- or set the RTL_SKIP_AUTO_CLEANUP env variable to 'true'.
	if
		-- ROBLOX deviation START: adapt conditions
		not _G.RTL_SKIP_AUTO_CLEANUP
		-- ROBLOX deviation END
	then
		-- ignore teardown() in code coverage because Jest does not support it
		--[[ istanbul ignore else ]]
		if typeof(afterEach) == "function" then
			afterEach(function()
				cleanup()
			end)
			-- ROBLOX deviation START: does not apply
			-- elseif typeof(teardown) == "function" then
			-- 	-- Block is guarded by `typeof` check.
			-- 	-- eslint does not support `typeof` guards.
			-- 	-- eslint-disable-next-line no-undef
			-- 	teardown(function()
			-- 		cleanup()
			-- 	end)
			-- ROBLOX deviation END
		end
	end

	Object.assign(exports, require(script.pure))

	return exports
end

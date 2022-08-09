-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/src/__tests__/new-act.js
return function()
	local Packages = script.Parent.Parent.Parent

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect
	local jest = JestGlobals.jest

	local LuauPolyfill = require(Packages.LuauPolyfill)
	local Error = LuauPolyfill.Error
	local console = LuauPolyfill.console
	type Promise<T> = LuauPolyfill.Promise<T>

	local Promise = require(Packages.Promise)

	local asyncAct, consoleErrorMock

	-- ROBLOX deviation: Mock is not supported
	-- local _testUtils = require(script.Parent.Parent.jsHelpers["react-dom"]["test-utils"])
	-- jest.mock(testUtils, function()
	-- 	return {
	-- 		act = function(cb)
	-- 			return cb()
	-- 		end,
	-- 	}
	-- end)

	local originalConsoleError = console.error

	beforeEach(function()
		console.error = jest.fn()

		jest.resetModules()
		asyncAct = require(script.Parent.Parent["act-compat"]).asyncAct
	end)

	afterEach(function()
		console.error:mockRestore()
		console.error = originalConsoleError
	end)

	it("async act works when it does not exist (older versions of react)", function()
		return Promise.resolve()
			:andThen(function()
				local callback = jest.fn()
				asyncAct(function()
					return Promise.resolve():andThen(function()
						Promise.resolve():expect()
						Promise.resolve()
							:andThen(function()
								return callback()
							end)
							:expect()
					end)
				end):expect()
				jestExpect(console.error).toHaveBeenCalledTimes(0)
				jestExpect(callback).toHaveBeenCalledTimes(1)
				callback:mockClear();

				(console.error :: any):mockClear()

				asyncAct(function()
					return Promise.resolve():andThen(function()
						Promise.resolve():expect()

						Promise.resolve()
							:andThen(function()
								return callback()
							end)
							:expect()
					end)
				end):expect()

				jestExpect(console.error).toHaveBeenCalledTimes(0)
				jestExpect(callback).toHaveBeenCalledTimes(1)
			end)
			:expect()
	end)

	it("async act recovers from errors", function()
		return Promise.resolve()
			:andThen(function()
				local ok = pcall(function()
					asyncAct(function()
						return Promise.resolve():andThen(function()
							Promise.resolve(nil):expect()
							error(Error.new("test error"))
						end)
					end):expect()
				end)

				if not ok then
					console.error("call console.error")
				end

				jestExpect(console.error).toHaveBeenCalledTimes(1)

				-- ROBLOX deviation START: We are using a custom toMatchInlineSnapshot serializer which changes how our snapshot is expected to be
				jestExpect((console.error :: any).mock.calls).toMatchInlineSnapshot([=[
Array [
Array [
call console.error
]
]]=])
			end)
			:expect()
		-- ROBLOX deviation END
	end)

	it("async act recovers from sync errors", function()
		return Promise.resolve()
			:andThen(function()
				local ok = pcall(function()
					asyncAct(function()
						error(Error.new("test error"))
					end):expect()
				end)
				if not ok then
					console.error("call console.error")
				end
				jestExpect(console.error).toHaveBeenCalledTimes(1)
				-- ROBLOX deviation START: We are using a custom toMatchInlineSnapshot serializer which changes how our snapshot is expected to be
				jestExpect((console.error :: any).mock.calls).toMatchInlineSnapshot([=[
Array [
Array [
call console.error
]
]]=])
			end)
			:expect()
		-- ROBLOX deviation END
	end)
	--[[ eslint no-console:0 ]]
end

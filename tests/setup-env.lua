-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/tests/setup-env.js

local LuauPolyfill = require("@pkg/@jsdotlua/luau-polyfill")
local console = LuauPolyfill.console

local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local jest = JestGlobals.jest
local expect = JestGlobals.expect
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach

-- ROBLOX deviation START: explicitly extend expect
local jestDomMatchers = require("../src/jsHelpers/jest-dom")
expect.extend(jestDomMatchers)
-- ROBLOX deviation END

-- ROBLOX deviation START: extend with missing matchers from jest
local matchers = require("../src/jsHelpers/matchers")
expect.extend(matchers)
-- ROBLOX deviation END

local consoleErrorMock
-- ROBLOX deviation START: replace spyOn and String.indexof (both unavailable)
local originalConsoleError = console.error
beforeEach(function()
	consoleErrorMock = jest.fn(function(message, ...: any)
		local optionalParams = table.pack(...)
		-- Ignore ReactDOM.render/ReactDOM.hydrate deprecation warning
		if string.find(message, "Use createRoot instead.", 1, true) then
			return
		end
		originalConsoleError(message, table.unpack(optionalParams))
	end)
	console.error = consoleErrorMock
end)

afterEach(function()
	consoleErrorMock:mockRestore()
	console.error = originalConsoleError
end)
-- ROBLOX deviation END

return {}

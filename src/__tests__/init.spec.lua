-- ROBLOX upstream: no upstream
return function()
	local Packages = script.Parent.Parent.Parent

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect

	local jestDomMatchers = require(script.Parent.Parent.jsHelpers["jest-dom"])

	beforeAll(function()
		jestExpect.extend(jestDomMatchers)
	end)
end

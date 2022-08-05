-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/src/__tests__/auto-cleanup.js
return function()
	local Packages = script.Parent.Parent.Parent

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect

	local document = require(Packages.DomTestingLibrary).document

	local React = require(Packages.React)
	local render = require(script.Parent.Parent)(afterEach).render -- This just verifies that by importing RTL in an
	-- environment which supports afterEach (like jest)
	-- we'll get automatic cleanup between tests.
	it("first", function()
		render(React.createElement("TextLabel", { Text = "hi" }))
	end)

	it("second", function()
		jestExpect(document).toBeEmptyDOMElement()
	end)
end

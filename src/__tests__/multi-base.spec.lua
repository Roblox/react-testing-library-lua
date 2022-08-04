-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/src/__tests__/multi-base.js
return function()
	local Packages = script.Parent.Parent.Parent

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect

	local document = require(Packages.DomTestingLibrary).document

	local React = require(Packages.React)
	local render = require(script.Parent.Parent)(afterEach).render

	-- these are created once per test suite and reused for each case
	local treeA, treeB
	beforeAll(function()
		treeA = Instance.new("Frame")
		treeB = Instance.new("Frame")
		treeA.Parent = document
		treeB.Parent = document
	end)

	afterAll(function()
		treeA.Parent = nil
		treeB.Parent = nil
	end)

	it("baseElement isolates trees from one another", function()
		local getByTextInA =
			render(React.createElement("TextLabel", { Text = "Jekyll" }), { baseElement = treeA }).getByText
		local getByTextInB =
			render(React.createElement("TextLabel", { Text = "Hyde" }), { baseElement = treeB }).getByText

		jestExpect(function()
			return getByTextInA("Jekyll")
		end).never.toThrow("Unable to find an element with the text: Jekyll.")

		jestExpect(function()
			return getByTextInB("Jekyll")
		end).toThrow("Unable to find an element with the text: Jekyll.")

		jestExpect(function()
			return getByTextInA("Hyde")
		end).toThrow("Unable to find an element with the text: Hyde.")

		jestExpect(function()
			return getByTextInB("Hyde")
		end).never.toThrow("Unable to find an element with the text: Hyde.")
	end)
	-- https://github.com/testing-library/eslint-plugin-testing-library/issues/188
	--[[
		eslint
  		testing-library/prefer-screen-queries: "off",
	]]
end

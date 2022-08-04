-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/src/__tests__/debug.js
return function()
	local Packages = script.Parent.Parent.Parent

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect
	local jest = JestGlobals.jest

	local LuauPolyfill = require(Packages.LuauPolyfill)
	local console = LuauPolyfill.console

	local React = require(Packages.React)
	local ParentModule = require(script.Parent.Parent)(afterEach)
	local render = ParentModule.render
	local screen = ParentModule.screen

	local originalConsoleLog = console.log
	beforeEach(function()
		-- ROBLOX deviation START: replace sypOn
		console.log = jest.fn(function() end)
		--ROBLOX deviation END
	end)
	afterEach(function()
		(console.log :: any):mockRestore()
	end)

	-- ROBLOX deviation START: restore console log
	afterAll(function()
		console.log = originalConsoleLog
	end)
	-- ROBLOX deviation END

	it("debug pretty prints the container", function()
		local function HelloWorld()
			return React.createElement("TextLabel", { Text = "Hello World" })
		end
		local debug_ = render(React.createElement(HelloWorld, nil)).debug
		debug_()
		jestExpect(console.log).toHaveBeenCalledTimes(1)
		jestExpect(console.log).toHaveBeenCalledWith(jestExpect.stringContaining("Hello World"))
	end)

	it("debug pretty prints multiple containers", function()
		local function HelloWorld()
			local el1 =
				React.createElement("TextLabel", { [React.Tag] = "data-testid=testId", Text = "Hello World" }, nil)
			local el2 =
				React.createElement("TextLabel", { [React.Tag] = "data-testid=testId", Text = "Hello World" }, nil)

			return React.createElement(React.Fragment, nil, el1, el2)
		end
		local debug_ = render(React.createElement(HelloWorld, nil)).debug
		local multipleElements = screen.getAllByTestId("testId")
		debug_(multipleElements)

		jestExpect(console.log).toHaveBeenCalledTimes(2)
		jestExpect(console.log).toHaveBeenCalledWith(jestExpect.stringContaining("Hello World"))
	end)

	it("allows same arguments as prettyDOM", function()
		local function HelloWorld()
			return React.createElement("TextLabel", { Text = "Hello World" })
		end
		local debug_, container
		do
			local ref = render(React.createElement(HelloWorld, nil))
			debug_, container = ref.debug, ref.container
		end
		debug_(container, 6, { highlight = false })

		jestExpect(console.log).toHaveBeenCalledTimes(1)
		jestExpect((console.log :: any).mock.calls[1]).toEqual({ "Frame ..." })
	end)
	--[[
eslint
  no-console: "off",
  testing-library/no-debug: "off",
]]
end

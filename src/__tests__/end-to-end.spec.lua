-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/src/__tests__/end-to-end.js
return function()
	local Packages = script.Parent.Parent.Parent

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect
	local jest = JestGlobals.jest

	local LuauPolyfill = require(Packages.LuauPolyfill)
	local Array = LuauPolyfill.Array
	local setTimeout = LuauPolyfill.setTimeout

	local Promise = require(Packages.Promise)
	local RegExp = require(Packages.Dev.LuauRegExp)

	local React = require(Packages.React)
	local ParentModule = require(script.Parent.Parent)(afterEach)
	local render = ParentModule.render
	local waitForElementToBeRemoved = ParentModule.waitForElementToBeRemoved
	local screen = ParentModule.screen
	local waitFor = ParentModule.waitFor

	local function fetchAMessage()
		return Promise.new(function(resolve)
			-- we are using random timeout here to simulate a real-time example
			-- of an async operation calling a callback at a non-deterministic time
			local randomTimeout = math.floor(math.random() * 100)
			setTimeout(function()
				resolve({ returnedMessage = "Hello World" })
			end, randomTimeout)
		end)
	end

	local function ComponentWithLoader()
		local state, setState = React.useState({ data = nil, loading = true })
		React.useEffect(function()
			local cancelled = false
			fetchAMessage():andThen(function(data)
				if not cancelled then
					setState({ data = data, loading = false })
				end
			end)
			return function()
				cancelled = true
			end
		end, {})
		if state.loading then
			return React.createElement("TextLabel", { Text = "Loading..." })
		end
		return React.createElement("TextLabel", {
			Text = "Loaded this message: " .. if state.data then state.data.returnedMessage else "" .. "!",
			[React.Tag] = "data-testid=message",
		}) :: any
	end

	-- ROBLOX deviation START: use describe.each when available
	Array.forEach({
		{
			"real timers",
			function()
				return jest.useRealTimers()
			end :: any,
		},
		-- ROBLOX deviation START: no legacy timers
		-- {
		-- 	"fake legacy timers",
		-- 	function()
		-- 		return jest.useFakeTimers("legacy")
		-- 	end,
		-- },
		-- ROBLOX deviation END
		{
			"fake modern timers",
			function()
				return jest.useFakeTimers("modern")
			end :: any,
		},
	}, function(ref)
		local label: string, useTimers: () -> any = table.unpack(ref :: any, 1, 2)
		describe("it waits for the data to be loaded using " .. label, function()
			beforeEach(function()
				useTimers()
			end)
			afterEach(function()
				jest.useRealTimers()
			end)

			it("waitForElementToBeRemoved", function()
				return Promise.resolve()
					:andThen(function()
						render(React.createElement(ComponentWithLoader, nil))
						local function loading()
							return screen.getByText("Loading...")
						end
						waitForElementToBeRemoved(loading):expect()
						jestExpect(screen.getByTestId("message")).toHaveTextContent(RegExp("Hello World"))
					end)
					:expect()
			end)

			it("waitFor", function()
				return Promise.resolve()
					:andThen(function()
						render(React.createElement(ComponentWithLoader, nil))
						local function message()
							return screen.getByText(RegExp("Loaded this message:"))
						end
						waitFor(message):expect()
						jestExpect(screen.getByTestId("message")).toHaveTextContent(RegExp("Hello World"))
					end)
					:expect()
			end)

			it("findBy", function()
				return Promise.resolve()
					:andThen(function()
						render(React.createElement(ComponentWithLoader, nil))
						jestExpect((screen.findByTestId("message"):expect())).toHaveTextContent(RegExp("Hello World"))
					end)
					:expect()
			end)
		end)
	end)
	-- ROBLOX deviation END
end

-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/src/__tests__/act.js
return function()
	local Packages = script.Parent.Parent.Parent

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect
	local jest = JestGlobals.jest

	local Promise = require(Packages.Promise)

	local React = require(Packages.React)
	local ParentModule = require(script.Parent.Parent)(afterEach)
	local render = ParentModule.render
	local fireEvent = ParentModule.fireEvent
	local screen = ParentModule.screen

	it("render calls useEffect immediately", function()
		local effectCb = jest.fn()
		local function MyUselessComponent()
			React.useEffect(effectCb)
			return nil
		end
		render(React.createElement(MyUselessComponent, nil))
		jestExpect(effectCb).toHaveBeenCalledTimes(1)
	end)

	it("findByTestId returns the element", function()
		return Promise.resolve()
			:andThen(function()
				local ref = React.createRef()
				render(React.createElement("Frame", { ref = ref, [React.Tag] = "data-testid=foo" }))
				jestExpect(screen.findByTestId("foo"):expect()).toBe(ref.current)
			end)
			:expect()
	end)

	it("fireEvent triggers useEffect calls", function()
		local effectCb = jest.fn()
		local function Counter()
			React.useEffect(effectCb)
			local count, setCount = React.useState(0)
			return React.createElement("TextButton", {
				Size = UDim2.new(0, 100, 0, 100),
				[React.Event.Activated] = function()
					return setCount(count + 1)
				end,
				Text = count,
			})
		end
		local buttonNode = render(React.createElement(Counter, nil)).container:GetChildren()[1]
		task.wait()
		effectCb:mockClear()
		fireEvent.click(buttonNode)
		jestExpect(buttonNode).toHaveTextContent("1")
		jestExpect(effectCb).toHaveBeenCalledTimes(1)
	end)

	-- ROBLOX deviation START: hydrate is not supported
	-- it("calls to hydrate will run useEffects", function()
	-- 	local effectCb = jest.fn()
	-- 	local function MyUselessComponent()
	-- 		React.useEffect(effectCb)
	-- 		return nil
	-- 	end
	-- 	render(React.createElement(MyUselessComponent, nil), { hydrate = true })
	-- 	jestExpect(effectCb).toHaveBeenCalledTimes(1)
	-- end)
	-- ROBLOX deviation END
end

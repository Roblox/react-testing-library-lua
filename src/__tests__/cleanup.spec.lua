-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/src/__tests__/cleanup.js
local JestGlobals = require("@pkg/@jsdotlua/jest-globals")
local expect = JestGlobals.expect
local test = JestGlobals.test
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach
local jest = JestGlobals.jest

local LuauPolyfill = require("@pkg/@jsdotlua/luau-polyfill")
local console = LuauPolyfill.console

local document = require("@pkg/@jsdotlua/dom-testing-library").document

local getElementByName = require("../jsHelpers/Element").getElementByName

local React = require("@pkg/@jsdotlua/react")

local ParentModule = require("..")
local render = ParentModule.render
local cleanup = ParentModule.cleanup

test("cleans up the document", function()
	local spy = jest.fn()
	local divId = "my-div"

	local Test = React.Component:extend("Test")

	function Test:componentWillUnmount()
		expect(getElementByName(document, divId)).toBeInTheDocument()
		spy()
	end

	function Test:render()
		-- selene: allow(roblox_incorrect_roact_usage)
		return React.createElement("Frame", { Name = divId })
	end

	render(React.createElement(Test, nil))

	cleanup()

	expect(document).toBeEmptyDOMElement()
	expect(spy).toHaveBeenCalledTimes(1)
end)

test("cleanup does not error when an element is not a child", function()
	render(React.createElement("Frame", nil), { container = Instance.new("Frame") })
	cleanup()
end)

test("cleanup runs effect cleanup functions", function()
	local spy = jest.fn()

	local function Test()
		React.useEffect(function()
			spy()
		end)
		return nil
	end

	render(React.createElement(Test, nil))
	cleanup()
	expect(spy).toHaveBeenCalledTimes(1)
end)

describe("fake timers and missing act warnings", function()
	beforeEach(function()
		jest.resetAllMocks()
		-- ROBLOX deviation START: replace spyOn
		console.error = jest.fn(function()
			-- assert messages explicitly
		end)
		-- ROBLOX deviation END
		jest.useFakeTimers().setEngineFrameTime(1000 / 60)
	end)

	afterEach(function()
		jest.useRealTimers()
	end)

	test("cleanup does not flush microtasks", function()
		local microTaskSpy = jest.fn()
		local function Test()
			local counter = 1
			local _, setDeferredCounter = React.useState(nil :: number?)
			React.useEffect(function()
				local cancelled = false
				-- ROBLOX deviation START: Using task.delay for mockability
				task.delay(0, function()
					microTaskSpy()
					-- eslint-disable-next-line jest/no-if -- false positive
					if not cancelled then
						setDeferredCounter(counter)
					end
				end)

				return function()
					cancelled = true
				end
			end, { counter })

			return nil
		end
		render(React.createElement(Test, nil))

		cleanup()

		expect(microTaskSpy).toHaveBeenCalledTimes(0)
		-- console.error is mocked
		-- eslint-disable-next-line no-console

		-- ROBLOX deviation START: React.version not available, but will stick to React 17 for now
		expect(console.error).toHaveBeenCalledTimes(
			-- ReactDOM.render is deprecated in React 18
			0
		)
		-- ROBLOX deviation END
	end)

	test("cleanup does not swallow missing act warnings", function()
		local deferredStateUpdateSpy = jest.fn()
		local function Test()
			local counter = 1
			local _, setDeferredCounter = React.useState(nil :: number?)
			React.useEffect(function()
				local cancelled = false
				task.delay(0, function()
					deferredStateUpdateSpy()
					if not cancelled then
						setDeferredCounter(counter)
					end
				end)

				return function()
					cancelled = true
				end
			end, { counter })

			return nil
		end
		render(React.createElement(Test, nil))

		jest.advanceTimersByTime(0)

		cleanup()

		expect(deferredStateUpdateSpy).toHaveBeenCalledTimes(1)
		-- console.error is mocked
		-- eslint-disable-next-line no-console
		-- ROBLOX deviation START: React.version not available, but will stick to React 17 for now
		-- expect(console.error).toHaveBeenCalledTimes(
		-- 	-- ReactDOM.render is deprecated in React 18
		-- 	1
		-- )
		-- eslint-disable-next-line no-console
		-- expect((console.error :: any).mock.calls[
		-- 	1 -- ReactDOM.render is deprecated in React 18
		-- ][1]).toMatch("a test was not wrapped in act(...)")

		-- ROBLOX deviation END
	end)
end)
return {}

-- ROBLOX upstream: https://github.com/testing-library/react-testing-library/blob/v12.1.5/src/__tests__/render.js
return function()
	local Packages = script.Parent.Parent.Parent

	local JestGlobals = require(Packages.Dev.JestGlobals)
	local jestExpect = JestGlobals.expect
	local jest = JestGlobals.jest

	local document = require(Packages.DomTestingLibrary).document

	local CollectionService = game:GetService("CollectionService")

	local React = require(Packages.React)
	local ReactRoblox = require(Packages.ReactRoblox)
	local ParentModule = require(script.Parent.Parent)(afterEach)
	local render = ParentModule.render
	local screen = ParentModule.screen

	it("renders div into document", function()
		local ref = React.createRef()
		local container = render(React.createElement("Frame", { ref = ref })).container
		-- ROBLOX deviation START: replace firstChild with Instance equivalent
		jestExpect(container:GetChildren()[1]).toBe(ref.current)
		-- ROBLOX deviation END
	end)

	it("works great with react portals", function()
		-- ROBLOX deviation START: predeclare
		local Greet
		-- ROBLOX deviation END

		local MyPortal = React.Component:extend("MyPortal")

		function MyPortal:init(...: any)
			self.portalNode = Instance.new("Frame")
			CollectionService:AddTag(self.portalNode, "data-testid=my-portal")
		end

		function MyPortal:componentDidMount()
			self.portalNode.Parent = document
		end

		function MyPortal:componentWillUnmount()
			self.portalNode.Parent = nil
		end

		function MyPortal:render()
			return ReactRoblox.createPortal(
				React.createElement(Greet, { greeting = "Hello", subject = "World" }),
				self.portalNode
			)
		end

		function Greet(ref: { greeting: string, subject: string })
			local greeting, subject = ref.greeting, ref.subject
			return React.createElement(
				"Frame",
				nil,
				React.createElement("TextLabel", { Text = greeting .. " " .. subject })
			)
		end

		local unmount = render(React.createElement(MyPortal, nil)).unmount
		jestExpect(screen.getByText("Hello World")).toBeInTheDocument()
		local portalNode = screen.getByTestId("my-portal")
		jestExpect(portalNode).toBeInTheDocument()
		unmount()
		jestExpect(portalNode).never.toBeInTheDocument()
	end)

	it("returns baseElement which defaults to document.body", function()
		local baseElement = render(React.createElement("Frame", nil)).baseElement
		jestExpect(baseElement).toBe(document)
	end)

	-- ROBLOX deviation START: asFragment not supported
	-- it("supports fragments", function()
	-- 	local Test = React.Component:extend("Test")
	-- 	function Test:render()
	-- 		return React.createElement(
	-- 			"Frame",
	-- 			nil,
	-- 			React.createElement("code", nil, "DocumentFragment"),
	-- 			" is pretty cool!"
	-- 		)
	-- 	end
	-- 	local asFragment = render(React.createElement(Test, nil)).asFragment
	-- 	jestExpect(asFragment()).toMatchSnapshot()
	-- end)
	-- ROBLOX deviation END

	it("renders options.wrapper around node", function()
		local function WrapperComponent(ref)
			local children = ref.children
			return React.createElement("Frame", { [React.Tag] = "data-testid=wrapper" }, children)
		end

		local container = render(
			React.createElement("Frame", { [React.Tag] = "data-testid=inner" }),
			{ wrapper = WrapperComponent }
		).container

		jestExpect(screen.getByTestId("wrapper")).toBeInTheDocument()
		-- ROBLOX deviation START: replace to MatchInlineSnapshot
		jestExpect(CollectionService:GetTags(container:GetChildren()[1])).toContain("data-testid=wrapper")
		jestExpect(CollectionService:GetTags(container:GetChildren()[1]:GetChildren()[1])).toContain(
			"data-testid=inner"
		)
		-- ROBLOX deviation END
	end)

	-- ROBLOX FIXME: useEffect is triggered before unmount
	itFIXME("flushes useEffect cleanup functions sync on unmount()", function()
		local spy = jest.fn()
		local function Component()
			React.useEffect(function()
				spy()
			end, {})
			return nil
		end
		local unmount = render(React.createElement(Component, nil)).unmount
		jestExpect(spy).toHaveBeenCalledTimes(0)
		unmount()
		jestExpect(spy).toHaveBeenCalledTimes(1)
	end)
end

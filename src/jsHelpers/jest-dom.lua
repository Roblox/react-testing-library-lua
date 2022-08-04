-- ROBLOX upstream: no upstream
--[[
    ROBLOX comment: 
    reduce deviations by adding matchers based on testing-library/jest-dom
]]
local Packages = script.Parent.Parent.Parent
local document = require(Packages.DomTestingLibrary).document

local exports = {}

local function toBeInTheDocument(self, received: Instance, expected)
	local matcherName = "toBeInTheDocument"
	local options = {
		isNot = self.isNot,
		promise = self.promise,
	}
	local pass = received:IsDescendantOf(document)
	local message = function()
		return self.utils.matcherHint(matcherName, nil, nil, options) :: string
			.. "\n\n"
			.. (
				if self.isNot then "element was found in the document" else "element could not be found in the document"
			)
	end
	return { message = message, pass = pass }
end
exports.toBeInTheDocument = toBeInTheDocument

local function toBeEmptyDOMElement(self, received: Instance, expected)
	local matcherName = "toBeEmptyDOMElement"
	local options = {
		isNot = self.isNot,
		promise = self.promise,
	}
	local pass = #received:GetChildren() == 0
	local message = function()
		return self.utils.matcherHint(matcherName, nil, nil, options) :: string
			.. "\n\n"
			.. (if self.isNot then "element is empty" else "element is not empty")
	end
	return { message = message, pass = pass }
end
exports.toBeEmptyDOMElement = toBeEmptyDOMElement

return exports

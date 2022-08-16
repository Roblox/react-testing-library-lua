-- ROBLOX upstream: no upstream
local Root = script.Parent.Parent
local Packages = Root.Parent

local JestGlobals = require(Packages.JestGlobals)
local expect = JestGlobals.expect

local jsHelpers = Root.jsHelpers
local jestDomMatchers = require(jsHelpers["jest-dom"])
local matchers = require(jsHelpers.matchers)

expect.extend(jestDomMatchers)
expect.extend(matchers)

return {}

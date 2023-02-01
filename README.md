# React Testing Library Lua
Simple and complete testing utilities that encourage good testing practices.

**Ported version [v12.1.5](https://github.com/testing-library/react-testing-library/tree/v12.1.5)**

## Installation

At the moment, React Testing Library only works well with projects that are relying on Jest Roblox 3.0 or great. You can install react-testing-library-lua as a dev dependency using [Rotriever](https://github.com/roblox/rotriever):

```
[dev_dependencies]
ReactTestingLibrary = "github.com/roblox/react-testing-library-lua.git@12.1.5"
```

<hr />

## Table of Contents

- [The Problem](#the-problem)
- [This Solution](#this-solution)
- [Guiding Principles](#guiding-principles)
- [Requirements](#requirements)
- [Installation](#installation)
- [Deviations](#deviations)

## The Problem

You want to write maintainable tests for your React components. As a part of this goal, you want your tests to avoid including implementation details of your components and rather focus on making your tests give you the confidence for which they are intended. As part of this, you want your testbase to be maintainable in the long run so refactors of your components (changes to implementation but not functionality) don't break your tests and slow you and your team down.

## This Solution

The `React Testing Library` is a very light-weight solution for testing React components. It provides light utility functions on top of `react-roblox` in a way that encourages better testing practices.

Rather than dealing with instances of rendered React components, your tests will work with actual nodes. The utilities this library provides facilitate querying in the same way the user would. Finding form elements by their placeholder text (just like a user would), finding links and buttons from their text (like a user would). It also exposes a recommended way to find elements by a data-testid as an "escape hatch" for elements where the text content does not make sense or is not practical.

This library allows you to get your tests closer to using your components the way a user will, which allows your tests to give you more confidence that your application will work when a real user uses it.


## Guiding Principles

> [The more your tests resemble the way your software is used, the more
> confidence they can give you.][guiding-principle]

We try to only expose methods and utilities that encourage you to write tests
that closely resemble how your web pages are used.


## Requirements
`React Testing Library` requires `Jest-Roblox` v3 or higher. For more information on Jest-Roblox, check the documentation

**This guide assumes Jest-Roblox is installed and working**

## Installation

To install this library add it to your dev_dependencies in your rotriever.toml.

```
[dev_dependencies]
ReactTestingLibrary = "github.com/roblox/react-testing-library-lua@12.1.5"
```

Run `rotrieve install` to install React Testing Library Lua.

**Check the [the JS documentation](https://testing-library.com/docs/) for details. This guide focuses on deviations, and gives some examples.**

## Deviations
`React Testing Library` exposes the Core API from [dom-testing-library-lua](https://github.com/Roblox/dom-testing-library-lua). The same deviations described in its README apply to this library.

### TestId
TestId is implemented as a Tag. DOM version is implemented as an HTML element attribute.
The tag is declared as `<TEST_ID_ATTRIBUTE>=<VALUE>`. Like upstream, the attribute name by default is `data-testid` but can configured.

Basic example
```lua
local ref = React.createRef()
render(React.createElement("Frame",{ [React.Tag]= "data-testid=firstName" }))
expect(queryByTestId("firstName")).toBeTruthy()
```

### render
The `render` function will accept ReactElements instead of jsx (not available/supported)
```lua
local spy = jest.fn()
local function Component()
	React.useEffect(function()
		spy()
	end, {})
	return nil
end
local unmount = render(React.createElement(Component, nil)).unmount
expect(spy).toHaveBeenCalledTimes(0)
unmount()
expect(spy).toHaveBeenCalledTimes(1)
```


### Document
Because in Lua there is no concept of document, we provide one Instance that will be used as the default one. This will ensure that tags, and events work as expected, while keeping the test setup simple. It is reexported as is from `dom-testing-library-lua`.

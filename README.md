# ElectronDisplay

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/davidanthoff/ElectronDisplay.jl.svg?branch=master)](https://travis-ci.org/davidanthoff/ElectronDisplay.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/i2pk3rsm9ratt6vn/branch/master?svg=true)](https://ci.appveyor.com/project/davidanthoff/electrondisplay-jl/branch/master)
[![ElectronDisplay](http://pkg.julialang.org/badges/ElectronDisplay_0.6.svg)](http://pkg.julialang.org/?pkg=ElectronDisplay)
[![codecov.io](http://codecov.io/github/davidanthoff/ElectronDisplay.jl/coverage.svg?branch=master)](http://codecov.io/github/davidanthoff/ElectronDisplay.jl?branch=master)

## Overview

This package provides a display for figures and plots. When you load the
package, it will push a new display onto the julia display stack and from
then on it will display any value that can be rendered as png, svg or
vega-lite in an electron based window. This is especially handy when
one works on the REPL and wants plots to show up in a nice window.

## Getting Started

You can install the package via the normal julia package manger:
````julia
Pkg.add("ElectronDisplay")
````

As soon as you load the package with ``using ElectronDisplay``, it will
start to show plots that have the correct ``show`` methods in an electron
window.

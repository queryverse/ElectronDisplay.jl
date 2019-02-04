using Gadfly
using ElectronDisplay
using Electron
using Test

@testset "ElectronDisplay" begin

p1 = plot(y=[1,2,3])

f = display(p1)

@test f isa Electron.Window

ElectronDisplay.CONFIG.single_window = true

f = display(p1)

@test f === ElectronDisplay._getglobalwindow()

p2 = plot(y=[1,2,3])
f2 = display(p2)

@test f2 === f   # Window is reused

@test electrondisplay(@doc reduce) isa Electron.Window

end

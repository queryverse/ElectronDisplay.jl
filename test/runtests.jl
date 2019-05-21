using Gadfly
using ElectronDisplay
using Electron
using VegaDatasets
using Test

# Register ElectronDisplay in case this Julia session is started
# without RPEL.
if ElectronDisplay.ElectronDisplayType() ∉ Base.Multimedia.displays
    Base.Multimedia.pushdisplay(ElectronDisplay.ElectronDisplayType())
end

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

@testset "smoke test: single_window=$single_window focus=$focus " for
        single_window in [false, true],
        focus in [false, true]
    ElectronDisplay.CONFIG.single_window = single_window
    ElectronDisplay.CONFIG.focus = focus
    @test electrondisplay(dataset("cars")) isa Electron.Window
    @test electrondisplay(@doc reduce) isa Electron.Window
end

end

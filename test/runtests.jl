using Gadfly
using ElectronDisplay
using Electron
using VegaDatasets
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

eldt = ElectronDisplay.ElectronDisplayType()

@test displayable(eldt, "text/html") == true
@test displayable(eldt, "text/markdown") == true
@test displayable(eldt, "image/png") == true
@test displayable(eldt, "image/svg+xml") == true
@test displayable(eldt, "application/vnd.vegalite.v2+json") == true
@test displayable(eldt, "application/vnd.vega.v3+json") == true
@test displayable(eldt, "application/vnd.plotly.v1+json") == true
@test displayable(eldt, "application/vnd.dataresource+json") == true

@testset "smoke test: single_window=$single_window focus=$focus " for
        single_window in [false, true],
        focus in [false, true]
    ElectronDisplay.CONFIG.single_window = single_window
    ElectronDisplay.CONFIG.focus = focus
    @test electrondisplay(dataset("cars")) isa Electron.Window
    @test electrondisplay(@doc reduce) isa Electron.Window

    config = (single_window=single_window, focus=focus)
    @test electrondisplay(dataset("cars"); config...) isa Electron.Window
    @test electrondisplay(@doc reduce; config...) isa Electron.Window
end

end

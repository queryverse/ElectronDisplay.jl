using ElectronDisplay
using Electron
using VegaLite
using DataFrames
using Test

@testset "ElectronDisplay" begin

p1 =  DataFrame(x=rand(10),y=rand(10)) |> @vlplot(:point, x=:x, y=:y)

f = display(p1)

@test f isa Electron.Window

ElectronDisplay.CONFIG.single_window = true

f = display(p1)

@test f === ElectronDisplay._getglobalwindow()

p2 = DataFrame(x=rand(10),y=rand(10)) |> @vlplot(:point, x=:x, y=:y)
f2 = display(p2)

@test f2 === f   # Window is reused

end

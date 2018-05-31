using ElectronDisplay
using Gadfly
using Base.Test

@testset "ElectronDisplay" begin

p1 = plot(x=rand(10),y=rand(10),Geom.point)

f = display(p1)

@test f isa Electron.Window

end

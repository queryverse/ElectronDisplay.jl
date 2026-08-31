@testitem "ElectronDisplay" begin
    using Gadfly
    using Electron
    using VegaDatasets

    Electron.prep_test_env()

    struct DummyDisplayable{M}
        data
    end

    Base.show(io::IO, m::M, x::DummyDisplayable{M}) where {M} = print(io, x.data)

    # These are normally defined in Vega.jl and VegaLite.jl, but because we don't use
    # those packages here, we redefine them just for the tests
    Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vega.v3+json")}) = true
    Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vega.v4+json")}) = true
    Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vega.v5+json")}) = true
    Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vegalite.v2+json")}) = true
    Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vegalite.v3+json")}) = true
    Base.Multimedia.istextmime(::MIME{Symbol("application/vnd.vegalite.v4+json")}) = true

    include("testhelper_construct_vega_specs.jl")

    try
        p1 = plot(y=[1,2,3])

        f = display(p1)

        @test f isa Electron.Window

        ElectronDisplay.CONFIG.single_window = true

        f = display(p1)

        @test f === ElectronDisplay._getglobalplotwindow()

        p2 = plot(y=[1,2,3])
        f2 = display(p2)

        @test f2 === f   # Window is reused

        eldt = ElectronDisplay.ElectronDisplayType()

        @test electrondisplay(vl2) isa Electron.Window
        @test electrondisplay(vl3) isa Electron.Window
        @test electrondisplay(vg3) isa Electron.Window
        @test electrondisplay(vg4) isa Electron.Window
        @test electrondisplay(vg5) isa Electron.Window

        @test_logs(
        (:warn, r"The size of JSON representation.*exceeds.*max_json_bytes"),
        electrondisplay(vl3png; max_json_bytes=-1)::Electron.Window
    )

        mdo = DummyDisplayable{MIME"text/markdown"}("""foo""")
        @test electrondisplay(mdo) isa Electron.Window

        pngo = DummyDisplayable{MIME"image/png"}("""fakedata""")
        @test electrondisplay(pngo) isa Electron.Window

        dro = DummyDisplayable{MIME"application/vnd.dataresource+json"}("""{"schema":{"fields":[{"name": "Miles_per_Gallon","type": "number"}]},"data":[{"Miles_per_Gallon":18}]}""")
        @test electrondisplay(dro) isa Electron.Window

        @test displayable(eldt, "text/html") == true
        @test displayable(eldt, "text/markdown") == true
        @test displayable(eldt, "image/png") == true
        @test displayable(eldt, "image/svg+xml") == true
        @test displayable(eldt, "application/vnd.vegalite.v2+json") == true
        @test displayable(eldt, "application/vnd.vegalite.v3+json") == true
        @test displayable(eldt, "application/vnd.vegalite.v4+json") == true
        @test displayable(eldt, "application/vnd.vega.v3+json") == true
        @test displayable(eldt, "application/vnd.vega.v4+json") == true
        @test displayable(eldt, "application/vnd.vega.v5+json") == true
        @test displayable(eldt, "application/vnd.plotly.v1+json") == true
        @test displayable(eldt, "application/vnd.dataresource+json") == true

        @testset "smoke test: single_window=$single_window focus=$focus " for single_window in [false, true],
            focus in [false, true]
            ElectronDisplay.CONFIG.single_window = single_window
            ElectronDisplay.CONFIG.focus = focus
            @test electrondisplay(dataset("cars")) isa Electron.Window
            @test electrondisplay(@doc reduce) isa Electron.Window

            config = (single_window = single_window, focus = focus)
            @test electrondisplay(dataset("cars"); config...) isa Electron.Window
            @test electrondisplay(@doc reduce; config...) isa Electron.Window
        end
    finally
        # Close every window opened during the test. Each window is closed at most
        # once, from a snapshot of the window list: `close(app)` instead loops over
        # `windows(app)`, and re-closes a window whose asynchronous "windowclosed"
        # notification has not arrived yet -- Electron never replies to a close for a
        # window it already destroyed, so that call blocks forever.
        for app in Electron.applications()
            app.exists || continue
            for win in copy(Electron.windows(app))
                win.exists && close(win)
            end
        end
    end
end

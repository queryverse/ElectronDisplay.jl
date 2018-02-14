__precompile__()
module ElectronDisplay

using Electron

struct ElectronDisplayType <: Base.Display end


# function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/png")}, x)
#     payload = stringmime(MIME("image/png"), x)
#     print(conn, "image/png", ":", endof(payload), ";")
#     print(conn, payload)
# end

# Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/png")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}, x)
    w = Electron.Window()

    payload = stringmime(MIME("image/svg+xml"), x)

    body!(w, payload)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}) = true

# function Base.display(d::ElectronDisplayType, ::MIME{Symbol("text/html")}, x)
#     payload = stringmime(MIME("text/html"), x)
#     print(conn, "text/html", ":", endof(payload), ";")
#     print(conn, payload)
# end

# Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("text/html")}) = true

function Base.display(d::ElectronDisplayType, x)
    # if mimewritable("text/html", x)
    #     display(d,"text/html", x)
    if mimewritable("image/svg+xml", x)
        display(d,MIME("image/svg+xml"), x)
    # elseif mimewritable("image/png", x)
    #     display(d,"image/png", x)
    else
        throw(MethodError(Base.display,(d,x)))
    end
end

function __init__()
    # atreplinit(i->Base.Multimedia.pushdisplay(InlineDisplay()))
    Base.Multimedia.pushdisplay(ElectronDisplayType())
end

end # module

__precompile__()
module ElectronDisplay

using Electron

struct ElectronDisplayType <: Base.Display end


function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/png")}, x)
    img = stringmime(MIME("image/png"), x)

    payload = string("<img src=\"data:image/png;base64,", img, "\"/>")

    w = Electron.Window(payload)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/png")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}, x)
    payload = stringmime(MIME("image/svg+xml"), x)

    w = Electron.Window(payload)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}) = true

asset(url...) = replace(normpath(joinpath(@__DIR__, "..", "assets", "vega", url...)), "\\", "/")

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}, x)
    payload = stringmime(MIME("application/vnd.vegalite.v2+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file:///$(asset("vega.min.js"))"></script>
        <script src="file:///$(asset("vega-lite.min.js"))"></script>
        <script src="file:///$(asset("vega-embed.min.js"))"></script>
    </head>
    <body>
      <div id="plotdiv"></div>
    </body>

    <style media="screen">
      .vega-actions a {
        margin-right: 10px;
        font-family: sans-serif;
        font-size: x-small;
        font-style: italic;
      }
    </style>

    <script type="text/javascript">

      var opt = {
        mode: "vega-lite",
        actions: false
      }

      var spec = $payload

      vegaEmbed('#plotdiv', spec, opt);

    </script>

    </html>
    """

    w = Electron.Window(html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}) = true

function Base.display(d::ElectronDisplayType, x)
    if mimewritable("application/vnd.vegalite.v2+json", x)
        display(d,MIME("application/vnd.vegalite.v2+json"), x)
    elseif mimewritable("image/svg+xml", x)
        display(d,"image/svg+xml", x)
    elseif mimewritable("image/png", x)
        display(d,"image/png", x)
    else
        throw(MethodError(Base.display,(d,x)))
    end
end

function __init__()
    Base.Multimedia.pushdisplay(ElectronDisplayType())
end

end # module

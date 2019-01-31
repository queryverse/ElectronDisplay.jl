module ElectronDisplay

using Electron, Base64

struct ElectronDisplayType <: Base.AbstractDisplay end

mutable struct ElectronDisplayConfig
    showable
    single_window::Bool
end

"""
    ElectronDisplay.CONFIG

Configuration for ElectronDisplay.

* `showable = Base.showable`: A function with signature
  `showable(mime::String, x::Any) :: Bool`.  This determines if object
  `x` is displayed by `ElectronDisplay`.  Default to `Base.showable`.

* `single_window::Bool = false`: If `true`, reuse existing window for
  displaying a new content.  If `false` (default), create a new window
  for each display.
"""
const CONFIG = ElectronDisplayConfig(showable, false)

const _window = Ref{Window}()

function _getglobalwindow()
    if !(isdefined(_window, 1) && _window[].exists)
        _window[] = Electron.Window(
            URI("about:blank"),
            options=Dict("webPreferences" => Dict("webSecurity" => false)))
    end
    return _window[]
end

function displayhtml(payload; kwargs...)
    if CONFIG.single_window
        w = _getglobalwindow()
        load(w, payload)
        run(w.app, "BrowserWindow.fromId($(w.id)).show()")
        return w
    else
        return Electron.Window(payload; kwargs...)
    end
end


Base.display(d::ElectronDisplayType, ::MIME{Symbol("text/html")}, x) =
    displayhtml(repr("text/html", x))

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("text/html")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("text/markdown")}, x)
    html_page = string(
        """
        <!doctype html>
        <html>

        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="file:///$(asset("github-markdown-css", "github-markdown.css"))">
        <style>
            .markdown-body {
                box-sizing: border-box;
                padding: 15px;
            }
        </style>
        </head>
        <body>
        <article class="markdown-body">
        """,
        repr("text/html", x),
        """
         </article>
        </body>
         </html>
        """,
    )
    displayhtml(html_page)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("text/markdown")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/png")}, x)
    img = stringmime(MIME("image/png"), x)

    payload = string("<img src=\"data:image/png;base64,", img, "\"/>")

    displayhtml(payload)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/png")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}, x)
    payload = stringmime(MIME("image/svg+xml"), x)

    displayhtml(payload)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}) = true

asset(url...) = replace(normpath(joinpath(@__DIR__, "..", "assets", url...)), "\\" => "/")

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}, x)
    payload = stringmime(MIME("application/vnd.vegalite.v2+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file:///$(asset("vega", "vega.min.js"))"></script>
        <script src="file:///$(asset("vega", "vega-lite.min.js"))"></script>
        <script src="file:///$(asset("vega", "vega-embed.min.js"))"></script>
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

    displayhtml(html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v3+json")}, x)
    payload = stringmime(MIME("application/vnd.vega.v3+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file:///$(asset("vega", "vega.min.js"))"></script>
        <script src="file:///$(asset("vega", "vega-embed.min.js"))"></script>
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
        mode: "vega",
        actions: false
      }

      var spec = $payload

      vegaEmbed('#plotdiv', spec, opt);

    </script>

    </html>
    """

    displayhtml(html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v3+json")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.plotly.v1+json")}, x)
    payload = stringmime(MIME("application/vnd.plotly.v1+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file:///$(asset("plotly", "plotly-latest.min.js"))"></script>
    </head>
    <body>
    </body>

    <script type="text/javascript">
        gd = (function() {
            var WIDTH_IN_PERCENT_OF_PARENT = 100
            var HEIGHT_IN_PERCENT_OF_PARENT = 100;
            var gd = Plotly.d3.select('body')
                .append('div').attr("id", "plotdiv")
                .style({
                    width: WIDTH_IN_PERCENT_OF_PARENT + '%',
                    'margin-left': (100 - WIDTH_IN_PERCENT_OF_PARENT) / 2 + '%',
                    height: HEIGHT_IN_PERCENT_OF_PARENT + 'vh',
                    'margin-top': (100 - HEIGHT_IN_PERCENT_OF_PARENT) / 2 + 'vh'
                })
                .node();
            var spec = $payload
            Plotly.newPlot(gd, spec.data, spec.layout);
            window.onresize = function() {
                Plotly.Plots.resize(gd);
                };
            return gd;
        })();
    </script>

    </html>
    """

    displayhtml(html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.plotly.v1+json")}) = true

function Base.display(d::ElectronDisplayType, x)
    if CONFIG.showable("application/vnd.vegalite.v2+json", x)
        display(d,MIME("application/vnd.vegalite.v2+json"), x)
    elseif CONFIG.showable("application/vnd.vega.v3+json", x)
            display(d,MIME("application/vnd.vega.v3+json"), x)
    elseif CONFIG.showable("application/vnd.plotly.v1+json", x)
            display(d,MIME("application/vnd.plotly.v1+json"), x)
    elseif CONFIG.showable("image/svg+xml", x)
        display(d,"image/svg+xml", x)
    elseif CONFIG.showable("image/png", x)
        display(d,"image/png", x)
    elseif CONFIG.showable("text/markdown", x)
        display(d, "text/markdown", x)
    elseif CONFIG.showable("text/html", x)
        display(d, "text/html", x)
    else
        throw(MethodError(Base.display,(d,x)))
    end
end

function __init__()
    Base.Multimedia.pushdisplay(ElectronDisplayType())
end

end # module

module ElectronDisplay

export electrondisplay

using Electron, Base64, Markdown

import IteratorInterfaceExtensions, TableTraits, TableShowUtils

using FilePaths

asset(url...) = replace(normpath(joinpath(@__DIR__, "..", "assets", url...)), "\\" => "/")
react_html_url = join(@__PATH__, "..", "assets", "plotgallery", "index.html")

Base.@kwdef mutable struct ElectronDisplayConfig
    showable = electron_showable
    single_window::Bool = false
    focus::Bool = true
    max_json_bytes::Int = 2^20
end

"""
    setconfig(config; kwargs...)

Update a copy of `config` based on `kwargs`.
"""
setconfig(
    config::ElectronDisplayConfig;
    showable = config.showable,
    single_window::Bool = config.single_window,
    focus::Bool = config.focus,
    max_json_bytes::Int = config.max_json_bytes,
) =
    ElectronDisplayConfig(
        showable = showable,
        single_window = single_window,
        focus = focus,
        max_json_bytes = max_json_bytes,
    )

struct ElectronDisplayType <: Base.AbstractDisplay
    config::ElectronDisplayConfig
end

ElectronDisplayType() = ElectronDisplayType(CONFIG)
newdisplay(; config...) = ElectronDisplayType(setconfig(CONFIG; config...))

electron_showable(m, x) =
    m ∉ ("application/vnd.dataresource+json", "text/html", "text/markdown") &&
    showable(m, x)

"""
    ElectronDisplay.CONFIG

Configuration for ElectronDisplay.

* `showable`: A callable with signature `showable(mime::String,
  x::Any) :: Bool`.  This determines if object `x` is displayed by
  `ElectronDisplay`.  Default is to return `false` if `mime` is
  `"text/html"` or `"text/markdown"` and otherwise fallbacks to
  `Base.showable(mime, x)`.

* `single_window::Bool = false`: If `true`, reuse existing window for
  displaying a new content.  If `false` (default), create a new window
  for each display.

* `focus::Bool = true`: Focus the Electron window on `display` if `true`
  (default).

* `max_json_bytes::Int = $(ElectronDisplayConfig().max_json_bytes)`:
  Maximum size in bytes for which JSON representation is used.  Otherwise,
  convert visualization locally in a binary form before sending it to the
  Electron display.  Currently only Vega and Vega-Lite support this.
"""
const CONFIG = ElectronDisplayConfig()

const _window = Ref{Window}()

function _getglobalwindow()
    if !(isdefined(_window, 1) && _window[].exists)
        _window[] = Electron.Window(
            URI("about:blank"),
            options=Dict("webPreferences" => Dict("webSecurity" => false)))
    end
    return _window[]
end

const _plot_window = Ref{Window}()

function _getglobalplotwindow()
    if !(isdefined(_plot_window, 1) && _plot_window[].exists)
        _plot_window[] = Electron.Window(
            URI(react_html_url),
            options=Dict("webPreferences" => Dict("webSecurity" => false)))
    end
    return _plot_window[]
end

function displayplot(d::ElectronDisplayType, type::String, data; options::Dict=Dict{String,Any}())
    w = _getglobalplotwindow()
    run(w, "addPlot({type: '$(type)', data: $(data)})")

    showfun = get(options, "show", d.config.focus) ? "show" : "showInactive"
    run(w.app, "BrowserWindow.fromId($(w.id)).$showfun()")
end

function displayhtml(d::ElectronDisplayType, payload; options::Dict=Dict{String,Any}())
    if d.config.single_window
        w = _getglobalwindow()
        load(w, payload)
        showfun = get(options, "show", d.config.focus) ? "show" : "showInactive"
        run(w.app, "BrowserWindow.fromId($(w.id)).$showfun()")
        return w
    else
        options = Dict{String,Any}(options)
        get!(options, "show", d.config.focus)
        return Electron.Window(payload; options=options)
    end
end

displayhtmlbody(d::ElectronDisplayType, payload) =
    displayhtml(d, string(
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

        <link rel="stylesheet" href="file://$(asset("katex-0.11.1", "katex.min.css"))" integrity="sha384-zB1R0rpPzHqg7Kpt0Aljp8JPLqbXI3bhnPWROx27a9N0Ll6ZP/+DiW/UqRcLbRjq" crossorigin="anonymous">
        <script defer src="file://$(asset("katex-0.11.1", "katex.min.js"))" integrity="sha384-y23I5Q6l+B6vatafAwxRu/0oK/79VlbSz7Q9aiSZUvyWYIYsd+qj+o24G5ZU2zJz" crossorigin="anonymous"></script>
        <script defer src="file://$(asset("katex-0.11.1", "auto-render.min.js"))" integrity="sha384-kWPLUVMOks5AQFrykwIup5lo0m3iMkkHrD0uJ4H5cjeGihAutqP0yW0J6dpFiVkI" crossorigin="anonymous"
            onload="renderMathInElement(document.body, {delimiters: [{left: '\$', right: '\$', display: false}]});"></script>

        </head>
        <body>
        <article class="markdown-body">
        """,
        payload,
        """
         </article>
        </body>
         </html>
        """,
    ))


function Base.display(d::ElectronDisplayType, ::MIME{Symbol("text/html")}, x)
    html_page = repr("text/html", x)
    if occursin(r"<html\b"i, html_page)
        # Detect if object `x` rendered itself as a "standalone" HTML page.
        # If so, display it as-is:
        displayhtml(d, html_page)
    else
        # Otherwise, i.e., if `x` only produced an HTML fragment, apply
        # our default CSS to it:
        displayhtmlbody(d, html_page)
    end
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("text/html")}) = true

Base.display(d::ElectronDisplayType, ::MIME{Symbol("text/markdown")}, x) =
    displayhtmlbody(d, repr("text/html", asmarkdown(x)))

asmarkdown(x::Markdown.MD) = x
asmarkdown(x) = Markdown.parse(repr("text/markdown", x))

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("text/markdown")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/png")}, x)
    img = stringmime(MIME("image/png"), x)

    imgdata = "`data:image/png;base64, $(img)`"

    displayplot(d, "image", imgdata)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/png")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}, x)
    img = stringmime(MIME("image/svg+xml"), x)
    imgdata = "`data:image/svg+xml;utf8, $(img)`" # SVG does not need base64 encoding

    # TODO Is there are more elegant way to to this?
    imgdata = replace(imgdata, "#"=>"%23")

    displayplot(d, "image", imgdata)
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("image/svg+xml")}) = true

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

    displayhtml(d, html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.plotly.v1+json")}) = true

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.dataresource+json")}, x)
    payload = stringmime(MIME("application/vnd.dataresource+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file://$(asset("ag-grid", "ag-grid-community.min.noStyle.js"))"></script>
        <link rel="stylesheet" href="file://$(asset("ag-grid", "ag-grid.css"))">
        <link rel="stylesheet" href="file://$(asset("ag-grid", "ag-theme-balham.css"))">
    </head>
    <body>
        <div id="myGrid" style="height: 100%; width: 100%;" class="ag-theme-balham"></div>
    </body>

    <script type="text/javascript">
        var payload = $payload;
        var gridOptions = {
            onGridReady: event => event.api.sizeColumnsToFit(),
            onGridSizeChanged: event => event.api.sizeColumnsToFit(),
            defaultColDef: {
                resizable: true,
                filter: true,
                sortable: true
            },
            columnDefs: payload.schema.fields.map(function(x) {
                if (x.type == "number" || x.type == "integer") {
                    return {
                        field: x.name,
                        type: "numericColumn",
                        filter: "agNumberColumnFilter"
                    };
                } else if (x.type == "date") {
                    return {
                        field: x.name,
                        filter: "agDateColumnFilter"
                    };
                } else {
                    return {field: x.name};
                };
            }),
            rowData: payload.data
        };
        var eGridDiv = document.querySelector('#myGrid');
        new agGrid.Grid(eGridDiv, gridOptions);
    </script>

    </html>
    """

    displayhtml(d, html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.dataresource+json")}) = true

function Base.display(d::ElectronDisplayType, x)
    showable = d.config.showable
    if showable("application/vnd.vegalite.v4+json", x)
        display(d,MIME("application/vnd.vegalite.v4+json"), x)
    elseif showable("application/vnd.vegalite.v3+json", x)
        display(d,MIME("application/vnd.vegalite.v3+json"), x)
    elseif showable("application/vnd.vegalite.v2+json", x)
        display(d,MIME("application/vnd.vegalite.v2+json"), x)
    elseif showable("application/vnd.vega.v5+json", x)
        display(d,MIME("application/vnd.vega.v5+json"), x)
    elseif showable("application/vnd.vega.v4+json", x)
        display(d,MIME("application/vnd.vega.v4+json"), x)
    elseif showable("application/vnd.vega.v3+json", x)
        display(d,MIME("application/vnd.vega.v3+json"), x)
    elseif showable("application/vnd.plotly.v1+json", x)
        display(d,MIME("application/vnd.plotly.v1+json"), x)
    elseif showable("application/vnd.dataresource+json", x)
        display(d, "application/vnd.dataresource+json", x)
    elseif showable("image/svg+xml", x)
        display(d,"image/svg+xml", x)
    elseif showable("image/png", x)
        display(d,"image/png", x)
    elseif showable("text/html", x)
        display(d, "text/html", x)
    elseif showable("text/markdown", x)
        display(d, "text/markdown", x)
    else
        throw(MethodError(Base.display,(d,x)))
    end
end

"""
    electrondisplay([mime,] x; config...)

Show `x` in Electron window.  Use MIME `mime` if specified.  The keyword
arguments can be used to override [`ElectronDisplay.CONFIG`](@ref) without
mutating it.

# Examples
```julia
electrondisplay(@doc reduce; single_window=true, focus=false)
```
"""
electrondisplay(mime, x; config...) = display(newdisplay(; config...), mime, x)

struct DataresourceTableTraitsWrapper{T}
    source::T
end

function Base.show(io::IO, ::MIME"application/vnd.dataresource+json", source::DataresourceTableTraitsWrapper)
    TableShowUtils.printdataresource(io, IteratorInterfaceExtensions.getiterator(source.source))
end

Base.showable(::MIME"application/vnd.dataresource+json", dt::DataresourceTableTraitsWrapper) = true

struct CachedDataResourceString
    content::String
end

Base.show(io::IO, ::MIME"application/vnd.dataresource+json", source::CachedDataResourceString) = print(io, source.content)

Base.showable(::MIME"application/vnd.dataresource+json", dt::CachedDataResourceString) = true

function electrondisplay(x; config...)
    d = newdisplay(; showable=showable, config...)
    if TableTraits.isiterabletable(x)!==false
        if showable("application/vnd.dataresource+json", x)
            display(d, x)
        elseif TableTraits.isiterabletable(x)===true
            display(d, DataresourceTableTraitsWrapper(x))
        else
            try
                buffer = IOBuffer()
                TableShowUtils.printdataresource(buffer, IteratorInterfaceExtensions.getiterator(x))

                buffer_asstring = CachedDataResourceString(String(take!(buffer)))
                display(d, buffer_asstring)
            catch err
                display(d, x)
            end
        end
    else
        display(d, x)
    end
end

include("vega.jl")

function __init__()
    Base.Multimedia.pushdisplay(ElectronDisplayType())
end

end # module

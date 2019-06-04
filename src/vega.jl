Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}) = true
Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v3+json")}) = true
Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v3+json")}) = true
Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v4+json")}) = true
Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v5+json")}) = true

function _display_vegalite(d, major_version_vegalite, major_version_vega, x)
    payload = stringmime(MIME("application/vnd.vegalite.v$major_version_vegalite+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file:///$(asset("vega-$major_version_vega", "vega.min.js"))"></script>
        <script src="file:///$(asset("vega-lite-$major_version_vegalite", "vega-lite.min.js"))"></script>
        <script src="file:///$(asset("vega-embed", "vega-embed.min.js"))"></script>
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

    displayhtml(d, html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

function _display_vega(d, major_version, x)
    payload = stringmime(MIME("application/vnd.vega.v$major_version+json"), x)

    html_page = """
    <html>

    <head>
        <script src="file:///$(asset("vega-$major_version", "vega.min.js"))"></script>
        <script src="file:///$(asset("vega-embed", "vega-embed.min.js"))"></script>
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

    displayhtml(d, html_page, options=Dict("webPreferences" => Dict("webSecurity" => false)))  
end

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}, x)
    return _display_vegalite(d, "2", "3", x)
end

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v3+json")}, x)
    return _display_vegalite(d, "3", "5", x)
end

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v3+json")}, x)
    return _display_vega(d, "3", x)
end

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v4+json")}, x)
    return _display_vega(d, "4", x)
end

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v5+json")}, x)
    return _display_vega(d, "5", x)
end

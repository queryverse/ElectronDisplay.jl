Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}) = true
Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v3+json")}) = true
Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v4+json")}) = true
Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v3+json")}) = true
Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v4+json")}) = true
Base.displayable(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vega.v5+json")}) = true

function _maybe_fallback_to(mime, d, x, payload)
    if sizeof(payload) > d.config.max_json_bytes
        @warn string(
            "The size of JSON representation (", sizeof(payload), ")",
            " exceeds `max_json_bytes = ", d.config.max_json_bytes, "`.",
            " Falling back to $mime."
        )
        return display(d, mime, x)
    end
    return nothing
end

function _display_vegalite(d, major_version_vegalite, major_version_vega, x)
    payload = stringmime(MIME("application/vnd.vegalite.v$major_version_vegalite+json"), x)
    ans = _maybe_fallback_to(MIME"image/png"(), d, x, payload)
    ans === nothing || return ans
    displayplot(d, "vega-lite", JSON.JSONText(payload), options=Dict("webPreferences" => Dict("webSecurity" => false)))
end

function _display_vega(d, major_version, x)
    payload = stringmime(MIME("application/vnd.vega.v$major_version+json"), x)
    ans = _maybe_fallback_to(MIME"image/png"(), d, x, payload)
    ans === nothing || return ans
    displayplot(d, "vega", JSON.JSONText(payload), options=Dict("webPreferences" => Dict("webSecurity" => false)))  
end

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v2+json")}, x)
    return _display_vegalite(d, "2", "3", x)
end

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v3+json")}, x)
    return _display_vegalite(d, "3", "5", x)
end

function Base.display(d::ElectronDisplayType, ::MIME{Symbol("application/vnd.vegalite.v4+json")}, x)
    return _display_vegalite(d, "4", "5", x)
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

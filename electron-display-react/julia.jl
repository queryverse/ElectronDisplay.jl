#!/usr/bin/env julia

using Electron, URIParser

asset(url...) = replace(normpath(joinpath(@__DIR__, "build", url...)), "\\" => "/")

app = Application()

win = Window(app, URI("file://$(asset("index.html"))"))

run(win, """
  addPlot({type: "image", data: "data:image/png;base64,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"})
""")


run(win, """addPlot({type: "vega", data:
{
    "\$schema": "https://vega.github.io/schema/vega/v5.json",
"width": 500,
"height": 200,
"padding": 5,

"signals": [
{
  "name": "interpolate",
  "value": "linear",
  "bind": {
    "input": "select",
    "options": [
      "basis",
      "cardinal",
      "catmull-rom",
      "linear",
      "monotone",
      "natural",
      "step",
      "step-after",
      "step-before"
    ]
  }
}
],

"data": [
{
  "name": "table",
  "values": [
    {"x": 0, "y": 28, "c":0}, {"x": 0, "y": 20, "c":1},
    {"x": 1, "y": 43, "c":0}, {"x": 1, "y": 35, "c":1},
    {"x": 2, "y": 81, "c":0}, {"x": 2, "y": 10, "c":1},
    {"x": 3, "y": 19, "c":0}, {"x": 3, "y": 15, "c":1},
    {"x": 4, "y": 52, "c":0}, {"x": 4, "y": 48, "c":1},
    {"x": 5, "y": 24, "c":0}, {"x": 5, "y": 28, "c":1},
    {"x": 6, "y": 87, "c":0}, {"x": 6, "y": 66, "c":1},
    {"x": 7, "y": 17, "c":0}, {"x": 7, "y": 27, "c":1},
    {"x": 8, "y": 68, "c":0}, {"x": 8, "y": 16, "c":1},
    {"x": 9, "y": 49, "c":0}, {"x": 9, "y": 25, "c":1}
  ]
}
],

"scales": [
{
  "name": "x",
  "type": "point",
  "range": "width",
  "domain": {"data": "table", "field": "x"}
},
{
  "name": "y",
  "type": "linear",
  "range": "height",
  "nice": true,
  "zero": true,
  "domain": {"data": "table", "field": "y"}
},
{
  "name": "color",
  "type": "ordinal",
  "range": "category",
  "domain": {"data": "table", "field": "c"}
}
],

"axes": [
{"orient": "bottom", "scale": "x"},
{"orient": "left", "scale": "y"}
],

"marks": [
{
  "type": "group",
  "from": {
    "facet": {
      "name": "series",
      "data": "table",
      "groupby": "c"
    }
  },
  "marks": [
    {
      "type": "line",
      "from": {"data": "series"},
      "encode": {
        "enter": {
          "x": {"scale": "x", "field": "x"},
          "y": {"scale": "y", "field": "y"},
          "stroke": {"scale": "color", "field": "c"},
          "strokeWidth": {"value": 2}
        },
        "update": {
          "interpolate": {"signal": "interpolate"},
          "fillOpacity": {"value": 1}
        },
        "hover": {
          "fillOpacity": {"value": 0.5}
        }
      }
    }
  ]
}
]
}})""")

run(win, """switchTo(1)""")


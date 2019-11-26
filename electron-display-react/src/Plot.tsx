import React from 'react';
import { Vega, VegaLite } from 'react-vega';
// import { VisualizationSpec } from 'vega-embed';
import { vega } from 'vega-embed';
import { compile, TopLevelSpec } from 'vega-lite';
import { PlotData } from './App';

export type PlotProps = {
    plot: PlotData | null,
    onThumbnailUpdate: (thumbnailURL:string) => void
}

/* Example spec:
addPlot({type: "vega", data:
    {
        "$schema": "https://vega.github.io/schema/vega/v5.json",
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
}})*/

const Plot = ({plot, onThumbnailUpdate} : PlotProps) => {
  if (plot) {
    // console.log(plot.data);

    // For developers: uncomment the code below to expose vega
    (window as any).vega = vega;
    switch (plot.type) {
      case "vega":
        if (!plot.thumbnail) {
          // render a thumbnail if there is no thumbnail in the plot object
          new vega.View(vega.parse(plot.data)).initialize().toCanvas().then(canvas =>
            (onThumbnailUpdate(canvas.toDataURL()))
          );
        }
        return (
          <Vega spec={plot.data} className="vega-plot"/>
        );
      case "vega-lite":
        if (!plot.thumbnail) {
          new vega.View(vega.parse(compile(plot.data as TopLevelSpec).spec)).initialize().toCanvas().then(canvas =>
            (onThumbnailUpdate(canvas.toDataURL()))
          );
        }
        return (
          <VegaLite spec={plot.data} className="vegalite-plot"/>
        );
      case "image":
        if (!plot.thumbnail) {
          plot.thumbnail = plot.data.toString();
        }
        return <img src={plot.data} alt="Plot"></img>
      default:
        return <p>Unsupported plot type: {plot.type}</p>
    }
  }
  return null;
}

export default Plot;

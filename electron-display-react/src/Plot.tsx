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

const Plot = ({plot, onThumbnailUpdate} : PlotProps) => {
  if (plot) {
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

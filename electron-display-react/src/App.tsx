import React, {Component} from 'react';
import Thumbnail from './Thumbnail'
import Plot from './Plot';

import './App.css';

export type PlotData = {
  type: string,
  data: any,
  thumbnail: string | null,
}

type AppState = {
  plots: any[],
  index: number,
}

export class App extends Component<{}, AppState> {
  constructor(props: {}) {
    super(props);
    this.state = {
      plots: [],
      index: 0
    };
    (window as any).addPlot = this.addPlot;
    (window as any).switchTo = this.switchTo;
  }

  addPlot = (plot: PlotData) => {
    this.setState((state) => (
      {
        ...state,
        plots: [...state.plots, plot],
      }
    ));
  }

  switchTo = (index: number) => {
    this.setState((state) => (
      {
        ...state,
        index,
      }
    ));
  }

  updateThumbnail = (index:number, thumbnailURL:string) => {
    let plots = this.state.plots.slice();
    plots[index].thumbnail = thumbnailURL;
    this.setState((state) => (
      {
        ...state,
        plots: plots,
      }
    ));
  }

  render = () => (
    <div className="App">
      <div className="left-panel">
        {this.state.plots.map((_, index) => <Thumbnail key={index} index={index} thumbnailURL={this.state.plots[index].thumbnail} onClick={()=>{this.switchTo(index)}}  />)}
      </div>
      <div className="main-plot">
        <Plot plot={this.state.plots[this.state.index] ? this.state.plots[this.state.index] : null} onThumbnailUpdate={(thumbnailURL) => this.updateThumbnail(this.state.index, thumbnailURL)}/>
      </div>
    </div>
  );

}

export default App;
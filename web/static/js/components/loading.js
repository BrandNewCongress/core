import React, { Component } from 'react'

const bncColors = [
  'rgb(95, 39, 135)',
  'white',
  'rgb(95, 39, 135)',
  'white',
]

const jdColors = [
  '#F6FF00',
  '#5B919F',
  '#F6FF00',
  '#5B919F',
]

export default class Loading extends Component {
  render() {
    const { brand } = window.opts

    return brand == 'jd' ? this.renderJDLoading(jdColors) : this.renderBNCLoading(bncColors)
  }

  renderBNCLoading(colors) {
    return (
      <div className="loading" {...this.props} >
        {new Array(4).fill(null).map((_, idx) => (
          <div className="loading-bar" style={{backgroundColor: colors[idx]}}/>
        ))}
      </div>
    )
  }

  renderJDLoading(colors) {
    return this.renderBNCLoading(colors)
  }
}

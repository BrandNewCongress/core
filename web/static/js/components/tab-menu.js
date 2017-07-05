import React, { Component } from 'react'

export default class TabMenu extends Component {
  state = {
    selected: []
  }

  select = (level, idx, o) => () => {
    this.setState({
      selected: this.state.selected.splice(0, level).concat([idx])
    })

    this.props.onSelect(o.key)
  }

  componentWillMount() {
    this.state.selected = this.state.selected.concat(this.props.initialSelected)
  }

  render() {
    const { options, initialSelected } = this.props

    return (
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-around',
          alignItems: 'flex',
          width: '100%',
          flexDirection: 'column'
        }}
        >
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-around',
            alignItems: 'flex',
            width: '100%'
          }}
        >
          {options.map((o, idx) => this.renderOption(o, idx, 0))}
        </div>
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-around',
            alignItems: 'flex',
            width: '100%'
          }}
        >
          {options[this.state.selected[0]].children.length > 0 &&
            options[this.state.selected[0]].children.map((o, idx) =>
              this.renderOption(o, idx, 1, true)
            )}
        </div>
      </div>
    )
  }

  renderOption = (o, idx, level, inverted) => {

    return this.state.selected[level] == idx
      ? <div
          key={o.key}
          className={`tab-menu-option selected ${inverted ? 'inverted' : ''}`}
          onClick={this.select(level, idx, o)}
        >
          <div>
            {o.text}
          </div>
        </div>
      : <div
          key={o.key}
          className={`tab-menu-option ${inverted ? 'inverted' : ''}`}
          onClick={this.select(level, idx, o)}
        >
          <div>
            {o.text}
          </div>
        </div>
      }
}

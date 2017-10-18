import React, { Component } from 'react'
import { render } from 'react-dom'
import spa from './spa'
import EventMap from './components/event-map'

class EmbededMap extends Component {
  componentWillMount() {
    this.state = {
      district: undefined,
      startingCoordinates: undefined
    }

    this.fetchState()

    spa.bus.on('page-change', this.fetchState)
  }

  fetchState = () => {
    const cookie = getCookie('coordinates')
    const startingCoordinates = window.startingCoordinates
      ? window.startingCoordinates
      : cookie ? JSON.parse(cookie) : null

    const district = window.district ? window.district : getCookie('district')

    if (this.state.district !== district) {
      this.setState({
        startingCoordinates,
        district
      })
    }
  }

  render() {
    return (
      <EventMap
        {...window.opts}
        showDistrictSelector={false}
        startingCoordinates={this.state.startingCoordinates}
        district={this.state.district}
      />
    )
  }
}

const eventsApp = document.getElementById('events-app')
render(<EmbededMap />, eventsApp)

function getCookie(name) {
  var value = '; ' + document.cookie
  var parts = value.split('; ' + name + '=')
  if (parts.length == 2)
    return parts
      .pop()
      .split(';')
      .shift()
}

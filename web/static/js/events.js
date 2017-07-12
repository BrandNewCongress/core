import React, { Component } from 'react'
import { render } from 'react-dom'
import EventMap from './components/event-map'
import socket from './socket'

class Events extends Component {
  state = {
    events: [],
    center: [38.805470223177466, -100.23925781250001],
    zoom: 4
  }

  channel = null

  componentDidMount() {
    this.channel = socket.channel('events')

    this.channel
      .join()
      .receive('ok', msg => {
        console.log(`Connected with ${JSON.stringify(msg)}`)
        console.log(msg)

        this.channel.push('ready', {})
      })
      .receive('error', msg => {
        console.log(`Could not connect with ${JSON.stringify(msg)}`)
        console.log(msg)
      })

    this.channel.on('event', ({ event }) =>
      this.setState({
        events: this.state.events.concat([event])
      })
    )

    if (window.startingCoordinates) {
      const [y, x] = window.startingCoordinates
      this.setState({ center: [x, y], zoom: 7 })
    }
  }

  onViewportChanged = ({ center, zoom }) => this.setState({ center, zoom })

  render() {
    const { events, center, zoom } = this.state

    return (
      <EventMap
        events={events}
        center={center}
        zoom={zoom}
        onViewportChanged={this.onViewportChanged}
        events={events}
      />
    )
  }
}

render(<Events {...window.opts} />, document.getElementById('events-app'))

function getCookie(name) {
  var value = '; ' + document.cookie
  var parts = value.split('; ' + name + '=')
  if (parts.length == 2) return parts.pop().split(';').shift()
}

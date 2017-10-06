import React, { Component } from 'react'
import { render } from 'react-dom'
import EventMap from './components/event-map'

class EmbededMap extends Component {
  componentWillMount() {
    this.state = {
      district: undefined,
      startingCoordinates: undefined
    }

    this.fetchState()
  }

  fetchState = () => {
    const {d, c} = getJsonFromUrl()

    if (!d)
      console.error(`Missing url parameter 'd' – please include d=TX-14 or equivalently formatted district`)

    if (!c)
      console.error(`Missing url parameter 'c' – please include c=40.1234,70.12341 or equivalently formatted district`)

    this.setState({
      district: d,
      startingCoordinates: c
    })
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
  if (parts.length == 2) return parts.pop().split(';').shift()
}

function getJsonFromUrl() {
  var query = location.search.substr(1);
  var result = {};
  query.split("&").forEach(function(part) {
    var item = part.split("=");
    result[item[0]] = decodeURIComponent(item[1]);
  });
  return result;
}

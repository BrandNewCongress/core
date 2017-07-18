import React, { Component } from 'react'
import { Map, TileLayer, CircleMarker, Popup, GeoJSON } from 'react-leaflet'
import EventMarker from './event-marker'
import GeoSuggest from 'react-geosuggest'
import socket from '../socket'

export default class EventMap extends Component {
  state = {
    events: [],
    center: [38.805470223177466, -100.23925781250001],
    zoom: 4,
    overlay: undefined
  }

  channel = null
  l = null

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

    if (this.props.startingCoordinates || window.startingCoordinates) {
      this.setState({
        center: this.props.startingCoordinates || window.startingCoordinates,
        zoom:
          JSON.stringify([38.805470223177466, -100.23925781250001]) ==
          JSON.stringify(window.startingCoordinates)
            ? 4
            : 11
      })
    }

    if (this.props.district) {
      this.setDistrictOverlay(this.props.district)
    }
  }

  componentWillReceiveProps(nextProps) {
    this.setState({
      center: nextProps.startingCoordinates
    })

    this.setDistrictOverlay(nextProps.district)
  }

  setDistrictOverlay = (district) => {
    this.channel.push('get-district-overlay', { district: district })
    this.channel.on('district-overlay', ({ polygon }) => {
      console.log(district)
      this.setState({
        overlay: polygon
      })
    })
  }

  onViewportChanged = ({ center, zoom }) => this.setState({ center, zoom })

  render() {
    const { showDistrictSelector } = this.props
    const { center, zoom, events, overlay } = this.state

    return (
      <div>
        {showDistrictSelector &&
          <div className="district-selector">
            <div className="district-selector-header">
              <h2> Events Near You </h2>
            </div>
            <div className="district-selector-prompt">
              <p>Type in your address, zip code, or congressional district</p>
              <div className="input-container">
                <input ref={ref => (this.locationInput = ref)} />
                <a onClick={this.getDistrict}> Go </a>
              </div>
            </div>
          </div>}

        <Map
          animate={true}
          viewport={{ center, zoom }}
          onViewportChanged={this.onViewportChanged}
        >
          <TileLayer
            attribution="&copy; <a href=&quot;https://openstreetmap.org/copyright&quot;>OpenStreetMap</a> contributors"
            url="https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png"
          />
          {overlay && <GeoJSON data={overlay} className="district-overlay" />}
          {events.map(e => <EventMarker key={e.name} event={e} />)}
        </Map>
      </div>
    )
  }
}

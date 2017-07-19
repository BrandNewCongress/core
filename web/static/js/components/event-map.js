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
    overlay: undefined,
    noEvents: false
  }

  channel = null
  l = null

  componentDidMount() {
    this.channel = socket.channel('events')

    this.channel
      .join()
      .receive('ok', msg => {
        console.log(`Connected`)
        this.channel.push('ready', { district: this.props.district })
      })
      .receive('error', msg => {
        console.log(`Could not connect with ${JSON.stringify(msg)}`)
        console.log(msg)
      })

    this.channel.on('event', ({ event }) => {
      this.setState({
        events: this.state.events.concat([event])
      })
    })

    this.channel.on('no-events', () => {
      this.setState({
        noEvents: true
      })
    })

    if (this.props.startingCoordinates) {
      this.setState({
        center: this.props.startingCoordinates,
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
    if (nextProps.district !== this.props.district) {
      this.state.center = nextProps.startingCoordinates
      this.state.noEvents = false
      this.setDistrictOverlay(nextProps.district)
    }
  }

  setDistrictOverlay = (district, center) => {
    this.channel.push('get-district-overlay', { district: district })
    this.channel.on('district-overlay', ({ polygon }) => {
      this.setState({
        overlay: polygon
      })

      this.channel.off('district-overlay')
    })
  }

  onViewportChanged = ({ center, zoom }) => this.setState({ center, zoom })
  closeModal = () => this.setState({ noEvents: false })

  render() {
    const { showDistrictSelector } = this.props
    const { center, zoom, events, overlay, noEvents } = this.state

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
          {this.renderNoEventsModal()}
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

  renderNoEventsModal = () =>
    this.state.noEvents &&
    <div
      style={{
        position: 'absolute',
        zIndex: '1000',
        backgroundColor: 'black',
        color: 'white',
        left: '50%',
        transform: 'translate(-50%, 150%) scale(1.3)',
        padding: '40px',
        fontFamily: 'Roboto Slab, sans-serif'
      }}
    >
      <div
        className="close-modal"
        style={{
          position: 'absolute',
          marginTop: '-30px',
          float: 'right',
          right: '15px',
          cursor: 'pointer'
        }}
        onClick={this.closeModal}
      >
        X
      </div>
      <div className="no-events-text">
        There's not an event near you yet, but you can be the first.
      </div>
      <a
        className="primary-button"
        style={{
          paddingTop: '5px',
          margin: '0px',
          paddingBottom: '5px',
          marginTop: '10px'
        }}
        onClick={() => window.navigateTo('/form/submit-event')}
      >
        Host One Now
      </a>
    </div>
}

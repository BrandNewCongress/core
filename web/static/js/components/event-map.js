import React, { Component } from 'react'
import { Map, TileLayer, CircleMarker, Popup } from 'react-leaflet'
import moment from '../lib/mini-moment'

export default class EventMap extends Component {
  render() {
    const { center, zoom, events } = this.props

    return (
      <Map
        viewport={{ center, zoom }}
        onViewportChanged={this.props.onViewportChanged}
      >
        <TileLayer
          attribution="&copy; <a href=&quot;http://osm.org/copyright&quot;>OpenStreetMap</a> contributors"
          url="http://{s}.tile.osm.org/{z}/{x}/{y}.png"
        />
        {events.map(e => <EventMarker event={e} />)}
      </Map>
    )
  }
}

class EventMarker extends Component {
  render() {
    const {
      venue,
      intro,
      startTime,
      endTime,
      url,
      title,
      timeZoneOffset
    } = this.props.event

    const offset = parseInt(timeZoneOffset.split(':')[0])

    const start = moment(new Date(startTime), offset)
    const end = moment(new Date(endTime), offset)

    return (
      <CircleMarker
        radius={10}
        center={[parseFloat(venue.address.lat), parseFloat(venue.address.lng)]}
      >
        <Popup style={{ overflow: 'scroll' }}>
          <div className="event-item event">
            <h5 className="time-info">
              <div className="dateblock">
                <span className="left" style="text-transform: uppercase">
                  {start.dayOfWeek}
                </span>
                <span className="right">
                  {`${start.month} ${start.dayOfMonth} ${start.humanTime} – ${end.humanTime}`}
                </span>
              </div>
            </h5>
            <h3>
              <a target="_blank" href={url} className="event-title">
                {title}
              </a>
            </h3>
            <span className="label-icon" />
            <p>{venue.name}</p>
            <p dangerouslySetInnerHTML={{ __html: intro }}/>
            <div>
              <a
                className="rsvp-link"
                href="http://go.brandnewcongress.org/call_out_corruption_phone_bank_minneapolis_minneapolis_1117"
                target="_blank"
              >
                DETAILS/RSVP
              </a>
              <span
                className="time-info-dist"
                style="float: right; padding-top: 10px"
              />
            </div>
          </div>
        </Popup>
      </CircleMarker>
    )
  }
}

import React, { Component } from 'react'
import { Map, TileLayer, CircleMarker, Popup } from 'react-leaflet'
import moment from '../lib/mini-moment'

export default class EventMarker extends Component {
  render() {
    const {
      location: { location: [latitude, longitude] }
    } = this.props.events[0]

    return (
      <CircleMarker
        radius={8}
        center={[parseFloat(latitude), parseFloat(longitude)]}
      >
        <Popup style={{ overflow: 'scroll' }}>
          <div style={{ maxHeight: 310, overflow: 'scroll' }}>
            {this.props.events.sort(this.byDate).map(this.renderEvent)}
          </div>
        </Popup>
      </CircleMarker>
    )
  }

  byDate = (e1, e2) => {
    return new Date(e1.start_date) > new Date(e2.start_date)
  }

  renderEvent = (ev, idx) => {
    const {
      type,
      title,
      summary,
      start_date,
      end_date,
      name,
      location: { venue, region, locality },
      featured_image_url,
      browser_url,
      time_zone,
      date_line
    } = ev

    const style = {
      maxHeight: 290,
      borderTop: idx > 0 ? '1px solid black' : '',
      marginTop: idx > 0 ? 10 : 0
    }

    return (
      <div key={idx} id={ev.name} className="event-item event" style={style}>
        <h5 className="time-info">
          <div className="dateblock">{date_line}</div>
        </h5>
        <h3>
          <a target="_blank" href={browser_url} className="event-title">
            {title}
          </a>
        </h3>
        <span className="label-icon" />
        <p>{venue}</p>
        <p
          style={{ whiteSpace: 'pre-wrap' }}
          dangerouslySetInnerHTML={{ __html: summary }}
        />
        <div>
          <a className="rsvp-link" href={browser_url} target="_blank">
            DETAILS/RSVP
          </a>

          <span
            className="time-info-dist"
            style={{ float: 'right', paddingTop: '10px' }}
          />
        </div>
      </div>
    )
  }
}

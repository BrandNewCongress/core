import React, { Component } from 'react'
import { Map, TileLayer, CircleMarker, Popup } from 'react-leaflet'
import moment from '../lib/mini-moment'

export default class EventMarker extends Component {
  render() {
    const {
      type,
      title,
      summary,
      start_date,
      end_date,
      name,
      location: { venue, region, location: [latitude, longitude], locality },
      featured_image_url,
      browser_url,
      time_zone,
      date_line
    } = this.props.event

    return (
      <CircleMarker
        radius={8}
        center={[parseFloat(latitude), parseFloat(longitude)]}
      >
        <Popup style={{ overflow: 'scroll' }}>
          <div className="event-item event">
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
        </Popup>
      </CircleMarker>
    )
  }
}

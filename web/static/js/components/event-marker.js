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
      location: { venue, region, location: [ latitude, longitude ], locality },
      featured_image_url,
      description,
      browser_url,
      time_zone
    } = this.props.event

    const timeZoneMap = {
      'Eastern Time (US & Canada)': -5,
      'Central Time (US & Canada)': -6,
      'Mountain Time (US & Canada)': -7,
      'Pacific Time (US & Canada)': -8,
      Alaska: -9,
      Hawaii: -10
    }

    const offset = timeZoneMap[time_zone]

    const start = moment(new Date(start_date), offset)
    const end = moment(new Date(end_date), offset)

    console.log(this.props.event)

    console.log([parseFloat(latitude), parseFloat(longitude)])

    return (
      <CircleMarker
        radius={8}
        center={[parseFloat(latitude), parseFloat(longitude)]}
      >
        <Popup style={{ overflow: 'scroll' }}>
          <div className="event-item event">
            <h5 className="time-info">
              <div className="dateblock">
                <span className="left" style={{ textTransform: 'uppercase' }}>
                  {start.dayOfWeek}
                </span>
                <span className="right">
                  {`${start.month} ${start.dayOfMonth} ${start.humanTime} – ${end.humanTime}`}
                </span>
              </div>
            </h5>
            <h3>
              <a target="_blank" href={browser_url} className="event-title">
                {title}
              </a>
            </h3>
            <span className="label-icon" />
            <p>
              {venue}
            </p>
            <p dangerouslySetInnerHTML={{ __html: description }} />
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

import React, { Component } from 'react'
import { render } from 'react-dom'
import Intro from './act/intro'
import menuConfig from './act/menu-config'
import callVotersEmbed from './act/call-voters-embed'
import TabMenu from './components/tab-menu'
import EventMap from './components/event-map'
import socket from './socket'
import request from 'superagent'
import 'phoenix_html'

const print = s => {
  console.log(s)
  return s
}

class Act extends Component {
  state = {
    channel: null,
    zip: '',
    center: [38.805470223177466, -100.23925781250001],
    zoom: 4,
    candidate: undefined,
    selected: 'attend-event',
    events: []
  }

  channel = null

  componentWillMount() {
    this.state.channel = socket.channel('act')
  }

  componentDidMount() {
    this.state.channel
      .join()
      .receive('ok', msg => {
        console.log(`Connected with ${JSON.stringify(msg)}`)
        console.log(msg)
      })
      .receive('error', msg => {
        console.log(`Could not connect with ${JSON.stringify(msg)}`)
        console.log(msg)
      })

    this.state.channel.on('center', ({ center }) => {
      const [a, b] = center
      this.setState({
        center: [parseFloat(a), parseFloat(b)],
        zoom: 10
      })
    })
  }

  set = prop => val => this.setState({ [prop]: val });
  onViewportChanged = ({ center, zoom }) => this.setState({ center, zoom })

  onTabSelect = key => {
    const altOpens = {
      'call-voters': window.location.origin + '/form/call-from-home',
      nominate: window.location.origin.replace('now.', '') + '/nominate',
      'tell-us':
        'https://docs.google.com/forms/d/e/1FAIpQLSe8CfK0gUULEVpYFm9Eb4iyGOL-_iDl395qB0z4hny7ek4iNw/viewform?refcode=www.google.com'
    }

    if (altOpens[key]) {
      debugger
      window.open(altOpens[key])
    } else {
      this.setState({ selected: key })
    }
  }

  go = ({ candidate, zip }) => {
    this.setState({ candidate, zip })

    request
      .get('https://api.brandnewcongress.org/events')
      .query({ candidate: candidate.slug })
      .end((err, res) => {
        this.setState({ events: res.body || [] })
      })
  }

  render() {
    const { zip, center, zoom, candidate, selected, events } = this.state
    const { brand } = this.props

    return (
      <div
        style={{
          maxWidth: '95vw',
          minWidth: '80vw',
          height: 'calc(100vh - 75px)'
        }}
      >
        <h1 className="page-title">
          {brand == 'bnc' &&
            <span
              className="small-star"
              style={{ float: 'left', marginLeft: '10px' }}
            >
              &#9733;
            </span>}

          {candidate === undefined
            ? `Let's get to work`
            : candidate === null
              ? `Help from home`
              : `Volunteer for ${candidate.title} - ${candidate.metadata
                  .district}`}

          {brand == 'bnc' &&
            <span
              className="small-star"
              style={{ float: 'right', marginRight: '10px' }}
            >
              &#9733;
            </span>}
        </h1>

        <div
          style={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            flexDirection: 'column'
          }}
        >

          {candidate === undefined
            ? <Intro channel={this.state.channel} go={this.go} />
            : <TabMenu
                initialSelected={0}
                onSelect={this.onTabSelect}
                options={menuConfig}
              />}

          {(candidate === undefined || selected == 'attend-event') &&
            <EventMap
              center={center}
              zoom={zoom}
              onViewportChanged={this.onViewportChanged}
              events={events}
            />}

        </div>

      </div>
    )
  }
}

render(<Act {...window.opts} />, document.getElementById('work-app'))

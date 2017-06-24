import React, { Component } from 'react'
import { render } from 'react-dom'
import request from 'superagent'
import createHistory from 'history/createBrowserHistory'
import Intro from './act/intro'
import menuConfig from './act/menu-config'
import TabMenu from './components/tab-menu'
import EventMap from './components/event-map'
import socket from './socket'
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
    candidate: {},
    selected: 'attend-event',
    events: [],
    candidateCallingHTML: ''
  }

  history = null

  componentWillMount() {
    this.state.channel = socket.channel('act')

    this.state.selected = window.initialSelected != ''
      ? window.initialSelected
      : 'attend-event'

    this.history = createHistory()

    if (window.initialState) {
      Object.assign(this.state, window.initialState)
    }
  }

  componentDidMount() {
    this.fetchEvents()

    this.state.channel
      .join()
      .receive('ok', msg => {
        console.log(`Connected with ${JSON.stringify(msg)}`)
        console.log(msg)

        if (this.state.candidate.metadata) {
          this.state.channel.push('zip', {
            zip: this.state.candidate.metadata.zip
          })

          request
            .get(`/act/calling-html/${this.state.candidate.slug}`)
            .end((err, res) => {
              this.setState({ candidateCallingHTML: res.text})
            })
        }
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
    const domain = window.location.origin.replace('now.', '')

    const altOpens = {
      nominate: domain + '/nominate',
      'tell-us':
        'https://docs.google.com/forms/d/e/1FAIpQLSe8CfK0gUULEVpYFm9Eb4iyGOL-_iDl395qB0z4hny7ek4iNw/viewform?refcode=www.google.com',
      'join-national': domain + '/form/teams'
    }

    if (altOpens[key]) {
      window.open(altOpens[key])
    } else {
      this.setState({ selected: key })
    }
  }

  go = ({ candidate, zip }) => {
    this.setState({ candidate, zip })

    if (candidate) this.history.push(`/act/${candidate.slug}`)
  }

  fetchEvents = () =>
    request
      .get('https://api.brandnewcongress.org/events')
      .query()
      .end((err, res) => {
        this.setState({ events: res.body || [] })
      })

  render() {
    const { zip, center, zoom, candidate, selected, events } = this.state
    const { brand } = this.props

    console.log(selected)

    return (
      <div
        style={{
          maxWidth: '95vw',
          minWidth: '80vw',
          minHeight: 'calc(100vh - 75px)'
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

          {candidate && Object.keys(candidate).length == 0
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

          {candidate && Object.keys(candidate).length == 0
            ? <Intro channel={this.state.channel} go={this.go} />
            : <TabMenu
                initialSelected={0}
                onSelect={this.onTabSelect}
                options={menuConfig}
              />}

          {selected == 'attend-event' &&
            <EventMap
              center={center}
              zoom={zoom}
              onViewportChanged={this.onViewportChanged}
              events={events}
            />}

          {selected === 'call-voters' &&
            this.isTimeToCall() &&
            this.renderOnHours()}

          {selected === 'call-voters' &&
            !this.isTimeToCall() &&
            <p>
              At the moment, we're making calls from 5PM - 9PM on weekdays and
              10AM - 9PM on weekends.

              {`Since we're not calling right now, please fill out `}
              <a
                href="https://now.brandnewcongress.org/form/call-from-home"
                target="_blank"
              >
                this form
              </a>
              {` and we'll get you set up soon.`}
            </p>}

        </div>

      </div>
    )
  }

  isTimeToCall = () => {
    const now = new Date()
    const isWeekend = now.getDay() == 6 || now.getDay() == 0
    const hours = now.getUTCHours() - 5
    return true
    if (isWeekend) {
      return hours >= 10
    } else {
      return hours >= 17
    }
  }

  renderOnHours = () => {
    if (
      window.callable &&
      this.state.candidate &&
      window.callable
        .map(({ slug, name }) => slug)
        .includes(this.state.candidate.slug)
    ) {
      return (
        <div
          style={{
            textAlign: 'center',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center'
          }}
        >
          <div
            style={{ marginTop: 10, marginBottom: 10, textAlign: 'left' }}
            dangerouslySetInnerHTML={{
              __html: this.state.candidateCallingHTML
            }}
          />
          <label> First, </label>
          <a
            style={{
              width: '200px',
              padding: 10,
              textTransform: 'none',
              textDecoration: 'none'
            }}
            target="_blank"
            className="primary-button"
            href="https://docs.google.com/document/d/1AKs90WQvTLzA9-fzt7RkR_V1Af8p5-xXgDT2JenOw5k/edit?usp=sharing"
          >
            Read the guide on how to make calls for BNC
          </a>

          <label> Second, </label>
          <a
            style={{
              width: '200px',
              padding: 10,
              textTransform: 'none',
              textDecoration: 'none'
            }}
            target="_blank"
            className="primary-button"
            href={this.state.candidate.metadata.calling_script_link}
          >
            Read the calling script
          </a>

          <label> Third, </label>
          <a
            style={{
              width: '200px',
              padding: 10,
              textTransform: 'none',
              textDecoration: 'none'
            }}
            target="_blank"
            className="primary-button"
            href="https://now.brandnewcongress.org/call"
          >
            Claim your login
          </a>

          <label> Fourth, </label>
          <a
            style={{
              width: '200px',
              padding: 10,
              textTransform: 'none',
              textDecoration: 'none'
            }}
            target="_blank"
            className="primary-button"
            href="https://portal.na4.livevox.com/BrandNewCampaign/AgentLogin"
          >
            Login to our dialer, and get calling!
          </a>

          <div style={{ textAlign: 'left' }}>
            <h3> Calling hours </h3>
            <p>
              We make calls from 5PM - 9PM on weekdays and 10AM - 9PM on
              weekends,
              so check back anytime you want to make calls.
              <br />
              However, your login information will change each day, so you'll
              need to reclaim it.
            </p>
            <h3> Questions? </h3>
            <p>
              Please email{' '}
              <a href="mailto:dailer@brandnewcongress.org" target="-blank">
                {' '}dailer@brandnewcongress.org{' '}
              </a>.
              We'll get back to you as soon as we can.
            </p>
          </div>
        </div>
      )
    } else if (this.state.candidate) {
      return (
        <p>
          We've made all of our calls for {this.state.candidate.title} for
          today! <br />
          <br />
          Please make calls for one of our other candidates: <br />
          {window.callable.map(({ slug, name }) =>
            <div>
              <a
                href={
                  window.location.origin +
                  '/act/' +
                  slug +
                  '?selected=call-voters'
                }
                target="_blank"
              >
                {' '}{name}{' '}
              </a>
            </div>
          )}
        </p>
      )
    } else {
      return (
        <p>
          Sorry, we don't have a candidate in your district yet. <br />
          <br />
          Please make calls for one of our other candidates: <br />
          {window.callable.map(({ slug, name }) =>
            <div>
              <a
                href={
                  window.location.origin +
                  '/act/' +
                  slug +
                  '?selected=call-voters'
                }
                target="_blank"
              >
                {' '}{name}{' '}
              </a>
            </div>
          )}
        </p>
      )
    }
  }
}

render(<Act {...window.opts} />, document.getElementById('work-app'))

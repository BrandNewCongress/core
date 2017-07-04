import React, { Component } from 'react'
import Loading from '../components/loading'

export default class Intro extends Component {
  state = {
    zip: '',
    candidate: undefined
  }

  componentDidMount() {
    this.props.channel.on('candidate', ({ candidate }) => {
      this.setState({ candidate })
    })
  }

  handleZipChange = ev => {
    const change = { zip: ev.target.value }
    if (ev.target.value.length == 5) {
      this.props.channel.push('zip', { zip: ev.target.value })
    } else {
      if (this.state.candidate !== undefined) {
        change.candidate = undefined
      }
    }

    this.setState(change)
  }

  go = () => this.props.go({
    candidate: this.state.candidate,
    zip: this.state.zip
  })

  render() {
    const { candidate, zip } = this.state
    const { brand } = this.props

    // for 4th of july
    return (
      <div>
        <h1> Happy 4th of July! </h1>
        <br/>
        <iframe src="https://giphy.com/embed/TmT51OyQLFD7a" width="400" height="480" frameBorder="0" className="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/america-fireworks-4th-of-july-TmT51OyQLFD7a">via GIPHY</a></p>
        <br/>
        <h3>
          Calls will resume July 5th at 10am eastern
        </h3>

      </div>
    )

    return (
      <div
        id="explanation"
        style={{
          position: 'absolute',
          bottom: '6vh',
          zIndex: '1000',
          width: '70%'
        }}
      >
        <div id="strategy">
          <div id="strategy-explanation" style={{ marginBottom: 10 }}>
            Our strategy: <br />
            1) Gather enough supporters in every district to win. <br />
            2) Turn those supporters out to vote on election day. <br />
            3) Change the country. <br />
          </div>
          <div id="zip-input" style={{textAlign: 'center'}}>
            Enter your zip to learn the best way for you to help: <br />
            <input
              value={zip}
              className="text"
              style={{ width: 150, textAlign: 'center' }}
              onInput={this.handleZipChange}
            />
          </div>

          <div
            style={{
              height: 60,
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center'
            }}
          >
            {zip.length < 5
              ? <div
                  style={{ width: 150, marginTop: 5, marginBottom: 5 }}
                />
              : candidate !== undefined
                ? <a
                    className="primary-button"
                    onClick={this.go}
                    style={{
                      marginTop: 5,
                      marginBottom: 5,
                      width: 150
                    }}
                  >
                    Go
                  </a>
                : <Loading style={{ marginTop: 5, marginBottom: 5 }} />}
          </div>
        </div>
      </div>
    )
  }
}

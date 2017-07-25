import React, { Component } from 'react'
import store from '../lib/standup-store'

export default class PledgeTally extends Component {
  state = {
    congress: {}
  }

  componentDidMount() {
    store.reps
      .get()
      .then(congress => {
        this.setState(congress)
      })
      .catch(console.error)
  }

  render() {
    const { congress } = this.state

    return (
      <div
        style={{
          display: 'flex'
        }}
      >

        {Object.keys(congress).sort().map(state =>
          <div
            key={state}
            style={{
              display: 'flex',
              flexDirection: 'column'
            }}
          >
            {state}
            {congress[state].map(rep =>
              <div
                key={rep.name}
                className="grayscale"
                style={{
                  backgroundImage: `url(${rep.img})`,
                  backgroundSize: 'cover',
                  height: '50px',
                  width: '50px'
                }}
              >
              </div>
            )}

          </div>
        )}
      </div>
    )
  }
}

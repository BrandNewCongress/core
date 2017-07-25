import React, { Component } from 'react'
import store from '../lib/standup-store'

export default class PledgeTally extends Component {
  state = {
    congress: []
  }

  componentDidMount() {
    store.reps
      .get()
      .then(congress => this.setState(congress))
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
        {Object.keys(congress).map(state =>
          <div
            style={{
              display: 'flex',
              flexDirection: 'column'
            }}
          >
            {congress[state].map(rep =>
              <div
                className='grayscale'
                style={{
                  backgroundImage: `url(${rep.image})`
                }}
              >
                {rep.name}
              </div>
            )}
          </div>
        )}
      </div>
    )
  }
}

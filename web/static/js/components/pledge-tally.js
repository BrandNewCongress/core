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
          display: 'flex',
          flexDirection: 'column'
        }}
      >
        <div style={{ display: 'flex', marginTop: '35px' }}>
          {Object.keys(congress).sort().map(state =>
            <div
              style={{
                width: '15px',
                height: '50px',
                fontSize: '8px',
                marginLeft: '2px',
                marginRight: '2px'
              }}
            >
              <div
                style={{
                  transform: 'rotate(270deg) translate(20px, -41px)',
                  width: '100px'
                }}
              >
                {state}
              </div>
            </div>
          )}
        </div>

        <div
          style={{
            backgroundColor: 'grey',
            paddingTop: '1px',
            paddingBottom: '1px',
            marginBottom: '15px'
          }}
        />

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
              {congress[state].map(rep =>
                <div
                  className="grayscale"
                  key={rep.name}
                  style={{
                    backgroundImage: `url(${rep.img})`,
                    backgroundSize: 'cover',
                    height: '15px',
                    width: '15px',
                    marginTop: '1px',
                    marginBottom: '1px',
                    marginLeft: '2px',
                    marginRight: '2px'
                  }}
                />
              )}
            </div>
          )}
        </div>
      </div>
    )
  }
}

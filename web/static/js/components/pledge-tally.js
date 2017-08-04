import React, { Component } from 'react'
import store from '../lib/standup-store'

export default class PledgeTally extends Component {
  state = {
    congress: {},
    hovering: {
      idxs: {
        col: undefined,
        row: undefined
      },
      district: undefined
    }
  }

  mouseOver = false

  componentDidMount() {
    store.reps
      .get()
      .then(congress => this.setState(congress))
      .catch(console.error)
  }

  bubbleHover = ({ idxs, district }) => ev => {
    this.setState({ hovering: { idxs, district } })
    this.mouseOver = true
  }

  resetHover = ev => {
    this.mouseOver = false

    setTimeout(
      () =>
        this.mouseOver
          ? null
          : this.setState({
              hovering: {
                idxs: { col: undefined, row: undefined },
                district: undefined
              }
            }),
      500
    )
  }

  render() {
    const { congress, hovering } = this.state

    return (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column'
        }}
      >
        <div className="title section-header" style={{ paddingBottom: 0 }}>
          Pledge Tally
        </div>
        <div
          className="section-header"
          style={{ paddingBottom: 50, paddingTop: 0 }}
        >
          Click to see a signer's name and contact information
        </div>
        <div style={{ display: 'flex', height: '300px' }}>
          {this.pledgesByState().map((state, col) =>
            <div
              key={state}
              style={{
                width: '13px',
                fontSize: '8px',
                marginLeft: '2px',
                marginRight: '2px',
                position: 'relative'
              }}
            >
              {state[1].map((pledge, row) =>
                <div
                  key={pledge.name}
                  style={{
                    borderRadius: '50%',
                    width: '28px',
                    height: '28px',
                    position: 'absolute',
                    bottom: `${this.calcOffset(col, row)}px`,
                    marginLeft: '-5px',
                    backgroundSize: 'cover',
                    backgroundPosition: 'center',
                    backgroundImage: `url("${pledge.headshot}")`
                  }}
                  className={`bubble ${pledge.position}`}
                  onMouseEnter={this.bubbleHover({
                    idxs: { col, row },
                    dstrict: pledge.district
                  })}
                  onMouseLeave={this.resetHover}
                >
                  {col == hovering.idxs.col &&
                    row == hovering.idxs.row &&
                    <div className="bubble-modal signer">
                      <div className="pledge-info-box">
                        <div className="standing-up">Standing Up</div>

                        <div className="pledger-info">
                          <img
                            src={`/images/m4a-candidate-in.png`}
                            style={{
                              marginTop: 5,
                              marginBottom: 5,
                              width: 170,
                              height: 42
                            }}
                          />
                          <div className="name-position-container">
                            <div className="name">
                              {pledge.name}
                            </div>
                            <div className="position">
                              {`${pledge.position} ${pledge.district}`}
                            </div>
                          </div>
                        </div>

                        <div className="pledger-share">
                          <a href={pledge.twitter} target="_blank">
                            <img src="/images/m4a-twitter.png" />
                          </a>
                          <a href={pledge.facebook} target="_blank">
                            <img src="/images/m4a-facebook.png" />
                          </a>
                          <a href={pledge.instagram} target="_blank">
                            <img src="/images/m4a-instagram.png" />
                          </a>
                        </div>
                      </div>

                      <div className="tooltip">
                        <div className="tooltip-item" />
                      </div>
                    </div>}
                </div>
              )}
            </div>
          )}
        </div>

        <div style={{ display: 'flex', marginTop: '35px' }}>
          {Object.keys(congress).sort().map((state, idx) =>
            <div
              key={state}
              style={{
                width: '13px',
                height: '50px',
                fontSize: '8px',
                marginLeft: '2px',
                marginRight: '2px'
              }}
            >
              <div
                style={{
                  transform: 'rotate(270deg) translate(20px, -47px)',
                  width: '110px',
                  textAlign: 'left'
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
              id={state}
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
                    width: '13px',
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

  pledgesByState = () => {
    const byState = Object.assign({}, this.state.congress)

    for (let state in byState) {
      byState[state] = []
    }

    if (Object.keys(byState).length > 0) {
      this.props.pledges.forEach(p => {
        byState[p.state].push(p)
      })

      return Object.keys(byState).sort().map(state => [state, byState[state]])
    } else {
      return []
    }
  }

  calcOffset = (col, row) => (col % 2 == 0 ? 50 : 100) + row * 21
}

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
      district: undefined,
      incumbent: undefined
    }
  }

  mouseOver = false

  componentDidMount() {
    store.reps
      .get()
      .then(congress => this.setState(congress))
      .catch(console.error)
  }

  bubbleHover = ({ idxs, district, incumbent }) => ev => {
    ev.stopPropagation()
    this.setState({ hovering: { idxs, district, incumbent } })
    this.mouseOver = true
  }

  resetHover = ev => {
    this.mouseOver = false

    this.setState({
      hovering: {
        idxs: { col: undefined, row: undefined },
        district: undefined,
        incumbent: undefined
      }
    })
  }

  render() {
    const { congress, hovering } = this.state

    return (
      <div
        style={{
          display: 'flex',
          flexDirection: 'column'
        }}
        onClick={this.resetHover}
      >
        <div className="title section-header" style={{ paddingBottom: 0 }}>
          Pledge Tally
        </div>
        <div
          className="section-header"
          style={{ paddingBottom: 50, paddingTop: 0, fontSize: '20px' }}
        >
          Click to see a pledger's name and contact information
        </div>
        <div style={{ display: 'flex', height: '220px' }}>
          {this.pledgesByState().map((state, col) =>
            <div
              key={state}
              style={{
                width: '13px',
                marginLeft: '2px',
                marginRight: '2px',
                position: 'relative'
              }}
            >
              {state[1].map((pledge, row) => [
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
                  onClick={this.bubbleHover({
                    idxs: { col, row },
                    district: pledge.district,
                    incumbent: pledge.position == 'Incumbent'
                  })}
                >
                  {col == hovering.idxs.col &&
                    row == hovering.idxs.row &&
                    this.renderPledgerModal(pledge)}
                </div>,

                <div
                  key="line"
                  data-col={col}
                  style={{
                    height: 38,
                    borderRight: '1px solid grey',
                    marginLeft: '10px',
                    position: 'absolute',
                    bottom: `${this.calcOffset(col, row) - 50}px`
                  }}
                />,

                col % 2 != 0
                  ? <div
                      key="line-2"
                      style={{
                        height: 50,
                        borderRight: '1px solid grey',
                        marginLeft: '10px',
                        position: 'absolute',
                        bottom: `${this.calcOffset(col, row) - 100}px`
                      }}
                    />
                  : undefined
              ])}
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
                    marginRight: '2px',
                    zIndex: this.incumbentOfPledger(rep) ? '10000' : '-10'
                  }}
                >
                  {this.incumbentOfPledger(rep) && this.renderEvilModal(rep)}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    )
  }

  incumbentOfPledger = rep =>
    this.state.hovering && this.state.hovering.incumbent !== true
      ? `${rep.state}-${rep.district.toString().padStart(2, '0')}` ==
        this.state.hovering.district
      : false

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

  calcOffset = (col, row) => (col % 2 == 0 ? 50 : 100) + row * 30

  renderPledgerModal = pledge =>
    <div className="bubble-modal signer">
      <div className="pledge-info-box">
        <div className="standing-up">Standing Up</div>

        <div className="pledger-info">
          <img
            src={
              pledge.position == 'Candidate'
                ? '/images/m4a-candidate-in.png'
                : '/images/m4a-incumbent-in.png'
            }
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

        <a
          href={`https://youtube.com/watch?v=${pledge.youtube_id}`}
          target="_blank"
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: '#cd1041',
            padding: 8,
            textDecoration: 'none',
            color: 'white',
            fontFamily: 'Oleo Script, cursive',
            fontSize: '15px'
          }}
        >
          <svg
            fill="#ffffff"
            height="24"
            viewBox="0 0 24 24"
            width="24"
            xmlns="http://www.w3.org/2000/svg"
            style={{ marginRight: 10 }}
          >
            <path d="M0 0h24v24H0z" fill="none" />
            <path d="M10 16.5l6-4.5-6-4.5v9zM12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z" />
          </svg>
          Watch Their Pledge
        </a>

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
    </div>

  renderEvilModal = rep =>
    <div className="bubble-modal incumbent">
      <div className="pledge-info-box">
        <div className="standing-up">Not Standing Up</div>

        <div className="pledger-info">
          <img
            src="/images/m4a-incumbent-in.png"
            style={{
              marginTop: 5,
              marginBottom: 5,
              width: 170,
              height: 42
            }}
          />
          <div className="name-position-container">
            <div className="name">
              {rep.name}
            </div>
            <div className="position">
              {rep.district
                ? `Congressperson for ${rep.state}-${rep.district
                    .toString()
                    .padStart(2, '0')}`
                : `Senator for ${rep.state}`}
            </div>
          </div>
        </div>
      </div>

      <div className="tooltip">
        <div className="tooltip-item" />
      </div>
    </div>
}

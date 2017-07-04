import React, { Component } from 'react'
import { render } from 'react-dom'

const siteMap = {
  '/join': {
    label: 'Join',
    children: {}
  },
  '/candidates': {
    label: 'Candidates',
    children: {
      '/candidates': 'Candidates',
      '/nominate': 'Nominate'
    }
  },
  '/act': {
    label: 'Action',
    children: {
      '/act': 'Action Portal',
      '/events': 'Find an Event Near You',
      '/call': 'Call from Home'
    }
  },
  '/plan': {
    label: 'The Plan',
    children: {
      '/plan': 'Our Plan',
      '/platform': 'Platform'
    }
  }
}

class Sidebar extends Component {
  state = {
    page: '/',
    open: false,
    closing: false,
    opening: false
  }

  open = () => {
    this.setState({ open: true })
  }

  close = () => {
    this.setState({ open: false })
  }

  render() {
    return this.state.open ? this.renderOpen() : this.renderClosed()
  }

  renderOpen() {
    const { open } = this.state

    return (
      <div className={open ? 'opening': ''}>
        <div id="overlay" onClick={this.close} />
        <div
          id="drawer"
          style={{
            position: 'fixed',
            right: 0,
            top: 0,
            left: 'auto',
            height: '100vh',
            overflowY: 'scroll',
            backgroundColor: 'black'
          }}
        >
          Hello!
        </div>
      </div>
    )
  }

  renderClosed() {
    return (
      <a className="hamburger-menu" id="sidebar-toggle" onClick={this.open}>
        <div className="bar" />
        <div className="bar" />
        <div className="bar" />
      </a>
    )
  }
}

render(<Sidebar {...window.opts} />, document.getElementById('sidebar'))

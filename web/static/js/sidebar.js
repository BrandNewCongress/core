import React, { Component } from 'react'
import { render } from 'react-dom'
import CloseIcon from './sidebar/close-icon'
import siteMap from './sidebar/sitemap'

class Sidebar extends Component {
  state = {
    page: '/',
    open: false
  }

  open = () => this.setState({ open: true })
  close = () => this.setState({ open: false })

  render() {
    return this.state.open ? this.renderOpen() : this.renderClosed()
  }

  renderOpen() {
    const { open } = this.state

    return (
      <div className={open ? 'opening' : ''}>
        <div id="overlay" onClick={this.close} />
        <div id="drawer">
          <a onClick={this.close} >
            <CloseIcon />
          </a>
          <div id="inner-drawer">
            {siteMap.map(this.renderEntry)}
          </div>
        </div>
      </div>
    )
  }

  renderEntry = entry => {
    const href = hrefOfEntry(entry)
    if (href === null) {
      return (
        <div key={entry.label} className="nav-section">
          <span className="nav-section-header condensed">
            {entry.label}
          </span>
          {entry.children &&
            entry.children.length > 0 &&
            <div className="children-container condensed">
              {entry.children.map(this.renderChild)}
            </div>}
        </div>
      )
    } else {
      return (
        <a key={entry.label} className="nav-section" href={href}>
          <span className="nav-section-header condensed">
            {entry.label}
          </span>
        </a>
      )
    }
  }

  renderChild = child => {
    const href = hrefOfEntry(child)
    return (
      <a key={child.label} className="nav-element condensed" href={href}>
        {child.label}
      </a>
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

// This needs to change when now. gets deployed to @
const apexDomain = window.location.origin.replace('now.', '')
function hrefOfEntry(entry) {
  if (entry.children === undefined || entry.children.length === 0) {
    return entry.subdomained ? entry.path : apexDomain + entry.path
  } else {
    return null
  }
}

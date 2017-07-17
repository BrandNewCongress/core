import React, { Component } from 'react'
import { render } from 'react-dom'
import CloseIcon from './sidebar/close-icon'
import siteMap from './sidebar/sitemap'
import hrefOfEntry from './lib/href-of-entry'

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
          <a onClick={this.close}>
            <CloseIcon />
          </a>
          <div id="inner-drawer">
            {this.order(siteMap).map(this.renderEntry)}
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

  order = entries => {
    const current = this.current(entries)
    const rest = entries.filter(
      e => !window.location.href.match(e.path) || e.path === '/'
    )

    return current ? current.concat(rest) : rest
  }

  current = entries => entries.filter(e => e.matches())
}

render(<Sidebar {...window.opts} />, document.getElementById('sidebar'))

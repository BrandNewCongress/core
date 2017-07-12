import React, { Component } from 'react'
import { render } from 'react-dom'
import CloseIcon from './sidebar/close-icon'
import siteMap from './sidebar/sitemap'

class TopNav extends Component {
  state = {
    hover: 2
  }

  showOpts = idx => ev => this.setState({ hover: idx })
  // hideOpts = idx => ev => this.setState({ hover: null })
  hideOpts = idx => ev => this.setState({})
  visit = entry => ev => window.navigateTo(hrefOfEntry(entry))

  render() {
    const { hover } = this.state

    return (
      <div className="drop-down">
        {siteMap.map((tl, idx) => [
          <div
            key={tl.label}
            className="top-level"
            onClick={this.visit(tl)}
            onMouseEnter={this.showOpts(idx)}
            onMouseLeave={this.hideOpts(idx)}
          >
            {tl.label}

            {hover == idx &&
              <div className="panel">
                {siteMap[idx].children.map(child =>
                  <div key={child.label} className="item">
                    {child.label}
                  </div>
                )}
              </div>}
          </div>,
          idx < siteMap.length - 1 && <div> / </div>
        ])}
      </div>
    )
  }

  current = entries =>
    entries.filter(e => window.location.href.match(e.path) && e.path !== '/')
}

class SideNav extends Component {
  state = {
    selected: ''
  }

  render() {
    return (
      <div className="side-nav-container">
        <div className="section-header-container">
          {this.current(siteMap)[0].label}
        </div>

        {this.current(siteMap)[0].children &&
          this.current(siteMap)[0].children.map(entry =>
            <a
              className="side-nav-item"
              href={hrefOfEntry(entry)}
              key={entry.label}
            >
              {entry.label}
            </a>
          )}
      </div>
    )
  }

  current = entries =>
    entries.filter(e => window.location.href.match(e.path) && e.path !== '/')
}

render(<TopNav {...window.opts} />, document.getElementById('sidebar'))

const target = document.getElementById('side-nav')
if (target)
  render(<SideNav {...window.opts} />, target)

// This needs to change when now. gets deployed to @
const apexDomain = window.location.origin.replace('now.', '')
function hrefOfEntry(entry) {
  if (entry.children === undefined || entry.children.length === 0) {
    return entry.subdomained ? entry.path : apexDomain + entry.path
  } else {
    return null
  }
}

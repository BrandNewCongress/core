import React, { Component } from 'react'
import { render } from 'react-dom'
import CloseIcon from './sidebar/close-icon'
import siteMap from './sidebar/sitemap'

class TopNav extends Component {
  state = {
    hover: null
  }

  showOpts = idx => ev => this.setState({ hover: idx })
  hideOpts = idx => ev => this.setState({ hover: null })
  visit = entry => ev => window.navigateTo(hrefOfEntry(entry))

  render() {
    const { hover } = this.state

    return (
      <div className="drop-down">
        {siteMap.map((tl, idx) => [
          <div
            className="top-level"
            onClick={this.visit(tl)}
            onMouseEnter={this.showOpts(idx)}
            onMouseLeave={this.hideOpts(idx)}
          >
            {tl.label}
            {hover == idx &&
              <div className="panel">
                {siteMap[idx].children.map(child =>
                  <div className="item">
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
}

class SideNav extends Component {
  state = {
    selected: ''
  }

  render() {
    return (
      <div className="side-nav-container">
        TODO
      </div>
    )
  }
}

render(<TopNav {...window.opts} />, document.getElementById('sidebar'))
render(<SideNav {...window.opts} />, document.getElementById('side-nav'))

// This needs to change when now. gets deployed to @
const apexDomain = window.location.origin.replace('now.', '')
function hrefOfEntry(entry) {
  if (entry.children === undefined || entry.children.length === 0) {
    return entry.subdomained ? entry.path : apexDomain + entry.path
  } else {
    return null
  }
}

import React, { Component } from 'react'
import { render } from 'react-dom'
import CloseIcon from './sidebar/close-icon'
import siteMap from './sidebar/sitemap'

class TopNav extends Component {
  state = {
    hover: undefined
  }

  showOpts = idx => ev => this.setState({ hover: idx })
  hideOpts = idx => ev => this.setState({ hover: null })
  visit = entry => ev => {
    ev.stopPropagation()
    window.navigateTo(hrefOfEntry(entry))
  }

  render() {
    const { hover } = this.state

    return (
      <div className="drop-down">
        {siteMap.map((tl, idx) => [
          <div
            key={tl.label}
            className={`top-level ${hover == idx ? 'hovering' : ''}`}
            onClick={this.visit(tl)}
            onMouseEnter={this.showOpts(idx)}
            onMouseLeave={this.hideOpts(idx)}
          >
            {tl.label}

            {hover == idx &&
              siteMap[idx].children.length > 0 &&
              <div className="panel">
                {siteMap[idx].children.map(child =>
                  <div
                    key={child.label}
                    className="item"
                    onClick={this.visit(child)}
                  >
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

  current = entries => entries.filter(e => e.matches())
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
              className={`side-nav-item ${entry.matches() ? 'selected' : ''}`}
              href={hrefOfEntry(entry)}
              key={entry.label}
            >
              {window.opts.brand == 'bnc' &&
                <span className="side-star" style={{ float: 'left' }}>
                  &#9733;
                </span>}
              {entry.label}
            </a>
          )}
      </div>
    )
  }

  current = entries => entries.filter(e => e.matches())
}

window.checkNavChange = () => {
  render(<TopNav {...window.opts} />, document.getElementById('sidebar'))

  const target = document.getElementById('side-nav')
  if (target) render(<SideNav {...window.opts} />, target)
}

window.checkNavChange()

// This needs to change when now. gets deployed to @
const apexDomain = window.location.origin.replace('now.', '')
function hrefOfEntry(entry) {
  return entry.subdomained ? entry.path : apexDomain + entry.path
}

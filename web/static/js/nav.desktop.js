import React, { Component } from 'react'
import { render } from 'react-dom'
import CloseIcon from './sidebar/close-icon'
import siteMap from './sidebar/sitemap'
import hrefOfEntry from './lib/href-of-entry'
import spa from './spa'

class TopNav extends Component {
  state = {
    hover: undefined
  }

  showOpts = idx => ev => this.setState({ hover: idx })
  hideOpts = idx => ev => this.setState({ hover: null })

  render() {
    const { hover } = this.state

    const divStyleAnchor = {display: 'block', textDecoration: 'none', color: 'inherit'}

    return (
      <div className="drop-down">
        {siteMap.map((tl, idx) => [
          <a
            key={tl.label}
            className={`top-level ${hover == idx ? 'hovering' : ''}`}
            href={hrefOfEntry(tl)}
            style={divStyleAnchor}
            onMouseEnter={this.showOpts(idx)}
            onMouseLeave={this.hideOpts(idx)}
          >
            {tl.label}

            {hover == idx &&
              siteMap[idx].children.length > 0 &&
              <div className="panel">
                {siteMap[idx].children.map(child =>
                  <a
                    key={child.label}
                    className="item"
                    style={divStyleAnchor}
                    href={hrefOfEntry(child)}
                  >
                    {child.label}
                  </a>
                )}
              </div>}
          </a>,
          idx < siteMap.length - 1 && <div className="separator"> / </div>
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
          {this.current(siteMap)[0] && this.current(siteMap)[0].label}
        </div>

        {this.current(siteMap)[0] &&
          this.current(siteMap)[0].children &&
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

function doRender() {
  render(<TopNav {...window.opts} />, document.getElementById('sidebar'))

  const target = document.getElementById('side-nav')
  if (target) render(<SideNav {...window.opts} />, target)

  spa.bind.all()
  spa.bus.on('morphed', doRender)
}

doRender()

import React, { Component } from 'react'
import { render } from 'react-dom'
import CloseIcon from './sidebar/close-icon'
import siteMap from './sidebar/sitemap'
import hrefOfEntry from './lib/href-of-entry'

class TopNav extends Component {
  state = {
    hover: undefined
  }

  showOpts = idx => ev => this.setState({ hover: idx })
  hideOpts = idx => ev => this.setState({ hover: null })
  visit = entry => ev => {
    ev.stopPropagation()
    ev.preventDefault()
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
          idx < siteMap.length - 1 && <div style={{marginTop: '5px'}}> / </div>
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

  visit = entry => ev => {
    ev.stopPropagation()
    ev.preventDefault()
    window.navigateTo(hrefOfEntry(entry))
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
              onClick={this.visit(entry)}
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
}

doRender()
window.bus.on('page-change', () => doRender())

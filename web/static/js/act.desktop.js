import 'antd/dist/antd.css'
import React, { Component } from 'react'
import { render } from 'react-dom'
import { Card } from 'antd'
import socket from "./socket"
import 'phoenix_html'

class Act extends Component {
  state = {
    zip: ''
  }

  handleZipChange = (ev) => {
    this.setState({zip: ev.target.value})
  }

  go = () => {

  }

  render() {
    const { zip } = this.state

    return (
      <Card id="explanation">
        Get to Work!
        <div id="strategy">
          <div id="strategy-explanation">
            Our strategy: <br/>
            1) Gather enough supporters in every district to win. <br/>
            2) Turn those supporters out to vote on election day. <br/>
            3) Change the country. <br/>
            <div id="zip-input">
              Enter your zip to learn the best way for you to help:
              <input value={zip} onInput={this.handleZipChange} />
            </div>
          </div>

          {zip.length == 5 && (
            <button onClick={this.go}>Go</button>
          )}
        </div>
      </Card>
    )
  }
}

render(<Act/>, document.getElementById('work-app'))

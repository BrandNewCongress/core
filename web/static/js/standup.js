import React, { Component } from 'react'
import { render } from 'react-dom'

class Standup extends Component {
  state = {
    videos: []
  }

  render() {
    const { videos } = this.state

    return (
      <div>
        Hello, world!
        {videos.map(v =>
          <div>
            {JSON.stringify(v)}
          </div>
        )}
      </div>
    )
  }
}

const app = document.getElementById('standup-app')
render(<Standup />, app)

import React, { Component } from 'react'
import { render } from 'react-dom'
import store from './lib/standup-store'
import PledgeTally from './components/pledge-tally'

/*
 * Available store methods

  store.get.for(district) ->
    returns a promise that resolves with an array of videos
    at the moment, it will not resolve if the district is invalid
    TODO: error on bad district

  store.get.recent() ->
    returns a promise that resolves with an array of videos sorted by recency

  store.create(data)
    returns a promise that resolves with the created video

 */

class Standup extends Component {
  state = {
    videos: []
  }

  componentDidMount() {
    store.videos
      .recent()
      .then(videos => this.setState({ videos }))
      .catch(console.error)
  }

  render() {
    const { videos } = this.state

    return (
      <div>
        Hello, world!
        {videos.map(({ district, first_name, email, rep, link }) =>
          <div>
            {`${first_name} in ${district} wants ${rep} to support medicare for all!`}
            <br />
            Watch their endorsement <a href={link}> here </a>
          </div>
        )}

        <PledgeTally />
      </div>
    )
  }
}

const el = document.getElementById('standup-app')
render(<Standup />, el)

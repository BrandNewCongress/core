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
    pledges: window.pledges.slice()
  }

  render() {
    const { pledges } = this.state

    return (
      <PledgeTally pledges={pledges} />
    )
  }
}

const el = document.getElementById('standup-app')
render(<Standup />, el)

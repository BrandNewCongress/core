import React, { Component } from 'react'
import { render } from 'react-dom'
import store from './lib/standup-store'

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
  styles = {

  }
  state = {
    videos: []
  }

  componentDidMount() {
    store.get
      .recent()
      .then(videos => this.setState({ videos }))
      .catch(console.error)
  }

  render() {
    const { videos } = this.state
    return (
      <div>
        <div>[COSMIC DATA]Video</div>
        <div>
          <div>Button for people</div>
          <div>Logo</div>
          <div>Button for people running</div>          
        </div>
        <div>
          [COSMIC DATA]Because of your pressure, 43 members of Congress decided to co-sponsor Conyers' house bill for Medicare for All. But as the health care debate rages, many of these same co-sponsors have publicly been advocating for half-measures like increasing subsidies for insurance companies or simply playing defense against Medicaid cuts. These congresspeople are silently backing Medicare for All just as a weak political move to cover their bases. We believe it's time for them to grow a spine and stand up for Medicare for All. We're calling on sitting members of Congress and anyone running for Congress to go on video pledging to stand up for Medicare for All in any public appearances and statements addressing our country's healthcare crisis.
        </div>        
        {videos.map(({ district, first_name, email, rep, link }) =>
          <div>
            {`${first_name} in ${district} wants ${rep} to support medicare for all!`}
            <br />
            Watch their endorsement <a href={link}> here </a>
          </div>
        )}
        <hr />
        <div>
          <div>
            [COSMIC DATA - LIST OF VIDEOS]
          </div>
          <div>
            [TWEET STREAM]
          </div>          
        </div>
        <hr />
        <div>
          [COSMIC DATA - STATS]
        </div>
        <hr />
        <div>
          [BEN'S COMPONENT]
        </div>
      </div>
    )
  }
}

const el = document.getElementById('standup-app')
render(<Standup />, el)

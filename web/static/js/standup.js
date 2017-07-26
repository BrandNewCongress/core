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
      <div className='body'>
        <div className='header'>          
          <div className='logo-container'>
            <img className='logo' src='/images/temp-logo.png' />
          </div>
          <div className='contact-bar'>
            <div className='social-icons'>
              <img height='20' src='/images/temp-social.png' />
            </div>
            <div className='contact-link'>
              Contact Us
            </div>
          </div>
        </div>
        <div className='hero'>
          <div className='title section-header'>
            [Why Medicare For All?]
          </div>
          <div className='hero-body'>
            <div className='hero-section'>
              <div className='hero-section-inner'>
                <img height='65' src='/images/temp-join.png' />
                <div className='title counter'>[43,000]</div>
                <div className='counter-description'>[Have Told Their Representative]</div>
                <div className='secondary-title'>[#StandUp4Medicare]</div>
              </div>
            </div>
            <div className='hero-video'>
              <video width='540' className="video-container" poster="http://content.bitsontherun.com/thumbs/bkaovAYt-320.jpg" autoPlay="" muted="" controls="controls">
                <source src="http://content.bitsontherun.com/videos/bkaovAYt-52qL9xLP.mp4" />
                <source src="http://content.bitsontherun.com/videos/bkaovAYt-27m5HpIu.webm" />
                <p className="warning">Your browser does not support HTML5 video.</p>
              </video> 
            </div>
            <div className='hero-section'>
              <div className='secondary-title'>[Running for Congress Or Serving a District?]</div>
              <div className='button'>Pledge</div>
              <div>[Take the Pledge and Stand With 73% of Americans]</div>
            </div>
          </div>
        </div>
        <div>
          <PledgeTally />
        </div>
      </div>
    )
  }
}

const el = document.getElementById('standup-app')
render(<Standup />, el)

import React, { Component } from 'react'
import { render } from 'react-dom'
import EventMap from './components/event-map'

render(<EventMap {...window.opts} />, document.getElementById('events-app'))

import React, { Component } from 'react'
import { render } from 'react-dom'
import EventMap from './components/event-map'

const eventsApp = document.getElementById('events-app')
const showDistrictSelector =
  eventsApp.getAttribute('data-show-prompt') != 'false'

const cookie = getCookie('coordinates')
const startingCoordinates = cookie ? JSON.parse(cookie) : null

render(
  <EventMap
    {...window.opts}
    showDistrictSelector={showDistrictSelector}
    startingCoordinates={startingCoordinates}
  />,
  eventsApp
)

function getCookie(name) {
  var value = '; ' + document.cookie
  var parts = value.split('; ' + name + '=')
  if (parts.length == 2) return parts.pop().split(';').shift()
}

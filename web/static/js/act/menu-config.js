import React, { Component } from 'react'
import TabMenu from '../components/tab-menu'

export default [
  {
    text: 'Attend an Event',
    key: 'attend-event',
    children: []
  },
  {
    text: 'Work from Home',
    key: 'from-home',
    children: [
      {
        text: 'Call Voters',
        key: 'call-voters',
        children: []
      },
      {
        text: 'Nominate a Candidate',
        key: 'nominate',
        children: []
      },
      {
        text: 'Tell us about your district',
        key: 'tell-us',
        children: []
      }
      // {
      //   text: 'Gather supporters online',
      //   key: 'gather-online',
      //   children: []
      // }
    ]
  },
  {
    text: 'Join a National Team',
    key: 'join-national',
    children: []
  }
]

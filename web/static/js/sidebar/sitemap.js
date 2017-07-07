const siteMap = [
  {
    label: 'Join',
    path: '/',
    subdomained: false,
    children: []
  },
  {
    label: 'Candidates',
    path: '/candidates',
    subdomained: false,
    children: [
      {
        label: 'Candidates',
        path: '/candidates',
        subdomained: false,
        children: []
      },
      {
        label: 'Nominate',
        path: '/nominate',
        subdomained: false,
        children: []
      }
    ]
  },
  {
    label: 'Action',
    path: '/act',
    subdomained: 'now',
    children: [
      {
        label: 'Action Portal',
        path: '/act',
        subdomained: 'now',
        children: []
      },
      {
        label: 'Attend an Event',
        path: '/',
        subdomained: 'events',
        children: []
      },
      {
        label: 'Host an Event',
        path: '/form/submit-event',
        subdomained: 'now',
        children: []
      },
      {
        label: 'Call Voters',
        path: '/act/call',
        subdomained: 'now',
        children: []
      }
    ]
  },
  {
    label: 'Plan',
    path: '/plan',
    children: [
      {
        label: 'Plan',
        path: '/plan',
        children: []
      },
      {
        label: 'Platform',
        path: '/platform',
        children: []
      }
    ]
  }
]

export default siteMap

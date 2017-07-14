const siteMap = [
  {
    label: 'Join',
    path: '/',
    subdomained: false,
    children: [],
    matches: () => false
  },

  {
    label: 'Candidates',
    path: '/candidates',
    subdomained: false,
    matches: () => window.location.href.match('/candidates'),
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
    matches: () => window.location.href.match('/act'),
    children: [
      {
        label: 'Action Portal',
        path: '/act',
        subdomained: 'now',
        matches: () => window.location.href.match('/act') && window.location.href.endsWith('act'),
        children: []
      },
      {
        label: 'Attend an Event',
        path: '/',
        subdomained: 'events',
        matches: () => false,
        children: []
      },
      {
        label: 'Host an Event',
        path: '/form/submit-event',
        subdomained: 'now',
        matches: () => window.location.href.match('/form/submit-event'),
        children: []
      },
      {
        label: 'Call Voters',
        path: '/act/call',
        subdomained: 'now',
        matches: () => window.location.href.match('/act/call'),
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
    ],
    matches: () => window.location.href.match('/plan')
  }
]

export default siteMap

const siteMap = [
  {
    label: 'Join',
    path: 'HOSTNAME',
    subdomained: false,
    children: [],
    matches: () => false
  },

  {
    label: 'Candidates',
    path: 'HOSTNAME/candidates',
    matches: () => window.location.href.match('/candidates'),
    children: [
      {
        label: 'Candidates',
        path: 'HOSTNAME/candidates',
        children: []
      },
      {
        label: 'Nominate',
        path: 'HOSTNAME/nominate',
        children: []
      }
    ]
  },

  {
    label: 'Action',
    path: '/act',
    matches: () =>
      window.location.href.match('/act') ||
      window.location.href.match('/form/submit-event') ||
      window.location.href.match('/form/teams'),
    children: [
      {
        label: 'Action Portal',
        path: '/act',
        matches: () =>
          window.location.href.match('/act') &&
          window.location.href.endsWith('act'),
        children: []
      },
      {
        label: 'Attend an Event',
        path: 'events.HOSTNAME/',
        matches: () => false,
        children: []
      },
      {
        label: 'Host an Event',
        path: '/form/submit-event',
        matches: () => window.location.href.match('/form/submit-event'),
        children: []
      },
      {
        label: 'Call Voters',
        path: '/act/call',
        matches: () => window.location.href.match('/act/call'),
        children: []
      },
      {
        label: 'Join a National Team',
        path: '/form/teams',
        matches: () => false,
        children: []
      },
      {
        label: 'Tell Us About Your District',
        path: 'https://docs.google.com/forms/d/e/1FAIpQLSe8CfK0gUULEVpYFm9Eb4iyGOL-_iDl395qB0z4hny7ek4iNw/viewform?refcode=www.google.com',
        matches: () => false,
        children: []
      },
      {
        label: 'Any special skills?',
        path: 'https://brandnewcongress.org/volunteer',
        matches: () => false,
        children: []
      }
    ]
  },
  {
    label: 'Platform',
    path: '/platform',
    matches: () =>
      window.location.href.match('/platform'),
    children: [
      {
        label: 'Our Economy',
        path: '/platform#economy',
        matches: () => false,
        children: []
      },
      {
        label: 'Healthcare for All',
        path: '/platform#healthcare',
        matches: () => false,
        children: []
      },
      {
        label: 'Mass Incarceration',
        path: '/platform#incarceration',
        matches: () => false,
        children: []
      },
      {
        label: 'Fight for Families',
        path: '/platform#families',
        matches: () => false,
        children: []
      },
      {
        label: 'Corruption',
        path: '/platform#corruption',
        matches: () => false,
        children: []
      }
    ]
  }
]

export default siteMap

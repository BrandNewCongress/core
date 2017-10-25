const bnc = [
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
        path: '/events',
        matches: () => false,
        children: []
      },
      {
        label: 'Call Voters',
        path: '/act/call',
        matches: () => window.location.href.match('/act/call'),
        children: []
      },
      {
        label: 'Tell Us About Your District',
        path:
          'https://docs.google.com/forms/d/e/1FAIpQLSe8CfK0gUULEVpYFm9Eb4iyGOL-_iDl395qB0z4hny7ek4iNw/viewform?refcode=www.google.com',
        matches: () => false,
        children: []
      },
      {
        label: 'Any special skills?',
        path: window.location.origin.includes('justicedemocrats')
          ? 'https://justicedemocrats.org/special-skills'
          : 'https://brandnewcongress.org/special-skills',
        matches: () => false,
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
        path: window.location.origin.includes('justicedemocrats')
          ? 'https://justicedemocrats.org/plan'
          : 'https://brandnewcongress.org/plan',
        children: []
      },
      {
        label: 'Platform',
        path: window.location.origin.includes('justicedemocrats')
          ? 'https://justicedemocrats.org/platform'
          : 'https://brandnewcongress.org/platform',
        children: []
      }
    ],
    matches: () => window.location.href.match('/plan')
  }
]

const jd = [
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
        path: 'HOSTNAME/events',
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
        label: 'Any special skills?',
        path: window.location.origin.includes('justicedemocrats')
          ? 'https://justicedemocrats.org/special-skills'
          : 'https://brandnewcongress.org/special-skills',
        matches: () => false,
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
        path: window.location.origin.includes('justicedemocrats')
          ? 'https://justicedemocrats.org/plan'
          : 'https://brandnewcongress.org/plan',
        children: []
      },
      {
        label: 'Platform',
        path: window.location.origin.includes('justicedemocrats')
          ? 'https://justicedemocrats.org/platform'
          : 'https://brandnewcongress.org/platform',
        children: []
      }
    ],
    matches: () => window.location.href.match('/plan')
  }
]

const siteMap = window.location.origin.includes('justicedemocrats')
  ? jd
  : bnc

export default siteMap

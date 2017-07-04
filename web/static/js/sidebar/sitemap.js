const siteMap = [
  {
    label: 'Join',
    path: '/join',
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
      // TODO
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

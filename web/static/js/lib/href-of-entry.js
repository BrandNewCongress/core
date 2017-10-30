const base = window.location.href.includes('justicedemocrats')
  ? 'https://justicedemocrats.com'
  : 'https://brandnewcongress.org'

export default entry => {
  return entry.path.indexOf('HOSTNAME') > -1
    ? entry.path.replace('HOSTNAME', base)
    : entry.path
}

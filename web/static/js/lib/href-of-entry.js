const base = window.location.href.includes('justicedemocrats')
  ? 'https://justicedemocrats.com'
  : 'https://brandnewcongress.org'

export default entry => {
  console.log(entry)
  return entry.path.indexOf('HOSTNAME') > -1
  ? entry.path.replace('HOSTNAME', base)
  : entry.path
}

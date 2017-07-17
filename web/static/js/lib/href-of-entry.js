const base = window.location.hostname.replace('now.', '')
export default entry => entry.path.indexOf('HOSTNAME') > -1
  ? 'https://' + entry.path.replace('HOSTNAME', base)
  : entry.path

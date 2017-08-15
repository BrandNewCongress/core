const bind = () => {
  const ref = getQueryStringValue('ref')
  if (ref != '') {
    Array.from(document.querySelectorAll('form'))
    .filter(f => f.method == 'post')
    .forEach(f => f.action = f.action + `?ref=${ref}`)
  }
}

function getQueryStringValue(key) {
  return decodeURIComponent(
    window.location.search.replace(
      new RegExp(
        '^(?:.*[&\\?]' +
          encodeURIComponent(key).replace(/[\.\+\*]/g, '\\$&') +
          '(?:\\=([^&]*))?)?.*$',
        'i'
      ),
      '$1'
    )
  )
}

module.exports = { bind: bind }

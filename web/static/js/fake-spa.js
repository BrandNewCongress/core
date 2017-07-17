import diff from 'virtual-dom/diff'
import patch from 'virtual-dom/patch'
import superagent from 'superagent'
import createHistory from 'history/createBrowserHistory'
import parser from 'vdom-parser'
const Emitter = require('emitter').EventEmitter

const bus = new Emitter()
window.bus = bus

window.onpopstate = () => bus.emit('page-change')

var nodeCache = document.querySelector('main')
var vdomCache = parser(nodeCache)

var hist = createHistory()

function postFetch(text, path, skipHistory) {
  const newVTree = parser(text)
  const patches = diff(vdomCache, newVTree)

  nodeCache = patch(nodeCache, patches)
  vdomCache = newVTree

  if (!skipHistory) hist.push(path)

  bind()
}

function navigateTo(path, skipHistory) {
  if (path.indexOf('https://') > -1) {
    window.location.href = path
  } else {
    superagent.get(path).query({ empty: true }).end(function(err, res) {
      if (window.checkNavChange) window.checkNavChange()
      postFetch(res.text, path, skipHistory)
      bus.emit('page-change')
    })
  }
}

function bind() {
  Array.from(document.querySelectorAll('a'))
    .filter(function(a) {
      return a.hostname === window.location.hostname
    })
    .filter(function(a) {
      return !a.href.startsWith('#')
    })
    .forEach(function(a) {
      a.onclick = function(ev) {
        ev.preventDefault()
        navigateTo(a.getAttribute('href'), a.getAttribute('data-skip-history'))
        return false
      }
    })

  Array.from(document.querySelectorAll('form')).forEach(function(f) {
    f.onsubmit = function(ev) {
      ev.preventDefault()

      var form = ev.target

      var body = {}
      Array.from(form.elements).forEach(el => {
        if (el.name && el.name !== '') body[el.name] = el.value
      })

      superagent(form.method, ev.target.action)
        .send(body)
        .query({ empty: true })
        .end(function(err, res) {
          postFetch(res.text, form.getAttribute('action'))
        })
    }
  })
}

window.navigateTo = navigateTo

module.exports = { bind: bind }

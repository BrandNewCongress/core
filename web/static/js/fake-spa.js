var diff = require('virtual-dom/diff')
var patch = require('virtual-dom/patch')
var superagent = require('superagent')
import createHistory from 'history/createBrowserHistory'
var parser = require('vdom-parser')

var nodeCache = document.querySelector('main')
var vdomCache = parser(nodeCache)

var hist = createHistory()

function postFetch(text, path) {
  const newVTree = parser(text)
  const patches = diff(vdomCache, newVTree)

  nodeCache = patch(nodeCache, patches)
  vdomCache = newVTree

  hist.push(path)

  bind()
}

function navigateTo(path) {
  superagent.get(path).query({ empty: true }).end(function(err, res) {
    postFetch(res.text, path)
  })
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
        navigateTo(a.pathname)
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
        .end(function(err, res) {
          postFetch(res.text, form.getAttribute('action'))
        })
    }
  })
}

window.navigateTo = navigateTo

module.exports = { bind: bind }

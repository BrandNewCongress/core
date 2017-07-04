var diff = require('virtual-dom/diff')
var patch = require('virtual-dom/patch')
var superagent = require('superagent')
import createHistory from 'history/createBrowserHistory'
var parser = require('vdom-parser')

var nodeCache = document.querySelector('main')
var vdomCache = parser(nodeCache)

var hist = createHistory()

function navigateTo(path) {
  superagent.get(path).query({ empty: true }).end(function(err, res) {
    const newVTree = parser(res.text)
    const patches = diff(vdomCache, newVTree)

    nodeCache = patch(nodeCache, patches)
    vdomCache = newVTree

    hist.push(path)

    bind()
  })
}

function bind() {
  Array.from(document.querySelectorAll('a'))
    .filter(function(a) {
      return a.hostname === window.location.hostname
    })
    .forEach(function(a) {
      a.onclick = function(ev) {
        ev.preventDefault()
        navigateTo(a.pathname)
        return false
      }
    })
}

window.navigateTo = navigateTo

module.exports = { bind: bind }

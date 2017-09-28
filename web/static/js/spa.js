import superagent from 'superagent'
import createHistory from 'history/createBrowserHistory'
import smoothScroll from 'smoothscroll'
import morphdom from 'morphdom'
import emitter from 'event-emitter-es6'

const history = createHistory()

// TODO - real back behavior
const attachHistory = () =>
  history.listen((location, action) => {
    action == 'POP' && (window.location.pathname = location.pathname)
  })

/*
 *
 * Behavior
 *
 * href=<relative url> with AJAX -> morphdom
 * done? no
 *
 * href=<absolute url> -> new tab
 * done? no
 *
 * href=# -> smooth scroll
 * done? no
 *
 * handle backs
 * done? no
 *
 * form submit -> add loading class, ajax submit, morphdom
 *
 */

const bus = emitter()

const base = document.querySelector('html')
const morph = html => morphdom(base, html, { childrenOnly: true })
const fetch = (href, fn) =>
  superagent
    .get(href)
    .end((err, res) => (err ? console.error(err) : fn(null, res.text)))

const is = {
  relative: a => a.href && a.getAttribute('href').startsWith('/'),
  internal: a => a.href && a.getAttribute('href').startsWith('#'),
  external: a =>
    a.href &&
    (a.getAttribute('href').startsWith('https://') ||
      a.getAttribute('href').startsWith('http://'))
}

const handle = {
  relative: a =>
    fetch(a.getAttribute('href'), (err, html) => {
      morph(html)
      history.push(a.getAttribute('href'))
      console.log('hi')
      bus.emit('morphed')
    }),

  external: a => window.open(a.getAttribute('href')),

  internal: a => {
    const [fragidHash] = a.getAttribute('href').match(/#[A-Za-z0-9\-_:\.]*/)

    const fragid = fragidHash.slice(1)
    const target =
      document.querySelector(`#${fragid}`) ||
      document.querySelector(`[name=${fragid}]`)

    smoothScroll(target)
  }
}

const createBinder = type => () =>
  Array.from(document.querySelectorAll('a'))
    .filter(is[type])
    .forEach(
      a =>
        (a.onclick = ev => {
          ev.preventDefault()
          handle[type](ev.target)
        })
    )

const relatives = createBinder('relative')
const externals = createBinder('external')
const internals = createBinder('internal')
const all = () => {
  relatives()
  externals()
  internals()
}

const bind = {
  relatives,
  externals,
  internals,
  all
}

bus.on('morphed', () => console.log('morphed here'))

export default { bind, bus, attachHistory }

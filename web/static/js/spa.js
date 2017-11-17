import superagent from 'superagent'
import createHistory from 'history/createBrowserHistory'
import smoothScroll from 'smoothscroll'
import morphdom from 'morphdom'
import EventEmitter from 'event-emitter-es6'
import closest from 'component-closest'

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
 * done? yes
 *
 * href=<absolute url> -> new tab
 * done? yes
 *
 * href=# -> smooth scroll
 * done? yes
 *
 * handle backs
 * done? no
 *
 * form submit -> add loading class, ajax submit, morphdom
 *
 */

const bus = new EventEmitter()

const base = document.querySelector('html')
const morph = html => morphdom(base, html, { childrenOnly: true })
const fetch = (href, fn) =>
  superagent
    .get(href)
    .end((err, res) => (err ? console.error(err) : fn(null, res.text)))

const reloadBodyScripts = () => {
  const scripts = document.querySelectorAll('main script')
  scripts.forEach(s => {
    const replacement = document.createElement('script')
    replacement.src = s.src
    s.insertAdjacentElement('afterend', replacement)
    s.remove()
  })
}

const is = {
  relative: a => a.href && a.getAttribute('href').startsWith('/'),
  internal: a => a.href && a.getAttribute('href').startsWith('#'),
  external: a =>
    a.href &&
    (a.getAttribute('href').startsWith('https://') ||
      a.getAttribute('href').startsWith('http://'))
}

const handle = {
  relative: a => {
    if (a.getAttribute('href').includes('form')) {
      return window.location.href = a.getAttribute('href')
    }

    fetch(a.getAttribute('href'), (err, html) => {
      morph(html)
      history.push(a.getAttribute('href'))
      reloadBodyScripts()
      bus.emit('morphed')
    })},

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
          const a = closest(ev.target, 'a', true)
          handle[type](a)
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

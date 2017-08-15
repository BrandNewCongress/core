# Core

## Running Locally

First, install Elixir – for Macs:

```
brew install elixir
```

should work. For anything else besides Macs, check: https://elixir-lang.org/install.html.

To start the app locally:
  * Install dependencies with `mix deps.get` (equivalent of npm install)
  * Run `npm install` to install Javascript + build dependencies
  * Set up your environment with `. dev-setup.sh`
  * Make sure you have redis running locally (hopefully this will not be a requirement soon).
    For macs, this means running `brew install redis` if you don't have it already, and then
    `redis-server` in a separate terminal tab.
  * Start Phoenix endpoint with `REDIS_URL=redis://localhost:6379 mix phoenix.server`

Now you can visit [`localhost:4000/act`](http://localhost:4000) from your browser.

## What's Happening Here

For the website, we are using an approach where the templates are in Elixir HTML
templates, but most of the content lives in [CosmicJS](cosmicjs.com). There,
we created "buckets", which are little bits of content (either plain text or
html) that are editable in the admin view.

Each time the server starts, it fetches all of our buckets from Cosmic and stores
them in `./cosmic_cache`. In order to develop without internet access, you'll need
to run the server at least once to create that cache, which the server will lead
on in the event of network failure.

## Roadmap

See issues!

## What's this stack?

This is a typical Phoenix/Elixir application. To edit some html, run
`mix phoenix.server`, edit anything in `/web`, and it will live reload. The
`.html.eex` files are mostly html, but anything in between `<%=` and `%>` will
be evaluated as Elixir code. If you're working on a page (a whole view), put the
`.html.eex` in `web/templates/pages`. If you're working on a component that is
shared accross pages, put it in `web/templates/layout`. When you include a sub-template
in a page, use
```
<%= render Core.PageView, "my-template-in-pages.html", [key: value] %>
```
OR
```
<%= render Core.LayoutView, "my-template-in-layout.html", [key: value] %>
```
depending on whether or not it's in `templates/pages` or `templates/layout`.

## JD vs. BNC

In the routing layer, `/web/router.ex`, a variable is passed to all views called
`brand`. Variables can be accessed inside a template prefaced with `@`, so you see
referenced to `@brand`. To set the brand (controlling whether the page is viewed
from brandnewcongress.org or justicedemocrats.com), append `?brand=jd` to the URL
for JD or anything else / nothing for BNC.

Right now, I'm setting the brand as a class name on the body, so that can be used
to conditionally apply styles.

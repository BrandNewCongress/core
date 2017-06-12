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
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## What's Happening Here

For the website, we are using an approach where the templates are in Elixir HTML
templates, but most of the content lives in [CosmicJS](cosmicjs.com). There,
we created "buckets", which are little bits of content (either plain text or
html) that are editable in the admin view.

When it's time for a page to be rendered here, code in `views/layout_view.ex` and
`controllers/page_controller.ex` fetches the data from Cosmic and passes it to
the templates. This lets us clearly separate display from content, allowing a
non-technical group of people to edit content while the technical people are in
control of its display.

## Roadmap

Right now, I've created a few buckets and gotten them to show up on the page.
We are sprinting to recreate the entire sites https://brandnewcongress.org and
https://justicedemocrats.com. There exist buckets `jd-platform`, `bnc-platform`,
`jd-footer-links` (incomplete), `bnc-footer-links` (incomplete), and `cori-bush`.

We need to create the website component by component and section by section, as
modularly as possible. For the moment, it's sufficient to insert some dummy data
and mark that a bucket should exist here with a comment `TODO - bucket`.

## TODO

The following need be styled and templated out in html:
- [] BNC Footer
- [] JD Footer
- [] BNC Header
- [] JD Header
- [] BNC Platform
- [] JD Platform

This also needs to happen:
[] Fetch all buckets at once and cache them
[] Handle edit webhooks and refetch and cache buckets

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

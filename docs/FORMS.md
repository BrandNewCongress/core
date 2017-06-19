# Forms!

Once you've made your form in Typeform, go to the `Share` pane. On the side, click
`Embed in a web page`. Scroll down a little bit, turn `Seamless mode` ON, and then
keep scrolling until you see a box with the header `Grab the code`. Click `Copy`,
and then hold on to your clipboard for a second.

Here's how to make them. Log in to https://cosmicjs.com, and navigate to our
dashboard, https://cosmicjs.com/brand-new-congress/dashboard. On the right, click
on `Forms`.

To make a new one, click `+ Add Form` in the upper right. Give it a nice title
and a nice slug, and ignore the content section. Instead, scroll down to the `Share HTML`
field, and paste what you copied earlier.

If you want to publish immediately, select `Published` for the visibility field
and do the update instructions below.

## Draft vs Published

If you want a draft to look at before making it live to all users, select `Draft`.
Now, your form will only be available at, for example,
https://now.brandnewcongress.org/form/host-event?draft=true, with that little
`?draft=true` at the end.

## JD vs. BNC

There is one metadata field in the new petition form called `Brands`, with
the possible values `bnc` and `jd`. If you select `bnc`, the petition will be
available at `https://now.brandnewcongress.org/form/#{slug}`. If you select
`jd`, it will be available at `https://now.justicedemocratcs.com/form/#{slug}`.
If you select both, it will be available at both.

## Updating

To see your updates, visit `https://now.brandnewcongress.org/api/update/cosmic?secret=`
and paste in the secret that Ben gave you when you asked him for it.

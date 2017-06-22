# Forms!

Note: Typeform does not allow me, through the API, to duplicate forms, etc. That is unfortunate.
As a result, for every form you want to show up with both JD and BNC branding, you'll
need to duplicate the form and change what appears in the design panel.

Once you've made your forms in Typeform, go to the `Share` pane. On the side, click
`Embed in a web page`. Scroll down a little bit, turn `Seamless mode` ON, and then
keep scrolling until you see a box with the header `Grab the code`. Click `Copy`,
and then hold on to your clipboard for a second.

Here's how to make them. Log in to https://cosmicjs.com, and navigate to our
dashboard, https://cosmicjs.com/brand-new-congress/dashboard. On the right, click
on `Forms`.

To make a new one, click `+ Add Form` in the upper right. Give it a nice title
and a nice slug, and ignore the content section. When creating a slug, try to make it
something that is short and descriptive, but you could imagine would never be
used for something similar. Scroll down to the `BNC Share HTML` and `JD Share HTML`
fields, and paste what you copied earlier from the JD and BNC Typeforms's respectively.

If you don't want it to be a JD form or don't want it to be a BNC form, leave that
`* Share HTML` field blank, and it won't exist there.

If you want to publish immediately, select `Published` for the visibility field
and do the update instructions below.

## Draft vs Published

If you want a draft to look at before making it live to all users, select `Draft`.
Now, your form will only be available at, for example,
https://now.brandnewcongress.org/form/host-event?draft=true, with that little
`?draft=true` at the end.

## Updating

To see your updates, visit `https://now.brandnewcongress.org/api/update/cosmic?secret=`
and paste in the secret that Ben gave you when you asked him for it.

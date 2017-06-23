# defmodule Core.EventTemplate do
#   def text(event) do
# "
# Hi!
#
# A user, #{contact_name}, has submitted a new event for #{candidate}.
#
# Please go to your candidate's calendar and modify and approve or delete it.
#
# Here are some details: <br/>
# Headline: #{title} <br />
# Intro: #{intro} <br />
# From #{start_time} to #{end_time}<br />
# Time zone: #{time_zone}<br />
#
# At #{venue.name}, <br />
# #{venue.address.address1}, <br />
# #{venue.address.city}, #{venue.address.state}, #{venue.address.zip5} <br />
#
# Host info: <br />
# Name: #{contact.name} <br />
# Email: #{contact.email} <br />
# Phone: #{contact.phone} <br />
#
# Other: <br />
# Event ID: #{id} <br />
# Campaign: #{candidate} <br />
# URL: #{url} <br />
# "
#   end
# end

defmodule Core.Mailer do
  use Swoosh.Mailer, otp_app: :core
  import Swoosh.Email
  require Logger

  def on_event_create(id, slug, event) do
    Logger.info "Sending email to Sam for event #{id}"

    new()
    |> to({"Sam Briggs", "ben@brandnewcongress.org"})
    |> from({event.contact.name, "us@mail.brandnewcongress.org"})
    |> subject("New User Submitted Event!")
    |> text_body(event_create_text(id, slug, event))
    |> deliver
  end

  def event_create_text(id, slug, event) do
    %{
      calendar_id: candidate,
      contact: contact,
      intro: intro,
      name: title,
      start_time: start_time,
      end_time: end_time,
      venue: venue,
      time_zone: time_zone
    } = event
"
Hi!

A user, #{contact.name}, has submitted a new event for #{candidate}.

Please go to your candidate's calendar and modify and approve or delete it.

Here are some details:
Headline: #{title}
Intro: #{intro}
From #{start_time} to #{end_time}
Time zone: #{time_zone}

At #{venue.name},
#{venue.address.address1},
#{venue.address.city}, #{venue.address.state}, #{venue.address.zip}

Host info:
Name: #{contact.name}
Email: #{contact.email}
Phone: #{contact.phone}

Other:
Event ID: #{id}
Campaign: #{candidate}
URL: http://go.brandnewcongress.org/#{slug}
"
  end
end

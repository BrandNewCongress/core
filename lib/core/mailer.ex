defmodule Core.Mailer do
  use Swoosh.Mailer, otp_app: :core
  import Swoosh.Email
  require Logger

  def on_event_create(id, slug, event) do
    Logger.info "Sending email to Sam for event #{id}"

    new()
    |> to({"Sam Briggs", "sam@brandnewcongress.org"})
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({event.contact.name, "us@mail.brandnewcongress.org"})
    |> subject("New User Submitted Event!")
    |> text_body(event_create_text(id, slug, event))
    |> deliver()
  end

  def typeform_failure_alert(body) do
    Logger.info "Sending email to Ben because of failure on Typeform webhook"

    {:ok, stringified} = Poison.encode(body)

    new()
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({"BNC Errors", "us@mail.brandnewcongress.org"})
    |> subject("Typeform Error")
    |> text_body(stringified)
    |> deliver()
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
From: #{start_time}Z
To: #{end_time}Z
Time zone: #{time_zone}

Venue Name: #{venue.name}
#{venue.address.address1}
#{venue.address.city}
#{venue.address.state}
#{venue.address.zip}

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

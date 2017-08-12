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

  def on_vox_login_claimed(%{"username" => username, "date" => date,
    "first_name" => first_name, "last_name" => last_name, "email" => email,
    "phone" => phone}) do

    new()
    |> to({"Sam Briggs", "sam@brandnewcongress.org"})
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({"Robot", "robot@brandnewcongress.org"})
    |> subject("New Vox Login Claimed!")
    |> text_body("Username: #{username}\nDate: #{date}\nFirst name: #{first_name}\nLast name: #{last_name}\nEmail: #{email}\nPhone: #{phone}")
    |> deliver()
  end

  def typeform_failure_alert(body, e) do
    Logger.info "Sending email to Ben because of failure on Typeform webhook"

    {:ok, stringified} = Poison.encode(%{body: body, error: e}, pretty: true)

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
      time_zone: time_zone,
      tags: tags,
      status: status
    } = event

    event_type = Enum.find tags, "Unknown", fn
      "Event Type:" <> _rest -> true
      _ -> false
    end

"
Hi!

A user, #{contact.name}, has submitted a new event for #{candidate}.

Please go to your candidate's calendar and modify and approve or delete it.

Here are some details:
Headline: #{title}
Intro: #{intro}
From: #{start_time}
To: #{end_time}
Time zone: #{time_zone}

Venue Name: #{venue.name}
Venue Address: #{venue.address.address1}
Venue City: #{venue.address.city}
Venue State: #{venue.address.state}
Venue Zip: #{venue.address.zip}

Host info
Name: #{contact.name}
Email: #{contact.email}
Phone: #{contact.phone}

Other
Event ID: #{id}
Campaign: #{candidate}
URL: http://now.brandnewcongress.org/events/#{slug}

Should Contact Host: #{Enum.member?(tags, "Event: Should Contact Host")}
#{event_type}
Status: #{status}
"
  end
end

defmodule Core.EventMailer do
  use Phoenix.Swoosh,
    view: Core.EmailView,
    layout: {Core.EmailView, :email}

  require Logger
  import ShorterMaps

  def on_create(id, slug, event) do
    Logger.info "Sending email to Sam for event #{id}"

    new()
    |> from({event.contact.name, "us@mail.brandnewcongress.org"})
    |> to({"Sam Briggs", "sam@brandnewcongress.org"})
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> subject("New User Submitted Event!")
    |> render_body("new-event.text", %{id: id, slug: slug, event: event})
    |> Core.Mailer.deliver()
  end

  def typeform_failure_alert(body) do
    Logger.info "Sending email to Ben because of failure on Typeform webhook"

    {:ok, stringified} = Poison.encode(body)

    new()
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({"BNC Errors", "us@mail.brandnewcongress.org"})
    |> subject("Typeform Error")
    |> render_body("event-failure.text", %{raw: stringified})
    |> Core.Mailer.deliver()
  end

  def on_rsvp(event, %{"first_name" => first_name, "last_name" => last_name, "email" => email}, calendar) do
    Logger.info "Sending email to #{email} because of RSVP to #{event.name}"

    params = Map.merge(event, ~m{first_name, last_name, email, candidate: calendar})

    new()
    |> to({"#{first_name} #{last_name}", email})
    |> from({event["contact"]["name"], event["contact"]["email"]})
    |> subject("RSVP Confirmation: #{event["title"]}")
    |> render_body("rsvp-email.html", params)
    |> render_body("rsvp-email.text", params)
    |> Core.Mailer.deliver()
  end
end

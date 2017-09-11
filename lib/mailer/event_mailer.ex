defmodule Core.EventMailer do
  use Phoenix.Swoosh,
    view: Core.EmailView,
    layout: {Core.EmailView, :email}

  require Logger
  import ShorterMaps

  def on_create(id, slug, event) do
    Logger.info "Sending email to Sam for event #{id}"

    new()
    |> to({"Sam Briggs", "sam@brandnewcongress.org"})
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({event.contact.name, "us@mail.brandnewcongress.org"})
    |> subject("New User Submitted Event!")
    |> render_body("new-event.text", %{id: id, slug: slug, event: event})
    |> Core.Mailer.deliver()
  end

  def failure_alert(body) do
    Logger.info "Sending email to Ben because of failure on Typeform webhook"

    {:ok, stringified} = Poison.encode(body)

    new()
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({"BNC Errors", "us@mail.brandnewcongress.org"})
    |> subject("Typeform Error")
    |> render_body("event-failure.text", %{raw: stringified})
    |> Core.Mailer.deliver()
  end

  def bad_event_alert(body) do
    Logger.info "Sending email to Ben because of bad event"

    {:ok, stringified} = Poison.encode(body)

    new()
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({"BNC Errors", "us@mail.brandnewcongress.org"})
    |> subject("Bad Event Error")
    |> render_body("event-failure.text", %{raw: stringified})
    |> Core.Mailer.deliver()
  end

  def on_rsvp(event, %{"first_name" => first_name, "last_name" => last_name, "email" => email}) do
    Logger.info "Sending email to #{email} because of RSVP to #{event.name}"

    candidate =
      event.tags
      |> Enum.map(&(&1.name))
      |> Enum.filter(&(String.contains?(&1, "Calendar: ")))
      |> Enum.map(&(&1 |> String.split(":") |> List.last() |> String.trim()))
      |> Enum.filter(&(not Enum.member?(["Brand New Congress", "Justice Democrats"], &1)))
      |> List.first()

    candidate = case candidate do
      nil -> "Justice Democrats"
      cand -> cand
    end

    IO.inspect candidate

    params = ~M{first_name, last_name, email, candidate, event}

    new()
    |> to({"#{first_name} #{last_name}", email})
    |> from({event.host.name, "events@brandnewcongress.org"})
    |> subject("RSVP Confirmation: #{event.title}")
    |> render_body(:"rsvp-email", params)
    |> Core.Mailer.deliver()
  end
end

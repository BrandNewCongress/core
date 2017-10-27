defmodule Core.EventMailer do
  use Phoenix.Swoosh,
    view: Core.EmailView,
    layout: {Core.EmailView, :email}

  require Logger
  import ShorterMaps

  def on_create(id, slug, event) do
    Logger.info("Sending email to Sam for event #{id}")

    new()
    |> to({"Sam Briggs", "sam@brandnewcongress.org"})
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({event.contact.name, "us@mail.brandnewcongress.org"})
    |> subject("New User Submitted Event!")
    |> render_body("new-event.text", %{id: id, slug: slug, event: event})
    |> Core.Mailer.deliver()
  end

  def failure_alert(body) do
    Logger.info("Sending email to Ben because of failure on Typeform webhook")

    {:ok, stringified} = Poison.encode(body)

    new()
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({"BNC Errors", "us@mail.brandnewcongress.org"})
    |> subject("Typeform Error")
    |> render_body("event-failure.text", %{raw: stringified})
    |> Core.Mailer.deliver()
  end

  def bad_event_alert(body) do
    Logger.info("Sending email to Ben because of bad event")

    {:ok, stringified} = Poison.encode(body)

    new()
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({"BNC Errors", "us@mail.brandnewcongress.org"})
    |> subject("Bad Event Error")
    |> render_body("event-failure.text", %{raw: stringified})
    |> Core.Mailer.deliver()
  end

  def on_rsvp(event, params, brand) do
    candidate =
      event.tags
      |> Enum.filter(&String.contains?(&1, "Calendar: "))
      |> Enum.map(&(&1 |> String.split(":") |> List.last() |> String.trim()))
      |> Enum.filter(&(not Enum.member?(["Brand New Congress", "Justice Democrats"], &1)))
      |> List.first()

    candidate =
      case candidate do
        nil ->
          case brand do
            "jd" -> "Justice Democrats"
            "bnc" -> "Brand New Congress"
          end
        cand -> cand
      end

    event =
      Map.put(
        event,
        :rsvp_download_url,
        "https://admin.justicedemocrats.com/rsvps/#{Osdi.Event.rsvp_link_for(event.name)}"
      )

    send_attendee_email(event, params, candidate, brand)
    send_host_email(event, params, candidate, brand)
  end

  defp send_attendee_email(
         event,
         _params = %{"first_name" => first_name, "last_name" => last_name, "email" => email},
         candidate,
         brand
       ) do

    Logger.info("Sending email to #{email} because they RSVPed to #{event.name}")
    params = ~M{first_name, last_name, email, candidate, event}

    new()
    |> to({"#{first_name} #{last_name}", email})
    |> from({event.contact.name || event.contact.email_address, brand_email(brand)})
    |> subject("RSVP Confirmation: #{event.title}")
    |> render_body(String.to_atom("rsvp-email-#{brand}"), params)
    |> Core.Mailer.deliver()
  end

  defp send_host_email(
         event,
         _params = %{"first_name" => first_name, "last_name" => last_name, "email" => email},
         candidate,
         brand
       ) do

    Logger.info("Sending email to #{email} because someone RSVPed to their event, #{event.name}")
    params = ~M{first_name, last_name, email, candidate, event}

    new()
    |> to({"#{event.contact.name}", event.contact.email_address})
    |> from({"#{candidate} Events Team", "events@justicedemocrats.com"})
    |> subject("A New RSVP for #{event.title}!")
    |> render_body(:"rsvp-host-email", params)
    |> Core.Mailer.deliver()
  end

  defp brand_email("jd"), do: "events@justicedemocrats.com"
  defp brand_email("bnc"), do: "events@brandnewcongress.org"
end

defmodule Jotform.SubmitEvent do
  require Logger

  @doc"""
  Takes a typeform post body from a webhook, creates the event in NB, and sends an email
  """
  def on_event_submit(params = %{"rawRequest" => raw}) do
    %{"q3_name" => %{"first" => first_name, "last" => last_name},
      "q4_area_phone" => %{"area" => area, "phone" => phone_rest},
      "q5_email" => email, "q6_event_type" => event_type, "q7_event_date" => event_date,
      "q8_start_time" => start_time, "q9_end_time" => end_time,
      "q10_description" => description, "q13_venue_name" => venue_name,
      "q14_should_hide" => hide_address, "q15_address" => venue_address,
      "q16_event_name" => event_name, "q17_should_contact" => should_contact} = Poison.decode!(raw)

    auto_whitelist = Map.has_key?(params, "whitelist")

    phone = area <> phone_rest
    should_hide = hide_address == "Yes"
    should_contact = should_contact == "Yes"

    [venue_street_name, venue_house_number, venue_city, venue_state, venue_zip] =
      case String.split venue_address, "\r\n" do
        ["Street name: " <> venue_street_name, "House number: " <> venue_house_number,
         "City: " <> venue_city, "State: " <> venue_state, "Postal code: " <> venue_zip]
           -> [venue_street_name, venue_house_number, venue_city, venue_state, venue_zip]

        ["City: " <> venue_city, "State: " <> venue_state]
          -> ["", "", venue_city, venue_state, ""]
      end

    venue_address = venue_house_number <> " " <> venue_street_name

    ensure_host = Task.async(fn ->
      %{"id" => id} = Nb.People.push(
        %{email: email, phone: phone_rest,
          first_name: first_name, last_name: last_name})
      id
    end)

    {calendar_id, time_zone_info} = Task.await(Task.async(fn ->
      # First, geocode
      {lat, lng} = Maps.geocode(venue_zip)

      # Use geocode for calendar_id
      calendar_id = Task.async(fn ->
        case District.closest_candidate({lat, lng}) do
          %{"metadata" => %{"calendar_id" => result}} -> result
          _ -> 9
        end
      end)

      # Use geocode for time zone
      time_zone_info = Task.async(fn ->
        Maps.time_zone_of({lat, lng})
      end)

      {Task.await(calendar_id), Task.await(time_zone_info)}
    end))

    host_id = Task.await(ensure_host)
    %{time_zone: time_zone} = time_zone_info

    whitelisted =
        "esm-whitelist"
        |> Cosmic.get()
        |> Kernel.get_in(["metadata", "emails"])
        |> String.split(";")
        |> Enum.map(&String.trim/1)
        |> MapSet.new()
        |> MapSet.member?(email)

    status = if whitelisted or auto_whitelist, do: "published", else: "unlisted"

    # Calc tags
    type_tag = ["Event Type: #{event_type}"]

    sharing_tag = case should_hide do
      true -> []
      false -> ["Event: Hide Address"]
    end

    contact_tag =
      if should_contact and not whitelisted do
        ["Event: Should Contact Host"]
      else
        []
      end

    tags = type_tag ++ sharing_tag ++ contact_tag

    event = %{
      name: event_name,
      status: status,
      author_id: host_id,
      time_zone: time_zone,
      intro: description,
      start_time: to_iso(start_time, event_date, time_zone_info),
      end_time: to_iso(end_time, event_date, time_zone_info),
      contact: %{
        name: first_name <> " " <> last_name,
        phone: phone,
        email: email
      },
      rsvp_form: %{
        phone: "optional",
        address: "optional",
        accept_rsvps: true,
        gather_volunteers: true,
        allow_guests: true
      },
      venue: %{
        name: venue_name,
        address: %{
          address1: venue_address,
          city: venue_city,
          state: venue_state,
          zip: venue_zip
        }
      },
      autoresponse: %{
        broadcaster_id: 21,
        subject: "RSVP Confirmation: #{event_name}",
        body: "{{ recipient.first_name_or_friend }} --
Thank you for your RSVP.

{% include \"mailing_event\" %}

If you need to update or cancel your RSVP, use this link:

{{ edit_url }}

And you can invite others to join you at the event with this link:

{{ page_url }}"
      },
      tags: tags,
      calendar_id: calendar_id
    }

    Logger.info "Creating event on calendar #{calendar_id}"
    %{"id" => event_id, "slug" => event_slug} = Nb.Events.create(event)
    Logger.info "Created event #{event_id}"
    Core.Mailer.on_event_create(event_id, event_slug, event)

    %{"ok" => "There you go!"}
  end

  def to_iso(time, date, time_zone_info) do
    %{utc_offset: utc_offset, time_zone: time_zone,
      zone_abbr: zone_abbr} = time_zone_info

    [hours, minutes] = military_time(time)

    [month, day, year] = String.split(date, "/")

    dt = %DateTime{
      year: easy_int(year), month: easy_int(month), day: easy_int(day),
      time_zone: time_zone, hour: easy_int(hours),
      minute: easy_int(minutes), second: 0, std_offset: 0,
      utc_offset: utc_offset, zone_abbr: zone_abbr
    }

    DateTime.to_iso8601(dt)
  end

  defp military_time(%{"hourSelect" => hours, "minuteSelect" => minutes, "ampm" => "AM"}) do
    ["#{hours}", "#{minutes}"]
  end

  defp military_time(%{"hourSelect" => hours, "minuteSelect" => minutes, "ampm" => "PM"}) do
    {hrs, _} = Integer.parse(hours)
    ["#{hrs + 12}", "#{minutes}"]
  end

  defp easy_int(str) do
    {int, _} = Integer.parse(str)
    int
  end
end

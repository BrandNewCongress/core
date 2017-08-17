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

    ## ------------ Determine whitelist status
    auto_whitelist = Map.has_key?(params, "whitelist")
    status = if auto_whitelist do
      "published"
    else
      whitelisted =
        "esm-whitelist"
        |> Cosmic.get()
        |> Kernel.get_in(["metadata", "emails"])
        |> String.split(";")
        |> Enum.map(&String.trim/1)
        |> MapSet.new()
        |> MapSet.member?(email)

      if whitelisted, do: "published", else: "unlisted"
    end

    ## ------------ Proper phone number
    phone = area <> phone_rest
    should_hide = hide_address == "Yes"
    should_contact = should_contact == "Yes"

    ## ------------ Extract and format the address
    [venue_street_name, venue_house_number, venue_city, venue_state, venue_zip] =
      case String.split venue_address, "\r\n" do
        ["Street name: " <> venue_street_name, "House number: " <> venue_house_number,
         "City: " <> venue_city, "State: " <> venue_state, "Postal code: " <> venue_zip]
           -> [venue_street_name, venue_house_number, venue_city, venue_state, venue_zip]

        ["City: " <> venue_city, "State: " <> venue_state]
          -> ["", "", venue_city, venue_state, ""]
      end

    venue_address = venue_house_number <> " " <> venue_street_name

    ## ------------ Create and or find person
    ensure_host = Task.async(fn ->
      %{"id" => id} = Nb.People.push(
        %{email: email, phone: phone_rest,
          first_name: first_name, last_name: last_name})
      id
    end)

    ## ------------ Determine calendar id and time zone, geocoding only once
    {calendar_id, time_zone_info} = Task.await(Task.async(fn ->
      # First, geocode
      to_geocode = "#{venue_house_number} #{venue_street_name}, #{venue_city}, #{venue_state}"
      {lat, lng} = Maps.geocode(to_geocode)

      # Use geocode for calendar_id
      calendar_id = Task.async(fn -> get_calendar({lat, lng}) end)

      # Use geocode for time zone
      time_zone_info = Task.async(fn ->
        Maps.time_zone_of({lat, lng})
      end)

      {Task.await(calendar_id), Task.await(time_zone_info)}
    end))

    host_id = Task.await(ensure_host)
    %{time_zone: time_zone, time_zone_id: time_zone_id} = time_zone_info

    ## ------------ Determine event tags
    type_and_time = ["Event Type: #{event_type}", "Event Time Zone: #{time_zone_id}"]

    sharing_tag = case should_hide do
      true -> []
      false -> ["Event: Hide Address"]
    end

    contact_tag = case (should_contact and status != "published") do
      true -> ["Event: Should Contact Host"]
      false -> []
    end

    tags = type_and_time ++ sharing_tag ++ contact_tag

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
      autoresponse: nil,
      tags: tags,
      calendar_id: calendar_id
    }

    Logger.info "Creating event on calendar #{calendar_id}"
    %{"id" => event_id, "slug" => event_slug} = Nb.Events.create(event)
    Logger.info "Created event #{event_id}"
    Core.EventMailer.on_create(event_id, event_slug, event)

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

  defp get_calendar({lat, lng}) do
    case District.closest_candidate({lat, lng}) do
      %{"metadata" => %{"calendar_id" => result}} ->
        if result == "", do: 9, else: result
      _ -> 9
    end
  end
end

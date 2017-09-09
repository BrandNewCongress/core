defmodule Jotform.SubmitEvent do
  alias Osdi.{Repo, Person, Event}
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
      "confirmed"
    else
      whitelisted =
        "esm-whitelist"
        |> Cosmic.get()
        |> Kernel.get_in(["metadata", "emails"])
        |> String.split(";")
        |> Enum.map(&String.trim/1)
        |> MapSet.new()
        |> MapSet.member?(email)

      if whitelisted, do: "confirmed", else: "tentative"
    end

    ## ------------ Proper phone number
    phone = area <> phone_rest
    should_hide = hide_address == "Yes"
    should_contact = should_contact == "Yes"

    ## ------------ Extract and format the address
    split_address = String.split venue_address, "\r\n"
    [venue_street_name, venue_house_number, venue_city, venue_state, venue_zip] =
      ["Street name: ", "House number: ", "City: ", "State: ", "Postal code: "]
      |> Enum.map(fn fragment ->
        addr_part = Enum.find(split_address, fn addr_part -> String.contains?(addr_part, fragment) end)
        if addr_part do
          addr_part |> String.split(":") |> List.last() |> String.trim()
        else
          ""
        end
      end)

    venue_address = venue_house_number <> " " <> venue_street_name

    ## ------------ Create and or find person
    organizer_task = Task.async fn ->
      create_organizer(%{email: email, phone: phone, first_name: first_name, last_name: last_name})
    end

    ## ------------ Determine calendar id and time zone, geocoding only once
    {calendars, time_zone_info, {latitude, longitude}} = Task.await(Task.async(fn ->
      # First, geocode
      to_geocode = "#{venue_house_number} #{venue_street_name}, #{venue_city}, #{venue_state}"
      {lat, lng} = Maps.geocode(to_geocode)

      # Use geocode for calendar_id
      calendars = Task.async(fn -> get_calendars({lat, lng}) end)

      # Use geocode for time zone
      time_zone_info = Task.async(fn ->
        Maps.time_zone_of({lat, lng})
      end)

      {Task.await(calendars), Task.await(time_zone_info), {lat, lng}}
    end))

    organizer = Task.await(organizer_task)
    %{time_zone_id: time_zone_id} = time_zone_info

    ## ------------ Determine event tags
    sharing_tag = case should_hide do
      true -> []
      false -> ["Event: Hide Address"]
    end

    contact_tag = case should_contact do
      true -> ["Event: Should Contact Host"]
      false -> []
    end

    tags = sharing_tag ++ contact_tag ++ (Enum.map calendars, &("Calendar: #{&1}"))

    # Create the thing!
    event = %{
      title: event_name,
      status: status,
      creator: organizer,
      organizer: organizer,
      time_zone: time_zone_id,
      type: event_type,
      description: description,
      start_date: construct_dt(start_time, event_date, time_zone_info),
      end_date: construct_dt(end_time, event_date, time_zone_info),
      host: %{
        name: first_name <> " " <> last_name,
        phone_number: phone,
        email_address: email
      },
      location: %{
        venue: venue_name,
        address_lines: [venue_address],
        locality: venue_city,
        region: venue_state,
        postal_code: venue_zip,
        location: %Geo.Point{coordinates: {latitude, longitude}, srid: nil},
      },
      tags: tags,
    }

    Logger.info "Creating event on calendars #{Enum.join calendars, ", "}"

    created = %{id: event_id, name: name} =
      %Event{}
      |> Event.changeset(event)
      |> Repo.insert!()

    Logger.info "Created event #{event_id}: #{name}"

    %{success: %{event: created |> Map.take(~w(
      name title description summary browser_url type
      featured_image_url start_date end_date status host
    )a)}}
  end

  def construct_dt(time, date, time_zone_info) do
    %{utc_offset: utc_offset, time_zone: time_zone,
      zone_abbr: zone_abbr} = time_zone_info

    [hours, minutes] = military_time(time)

    [month, day, year] = String.split(date, "/")

    %DateTime{
      year: easy_int(year), month: easy_int(month), day: easy_int(day),
      time_zone: time_zone, hour: easy_int(hours),
      minute: easy_int(minutes), second: 0, std_offset: 0,
      utc_offset: utc_offset, zone_abbr: zone_abbr
    }
  end

  defp military_time(%{"hourSelect" => hours, "minuteSelect" => minutes, "ampm" => "AM"}) do
    ["#{hours}", "#{minutes}"]
  end

  defp military_time(%{"hourSelect" => hours, "minuteSelect" => minutes, "ampm" => "PM"}) do
    {hrs, _} = Integer.parse(hours)
    hrs = if hrs == 12, do: hrs, else: hrs + 12
    ["#{hrs}", "#{minutes}"]
  end

  defp easy_int(str) do
    {int, _} = Integer.parse(str)
    int
  end

  defp get_calendars({lat, lng}) do
    case District.closest_candidate({lat, lng}) do
      %{"title" => title} -> [title]
      _ -> ["Brand New Congress", "Justice Democrats"]
    end
  end

  defp create_organizer(%{email: email, phone: phone, first_name: first_name, last_name: last_name}) do
    Nb.People.push(%{email: email, phone: phone, first_name: first_name, last_name: last_name})
    Person.push(%{email_address: email, phone_number: phone, given_name: first_name, family_name: last_name})
  end
end

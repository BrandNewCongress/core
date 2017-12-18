defmodule Jotform.SubmitEvent do
  require Logger

  @doc """
  Takes a typeform post body from a webhook, creates the event in NB, and sends an email
  """
  def on_event_submit(params = %{"rawRequest" => raw}) do
    as_map = Poison.decode!(raw)

    %{
      name: %{"first" => first_name, "last" => last_name},
      area_phone: %{"area" => area, "phone" => phone_rest},
      email: email,
      event_type: event_type,
      event_date: event_date,
      start_time: start_time,
      end_time: end_time,
      description: description,
      venue_name: venue_name,
      hide_address: hide_address,
      address: venue_address,
      event_name: event_name,
      should_contact: should_contact,
      instructions: instructions,
      hide_phone: hide_phone,
      candidate: candidate
    } =
      ~w(name area_phone email event_type event_date start_time end_time description
           venue_name hide_address address event_name should_contact instructions
           hide_phone candidate)
      |> Enum.map(fn attr -> {String.to_atom(attr), matching_val(attr, as_map)} end)
      |> Enum.into(%{})

    ## ------------ Determine whitelist status
    auto_whitelist = Map.has_key?(params, "whitelist")

    status =
      if auto_whitelist do
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
    should_contact = should_contact == "Yes"

    ## ------------ Extract and format the address
    split_address = String.split(venue_address, "\r\n")

    [venue_street_name, venue_house_number, venue_city, venue_state, venue_zip] =
      ["Street name: ", "House number: ", "City: ", "State: ", "Postal code: "]
      |> Enum.map(fn fragment ->
           addr_part =
             Enum.find(split_address, fn addr_part -> String.contains?(addr_part, fragment) end)

           if addr_part do
             addr_part |> String.split(":") |> List.last() |> String.trim()
           else
             nil
           end
         end)

    venue_address = "#{venue_house_number} #{venue_street_name}"

    ## ------------ Determine calendar id and time zone, geocoding only once
    calendars =
      ["Justice Democrats", "Brand New Congress"] ++
        if candidate,
          do: as_map["candidate"] |> String.split(":") |> List.last(),
          else: []

    ## ------------ Determine event tags
    contact_tag =
      case should_contact do
        true -> ["Event: Should Contact Host"]
        false -> []
      end

    direct_publish_tag =
      case status do
        "confirmed" -> ["Source: Direct Publish"]
        _ -> []
      end

    tags = contact_tag ++ direct_publish_tag ++ Enum.map(calendars, &"Calendar: #{&1}")

    summary =
      String.slice(description, 0..199) <>
        if String.length(description) > 200, do: "...", else: ""

    # Create the thing!
    event = %{
      title: event_name,
      status: status,
      type: event_type,
      description: description,
      summary: summary,
      instructions: instructions,
      start_date: construct_dt(start_time, event_date),
      end_date: construct_dt(end_time, event_date),
      contact: %{
        name: first_name <> " " <> last_name,
        phone_number: phone,
        email_address: email,
        public: hide_phone != "Hide"
      },
      location: %{
        public: hide_address == "Show",
        venue: venue_name,
        address_lines: [venue_address],
        locality: venue_city,
        region: venue_state,
        postal_code: venue_zip
      },
      tags: tags
    }

    Logger.info("Creating event on calendars #{Enum.join(calendars, ", ")}")

    %{body: created} = EventProxy.post("events", body: event)
    %{identifiers: identifiers, name: name} = created

    Logger.info("Created event #{inspect(identifiers)}: #{name}")

    rsvp_id = identifiers |> List.first() |> String.split(":") |> List.last()
    encrypted_id = Cipher.encrypt(rsvp_id)

    created =
      Map.put(
        created,
        :rsvp_download_url,
        "https://admin.justicedemocrats.com/rsvps/#{encrypted_id}"
      )

    organizer_edit_hash = Cipher.encrypt("#{created.organizer_id}")

    created =
      Map.put(
        created,
        :organizer_edit_url,
        "https://admin.justicedemocrats.com/my-events/#{organizer_edit_hash}"
      )

    created = EventHelp.add_date_line(created)

    %{event: created |> Map.take(~w(
      name title description summary browser_url type date_line
      featured_image_url start_date end_date status contact
      location tags rsvp_download_url instructions organizer_edit_url
    )a)}
  end

  def construct_dt(time, date) do
    [hours, minutes] = military_time(time)

    [month, day, year] = String.split(date, "/")

    %DateTime{
      year: easy_int(year),
      month: easy_int(month),
      day: easy_int(day),
      time_zone: "",
      hour: easy_int(hours),
      minute: easy_int(minutes),
      second: 0,
      std_offset: 0,
      utc_offset: 0,
      zone_abbr: "UTC"
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

  defp matching_val(attr, map) do
    key =
      map
      |> Map.keys()
      |> Enum.filter(fn full -> extract_val_portion(full) == attr end)
      |> List.first()

    Map.get(map, key)
  end

  defp extract_val_portion(attr) do
    [_ | rest] = String.split(attr, "_")
    Enum.join(rest, "_")
  end
end

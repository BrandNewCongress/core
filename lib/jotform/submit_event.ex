defmodule Jotform.SubmitEvent do
  require Logger

  @doc"""
  Takes a typeform post body from a webhook, creates the event in NB, and sends an email
  """
  def on_event_submit(data) do
    IO.inspect data
    %{"ok" => "There you go!"}
  end
end


  @doc"""
  Takes a typeform post body from a webhook, creates the event in NB, and sends an email
  """
  def on_event_submit(all_data = %{"rawRequest" => raw}) do
    IO.inspect all_data

    %{"q3_name" => %{"first" => first_name, "last" => last_name},
      "q4_phoneNumber" => %{"area" => area, "phone" => phone_rest},
      "q5_email" => email, "q6_whatType" => event_type, "q7_whenWould" => date,
      "q8_whenWill" => start_time, "q9_whenWill9" => end_time,
      "q10_giveUs" => description, "q14_shouldWe14" => hide_answer
      "q13_whatIs" => venue_name, "q14_shouldWe14" => hide_address,
      "q15_whatsThe" => venue_address} = Poison.decode!(raw)

    phone = area <> phone_rest
    should_hide = hide_answer == "Yes"

    ["City: " <> city,
     "State: " <> state,
     "Postal code: " <> zip,
     "Country: " <> country] = String.split venue_address, "\r\n"

    ensure_host = Task.async(fn ->
      %{"id" => id} = Nb.People.push(
        %{email: email, phone: phone_rest,
          first_name: first_name, last_name: last_name})
      id
    end)

    {calendar_id, time_zone_info} = Task.await(Task.async(fn ->
      # First, geocode
      {lat, lng} = Maps.geocode(zip)

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

    # Calc tags
    type_tag = ["Event Type: #{event_type}"]
    sharing_tag = case should_hide do
      true -> []
      false -> ["Event: Hide Address"]
    end

    tags = type_tag ++ sharing_tag

    event = %{
      name: event_name,
      status: "unlisted",
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

    Core.Mailer.on_event_create(event_id, event_slug, event)

    %{"ok" => "There you go!"}
  end

  def to_iso(time, date, time_zone_info) do
    %{utc_offset: utc_offset, time_zone: time_zone,
      zone_abbr: zone_abbr} = time_zone_info

    [hours, minutes] =
      time
      |> String.split(" ")
      |> military_time()

    [year, month, day] = String.split(date, "-")

    dt = %DateTime{
      year: easy_int(year), month: easy_int(month), day: easy_int(day),
      time_zone: time_zone, hour: easy_int(hours),
      minute: easy_int(minutes), second: 0, std_offset: 0,
      utc_offset: utc_offset, zone_abbr: zone_abbr
    }

    DateTime.to_iso8601(dt)
  end

  defp military_time([hours_minutes, "AM"]) do
    [hours, minutes] = String.split(hours_minutes, ":")
    ["#{hours}", "#{minutes}"]
  end

  defp military_time([hours_minutes, "PM"]) do
    [hours, minutes] = String.split(hours_minutes, ":")
    {hrs, _} = Integer.parse(hours)
    ["#{hrs + 12}", "#{minutes}"]
  end

  defp easy_int(str) do
    {int, _} = Integer.parse(str)
    int
  end
end

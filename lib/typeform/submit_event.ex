defmodule Typeform.SubmitEvent do
  require Logger

  @doc"""
  Takes a typeform post body from a webhook, creates the event in NB, and sends an email
  """
  def on_event_submit(%{"form_response" => %{"answers" => answers, "definition" => definition}}) do
    questions = definition["fields"] |> Enum.map(&field_name/1)
    responses = answers |> Enum.map(&get_answer/1)
    together = questions |> Enum.zip(responses) |> Enum.into(%{})

    ensure_host = Task.async(fn ->
      names = String.split(together["host_name"], " ")
      first_name = List.first(names)
      last_name = List.last(names) || ""

      %{"id" => id} = Nb.People.push(
        %{email: together["host_email"], phone: together["host_phone"],
          first_name: first_name, last_name: last_name})

      id
    end)

    {calendar_id, time_zone_info} = Task.await(Task.async(fn ->
      # First, geocode
      {lat, lng} = Maps.geocode(together["venue_zip"])

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
    type_tag = ["Event Type: #{together["event_type"]}"]
    sharing_tag = case together["sharing_permission"] do
      true -> []
      false -> ["Event: Hide Address"]
    end

    contact_tag = case together["should_contact"] do
      true -> ["Event: Should Contact Host"]
      _ -> []
    end
    tags = type_tag ++ sharing_tag ++ contact_tag

    event = %{
      name: together["event_name"],
      status: "unlisted",
      author_id: host_id,
      time_zone: time_zone,
      intro: together["event_intro"],
      start_time: to_iso(together["start_time"], together["event_date"], time_zone_info),
      end_time: to_iso(together["end_time"], together["event_date"], time_zone_info),
      contact: %{
        name: together["host_name"],
        phone: together["host_phone"],
        email: together["host_email"]
      },
      rsvp_form: %{
        phone: "optional",
        address: "optional",
        accept_rsvps: true,
        gather_volunteers: true,
        allow_guests: true
      },
      venue: %{
        name: together["venue_name"],
        address: %{
          address1: together["venue_address"],
          city: together["venue_city"],
          state: together["venue_state"],
          zip: together["venue_zip"]
        }
      },
      autoresponse: %{
        broadcaster_id: 21,
        subject: "RSVP Confirmation: #{together["event_name"]}",
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

  defp field_name(%{"title" => "What's your name?"}), do: "host_name"
  defp field_name(%{"title" => "What's your email?"}), do: "host_email"
  defp field_name(%{"title" => "What's your phone number?"}), do: "host_phone"
  defp field_name(%{"title" => "When will it be?"}), do: "event_date"
  defp field_name(%{"title" => "When will it start?"}), do: "start_time"
  defp field_name(%{"title" => "When will it end?"}), do: "end_time"
  defp field_name(%{"title" => "What should we call it?"}), do: "event_name"
  defp field_name(%{"title" => "Give us a little description..."}), do: "event_intro"
  defp field_name(%{"title" => "What is the place called?"}), do: "venue_name"
  defp field_name(%{"title" => "What's the address?"}), do: "venue_address"
  defp field_name(%{"title" => "What city is it in?"}), do: "venue_city"
  defp field_name(%{"title" => "What state is it in?"}), do: "venue_state"
  defp field_name(%{"title" => "Can we share the address of the event on our map?"}), do: "sharing_permission"
  defp field_name(%{"title" => "What's the zip code?"}), do: "venue_zip"
  defp field_name(%{"title" => "Do you want someone from the BNC/JD Events Team to contact you about your" <> _rest}), do: "should_contact"
  defp field_name(%{"title" => "What type of event are you hosting?"}), do: "event_type"

  defp get_answer(%{"text" => val}), do: val
  defp get_answer(%{"email" => val}), do: val
  defp get_answer(%{"date" => val}), do: val
  defp get_answer(%{"choice" => %{"label" => val}}), do: val
  defp get_answer(%{"boolean" => val}), do: val
  defp get_answer(%{"number" => val}), do: val

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

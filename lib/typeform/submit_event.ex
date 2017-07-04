defmodule Typeform.SubmitEvent do
  require Logger

  @doc"""
  Takes a typeform post body from a webhook, creates the event in NB, and sends an email
  """
  def on_event_submit(%{"form_response" => %{"answers" => answers, "definition" => definition}}) do
    questions =
      definition["fields"]
      |> Enum.map(&field_name/1)

    responses =
      answers
      |> Enum.map(&get_answer/1)

    together = questions |> Enum.zip(responses) |> Enum.into(%{})

    ensure_host = Task.async(fn ->
      names = String.split(together["host_name"], " ")
      first_name = List.first(names)

      last_name = if length(names) > 1 do
        List.last(names)
      else
        ""
      end

      %{"id" => id} = Nb.People.push(%{
        email: together["host_email"],
        phone: together["host_phone"],
        first_name: first_name,
        last_name: last_name
      })

      id
    end)

    find_calendar = Task.async(fn ->
      calendar_id = case Zip.closest_candidate(together["venue_zip"]) do
        %{"metadata" => %{"calendar_id" => result}} -> result
        _ -> 9
      end

      calendar_id
    end)

    find_time_zone = Task.async(fn ->
      Zip.time_zone_of(together["venue_zip"])
    end)

    host_id = Task.await(ensure_host)
    calendar_id = Task.await(find_calendar)
    time_zone = Task.await(find_time_zone)

    tags = case together["sharing_permission"] do
      true -> []
      false -> ["Event: Hide Address"]
    end

    event = %{
      name: together["event_name"],
      status: "unlisted",
      author_id: host_id,
      time_zone: time_zone,
      intro: together["event_intro"],
      start_time: together["event_date"] <> "T" <> process_time(together["start_time"]),
      end_time: together["event_date"] <> "T" <> process_time(together["end_time"]),
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

  defp field_name(%{"title" => "What's the host's name?"}), do: "host_name"
  defp field_name(%{"title" => "What's the host's email?"}), do: "host_email"
  defp field_name(%{"title" => "What's the host's phone number?"}), do: "host_phone"
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

  defp get_answer(%{"text" => val}), do: val
  defp get_answer(%{"email" => val}), do: val
  defp get_answer(%{"date" => val}), do: val
  defp get_answer(%{"choice" => %{"label" => val}}), do: val
  defp get_answer(%{"boolean" => val}), do: val
  defp get_answer(%{"number" => val}), do: val

  def process_time(time) do
    case String.split(time, " ") do
      [hours_and_minutes, "AM"] -> hours_and_minutes |> String.split(":") |> output_time("AM")
      [hours_and_minutes, "PM"] -> hours_and_minutes |> String.split(":") |> output_time("PM")
    end
  end

  defp output_time([hours, minutes], "AM"), do: "#{hours}:#{minutes}"
  defp output_time([hours, minutes], "PM") do
    {hrs, _} = Integer.parse(hours)
    "#{hrs + 12}:#{minutes}"
  end
end

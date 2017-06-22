defmodule Core.TypeformController do
  use Core.Web, :controller

  def submit_event(conn, %{"form_response" => %{"answers" => answers, "definition" => definition}}) do
    questions =
      definition["fields"]
      |> Enum.map(&field_name/1)

    responses =
      answers
      |> Enum.map(&get_answer/1)

    together = questions |> Enum.zip(responses) |> Enum.into(%{})

    names = String.split(together["host_name"], " ")
    first_name = List.first(names)
    last_name = if length(names) > 1 do
      List.last(names)
    else
      ""
    end

    person = %{
      email: together["host_email"],
      phone: together["host_phone"],
      first_name: first_name,
      last_name: last_name
    }

    IO.puts "Inspecting person"
    IO.inspect person

    # TODO - NB create person

    event = %{
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
          address1: "venue_address",
          city: "venue_city",
          state: "venue_state"
        }
      }
    }

    IO.puts "Inspecting event"
    IO.inspect event
  end

  defp field_name(%{"title" => "What's your name?"}), do: "host_name"
  defp field_name(%{"title" => "What's your email?"}), do: "host_email"
  defp field_name(%{"title" => "What's your phone number?"}), do: "host_phone"
  defp field_name(%{"title" => "When will it be?"}), do: "start_time"
  defp field_name(%{"title" => "When will it start?"}), do: "start_time"
  defp field_name(%{"title" => "When will it end?"}), do: "end_time"
  defp field_name(%{"title" => "What should we call it?"}), do: "event_name"
  defp field_name(%{"title" => "Give us a little description..."}), do: "intro"
  defp field_name(%{"title" => "What is the place called?"}), do: "venue_name"
  defp field_name(%{"title" => "What's the address?"}), do: "venue_address"
  defp field_name(%{"title" => "What city is it in?"}), do: "venue_city"
  defp field_name(%{"title" => "What state is it in?"}), do: "venue_state"
  defp field_name(%{"title" => "Can we share the address of the event on our map?"}), do: "sharing_permission"
  defp field_name(%{"title" => "What's your zip code?"}), do: "venue_zip"

  defp get_answer(%{"text" => val}), do: val
  defp get_answer(%{"email" => val}), do: val
  defp get_answer(%{"date" => val}), do: val
  defp get_answer(%{"choice" => %{"label" => val}}), do: val
  defp get_answer(%{"boolean" => val}), do: val
  defp get_answer(%{"number" => val}), do: val

end

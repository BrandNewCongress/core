defmodule Core.VoxReportChannel do
  use Phoenix.Channel
  require Logger

  def join("vox-report", _message, socket) do
    {:ok, socket}
  end

  def handle_in("download", _message, socket) do
    "tags"
    |> Nb.Api.stream()
    |> Stream.filter(&is_vox_tag/1)
    |> Stream.map(&get_person_of_tag/1)
    |> Stream.map(&(push_person(socket, &1)))
    |> Enum.to_list()

    push socket, "done", %{}

    {:noreply, socket}
  end

  defp is_vox_tag(%{"name" => "Vox Alias: BNC" <> _}), do: true
  defp is_vox_tag(tag) do
    # IO.puts tag
    false
  end

  defp get_person_of_tag(%{"name" => tag}) do
    person =
      tag
      |> Nb.Tags.stream_people()
      |> Enum.take(1)
      |> List.first()

    {tag, person}
  end

  defp push_person(socket, {tag,
      %{"first_name" => first, "last_name" => last, "email" => email,
        "phone" => phone}}) do

    [_, username, date] = String.split(tag, ":") |> Enum.map(&String.trim/1)

    push socket, "row", %{"row" => "#{tag}, #{username}, #{date}, #{first}, #{last}, #{email}, #{phone}"}
  end

  defp push_person(_, {tag, nil}) do
    Logger.info "No person match for tag #{tag}"
  end
end

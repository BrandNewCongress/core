defmodule Transformers.Nb.Event do
  use Remodel

  attributes [:id, :name, :title, :description, :summary, :browser_url, :type,
              :location, :featured_image_url, :start_date, :end_date, :calendar,
              :host]

  def name(event), do: event.slug
  def description(event), do: event.intro
  def calendar(event), do: event.calendar_id
  def browser_url(event), do: "events/#{event.slug}"
  def start_date(event), do: event.start_time
  def end_date(event), do: event.end_time

  def location(event) do
    location = %{venue: event.venue.name}

    location = if event.venue.address do
      %{address_lines: [event.venue.address.address1],
        locality: event.venue.address.city, region: event.venue.address.state,
        location: %{
          latitude: event.venue.address.lat,
          longitude: event.venue.address.lng
        },
        time_zone: get_time_zone(event),
        public: not (event.tags |> Enum.member?("Event: Hide Address"))}
      |> Map.merge(location)
    else
      %{public: not (event.tags |> Enum.member?("Event: Hide Address"))}
      |> Map.merge(location)
    end

    location
  end

  def type(event) do
    IO.inspect event
    IO.inspect event.tags

    type_tag =
      event.tags
      |> Enum.filter(fn tag -> tag =~ "Event Type:" end)
      |> List.first()

    if type_tag != nil do
      type_tag |> String.split(":") |> List.last() |> String.trim()
    else
      nil
    end
  end

  def host(event) do
    %{name: event.contact.name, phone: event.contact.phone,
      email: event.contact.email,
      public: not (event.tags |> Enum.member?("Event: Hide Host"))}
  end

  defp get_time_zone(event) do
    IO.inspect event
    IO.inspect event.tags

    event.tags
    |> Enum.filter(fn tag -> tag =~ "Event Time Zone:" end)
    |> List.first()
    |> String.split(":")
    |> List.last()
    |> String.trim()
  end
end

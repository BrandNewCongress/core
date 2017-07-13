defmodule Transformers.Nb.Event do
  use Remodel

  attributes [:id, :name, :title, :description, :summary, :browser_url, :type,
              :location, :featured_image_url, :start_date, :end_date, :calendar]

  def location(event) do
    location = %{venue: event.venue.name}

    location = if event.venue.address do
      %{address_lines: [event.venue.address.address1],
        locality: event.venue.address.city, region: event.venue.address.state,
        location: %{
          latitude: event.venue.address.lat,
          longitude: event.venue.address.lng
        },
        time_zone: event.time_zone}
      |> Map.merge(location)
    else
      location
    end

    location
  end

  def name(event), do: event.slug
  def description(event), do: event.intro
  def calendar(event), do: event.calendar_id
  def browser_url(event), do: "https://go.brandnewcongress.org/#{event.slug}"
  def start_date(event), do: event.start_time
  def end_date(event), do: event.end_time
end

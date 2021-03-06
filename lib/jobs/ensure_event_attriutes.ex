defmodule Core.Jobs.EnsureEventAttributes do
  import ShortMaps

  def go do
    missing_things =
      EventProxy.stream("events")
      |> Enum.filter(fn %{contact: contact} ->
           length(Map.keys(contact)) < 3
         end)

    missing_things
    |> Enum.map(fn event ->
         %{body: organizer} = Ak.Api.get("user/#{event.organizer_id}")
         ~m(email first_name last_name phones) = organizer

         phone_number =
           case List.first(phones) do
             "/rest/v1/" <> phone_uri ->
               %{body: %{"normalized_phone" => phone_number}} = Ak.Api.get(phone_uri)

             _ ->
               nil
           end

         contact = %{
           email_address: email,
           name: "#{first_name} #{last_name}",
           phone_number: phone_number
         }

         id = event.identifiers |> List.first() |> String.split(":") |> List.last()
         EventProxy.post("events/#{id}", body: ~m(contact))
       end)
    |> length()
    |> IO.inspect()
  end
end

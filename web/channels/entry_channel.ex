defmodule Core.EntryChannel do
  use Phoenix.Channel

  def join("entry", _message, socket) do
    {:ok, socket}
  end

  def handle_in("entry", %{"n" => n, "entry" => entry}, socket) do
    campaign_name = case entry["campaign"] do
      "brandnewcongress" -> "Brand New Congress"
      "justicedemocrats" -> "Justice Democrats"
      slug -> slug |> Cosmic.get() |> get_in(["metadata", "name"])
    end

    existing_person = get_existing_person(entry)

    nb_id = case existing_person do
      # If person exists, perform updates
      %{"id" => id} ->
        push socket, "update", %{"n" => n, "message" => "Found person: #{id}."}

        entry
        |> extract_update(campaign_name)
        |> (&Nb.People.update(id, &1)).()

        push socket, "update", %{"n" => n, "message" => "Updated person: #{id}."}

        id

      # If person does not exist, create them
      _else ->
        push socket, "update", %{"n" => n, "message" => "Creating person..."}

        %{"id" => id} =
          entry
          |> Map.merge(entry |> extract_update(campaign_name))
          |> Nb.People.push()

        push socket, "update", %{"n" => n, "message" => "Created new person: #{id}."}

        id
    end

    push socket, "update", %{"n" => n, "message" => "Adding new contact for id #{nb_id}"}

    if entry["contactMethod"] == "event_rsvp" do
      Nb.People.add_tags(nb_id, [
        "Action: Attended Event: #{campaign_name}"
      ])

      slug = 124

      Nb.Events.Rsvps.create(slug, %{
        person_id: nb_id
      })
    else
      Nb.Contacts.create(nb_id, %{
        type_id: 1,
        author_id: 70_380, # required but not in use
        sender_id: 70_380, # required but not in use
        method: entry["contactMethod"],
        status: entry["result"],
        note: "Primary issue: #{entry["issue"]}"
      })
    end

    push socket, "done", %{"n" => n}

    {:noreply, socket}
  end

  defp extract_update(entry, campaign_name) do
    base = %{"address" => process_address(entry["address"]), "phone" => entry["phone"],
             "deceased" => entry["deceased"], "support_level" => entry["supportScore"]}

    base = if entry["volunteer"] do
      Map.put(base, "tags", ["Action: Volunteer Interest: #{campaign_name}"])
    else
      base
    end

    base
  end

  defp get_existing_person(entry = %{"id_type" => "id"}), do: Nb.People.show(entry["identifier"])
  defp get_existing_person(%{"id_type" => "new"}), do: nil
  defp get_existing_person(entry = %{"id_type" => _id_type}), do: entry |> extract_matchers() |> Nb.People.match()

  defp extract_matchers(payload = %{"id_type" => "email"}) do
    %{"email" => payload["identifier"]}
  end

  defp process_address(address), do: address
end

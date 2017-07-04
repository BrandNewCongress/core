defmodule Nb.Api do
  use HTTPotion.Base

  @nb_slug Application.get_env(:core, :nb_slug)
  @nb_token Application.get_env(:core, :nb_token)

  @default_params %{
    limit: 100,
    access_token: @nb_token
  }

  # --------------- Process request ---------------
  defp process_url(url) do
    if String.starts_with? url, "/api/v1" do
      "https://#{@nb_slug}.nationbuilder.com" <> url
    else
      "https://#{@nb_slug}.nationbuilder.com/api/v1/" <> url
    end
  end

  defp process_request_headers(hdrs) do
    Dict.merge(hdrs, [
        "Accept": "application/json",
        "Content-Type": "application/json"
      ])
  end

  defp process_options(opts) do
    opts
    |> Keyword.update(:query, @default_params, &(Map.merge(@default_params, &1)))
  end

  defp process_request_body(body) when is_map(body) do
    case Poison.encode(body) do
      {:ok, encoded} -> encoded
      {:error, problem} -> problem
    end
  end

  defp process_request_body(body) do
    body
  end

  # --------------- Process response ---------------
  defp process_response_body(raw) do
    case Poison.decode(raw) do
      {:ok, body} -> body
      {:error, raw} -> {:error, raw}
    end
  end

  # -----------------------------------
  # ---------- STREAM HELPERS ---------
  # -----------------------------------

  # If results exist, send them, passing only the tail
  defp unfolder(%{"next" => next, "results" => [head | tail]}) do
    {head, %{"next" => next, "results" => tail}}
  end

  # If results don't exist, and next is nil, we're done (base case)
  defp unfolder(%{"next" => nil, "results" => _}) do
    nil
  end

  # If results don't exist, and next is not null, serve it
  defp unfolder(%{"next" => next, "results" => _}) do
    [core, params] = String.split(next, "?")
    case get(core, [query: Plug.Conn.Query.decode(params)]).body do
      %{"next" => next, "results" => [head | tail]} ->
        {head, %{"next" => next, "results" => tail}}
      true ->
        nil
    end
  end

  # Handle errors
  defp unfolder({:error, message}) do
    message
  end

  # Wrap it all
  def stream(url, opts \\ []) do
    get(url, opts).body
    |> Stream.unfold(fn state -> unfolder(state) end)
  end
end

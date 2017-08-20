defmodule LiveVox.Api do
  use HTTPotion.Base
  {:ok, login_agent} = Agent.start_link(fn -> nil end)
  @login_agent login_agent

  defp login do
    post ""
    Agent.update(login_agent, )
  end

  @livevox_token Application.get_env(:core, :livevox_token)

  @default_headers [
    "LV-Access": @livevox_token,
    "LV-Session": @livevox_session,
    "Accept": "application/json",
    "Content-Type": "application/json"
  ]

  # --------------- Process request ---------------
  defp process_url(url) do
    "https://api.livevox.com/" <> url
  end

  defp process_request_headers(hdrs) do
    result = Enum.into(hdrs, @default_headers)
    IO.inspect result
    result
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
  # defp process_response_body(raw) do
  #   case Poison.decode(raw) do
  #     {:ok, body} -> body
  #     {:error, raw} -> {:error, raw}
  #   end
  # end
end

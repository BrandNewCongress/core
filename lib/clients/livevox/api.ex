defmodule LiveVox.Api do
  @livevox_token Application.get_env(:core, :livevox_token)
  @client_name Application.get_env(:core, :livevox_client)
  @username Application.get_env(:core, :livevox_username)
  @password Application.get_env(:core, :livevox_password)

  use HTTPotion.Base

  @default_headers [
    "LV-Access": @livevox_token,
    "Accept": "application/json",
    "Content-Type": "application/json"
  ]

  # --------------- Process request ---------------
  defp process_url(url) do
    "https://api.na4.livevox.com/" <> url
  end

  defp process_request_headers(hdrs) do
    Enum.into(hdrs, @default_headers ++ ["LV-Session": get_session_id()])
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

  defp process_response_body(raw) do
    case Poison.decode(raw) do
      {:ok, body} -> body
      {:error, raw} -> {:error, raw}
    end
  end

  def get_session_id do
    case LiveVox.SessionAgent.get_token() do
      nil -> new_session_id()
      sid -> sid
    end
  end

  def new_session_id do
    %{body: %{"sessionId" => sid}} = LiveVox.Login.Api.login()
    LiveVox.SessionAgent.set_token(sid)
    sid
  end
end

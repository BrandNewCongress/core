defmodule LiveVox.Login.Api do
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
    Enum.into(hdrs, @default_headers)
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

  def login do
    IO.inspect body: %{clientName: @client_name, userName: @username, password: @password}
    post "session/v5.0/login", body: %{clientName: @client_name, userName: @username, password: @password}
  end

end

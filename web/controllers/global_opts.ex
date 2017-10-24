defmodule GlobalOpts do
  defp get_brand(conn, params) do
    cond do
      Map.has_key?(params, "brand") ->
        case params["brand"] do
          "bnc" -> "bnc"
          _ -> "jd"
        end

      String.contains?(conn.host, "justicedemocrats") ->
        "jd"

      String.contains?(conn.host, "brandnewcongress") ->
        "bnc"

      true ->
        "jd"
    end
  end

  defp is_mobile?(conn, _params) do
    case List.keyfind(conn.req_headers, "user-agent", 0, "") do
      {_head, tail} -> Browser.mobile?(tail)
      _ -> false
    end
  end

  def get(conn, params) do
    [brand: get_brand(conn, params), mobile: is_mobile?(conn, params), conn: conn]
  end
end

defmodule Core.CandidateController do
  use Core.Web, :controller

  def get(conn, params) do
    global_opts = GlobalOpts.get(conn, params)
    brand = Keyword.get(global_opts, :brand)

    candidates =
      "candidates"
      |> Cosmic.get_type()
      |> Enum.map(&metadata_only/1)
      |> Enum.filter(fn cand -> is_brand(cand, brand) end)
      |> Enum.filter(&is_launched/1)
      |> Enum.filter(&has_props/1)
      |> Enum.map(&preprocess/1)
      |> Enum.sort(&by_district/2)

    render conn, "candidates.html", [title: "Candidates", candidates: candidates] ++ global_opts
  end

  defp is_brand(%{"brands" => brands}, brand), do: Enum.member?(brands, brand)

  defp metadata_only(%{"metadata" => metadata, "title" => title}) do
    Map.merge(metadata, %{"title" => title})
  end

  defp is_launched(%{"launch_status" => "Launched"}), do: true
  defp is_launched(_else), do: false

  defp has_props(candidate) do
    missing =
      ~w(district external_website website_blurb)
      |> Enum.reject(fn prop -> Map.has_key?(candidate, prop) end)

    length(missing) == 0
  end

  defp preprocess(candidate) do
    %{"district" => district, "external_website" => external_website,
      "website_blurb" => website_blurb, "title" => title,
      "small_picture" => %{"imgix_url" => small_picture}} = candidate

    %{district: district, external_website: external_website, website_blurb: website_blurb,
      small_picture: small_picture, title: title}
  end

  defp by_district(%{district: d1}, %{district: d2}) do
    d1 <= d2
  end
end

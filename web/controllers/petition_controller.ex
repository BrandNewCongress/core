defmodule Core.PetitionController do
  use Core.Web, :controller

  def get(conn, params = %{"petition" => petition}) do
    object = Cosmic.get(petition)
    render_petition(conn, params, object)
  end

  # Match petition exists and is proper brand
  defp render_petition(conn, params, object = %{"metadata" => %{
    "brands" => brands,
    "visibility" => visibility
  }}) do
    brand = Keyword.get(GlobalOpts.get(conn, params), :brand)

    if Enum.member?(brands, brand) do
      case visibility do
        "Draft" -> do_render_draft(conn, params, object)
        "Published" -> do_render_petition(conn, params, object)
      end
    else
      redirect_home(conn, params)
    end
  end

  # Match petition is nil
  defp render_petition(conn, params, nil) do
    render conn, "404.html", GlobalOpts.get(conn, params)
  end

  defp do_render_draft(conn, params, object) do
    if Map.has_key?(params, "draft") do
      do_render_petition(conn, params, object)
    else
      redirect_home(conn, params)
    end
  end

  # Extract and render petition
  defp do_render_petition(conn, params, object = %{
    "slug" => slug,
    "content" => content,
    "metadata" => metadata = %{
      "title" => title,
      "sign_button_text" => sign_button_text,
      "post_sign_text" => post_sign_text,
      "background_image" => %{
        "imgix_url" => background_image
      }
    }
  }) do

    count = case Core.PetitionCount.stats_for(title) do
      {:ok, %{in_last: _in_last, total: count}} -> count
      {:error, _} -> nil
    end

    target =
      if count do
        Enum.max([round((count * 2) / 25_000) * 25_000, 25_000])
      end

    progress =
      if count do
        count / target * 100
      end

    og_description = HtmlSanitizeEx.strip_tags(content)

    share_image = URI.encode(get_in(object, ["metadata", "share_image", "imgix_url"]) || background_image)
    background_image = URI.encode(background_image)

    render conn, "petition.html",
      [slug: slug, title: title, content: content, sign_button_text: sign_button_text,
       post_sign_text: post_sign_text, background_image: background_image, share_image: share_image,
       banner: share_image, no_footer: true, signed: false, count: pretty_num(count), target: pretty_num(target),
       progress: pretty_num(progress), banner: background_image, description: og_description] ++ GlobalOpts.get(conn, params)
  end

  defp format_count(""), do: nil
  defp format_count(count) when is_integer(count), do: count
  defp format_count(count) when is_binary(count), do: count |> Integer.parse() |> Tuple.to_list() |> List.first()
  defp pretty_num(nil), do: nil
  defp pretty_num(n), do: n |> Number.Delimit.number_to_delimited(precision: 0)

  def post(conn, params = %{"petition" => petition, "name" => name, "email" => email, "zip" => zip}) do
    global_opts = GlobalOpts.get(conn, params)

    object = %{"slug" => slug,
      "content" => content,
      "title" => admin_title,
      "metadata" => %{
        "title" => title,
        "sign_button_text" => sign_button_text,
        "post_sign_text" => post_sign_text,
        "tweet_template" => tweet_template,
        "background_image" => %{
          "imgix_url" => background_image
        }
      }
    } = Cosmic.get(petition)


    call_power_campaign_id = object["call_power_campaign_id"]

    url = "https://#{conn.host}/petition/#{slug}"
    twitter_query = URI.encode_query([text: tweet_template, url: url])
    twitter_href = "https://twitter.com/intent/tweet?#{twitter_query}"

    fb_query = URI.encode_query([u: url])
    fb_href = "https://www.facebook.com/sharer/sharer.php?#{fb_query}&amp;src=sdkpreparse"

    # Get person's id / create them
    names = name |> String.trim() |> String.split(" ")
    first_name = List.first(names)
    last_name = if length(names) > 1 do
      List.last(names)
    else
      ""
    end

    # Add the petition signed tag
    brand = Keyword.get(global_opts, :brand)
    source = case brand do
      "jd" -> "Justice Democrats"
      "bnc" -> "Brand New Congress"
    end

    tags = ["Action: Signed Petition: #{source}: #{admin_title}"] ++
      if Map.has_key?(params, "ref") do
        ["Action: Signed Petition: #{source}: #{admin_title}: #{params["ref"]}"]
      else
        []
      end

    %{id: _id} = Osdi.PersonSignup.main(%{
      person: %{
        given_name: first_name,
        family_name: last_name,
        postal_addresses: [%{postal_code: zip}],
        email_addresses: [%{address: email, primary: true}],
      },
      add_tags: tags})

    share_image = URI.encode(get_in(object, ["metadata", "share_image", "imgix_url"]) || background_image)
    background_image = URI.encode(background_image)

    count = case Core.PetitionCount.stats_for(title) do
      {:ok, %{in_last: _in_last, total: count}} -> count
      {:error, _} -> nil
    end

    target =
      if count do
        Enum.max([round((count * 2) / 25_000) * 25_000, 25_000])
      end

    render conn, "petition.html",
      [slug: slug, title: title, content: content, sign_button_text: sign_button_text,
       post_sign_text: post_sign_text, background_image: background_image, share_image: share_image,
       banner: share_image, twitter_href: twitter_href, fb_href: fb_href, no_footer: true, url: url,
       count: count, target: target, signed: true, submitted_zip: zip,
       call_power_campaign_id: call_power_campaign_id] ++ GlobalOpts.get(conn, params)
  end

  def redirect_home(conn, params) do
    url = case (conn |> GlobalOpts.get(params) |> Keyword.get(:brand)) do
      "jd" -> "https://justicedemocrats.com"
      "bnc" -> "https://brandnewcongress.org"
    end
    redirect(conn, external: url)
  end
end

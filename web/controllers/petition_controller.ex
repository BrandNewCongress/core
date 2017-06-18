defmodule Core.PetitionController do
  use Core.Web, :controller

  def get(conn, params = %{"petition" => petition}) do
    object = Cosmic.get(petition)
    render_petition(conn, params, object)
  end

  # Match petition exists and is proper brand
  defp render_petition(conn, params, object = %{"metadata" => %{
    "brands" => brands
  }}) do
    brand = Keyword.get(GlobalOpts.get(conn, params), :brand)

    if Enum.member?(brands, brand) do
      do_render_petition(conn, params, object)
    else
      url = case (conn |> GlobalOpts.get(params) |> Keyword.get(:brand)) do
        "jd" -> "https://justicedemocrats.com"
        "bnc" -> "https://brandnewcongress.org"
      end
      redirect(conn, external: url)
    end
  end

  # Extract and render petition
  defp do_render_petition(conn, params = %{"petition" => petition}, %{
    "slug" => slug,
    "title" => title,
    "content" => content,
    "metadata" => %{
      "brands" => brands,
      "sign_button_text" => sign_button_text,
      "post_sign_text" => post_sign_text,
      "background_image" => %{
        "imgix_url" => background_image
      }
    }
  }) do
    render conn,
      "petition.html",
      [slug: slug, title: title, content: content, sign_button_text: sign_button_text,
       post_sign_text: post_sign_text, background_image: background_image,
       no_footer: true] ++ GlobalOpts.get(conn, params)
  end

  # Match petition is nil
  defp render_petition(conn, params, nil) do
    render conn, "404.html", GlobalOpts.get(conn, params)
  end

  # def post(conn, params = %{"petition" => petition, "name" => name, "email" => email, "zip" => zip}) do
  #   object = case Cosmic.get(petition) do
  #     nil -> nil
  #   end
  #
  #   render conn, "petition-signed.html", GlobalOpts.get(conn, params)
  # end
end

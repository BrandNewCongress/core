defmodule Core.VoxMailer do
  use Phoenix.Swoosh,
    view: Core.EmailView,
    layout: {Core.EmailView, :email}

  require Logger

  def on_vox_login_claimed(%{
        "username" => username,
        "date" => date,
        "name" => name,
        "email" => email,
        "phone" => phone,
        "source" => source
      }) do
    Logger.info("Sending email to Sam because of Vox claim #{username}")

    new()
    |> to({"Sam Briggs", "sam@brandnewcongress.org"})
    |> to({"Ben Packer", "ben@brandnewcongress.org"})
    |> from({"Robot", "robot@brandnewcongress.org"})
    |> subject("New Vox Login Claimed!")
    |> render_body("event-failure.text", %{raw: "
Username: #{username}
Date: #{date}
Name: #{name}
Email: #{email}
Phone: #{phone}
Source: #{source}
"})
    |> Core.Mailer.deliver()
  end
end

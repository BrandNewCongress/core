defmodule Core.StandupChannel do
  use Phoenix.Channel
  require Logger

  # require Core.StandUpVideo

  def join("standup", _message, socket) do
    {:ok, socket}
  end

  def handle_in("videos-for", %{"district" => district}, socket) do
    push socket, "videos-for-#{district}", %{videos: mock_videos()}
  end

  def handle_in("recent-videos", _body, socket) do
    push socket, "recent-videos", %{videos: mock_videos()}
  end

  def handle_in("create-video", _content, socket) do
    push socket, "video-created", %{}
  end

  defp mock_videos do
    [%{type: "twitter", link: "https://twitter.com/video/amva80", nbId: 1,
       district: "NY-14", first_name: "Ben", last_name: "Packer",
       email: "ben.paul.ryan.packer@gmail.com", rep: "Congresswoman"},
     %{type: "facebook", link: "https://facebook.com/280ma0", nbId: 1,
       district: "CA-09", first_name: "Greg", last_name: "Milton",
       email: "gregm@mail.com", rep: "Congressman"},
     %{type: "youtube", link: "https://youtube.com/4209ma2", nbId: 1,
       district: "MA-02", first_name: "Ashley", last_name: "Thomas",
       email: "thoma@outlook.com", rep: "Congressbaby"}]
  end
end

defmodule Core.Router do
  use Core.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Core do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    # get "/platform", PageController, :platform
    # get "/candidates", PageController, :candidates
    # get "/candidates/:candidate", PageController, :candidate
    get "/unsubscribe", SubscriptionController, :unsubscribe_get
    post "/unsubscribe", SubscriptionController, :unsubscribe_post
  end
end

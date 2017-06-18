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

    get "/petition/:petition", PetitionController, :get
    post "/petition/:petition", PetitionController, :post

    get "/unsubscribe", SubscriptionController, :unsubscribe_get
    post "/unsubscribe", SubscriptionController, :unsubscribe_post
    get "/unsubscribe/:candidate", SubscriptionController, :unsubscribe_candidate_get
    post "/unsubscribe/:candidate", SubscriptionController, :unsubscribe_candidate_post
  end


  scope "/api", Core do
    get "/update/cosmic", UpdateController, :cosmic
    # get "/update/typeform", UpdateController, :typeform
  end
end

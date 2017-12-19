defmodule Core.Router do
  use Core.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(Core.TurboVdomPlug, [])
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", Core do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    # get "/platform", PageController, :platform
    # get "/candidates", PageController, :candidates
    # get "/candidates/:candidate", PageController, :candidate
    # get "/standup", StandupController, :get

    get("/petition/:petition", PetitionController, :get)
    post("/petition/:petition", PetitionController, :post)
    get("/petition-counts", PetitionController, :counts)

    get("/form/:form", FormController, :get)
    get("/info/:info", InfoController, :get)

    get("/act", ActController, :get)
    # used for setting the district
    post("/act", ActController, :post)

    get("/act/call", ActController, :get_call)
    get("/act/call/:candidate", ActController, :get_candidate_call)
    get("/act/:candidate", ActController, :legacy_redirect)
    get("/call-aid/:candidate", ActController, :call_aid)
    post("/call-aid/:candidate", ActController, :easy_volunteer)

    get("/events", EventsController, :get)
    get("/events/:name", EventsController, :get_one)
    post("/events/:slug", EventsController, :rsvp)
    get("/events-iframe", EventsController, :iframe)
    get("/events-iframe/:district", EventsController, :iframe)

    get("/call", VoxController, :get)
    get("/call/logins", VoxController, :get_logins)
    get("/call/report", VoxController, :get_report)
    post("/call", VoxController, :post)
    get("/call/who-claimed/:client/:login", VoxController, :who_claimed)

    get("/call-iframe/:client", VoxController, :get_iframe)
    post("/call-iframe/:client", VoxController, :post_iframe)

    get("/leaderboard", LeaderboardController, :get)
    get("/leaderboard/report", LeaderboardController, :get_report)
    get("/leaderboard/email", LeaderboardController, :send_email)
    post("/leaderboard", LeaderboardController, :post)

    get("/candidates", CandidateController, :get)

    get("/unsubscribe", SubscriptionController, :unsubscribe_get)
    post("/unsubscribe", SubscriptionController, :unsubscribe_post)
    get("/unsubscribe/:candidate", SubscriptionController, :unsubscribe_candidate_get)
    post("/unsubscribe/:candidate", SubscriptionController, :unsubscribe_candidate_post)

    get("/entry", EntryController, :get)
  end

  scope "/api", Core do
    pipe_through(:api)

    get("/update/cosmic", UpdateController, :cosmic)
    post("/update/cosmic", UpdateController, :cosmic)
    post("/jotform/host-event", JotformController, :submit_event)

    get("/events", EventsController, :as_json)
    get("/events/:candidate", EventsController, :as_json)

    post("/signup", OsdiController, :signup)
    post("/record-contact", OsdiController, :record_contact)
  end
end

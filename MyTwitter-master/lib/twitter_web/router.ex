defmodule Twitter_backend.Router do
  use Twitter_backend, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.EnsureAuthenticated, handler: Twitter_backend.Token
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Twitter_backend do
    pipe_through :browser # Use the default browser stack
    
    get "/", SessionController, :new
    resources "/users", UserController, [:new, :create]
    resources "/sessions", SessionController, only: [:create, :delete]
  end

  scope "/", Twitter_backend do
    pipe_through [:browser, :browser_auth]
    
    get "/home", PageController, :home

    get "/sendtweet", TweetController, :sendtweetindex
    resources "/tweet", TweetController, only: [:create]

    get "/subscribeto", UserController, :sub_indie
    post "/users/subscribe", UserController, :subscribe

    get "/querytweet", TweetController, :querytweetindex
    post "/querytweet/fromsubscriber", TweetController, :searchfromsubscriber
    post "/querytweet/frommentioned", TweetController, :searchfrommentioned
    post "/querytweet/fromhashtag", TweetController, :searchfromhashtag
    
    resources "/retweet", RetweetController
  end
  # Other scopes may use custom stacks.
  # scope "/api", Twitter_backend do
  #   pipe_through :api
  # end
end

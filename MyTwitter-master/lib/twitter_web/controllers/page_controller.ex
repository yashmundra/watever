defmodule Twitter_backend.PageController do
  # main page
  use Twitter_backend, :controller
  import Ecto.Query
  alias Twitter.Tweet
  alias Twitter.Repo


  def index(conn, _params) do
    render conn, "index.html"
  end

  def home(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    tweets_live = getTweetsLive(user)
    render(conn, "home.html", user: user, tweetslive: tweets_live)
  end

  def getTweetsLive(curuser) do
    subscribe_list = curuser.subscribe |> String.split("$$") |> List.delete("")
    q_list = subscribe_list ++ [curuser.username]

    Repo.all(from t in Tweet, where: t.author in ^q_list, order_by: [desc: :inserted_at]) 
  end

end

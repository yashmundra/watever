defmodule Twitter_backend.RetweetController do
    # send retweets
    use Twitter_backend, :controller 
    import Ecto.Query
    # alias Twitter.User
    alias Twitter.Tweet
    alias Twitter.Repo


    def show(conn, %{"id" => tweetid}) do
        retweet = Repo.one(from t in Tweet, where: t.id == ^tweetid)
        retweet_str = "Original Author: " <> retweet.author <> " Time: " <> Date.to_string(retweet.inserted_at) <> " Content: " <> retweet.content
        author = Guardian.Plug.current_resource(conn).username
        Repo.insert(%Tweet{author: author, content: retweet_str, hashtag: "", mentioned: "", retweeted_status: true})
        conn
        |> put_flash(:info, "Retweet sent!")
        |> redirect(to: page_path(conn, :home))
    end

end
defmodule Twitter_backend.RetweetController do

    use Twitter_backend, :controller 
    import Ecto.Query
    alias Twitter.Repo
    alias Twitter.Tweet
    


    def show(conn, %{"id" => tweetid}) do
        retweet = Repo.one(from t in Tweet, where: t.id == ^tweetid)
        retweet_str = retweet.content
        author = Guardian.Plug.current_resource(conn).username
        Repo.insert(%Tweet{author: author, content: retweet_str, hashtag: "", mentioned: "", retweeted_status: true})
        conn
        |> redirect(to: page_path(conn, :home))
    end

end
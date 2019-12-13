defmodule Twitter_backend.TweetController do

    use Twitter_backend, :controller 
    import Ecto.Query
    alias Twitter.Repo
    alias Twitter.Tweet
    alias Twitter.User


   
    def sendtweetindex(conn,_params) do
        render(conn, "sendtweetindex.html")
    end

    
    def create(conn, %{"tweet" => %{"content" => content}}) do
        unless content===nil || content==="" do
            logged_user = Guardian.Plug.current_resource(conn)
            retweeted_status = false
            author = logged_user.username
            mentioned = Regex.scan(~r/@([0-9a-zA-Z]+)/, content) |> Enum.map(fn x -> Enum.at(x,1) end) |> Enum.join("@")
            hashtag = Regex.scan(~r/#([0-9a-zA-Z]+)/, content) |> Enum.map(fn x -> Enum.at(x,1) |> String.downcase() end) |> Enum.join("#")
            Repo.insert(%Tweet{author: author, content: content, hashtag: hashtag, mentioned: mentioned, retweeted_status: retweeted_status})
            conn
            |> redirect(to: tweet_path(conn, :sendtweetindex))
        else
            conn
            |> render("make.html")
        end
    end

   
    def querytweetindex(conn,_params) do
        render(conn, "query_res.html")
    end

    def query_subs(conn, %{"searchsubscriber" => %{"subscriber" => subscriber}}) do
        cond do
            subscriber===nil || subscriber==="" -> 
                conn
                |> render("query_res.html")
            Repo.one(from u in User, where: u.username==^subscriber) == nil -> 
                conn
                |> render("query_res.html")
            true ->   
                tweetsfound = Repo.all(from t in Tweet, where: t.author==^subscriber, order_by: [desc: :inserted_at])
                conn
                |> render("queryresult.html", tweetsfound: tweetsfound)
        end
    end
    
    def query_hashtag(conn, %{"searchhashtag" => %{"hashtag" => hashtag}}) do
        if hashtag===nil || hashtag==="" do 
            conn
            |> render("query_res.html")
        else
            hashtag_str = Regex.scan(~r/#(\s*[0-9a-zA-Z]+)/, hashtag) |> Enum.map(fn x -> Enum.at(x,1)|>String.replace(" ","") end) |> Enum.join("#") |> String.downcase() # "###uf # football" => ["uf","football"]
            if hashtag_str === "" do 
                conn
                |> render("query_res.html")
            else 
                query = from t in Tweet, where: ^hashtag_str == t.hashtag, order_by: [desc: :inserted_at]
                tweetsfound = Repo.all(query)
                conn
                |> render("queryresult.html", tweetsfound: tweetsfound)
            end
        end
    end

    def query_mention(conn, %{"searchmentioned" => %{"mentioned" => mentioned}}) do
        if mentioned===nil || mentioned==="" do 
            conn
            |> render("query_res.html")
        else 
            mentioned_str = Regex.scan(~r/@(\s*[0-9a-zA-Z]+)/, mentioned) |> Enum.map(fn x -> Enum.at(x,1) |> String.replace(" ","") end) |> Enum.join("@") # "@user1 @@ USer2 3" => "user1@USer2"
            if mentioned_str === "" do  
                conn
                |> render("query_res.html")
            else
                query = from t in Tweet, where: ^mentioned_str == t.mentioned, order_by: [desc: :inserted_at]
                tweetsfound = Repo.all(query)
                conn
                |> render("queryresult.html", tweetsfound: tweetsfound)
            end
        end
       
    end




 



end
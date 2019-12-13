defmodule Twitter_backend.TweetController do
    # send tweets
    use Twitter_backend, :controller 
    import Ecto.Query
    alias Twitter.User
    alias Twitter.Tweet
    alias Twitter.Repo


    # interface for sending tweet page
    def sendtweetindex(conn,_params) do
        render(conn, "sendtweetindex.html")
    end

    # create new tweet
    def create(conn, %{"tweet" => %{"content" => content}}) do
        unless content===nil || content==="" do
            logged_user = Guardian.Plug.current_resource(conn)
            author = logged_user.username
            hashtag = Regex.scan(~r/#([0-9a-zA-Z]+)/, content) |> Enum.map(fn x -> Enum.at(x,1) |> String.downcase() end) |> Enum.join("#")
            mentioned = Regex.scan(~r/@([0-9a-zA-Z]+)/, content) |> Enum.map(fn x -> Enum.at(x,1) end) |> Enum.join("@")
            retweeted_status = false
            Repo.insert(%Tweet{author: author, content: content, hashtag: hashtag, mentioned: mentioned, retweeted_status: retweeted_status})
            conn
            |> put_flash(:info, "Tweet sent!")
            |> redirect(to: tweet_path(conn, :sendtweetindex))
        else
            conn
            |> put_flash(:error, "Content cannot be blank")
            |> render("new.html")
        end
    end

    # interface for querying tweet page
    def querytweetindex(conn,_params) do
        render(conn, "querytweetindex.html")
    end

    def searchfromsubscriber(conn, %{"searchsubscriber" => %{"subscriber" => subscriber}}) do
        cond do
            subscriber===nil || subscriber==="" -> # input for search is empty
                conn
                |> put_flash(:error, "Content cannot be blank")
                |> render("querytweetindex.html")
            Repo.one(from u in User, where: u.username==^subscriber) == nil -> # subscriber for search does not exist
                conn
                |> put_flash(:error, "Subscriber does not exist")
                |> render("querytweetindex.html")
            true ->   # can successfully get a result
                tweetsfound = Repo.all(from t in Tweet, where: t.author==^subscriber, order_by: [desc: :inserted_at])
                conn
                |> render("queryresult.html", tweetsfound: tweetsfound)
        end
    end
    

    # Tweets which have exactly the same mentioned field will returned (case sensitive)
    def searchfrommentioned(conn, %{"searchmentioned" => %{"mentioned" => mentioned}}) do
        if mentioned===nil || mentioned==="" do # if user input is empty
            conn
            |> put_flash(:error, "Content cannot be blank")
            |> render("querytweetindex.html")
        else 
            mentioned_str = Regex.scan(~r/@(\s*[0-9a-zA-Z]+)/, mentioned) |> Enum.map(fn x -> Enum.at(x,1) |> String.replace(" ","") end) |> Enum.join("@") # "@user1 @@ USer2 3" => "user1@USer2"
            if mentioned_str === "" do  # if user input not valid (no @ in user input)
                conn
                |> put_flash(:error, "Invalid input, remember to add @ before your search")
                |> render("querytweetindex.html")
            else
                query = from t in Tweet, where: ^mentioned_str == t.mentioned, order_by: [desc: :inserted_at]
                tweetsfound = Repo.all(query)
                conn
                |> render("queryresult.html", tweetsfound: tweetsfound)
            end
        end
       
    end

    # Tweets which have exactly the same hashtag field will returned (case insensitive)
    def searchfromhashtag(conn, %{"searchhashtag" => %{"hashtag" => hashtag}}) do
        if hashtag===nil || hashtag==="" do # if user input is empty
            conn
            |> put_flash(:error, "Content cannot be blank")
            |> render("querytweetindex.html")
        else
            hashtag_str = Regex.scan(~r/#(\s*[0-9a-zA-Z]+)/, hashtag) |> Enum.map(fn x -> Enum.at(x,1)|>String.replace(" ","") end) |> Enum.join("#") |> String.downcase() # "###uf # football" => ["uf","football"]
            if hashtag_str === "" do # if user input not valid (no # in user input)
                conn
                |> put_flash(:error, "Invalid input, remember to add # before your search")
                |> render("querytweetindex.html")
            else 
                query = from t in Tweet, where: ^hashtag_str == t.hashtag, order_by: [desc: :inserted_at]
                tweetsfound = Repo.all(query)
                conn
                |> render("queryresult.html", tweetsfound: tweetsfound)
            end
        end
    end

    # # "a" is a list, say ["eee"];
    # # "b" is a string, say "www@eee@fff", 
    # # check if "a" is a subset of "b" (["www","eee","fff"])
    # def issubset?(a_list, b_str) do
    #     b_list = String.split(b_str,"@")
    #     MapSet.subset?(MapSet.new(a_list), MapSet.new(b_list))
    # end




end
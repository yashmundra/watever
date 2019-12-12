defmodule TwitterWeb.RoomChannel do
    use Phoenix.Channel
    #all actions will be here
    #state: {%userid -> userid}
  
    #join
    def join("room:lobby", _message, socket) do
        engine_pid = :global.whereis_name(:engine)
        {:ok, assign(socket, :engine_pid, engine_pid)}
    end

    #register
    def handle_in("register", %{}, socket) do
        userid = socket.assigns[:userid]
        IO.puts "my useris is #{userid}"
        res = if(userid != nil) do
            "Error: Already registered."
        else
            engine_pid = socket.assigns[:engine_pid]
            channel_pid = self()
            userid = GenServer.call(engine_pid, {:register, channel_pid})
            socket = assign(socket, :userid, userid)
            "Registered. Your userid is #{userid |> Integer.to_string}"
        end
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
    end

    #tweet
    def handle_in("tweet", %{"body" => body}, socket) do
        userid = socket.assigns[:userid]
        res = if(userid == nil) do
            "Error: You have not registered. First register by typing 'register' in textbox"
        else
            engine_pid = socket.assigns[:engine_pid]
            tweet_content = body |> String.trim()
            if tweet_content == "" do
                "Error: Empty tweet"
            else
                :ok = GenServer.call(engine_pid, {:tweet, userid, tweet_content}, :infinity)
                "You tweeted: #{tweet_content}"
            end    
        end
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
    end

    #subscribe
    def handle_in("subscribe", %{"body" => body}, socket) do
        userid = socket.assigns[:userid]
        res = if(userid == nil) do
            "Error: You have not registered. First register by typing 'register' in textbox"
        else
            engine_pid = socket.assigns[:engine_pid]
            subsId = body |> String.trim()
            is_int = case :re.run(subsId, "^[0-9]*$") do
                {:match, _} -> true
                :nomatch -> false
            end
            if is_int == true do
                subsId = subsId |> String.to_integer
                if subsId == userid do
                    "Error: Cannot subscribe to oneself"    
                else
                    GenServer.call(engine_pid, {:subscribe, userid, subsId}) 
                end
            else
                IO.inspect "inputted non-integer id"
                "Error: Please input a valid userid."        
            end  
        end
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
    end

    #get hashtag/mention
    def handle_in("tag", %{"body" => body}, socket) do
        userid = socket.assigns[:userid]
        res = if(userid == nil) do
            "Error: You have not registered. First register by typing 'register' in textbox"
        else
            engine_pid = socket.assigns[:engine_pid]
            tag = body |> String.trim()
            cond do
                String.starts_with?(tag, "#" ) ->
                    "Tweets with hashtag #{tag} are: " <> (GenServer.call(engine_pid, {:hashtag, :hashtag, tag}) |> Enum.join(", "))
                String.starts_with?(tag, "@" ) ->
                    "Tweets with mention #{tag} are: " <> (GenServer.call(engine_pid, {:mention, :mention, tag}) |> Enum.join(", "))
                true -> "Error: Invalid tag. It should either start with # or @"
            end   
        end
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
    end

    #retweet
    def handle_in("retweet", %{"body" => body}, socket) do
        userid = socket.assigns[:userid]
        res = if(userid == nil) do
            "Error: You have not registered. First register by typing 'register' in textbox"
        else
            engine_pid = socket.assigns[:engine_pid]
            tweetid = body |> String.trim()
            is_int = case :re.run(tweetid, "^[0-9]*$") do
                {:match, _} -> true
                :nomatch -> false
            end
            if is_int == true do
                ret = GenServer.call(engine_pid, {:retweet, userid, tweetid |> String.to_integer}) 
                case ret do
                    :fail -> "Error: Please input a valid tweetid to retweet."
                    {:ok, tweet} -> "You retweeted: #{tweet}"     
                end
            else
                IO.inspect "inputted non-integer id"
                "Error: Please input a valid tweetid to retweet."        
            end   
        end
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
    end

    def handle_info({:feed, userId, tweet, tweet_id}, socket) do
        res = "UserId " <> Integer.to_string(userId) <> " tweeted: '#{tweet}'. You can use id " <> Integer.to_string(tweet_id) <> " to retweet"
        push socket, "new_msg", %{body: res}
        {:noreply, socket}
      end

  end
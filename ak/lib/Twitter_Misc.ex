defmodule Twitter_Misc do
    
    def simulation(0,totalClients,tweets_time_diff,queries_subscribedto_time_diff,queries_hashtag_time_diff,queries_mention_time_diff,queries_myTweets_time_diff) do
    end

    def simulation(no_of_clients,totalClients,tweets_time_diff,queries_subscribedto_time_diff,queries_hashtag_time_diff,queries_mention_time_diff,queries_myTweets_time_diff) do
      # Receive convergence messages
      receive do
        {:perfmetrics,a,b,c,d,e} -> simulation(no_of_clients-1,totalClients,tweets_time_diff+a,queries_subscribedto_time_diff+b,queries_hashtag_time_diff+c,queries_mention_time_diff+d,queries_myTweets_time_diff+e)
      end
    end

    def creating_users(count,noOfClients,no_of_messages) do
        userName = Integer.to_string(count)
        tweetCount = no_of_messages
        msgs = 2
        pid = spawn(fn -> Twitter_Client.start_link(userName,tweetCount,msgs,false) end)
        :ets.insert(:username_pid_map, {userName, pid})
        if (count != noOfClients) do creating_users(count+1,noOfClients,no_of_messages) end
    end

    def whereis(userId) do
        [tup] = :ets.lookup(:username_pid_map, userId)
        elem(tup, 1)
    end

    def simulate_disconnection(no_of_clients,clientsToDisconnect) do
        Process.sleep(1000)
        disconnectList = handle_disconnection(no_of_clients,clientsToDisconnect,0,[])
        Process.sleep(1000)
        Enum.each disconnectList, fn userName -> 
            pid = spawn(fn -> Twitter_Client.start_link(userName,-1,-1,true) end)
            :ets.insert(:username_pid_map, {userName, pid})
        end
        simulate_disconnection(no_of_clients,clientsToDisconnect)
    end

    def handle_disconnection(no_of_clients,clientsToDisconnect,clientsDisconnected,disconnectList) do
        if clientsDisconnected < clientsToDisconnect do
            disconnectClient = :rand.uniform(no_of_clients)
            disconnectClientId = whereis(Integer.to_string(disconnectClient))
            if disconnectClientId != nil do
                userId = Integer.to_string(disconnectClient)
                disconnectList = [userId | disconnectList]
                send(:global.whereis_name(:TwitterServer),{:disconnectUser,userId})
                :ets.insert(:username_pid_map, {userId, nil})
                Process.exit(disconnectClientId,:kill)
                handle_disconnection(no_of_clients,clientsToDisconnect,clientsDisconnected+1,disconnectList)
            else
                handle_disconnection(no_of_clients,clientsToDisconnect,clientsDisconnected,disconnectList)
            end
        else
            disconnectList
        end
    end

    def random_string_generate(l) do
      :crypto.strong_rand_bytes(l) |> Base.url_encode64 |> binary_part(0, l) |> String.downcase
    end
end
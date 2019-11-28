defmodule Twitter_Misc do
    
    def converging(0,totalClients,tweets_time_diff,queries_subscribedto_time_diff,queries_hashtag_time_diff,queries_mention_time_diff,queries_myTweets_time_diff) do
    end

    def converging(numClients,totalClients,tweets_time_diff,queries_subscribedto_time_diff,queries_hashtag_time_diff,queries_mention_time_diff,queries_myTweets_time_diff) do
      # Receive convergence messages
      receive do
        {:perfmetrics,a,b,c,d,e} -> converging(numClients-1,totalClients,tweets_time_diff+a,queries_subscribedto_time_diff+b,queries_hashtag_time_diff+c,queries_mention_time_diff+d,queries_myTweets_time_diff+e)
      end
    end

    def createUsers(count,noOfClients,no_of_messages) do
        userName = Integer.to_string(count)
        noOfTweets = no_of_messages
        noToSubscribe = 2
        pid = spawn(fn -> Twitter_Client.start_link(userName,noOfTweets,noToSubscribe,false) end)
        :ets.insert(:mainregistry, {userName, pid})
        if (count != noOfClients) do createUsers(count+1,noOfClients,no_of_messages) end
    end

    def whereis(userId) do
        [tup] = :ets.lookup(:mainregistry, userId)
        elem(tup, 1)
    end

    def simulate_disconnection(numClients,clientsToDisconnect) do
        Process.sleep(1000)
        disconnectList = handle_disconnection(numClients,clientsToDisconnect,0,[])
        Process.sleep(1000)
        Enum.each disconnectList, fn userName -> 
            pid = spawn(fn -> Twitter_Client.start_link(userName,-1,-1,true) end)
            :ets.insert(:mainregistry, {userName, pid})
        end
        simulate_disconnection(numClients,clientsToDisconnect)
    end

    def handle_disconnection(numClients,clientsToDisconnect,clientsDisconnected,disconnectList) do
        if clientsDisconnected < clientsToDisconnect do
            disconnectClient = :rand.uniform(numClients)
            disconnectClientId = whereis(Integer.to_string(disconnectClient))
            if disconnectClientId != nil do
                userId = Integer.to_string(disconnectClient)
                disconnectList = [userId | disconnectList]
                send(:global.whereis_name(:TwitterServer),{:disconnectUser,userId})
                :ets.insert(:mainregistry, {userId, nil})
                Process.exit(disconnectClientId,:kill)
                handle_disconnection(numClients,clientsToDisconnect,clientsDisconnected+1,disconnectList)
            else
                handle_disconnection(numClients,clientsToDisconnect,clientsDisconnected,disconnectList)
            end
        else
            disconnectList
        end
    end

    def random_string_generate(l) do
      :crypto.strong_rand_bytes(l) |> Base.url_encode64 |> binary_part(0, l) |> String.downcase
    end
end
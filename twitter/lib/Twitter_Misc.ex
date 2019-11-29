defmodule Twitter_Misc do
    
    def simulation(0,totalClients,metric_1,metric_2,metric_3,metric_4,metric_5) do
    end

    def simulation(no_of_clients,totalClients,metric_1,metric_2,metric_3,metric_4,metric_5) do
      receive do
        {:simul_met,a,b,c,d,e} -> simulation(no_of_clients-1,totalClients,metric_1+a,metric_2+b,metric_3+c,metric_4+d,metric_5+e)
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

    def random_string_generate(l) do
      :crypto.strong_rand_bytes(l) |> Base.url_encode64 |> binary_part(0, l) |> String.downcase
    end
end
defmodule Project4part1 do

  require Logger
  def main(args) do
    {_, args, _} = OptionParser.parse(args)
    port = 6666
    mode = Enum.at(args, 0)
    if mode == "server" do
      Logger.debug "Starting as Server"
      Server.start_link(port)
    else

      server_ip = parse_ip(Enum.at(args, 1))
      # Connect to server
      if mode == "client" do
        Logger.debug "Establishing Server connection"
        {:ok, socket} = make_connection(server_ip, port)
        Logger.debug "Server Connection Established"
        Logger.debug "Starting as Interactive Client"
        Client.start_link(socket)
      else
        user_count = Enum.at(args, 2) |> String.to_integer
        subprocess_count = if length(args) == 4 do
          Enum.at(args, 3) |> String.to_integer
        else
          1
        end
        for _ <- 1..subprocess_count do
          Logger.debug "Establishing Server connection"
          {:ok, socket} = make_connection(server_ip, port)
          Logger.debug "Server Connection Established"
          spawn fn -> Client.simulate(socket, user_count) end
        end
        keep_alive()
      end
    end
  end
  def keep_alive() do
      :timer.sleep 10000
      keep_alive()
  end
  defp make_connection(server_ip, port) do
    :gen_tcp.connect(server_ip, port, [:binary, {:active, false},{:packet, 0}])
  end
  defp parse_ip(str) do
    # convert input string 127.0.0.1 to tuple of integers like {127, 0, 0, 1}
    [a, b, c, d] = String.split(str, ".")
    {String.to_integer(a), String.to_integer(b), String.to_integer(c), String.to_integer(d)}
  end
end

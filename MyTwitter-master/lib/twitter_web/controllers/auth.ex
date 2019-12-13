defmodule Twitter_backend.Auth do
    
    import Plug.Conn
    alias Twitter.Repo

    defp login(conn, user) do
        conn 
        |> Guardian.Plug.sign_in(user, :access)
    end

    def login_with(conn, username, password, _opts) do
        
        user = Repo.get_by(Twitter.User, username: username)

        cond do
            user && user.password == password ->
                {:ok, login(conn, user)}
            user ->
                {:error, :unauthorized, conn}
            true ->
                {:error, :not_found, conn}
        end
    end
end
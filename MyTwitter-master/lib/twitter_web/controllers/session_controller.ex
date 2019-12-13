defmodule Twitter_backend.SessionController do
    use Twitter_backend, :controller
    import Twitter_backend.Auth

    def new(conn,_params) do
      render(conn, "make.html")
    end


   def delete(conn, _) do
     conn
     |> Guardian.Plug.sign_out
     |> redirect(to: "/")
   end


   def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    case login_with(conn, username, password, repo: Repo) do
      {:ok, conn} ->
        logged_user = Guardian.Plug.current_resource(conn)
        conn
        |> redirect(to: page_path(conn, :home))
      {:error, _reason, conn} ->
        conn
        |> render("make.html")
    end
  end

end
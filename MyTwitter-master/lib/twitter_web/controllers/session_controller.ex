defmodule TwitterWeb.SessionController do
    # login related module
    use TwitterWeb, :controller
    import TwitterWeb.Auth

    def new(conn,_params) do
      render(conn, "new.html")
    end

    def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
      case login_with(conn, username, password, repo: Repo) do
        {:ok, conn} ->
          logged_user = Guardian.Plug.current_resource(conn)
          conn
          |> put_flash(:info, "logged in!")
          |> redirect(to: page_path(conn, :home))
        {:error, _reason, conn} ->
          conn
          |> put_flash(:error, "Wrong username/password")
          |> render("new.html")
      end
    end

   def delete(conn, _) do
     conn
     |> Guardian.Plug.sign_out
     |> redirect(to: "/")
   end

end
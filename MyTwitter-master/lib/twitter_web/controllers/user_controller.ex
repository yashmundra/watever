defmodule TwitterWeb.UserController do
    # create a new user
    use TwitterWeb, :controller 
    import Ecto.Query
    alias Twitter.User
    alias Twitter.Repo


    def new(conn, _params) do
        changeset = User.changeset(%User{},%{})
        render(conn, "new.html", changeset: changeset)
    end

    def create(conn, %{"user" => user_params}) do
        changeset = User.changeset(%User{}, user_params)

        case Repo.insert(changeset) do
            {:ok, user} ->
                conn 
                |> Guardian.Plug.sign_in(user, :access)
                |> put_flash(:info, "User Created Successfully!")
                |> redirect(to: page_path(conn, :home))
            {:error, changeset} ->
                render(conn, "new.html", changeset: changeset)
        end
    end

    def subscribeindex(conn, _params) do
        render(conn, "subscribe.html")
    end

    def subscribe(conn, %{"follow" => %{"subscribe" => subscribe}}) do
        logged_user = Guardian.Plug.current_resource(conn)
        subscribed_user = Repo.one(from u in User, where: u.username==^subscribe) # check whether user you try to subscribe exists
        subscribelist = String.split(logged_user.subscribe,"$$")
        cond do
            subscribe == logged_user.username ->
                conn
                |> put_flash(:error, "Cannot subscribe to yourself")
                |> redirect(to: user_path(conn, :subscribeindex))
            subscribed_user == nil ->
                conn
                |> put_flash(:error, "User you try to subscribe does not exist")
                |> redirect(to: user_path(conn, :subscribeindex))
            Enum.member?(subscribelist, subscribe) ->
                conn
                |> put_flash(:error, "You've already subscribed to this user")
                |> redirect(to: user_path(conn, :subscribeindex))
            true ->
                newsubscribe1 = logged_user.subscribe <> "$$" <> subscribe
                changeset1 = User.changeset(logged_user, %{subscribe: newsubscribe1})
                newfollower2 = subscribed_user.follower <> "$$" <> logged_user.username
                changeset2 = User.changeset(subscribed_user, %{follower: newfollower2})
                case Repo.update(changeset1) do
                    {:ok, _} ->
                        Repo.update(changeset2) # bug!!! happens when 1 succeeds 2 fails
                        conn
                        |> put_flash(:info, "Subscribe successfully.")
                        |> redirect(to: user_path(conn, :subscribeindex))
                    {:error, _} ->
                        conn
                        |> put_flash(:error, "Fail to subscribe, database record update failed")
                        |> redirect(to: user_path(conn, :subscribeindex))
                end
        end
    end
    


    
end
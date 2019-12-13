defmodule Twitter_backend.UserController do
    
    use Twitter_backend, :controller 
    import Ecto.Query
    alias Twitter.Repo
    alias Twitter.User
    


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
                |> redirect(to: page_path(conn, :home))
            {:error, changeset} ->
                render(conn, "new.html", changeset: changeset)
        end
    end

    def subscribeindex(conn, _params) do
        render(conn, "subscribe.html")
    end

    def subscribe(conn, %{"follow" => %{"subscribe" => subscribe}}) do
        subscribed_user = Repo.one(from u in User, where: u.username==^subscribe) 
        logged_user = Guardian.Plug.current_resource(conn)
        subscribelist = String.split(logged_user.subscribe,"$$")
        cond do
            subscribe == logged_user.username ->
                conn
                |> redirect(to: user_path(conn, :sub_indie))
            Enum.member?(subscribelist, subscribe) ->
                conn
                |> redirect(to: user_path(conn, :sub_indie))
            subscribed_user == nil ->
                conn
                |> redirect(to: user_path(conn, :sub_indie))
            true ->
                n_subscribe = logged_user.subscribe <> "$$@@" <> subscribe
                n_follow = subscribed_user.follower <> "$$@@" <> logged_user.username
                cs1 = User.changeset(logged_user, %{subscribe: n_subscribe})
                cs2 = User.changeset(subscribed_user, %{follower: n_follow})
                case Repo.update(cs1) do
                    {:ok, _} ->
                        Repo.update(cs2) 
                        conn
                        |> redirect(to: user_path(conn, :sub_indie))
                    {:error, _} ->
                        conn
                        |> redirect(to: user_path(conn, :sub_indie))
                end
        end
    end
    


    
end
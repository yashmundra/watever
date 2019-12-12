defmodule Twitter.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Twitter.User


  schema "users" do
    field :username, :string
    field :password, :string
    field :follower, :string, default: ""
    field :subscribe, :string, default: ""

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :password, :subscribe, :follower])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
  end
end

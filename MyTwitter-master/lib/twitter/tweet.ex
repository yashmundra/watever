defmodule Twitter.Tweet do
  use Ecto.Schema
  import Ecto.Changeset
  alias Twitter.Tweet


  schema "tweets" do
    field :author, :string
    field :content, :string
    field :hashtag, :string
    field :mentioned, :string
    field :retweeted_status, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(%Tweet{} = tweet, attrs) do
    tweet
    |> cast(attrs, [:author, :content, :hashtag, :mentioned, :retweeted_status])
    |> validate_required([:author, :content])
  end
end

defmodule Twitter.Repo.Migrations.CreateTweets do
  use Ecto.Migration

  def change do
    create table(:tweets) do
      add :author, :string
      add :content, :string
      add :hashtag, :string
      add :mentioned, :string
      add :retweeted_status, :boolean

      timestamps()
    end

  end
end

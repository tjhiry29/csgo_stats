defmodule CsgoStats.Repo.Migrations.CreateGameEvents do
  use Ecto.Migration

  def change do
    create table(:game_events) do
      add :type, :string
      add :fields, :map
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:game_events, [:game_id])
  end
end

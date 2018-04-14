defmodule CsgoStats.Repo.Migrations.CreateAssists do
  use Ecto.Migration

  def change do
    create table(:assists) do
      add :victim_name, :string
      add :victim_userid, :integer
      add :assister_name, :string
      add :assister_userid, :string
      add :round, :integer
      add :tick, :integer
      add :time_left_in_round, :float
      add :time_elapsed, :float
      add :victim_id, references(:players, on_delete: :nothing)
      add :assister_id, references(:players, on_delete: :nothing)
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:assists, [:victim_id])
    create index(:assists, [:assister_id])
    create index(:assists, [:game_id])
  end
end

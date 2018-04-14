defmodule CsgoStats.Repo.Migrations.CreateKills do
  use Ecto.Migration

  def change do
    create table(:kills) do
      add :attacker_name, :string
      add :attacker_userid, :integer
      add :victim_name, :string
      add :victim_userid, :integer
      add :weapon, :string
      add :round, :integer
      add :tick, :integer
      add :headshot, :boolean, default: false, null: false
      add :victim_position, {:array, :float}
      add :attacker_position, {:array, :float}
      add :map_name, :string
      add :time_elapsed, :float
      add :time_left_in_round, :float
      add :trade, :boolean, default: false, null: false
      add :first_of_round, :boolean, default: false, null: false
      add :assist_id, references(:assists, on_delete: :nothing)
      add :game_id, references(:games, on_delete: :nothing)
      add :attacker_id, references(:players, on_delete: :nothing)
      add :victim_id, references(:players, on_delete: :nothing)

      timestamps()
    end

    create index(:kills, [:assist_id])
    create index(:kills, [:game_id])
    create index(:kills, [:attacker_id])
    create index(:kills, [:victim_id])
  end
end

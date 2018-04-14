defmodule CsgoStats.Repo.Migrations.CreateHegrenadeThrows do
  use Ecto.Migration

  def change do
    create table(:hegrenade_throws) do
      add(:player_name, :string)
      add(:player_userid, :integer)
      add(:tick, :integer)
      add(:round, :integer)
      add(:origin, {:array, :float})
      add(:facing, :string)
      add(:location, {:array, :float})
      add(:time_elapsed, :float)
      add(:time_left_in_round, :float)
      add(:player_damage_dealt, :map)
      add(:total_damage_dealt, :float)
      add(:game_id, references(:games, on_delete: :nothing))
      add(:player_id, references(:players, on_delete: :nothing))

      timestamps()
    end

    create(index(:hegrenade_throws, [:game_id]))
    create(index(:hegrenade_throws, [:player_id]))
  end
end

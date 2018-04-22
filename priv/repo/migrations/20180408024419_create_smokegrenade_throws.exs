defmodule CsgoStats.Repo.Migrations.CreateSmokegrenadeThrows do
  use Ecto.Migration

  def change do
    create table(:smokegrenade_throws) do
      add(:player_name, :string)
      add(:player_userid, :integer)
      add(:tick, :integer)
      add(:round, :integer)
      add(:origin, {:array, :float})
      add(:time_elapsed, :float)
      add(:time_left_in_round, :float)
      add(:game_id, references(:games, on_delete: :nothing))
      add(:player_game_record_id, references(:player_game_records, on_delete: :nothing))

      timestamps()
    end

    create(index(:smokegrenade_throws, [:game_id]))
    create(index(:smokegrenade_throws, [:player_game_record_id]))
  end
end

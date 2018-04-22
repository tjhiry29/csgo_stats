defmodule CsgoStats.Repo.Migrations.CreateFlashbangThrows do
  use Ecto.Migration

  def change do
    create table(:flashbang_throws) do
      add(:player_name, :string)
      add(:player_userid, :integer)
      add(:tick, :integer)
      add(:round, :integer)
      add(:origin, {:array, :float})
      add(:facing, :string)
      add(:location, {:array, :float})
      add(:time_elapsed, :float)
      add(:time_left_in_round, :float)
      add(:player_blind_duration, :map)
      add(:total_blind_duration, :float)
      add(:flash_assist, :boolean, default: false, null: false)
      add(:game_id, references(:games, on_delete: :nothing))
      add(:player_game_record_id, references(:player_game_records, on_delete: :nothing))

      timestamps()
    end

    create(index(:flashbang_throws, [:game_id]))
    create(index(:flashbang_throws, [:player_game_record_id]))
  end
end

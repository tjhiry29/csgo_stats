defmodule CsgoStats.Repo.Migrations.CreatePlayerRoundRecords do
  use Ecto.Migration

  def change do
    create table(:player_round_records) do
      add(:name, :string)
      add(:userid, :integer)
      add(:teamnum, :integer)
      add(:round, :integer)
      add(:total_damage_dealt, :float)
      add(:damage_dealt, :map)
      add(:flash_assists, :integer)
      add(:health, :integer)
      add(:traded, :boolean, default: false, null: false)
      add(:dead, :boolean, default: false, null: false)
      add(:player_id, references(:players, on_delete: :nothing))
      add(:player_game_record_id, references(:player_game_records, on_delete: :nothing))
      add(:team_game_record_id, references(:team_game_records, on_delete: :nothing))
      add(:game_id, references(:games, on_delete: :nothing))

      timestamps()
    end

    create(index(:player_round_records, [:player_id]))
    create(index(:player_round_records, [:game_id]))
  end
end

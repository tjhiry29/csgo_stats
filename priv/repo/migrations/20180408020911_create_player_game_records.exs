defmodule CsgoStats.Repo.Migrations.CreatePlayerGameRecords do
  use Ecto.Migration

  def change do
    create table(:player_game_records) do
      add(:adr, :float)
      add(:assist_count, :integer)
      add(:death_count, :integer)
      add(:deaths_traded, :integer)
      add(:first_deaths, :integer)
      add(:first_kills, :integer)
      add(:headshot_count, :integer)
      add(:headshot_percentage, :float)
      add(:kast, :float)
      add(:kill_count, :integer)
      add(:kill_death_ratio, :float)
      add(:map_name, :string)
      add(:name, :string)
      add(:rounds_played, :integer)
      add(:teamnum, :integer)
      add(:trade_kills, :integer)
      add(:userid, :integer)
      add(:xuid, :bigint)
      add(:guid, :string)
      add(:friends_id, :bigint)
      add(:rounds_won, :integer)
      add(:rounds_lost, :integer)
      add(:won, :boolean)
      add(:tie, :boolean)
      add(:game_id, references(:games, on_delete: :nothing))
      add(:team_game_record_id, references(:team_game_records, on_delete: :nothing))
      add(:player_id, references(:players, on_delete: :nothing))

      timestamps()
    end

    create(index(:player_game_records, [:friends_id]))
    create(index(:player_game_records, [:guid]))
    create(index(:player_game_records, [:xuid]))

    create(index(:player_game_records, [:game_id, :team_game_record_id, :map_name, :xuid]))
  end
end

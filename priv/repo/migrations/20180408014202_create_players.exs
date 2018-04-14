defmodule CsgoStats.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add(:name, :string)
      add(:userid, :integer)
      add(:xuid, :string)
      add(:adr, :float)
      add(:kast, :float)
      add(:teamnum, :integer)
      add(:rounds_played, :integer)
      add(:kill_count, :integer)
      add(:assist_count, :integer)
      add(:death_count, :integer)
      add(:headshot_count, :integer)
      add(:first_kills, :integer)
      add(:first_deaths, :integer)
      add(:trade_kills, :integer)
      add(:deaths_traded, :integer)
      add(:game_id, references(:games, on_delete: :nothing))
      add(:team_id, references(:teams, on_delete: :nothing))

      timestamps()
    end

    create(index(:players, [:game_id]))
    create(index(:players, [:team_id]))
    create(index(:players, [:xuid]))
  end
end

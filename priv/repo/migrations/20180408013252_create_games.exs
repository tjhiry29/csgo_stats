defmodule CsgoStats.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add(:map_name, :string)
      add(:tick_rate, :integer)
      add(:team1_score, :integer)
      add(:team2_score, :integer)
      add(:rounds_played, :integer)
      add(:demo_name, :string)

      timestamps()
    end

    create(index(:games, [:demo_name]))
  end
end

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
      add(:major_version, :integer)
      add(:minor_version, :integer)
      add(:patch_version, :integer)

      timestamps()
    end

    create(index(:games, [:minor_version]))
    create(index(:games, [:major_version]))
    create(index(:games, [:major_version, :minor_version, :patch_version]))
    create(index(:games, [:map_name]))
    create(index(:games, [:demo_name], unique: true))
  end
end

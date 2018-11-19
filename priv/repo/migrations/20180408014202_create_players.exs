defmodule CsgoStats.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add(:name, :string)
      add(:xuid, :bigint)
      add(:guid, :string)
      add(:friends_id, :bigint)

      timestamps()
    end

    create(index(:players, [:guid], unique: true))
    create(index(:players, [:xuid], unique: true))
    create(index(:players, [:friends_id]))
  end
end

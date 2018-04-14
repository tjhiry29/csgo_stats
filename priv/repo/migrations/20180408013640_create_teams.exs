defmodule CsgoStats.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add(:teamnum, :integer)
      add(:round_win_ids, {:array, :integer})
      add(:round_loss_ids, {:array, :integer})
      add(:bomb_plant_ids, {:array, :integer})
      add(:bomb_defusal_ids, {:array, :integer})
      add(:rounds_won, :integer)
      add(:rounds_lost, :integer)
      add(:game_id, references(:games, on_delete: :nothing))

      timestamps()
    end

    create(index(:teams, [:game_id]))
  end
end

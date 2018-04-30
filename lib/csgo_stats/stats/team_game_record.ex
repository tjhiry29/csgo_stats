defmodule CsgoStats.Stats.TeamGameRecord do
  alias CsgoStats.Stats.{Game, TeamGameRecord, PlayerGameRecord}
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_game_records" do
    field(:bomb_defusal_ids, {:array, :integer})
    field(:bomb_plant_ids, {:array, :integer})
    field(:round_loss_ids, {:array, :integer})
    field(:round_win_ids, {:array, :integer})
    field(:rounds_lost, :integer)
    field(:rounds_won, :integer)
    field(:teamnum, :integer)
    belongs_to(:game, Game)
    has_many(:player_game_records, PlayerGameRecord)

    timestamps()
  end

  def create_team_game_record(
        struct = %TeamGameRecord{},
        game = %Game{},
        team = %DemoInfoGo.Team{}
      ) do
    attrs =
      team
      |> Map.put(:game, game)
      |> Map.from_struct()

    changeset(struct, attrs)
    |> put_assoc(:game, attrs.game)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [
      :teamnum,
      :rounds_won,
      :rounds_lost
    ])
    |> validate_required([
      :teamnum,
      :rounds_won,
      :rounds_lost
    ])
  end
end

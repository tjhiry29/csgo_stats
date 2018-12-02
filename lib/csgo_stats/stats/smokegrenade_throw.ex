defmodule CsgoStats.Stats.SmokegrenadeThrow do
  use Ecto.Schema
  import Ecto.Changeset
  alias CsgoStats.Stats.{Game, PlayerGameRecord, SmokegrenadeThrow}

  schema "smokegrenade_throws" do
    field(:origin, {:array, :float})
    field(:player_name, :string)
    field(:player_userid, :integer)
    field(:round, :integer)
    field(:tick, :integer)
    field(:time_elapsed, :float)
    field(:time_left_in_round, :float)
    belongs_to(:game, Game)
    belongs_to(:player_game_record, PlayerGameRecord)

    timestamps()
  end

  def create_smokegrenade_throw(smokegrenade_throw, players, game) do
    player = Enum.find(players, fn player -> player.name == smokegrenade_throw.player_name end)

    attrs =
      smokegrenade_throw
      |> Map.from_struct()
      |> Map.put(:player_userid, smokegrenade_throw.player_id)

    changeset(%SmokegrenadeThrow{}, attrs)
    |> put_assoc(:player_game_record, player)
    |> put_assoc(:game, game)
  end

  @doc false
  def changeset(smokegrenade_throw, attrs) do
    smokegrenade_throw
    |> cast(attrs, [
      :player_name,
      :player_userid,
      :tick,
      :round,
      :origin,
      :time_elapsed,
      :time_left_in_round
    ])
    |> validate_required([
      :player_name,
      :player_userid,
      :tick,
      :round,
      :origin,
      :time_elapsed
    ])
  end
end

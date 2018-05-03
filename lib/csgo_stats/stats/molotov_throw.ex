defmodule CsgoStats.Stats.MolotovThrow do
  use Ecto.Schema
  import Ecto.Changeset
  alias CsgoStats.Stats.{Game, PlayerGameRecord, MolotovThrow}

  schema "molotov_throws" do
    field(:facing, :string)
    field(:location, {:array, :float})
    field(:origin, {:array, :float})
    field(:player_damage_dealt, :map)
    field(:player_name, :string)
    field(:player_userid, :integer)
    field(:round, :integer)
    field(:tick, :integer)
    field(:time_elapsed, :float)
    field(:time_left_in_round, :float)
    field(:total_damage_dealt, :float)
    belongs_to(:game, Game)
    belongs_to(:player_game_record, PlayerGameRecord)

    timestamps()
  end

  def create_molotov_throw(molotov_throw, players, game) do
    player = Enum.find(players, fn player -> player.name == molotov_throw.player_name end)

    attrs =
      molotov_throw
      |> Map.from_struct()
      |> Map.put(:player_userid, molotov_throw.player_id)

    changeset(%MolotovThrow{}, attrs)
    |> put_assoc(:player_game_record, player)
    |> put_assoc(:game, game)
  end

  @doc false
  def changeset(molotov_throw, attrs) do
    molotov_throw
    |> cast(attrs, [
      :player_name,
      :player_userid,
      :tick,
      :round,
      :origin,
      :facing,
      :location,
      :time_elapsed,
      :time_left_in_round,
      :player_damage_dealt,
      :total_damage_dealt
    ])
    |> validate_required([
      :player_name,
      :player_userid,
      :tick,
      :round,
      :origin,
      :facing,
      :time_elapsed,
      :time_left_in_round,
      :player_damage_dealt,
      :total_damage_dealt
    ])
  end
end

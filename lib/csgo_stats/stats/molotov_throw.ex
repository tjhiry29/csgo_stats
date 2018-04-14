defmodule CsgoStats.Stats.MolotovThrow do
  use Ecto.Schema
  import Ecto.Changeset

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
    field(:game_id, :id)
    field(:player_id, :id)

    timestamps()
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
      :location,
      :time_elapsed,
      :time_left_in_round,
      :player_damage_dealt,
      :total_damage_dealt
    ])
  end
end

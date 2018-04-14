defmodule CsgoStats.Stats.FlashbangThrows do
  use Ecto.Schema
  import Ecto.Changeset

  schema "flashbang_throws" do
    field(:facing, :string)
    field(:flash_assist, :boolean, default: false)
    field(:location, {:array, :float})
    field(:origin, {:array, :float})
    field(:player_blind_duration, :map)
    field(:player_name, :string)
    field(:player_userid, :integer)
    field(:round, :integer)
    field(:tick, :integer)
    field(:time_elapsed, :float)
    field(:time_left_in_round, :float)
    field(:total_blind_duration, :float)
    field(:game_id, :id)
    field(:player_id, :id)

    timestamps()
  end

  @doc false
  def changeset(flashbang_throw, attrs) do
    flashbang_throw
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
      :player_blind_duration,
      :total_blind_duration,
      :flash_assist
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
      :player_blind_duration,
      :total_blind_duration,
      :flash_assist
    ])
  end
end

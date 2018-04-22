defmodule CsgoStats.Stats.FlashbangThrow do
  use Ecto.Schema
  import Ecto.Changeset
  alias CsgoStats.Stats.{Game, PlayerGameRecord, FlashbangThrow}

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
    belongs_to(:game, Game)
    belongs_to(:player_game_record, PlayerGameRecord)

    timestamps()
  end

  def create_flashbang_throw(flashbang_throw, players, game) do
    player = Enum.find(players, fn player -> player.name == flashbang_throw.player_name end)

    attrs =
      flashbang_throw
      |> Map.from_struct()
      |> Map.put(:player_userid, flashbang_throw.player_id)

    changeset(%FlashbangThrow{}, attrs)
    |> put_assoc(:player_game_record, player)
    |> put_assoc(:game, game)
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

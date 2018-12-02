defmodule CsgoStats.Stats.Player do
  alias CsgoStats.Stats.{Player, PlayerGameRecord}
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field(:name, :string)
    field(:xuid, :integer)
    field(:friends_id, :integer)
    field(:guid, :string)

    has_many(:player_game_records, PlayerGameRecord)
    timestamps()
  end

  def normalize_player(player = %DemoInfoGo.Player{}, player_infos) do
    infos =
      Enum.filter(player_infos, fn info ->
        info.fields |> Map.get("userID") |> String.to_integer() == player.id
      end)

    cond do
      length(infos) == 0 ->
        player |> Map.put(:fakeplayer, "1")

      true ->
        info = Enum.at(infos, 0)

        player
        |> Map.put(:xuid, Map.get(info.fields, "xuid") |> String.to_integer())
        |> Map.put(:guid, Map.get(info.fields, "guid"))
        |> Map.put(:fakeplayer, Map.get(info.fields, "fakeplayer"))
        |> Map.put(:friends_id, Map.get(info.fields, "friendsID") |> String.to_integer())
        |> Map.put(
          :headshot_percentage,
          PlayerGameRecord.headshot_percentage(player.headshot_count, player.kill_count)
        )
        |> Map.put(
          :kill_death_ratio,
          PlayerGameRecord.kill_death_ratio(player.kill_count, player.death_count)
        )
    end
  end

  def filter_bots(players) do
    Enum.filter(players, fn player -> player.fakeplayer == "0" end)
  end

  def create_player(player = %DemoInfoGo.Player{}) do
    attrs =
      player
      |> Map.from_struct()

    changeset(%Player{}, attrs)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [
      :name,
      :xuid,
      :guid,
      :friends_id
    ])
    |> validate_required([
      :name,
      :xuid,
      :guid
    ])
    |> unique_constraint(:xuid)
  end
end

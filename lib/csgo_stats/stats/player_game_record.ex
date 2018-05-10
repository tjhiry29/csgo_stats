defmodule CsgoStats.Stats.PlayerGameRecord do
  alias CsgoStats.Stats.{Game, TeamGameRecord, PlayerGameRecord, Kill, Player}
  use Ecto.Schema
  import Ecto.Changeset

  schema "player_game_records" do
    field(:adr, :float)
    field(:assist_count, :integer)
    field(:death_count, :integer)
    field(:deaths_traded, :integer)
    field(:first_deaths, :integer)
    field(:first_kills, :integer)
    field(:headshot_count, :integer)
    field(:headshot_percentage, :float)
    field(:kast, :float)
    field(:kill_count, :integer)
    field(:kill_death_ratio, :float)
    field(:map_name, :string)
    field(:name, :string)
    field(:rounds_played, :integer)
    field(:teamnum, :integer)
    field(:trade_kills, :integer)
    field(:userid, :integer)
    field(:xuid, :integer)
    field(:friends_id, :integer)
    field(:rounds_won, :integer)
    field(:rounds_lost, :integer)
    field(:won, :boolean)
    field(:tie, :boolean)
    belongs_to(:game, Game)
    belongs_to(:team_game_record, TeamGameRecord)
    belongs_to(:player, Player)
    has_many(:kills, Kill, foreign_key: :attacker_id)
    has_many(:deaths, Kill, foreign_key: :victim_id)

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
        |> Map.put(:fakeplayer, Map.get(info.fields, "fakeplayer"))
        |> Map.put(:friends_id, Map.get(info.fields, "friendsID") |> String.to_integer())
        |> Map.put(
          :headshot_percentage,
          headshot_percentage(player.headshot_count, player.kill_count)
        )
        |> Map.put(:kill_death_ratio, kill_death_ratio(player.kill_count, player.death_count))
    end
  end

  def create_player(
        player = %DemoInfoGo.Player{},
        game = %Game{},
        team = %TeamGameRecord{},
        stats_player = %Player{}
      ) do
    attrs =
      player
      |> Map.from_struct()
      |> Map.put(:userid, player.id)
      |> Map.put(:map_name, game.map_name)

    changeset(%PlayerGameRecord{}, attrs)
    |> put_assoc(:game, game)
    |> put_assoc(:team_game_record, team)
    |> put_assoc(:player, stats_player)
  end

  @doc false
  def changeset(player_game_record, attrs) do
    player_game_record
    |> cast(attrs, [
      :adr,
      :assist_count,
      :death_count,
      :deaths_traded,
      :first_deaths,
      :first_kills,
      :headshot_count,
      :headshot_percentage,
      :kill_death_ratio,
      :kast,
      :kill_count,
      :map_name,
      :name,
      :rounds_played,
      :teamnum,
      :trade_kills,
      :userid,
      :xuid,
      :rounds_won,
      :rounds_lost,
      :won,
      :tie
    ])
    |> validate_required([
      :adr,
      :assist_count,
      :death_count,
      :deaths_traded,
      :first_deaths,
      :first_kills,
      :headshot_count,
      :headshot_percentage,
      :kill_death_ratio,
      :kast,
      :kill_count,
      :map_name,
      :name,
      :rounds_played,
      :teamnum,
      :trade_kills,
      :userid,
      :xuid,
      :rounds_won,
      :rounds_lost,
      :won,
      :tie
    ])
  end

  def headshot_percentage(headshot_count, kill_count) do
    Float.round(headshot_count / kill_count * 100, 2)
  end

  def kill_death_ratio(kill_count, death_count) do
    Float.round(kill_count / death_count, 2)
  end
end

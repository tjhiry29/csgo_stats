defmodule CsgoStats.Stats.PlayerGameRecord do
  alias CsgoStats.Stats.{Game, Team, PlayerGameRecord, Kill, Player}
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
    field(:kast, :float)
    field(:kill_count, :integer)
    field(:name, :string)
    field(:rounds_played, :integer)
    field(:teamnum, :integer)
    field(:trade_kills, :integer)
    field(:userid, :integer)
    field(:xuid, :integer)
    field(:friends_id, :integer)
    belongs_to(:game, Game)
    belongs_to(:team, Team)
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
    end
  end

  def create_player(
        player = %DemoInfoGo.Player{},
        game = %Game{},
        team = %Team{},
        stats_player = %Player{}
      ) do
    attrs =
      player
      |> Map.from_struct()
      |> Map.put(:userid, player.id)

    changeset(%PlayerGameRecord{}, attrs)
    |> put_assoc(:game, game)
    |> put_assoc(:team, team)
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
      :kast,
      :kill_count,
      :name,
      :rounds_played,
      :teamnum,
      :trade_kills,
      :userid,
      :xuid
    ])
    |> validate_required([
      :adr,
      :assist_count,
      :death_count,
      :deaths_traded,
      :first_deaths,
      :first_kills,
      :headshot_count,
      :kast,
      :kill_count,
      :name,
      :rounds_played,
      :teamnum,
      :trade_kills,
      :userid,
      :xuid
    ])
  end
end

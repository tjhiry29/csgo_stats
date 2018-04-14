defmodule CsgoStats.Stats.Player do
  alias CsgoStats.Stats.{Game, Team, Player, Kill}
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
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
    field(:xuid, :string)
    belongs_to(:game, Game)
    belongs_to(:team, Team)
    has_many(:kills, Kill, foreign_key: :attacker_id)
    has_many(:deaths, Kill, foreign_key: :victim_id)

    timestamps()
  end

  def normalize_player(player = %DemoInfoGo.Player{}, player_infos) do
    IO.inspect(player_infos)

    infos =
      Enum.filter(player_infos, fn info ->
        info.fields |> Map.get("userID") |> String.to_integer() == player.id
      end)

    cond do
      length(infos) == 0 ->
        player |> Map.put(:fakeplayer, "1")

      true ->
        info = Enum.at(infos, 0)

        Map.put(player, :xuid, Map.get(info.fields, "xuid"))
        |> Map.put(:fakeplayer, Map.get(info.fields, "fakeplayer"))
    end
  end

  def filter_bots(players) do
    Enum.filter(players, fn player -> player.fakeplayer == "0" end)
  end

  def create_player(
        struct,
        player = %DemoInfoGo.Player{},
        game = %Game{},
        team = %Team{}
      ) do
    attrs =
      player
      |> Map.from_struct()
      |> Map.put(:userid, player.id)
      |> Map.put(:team, team)
      |> Map.put(:game, game)

    changeset(struct, attrs)
    |> put_assoc(:game, attrs.game)
    |> put_assoc(:team, attrs.team)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [
      :name,
      :userid,
      :xuid,
      :adr,
      :kast,
      :teamnum,
      :rounds_played,
      :kill_count,
      :assist_count,
      :death_count,
      :headshot_count,
      :first_kills,
      :first_deaths,
      :trade_kills,
      :deaths_traded
    ])
    |> validate_required([
      :name,
      :userid,
      :xuid,
      :adr,
      :kast,
      :teamnum,
      :rounds_played,
      :kill_count,
      :assist_count,
      :death_count,
      :headshot_count,
      :first_kills,
      :first_deaths,
      :trade_kills,
      :deaths_traded
    ])
  end
end

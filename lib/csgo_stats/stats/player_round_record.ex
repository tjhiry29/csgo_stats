defmodule CsgoStats.Stats.PlayerRoundRecord do
  alias CsgoStats.Stats.{Player, Game, PlayerGameRecord, TeamGameRecord}
  use Ecto.Schema
  import Ecto.Changeset

  schema "player_round_records" do
    field(:damage_dealt, :map)
    field(:dead, :boolean, default: false)
    field(:flash_assists, :integer)
    field(:health, :integer)
    field(:name, :string)
    field(:round, :integer)
    field(:teamnum, :integer)
    field(:total_damage_dealt, :float)
    field(:traded, :boolean, default: false)
    field(:userid, :integer)
    belongs_to(:player, Player)
    belongs_to(:player_game_record, PlayerGameRecord)
    belongs_to(:team_game_record, TeamGameRecord)
    belongs_to(:game, Game)

    timestamps()
  end

  def put_game(changeset, game) do
    changeset
    |> put_assoc(:game, game)
  end

  def put_team_game_record(changeset, team_game_record) do
    changeset
    |> put_assoc(:team_game_record, team_game_record)
  end

  def put_player(changeset, player) do
    changeset
    |> put_assoc(:player, player)
  end

  def put_player_game_record(changeset, player_game_record) do
    changeset
    |> put_assoc(:player_game_record, player_game_record)
  end

  @doc false
  def changeset(player_round_records, attrs) do
    player_round_records
    |> cast(attrs, [
      :name,
      :userid,
      :teamnum,
      :round,
      :damage_dealt,
      :total_damage_dealt,
      :flash_assists,
      :health,
      :traded,
      :dead
    ])
    |> validate_required([
      :name,
      :userid,
      :teamnum,
      :round,
      :health,
      :traded,
      :dead
    ])
  end
end

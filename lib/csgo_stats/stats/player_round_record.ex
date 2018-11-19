defmodule CsgoStats.Stats.PlayerRoundRecord do
  alias CsgoStats.Stats.{Player, Game}
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
    belongs_to(:game, Game)

    timestamps()
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
      :damage_dealt,
      :flash_assists,
      :health,
      :traded,
      :dead
    ])
  end
end

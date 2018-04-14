defmodule CsgoStats.Stats.PlayerRoundRecord do
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
    field(:traded, :boolean, default: false)
    field(:userid, :integer)
    field(:player_id, :id)
    field(:game_id, :id)

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

defmodule CsgoStats.Stats.Assist do
  use Ecto.Schema
  import Ecto.Changeset
  alias CsgoStats.Stats.{Game, PlayerGameRecord, Kill, Assist}

  schema "assists" do
    field(:assister_name, :string)
    field(:assister_userid, :integer)
    field(:round, :integer)
    field(:tick, :integer)
    field(:time_elapsed, :float)
    field(:time_left_in_round, :float)
    field(:victim_name, :string)
    field(:victim_userid, :integer)
    belongs_to(:victim, PlayerGameRecord)
    belongs_to(:assister, PlayerGameRecord)
    belongs_to(:game, Game)
    has_one(:kill, Kill)

    timestamps()
  end

  def create_assist(assist, players, game) do
    assister = Enum.find(players, fn player -> player.userid == assist.assister_id end)
    victim = Enum.find(players, fn player -> player.userid == assist.victim_id end)

    attrs =
      assist
      |> Map.from_struct()

    changeset(%Assist{}, attrs)
    |> put_assoc(:victim, victim)
    |> put_assoc(:game, game)
    |> put_assoc(:assister, assister)
  end

  def put_game(changeset, game) do
    changeset
    |> put_assoc(:game, game)
  end

  def put_victim(changeset, victim) do
    changeset
    |> put_assoc(:victim, victim)
  end

  def put_assister(changeset, assister) do
    changeset
    |> put_assoc(:assister, assister)
  end

  @doc false
  def changeset(assist, attrs) do
    assist
    |> cast(attrs, [
      :victim_name,
      :assister_name,
      :victim_userid,
      :assister_userid,
      :round,
      :tick,
      :time_left_in_round,
      :time_elapsed
    ])
    |> validate_required([
      :victim_name,
      :assister_name,
      :round,
      :tick
    ])
  end
end

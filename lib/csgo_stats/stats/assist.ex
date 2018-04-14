defmodule CsgoStats.Stats.Assist do
  use Ecto.Schema
  import Ecto.Changeset
  alias CsgoStats.Stats.{Game, Player, Kill, Assist}

  schema "assists" do
    field(:assister_name, :string)
    field(:assister_userid, :string)
    field(:round, :integer)
    field(:tick, :integer)
    field(:time_elapsed, :float)
    field(:time_left_in_round, :float)
    field(:victim_name, :string)
    field(:victim_userid, :integer)
    belongs_to(:victim, Player)
    belongs_to(:assister, Player)
    belongs_to(:game, Game)
    has_one(:kill, Kill)

    timestamps()
  end

  def create_assist(assist, players, game) do
    assister = Enum.find(players, fn player -> player.name == assist.assister_name end)
    victim = Enum.find(players, fn player -> player.name == assist.victim_name end)

    attrs =
      assist
      |> Map.from_struct()

    changeset(%Assist{}, attrs)
    |> put_assoc(:victim, victim)
    |> put_assoc(:game, game)
    |> put_assoc(:assister, assister)
  end

  @doc false
  def changeset(assist, attrs) do
    assist
    |> cast(attrs, [
      :victim_name,
      :assister_name,
      :round,
      :tick,
      :time_left_in_round,
      :time_elapsed
    ])
    |> validate_required([
      :victim_name,
      :assister_name,
      :round,
      :tick,
      :time_left_in_round,
      :time_elapsed
    ])
  end
end

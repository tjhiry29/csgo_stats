defmodule CsgoStats.Stats.Kill do
  use Ecto.Schema
  import Ecto.Changeset
  alias CsgoStats.Stats.{Game, PlayerGameRecord, Assist, Kill}

  schema "kills" do
    field(:attacker_name, :string)
    field(:attacker_position, {:array, :float})
    field(:attacker_userid, :integer)
    field(:first_of_round, :boolean, default: false)
    field(:headshot, :boolean, default: false)
    field(:map_name, :string)
    field(:round, :integer)
    field(:tick, :integer)
    field(:time_elapsed, :float)
    field(:time_left_in_round, :float)
    field(:trade, :boolean, default: false)
    field(:victim_name, :string)
    field(:victim_position, {:array, :float})
    field(:victim_userid, :integer)
    field(:weapon, :string)
    belongs_to(:assist, Assist)
    belongs_to(:game, Game)
    belongs_to(:attacker, PlayerGameRecord)
    belongs_to(:victim, PlayerGameRecord)

    timestamps()
  end

  def create_kill(kill, players, assist, game) do
    victim = Enum.find(players, fn player -> player.userid == kill.victim_id end)
    attacker = Enum.find(players, fn player -> player.userid == kill.attacker_id end)

    attrs =
      kill
      |> Map.from_struct()
      |> Map.put(:attacker_userid, kill.attacker_id)
      |> Map.put(:victim_userid, kill.victim_id)
      |> Map.put(
        :attacker_position,
        kill.attacker_position
      )
      |> Map.put(
        :victim_position,
        kill.victim_position
      )

    changeset(%Kill{}, attrs)
    |> put_assoc(:assist, assist)
    |> put_assoc(:game, game)
    |> put_assoc(:attacker, attacker)
    |> put_assoc(:victim, victim)
  end

  def put_game(changeset, game) do
    changeset
    |> put_assoc(:game, game)
  end

  def put_victim(changeset, victim) do
    changeset
    |> put_assoc(:victim, victim)
  end

  def put_attacker(changeset, attacker) do
    changeset
    |> put_assoc(:attacker, attacker)
  end

  def put_assist(changeset, assist) do
    changeset
    |> put_assoc(:assist, assist)
  end

  @doc false
  def changeset(kill, attrs) do
    kill
    |> cast(attrs, [
      :attacker_name,
      :attacker_userid,
      :victim_name,
      :victim_userid,
      :weapon,
      :round,
      :tick,
      :headshot,
      :victim_position,
      :attacker_position,
      :map_name,
      :time_elapsed,
      :time_left_in_round,
      :trade,
      :first_of_round
    ])
    |> validate_required([
      :attacker_name,
      :attacker_userid,
      :victim_name,
      :victim_userid,
      :weapon,
      :round,
      :tick,
      :headshot,
      :victim_position,
      :attacker_position,
      :map_name,
      :trade,
      :first_of_round
    ])
  end
end

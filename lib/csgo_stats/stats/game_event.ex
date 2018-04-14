defmodule CsgoStats.Stats.GameEvent do
  alias CsgoStats.Stats.{Game, GameEvent}
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_events" do
    field(:fields, :map)
    field(:type, :string)
    belongs_to(:game, Game)

    timestamps()
  end

  def create_game_event(event, game) do
    event =
      event
      |> Map.from_struct()
      |> Map.put(:game, game)

    changeset(%GameEvent{}, event)
    |> put_assoc(:game, event.game)
  end

  @doc false
  def changeset(game_event, attrs) do
    game_event
    |> cast(attrs, [:type, :fields])
    |> validate_required([:type, :fields])
  end
end

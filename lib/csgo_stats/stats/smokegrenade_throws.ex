defmodule CsgoStats.Stats.SmokegrenadeThrows do
  use Ecto.Schema
  import Ecto.Changeset


  schema "smokegrenade_throws" do
    field :origin, {:array, :float}
    field :player_name, :string
    field :player_userid, :integer
    field :roudn, :integer
    field :tick, :integer
    field :time_elapsed, :float
    field :time_left_in_round, :float
    field :game_id, :id
    field :player_id, :id

    timestamps()
  end

  @doc false
  def changeset(smokegrenade_throws, attrs) do
    smokegrenade_throws
    |> cast(attrs, [:player_name, :player_userid, :tick, :roudn, :origin, :time_elapsed, :time_left_in_round])
    |> validate_required([:player_name, :player_userid, :tick, :roudn, :origin, :time_elapsed, :time_left_in_round])
  end
end

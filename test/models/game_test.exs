defmodule CsgoStats.GameTest do
  use CsgoStats.ModelCase

  alias CsgoStats.Game

  @valid_attrs %{demo_name: "some demo_name", map_name: "some map_name", rounds_played: 42, team1_score: 42, team2_score: 42, tick_rate: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Game.changeset(%Game{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Game.changeset(%Game{}, @invalid_attrs)
    refute changeset.valid?
  end
end

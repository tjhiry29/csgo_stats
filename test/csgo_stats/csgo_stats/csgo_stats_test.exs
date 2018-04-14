defmodule CsgoStats.CsgoStatsTest do
  use CsgoStats.DataCase

  alias CsgoStats.CsgoStats

  describe "games" do
    alias CsgoStats.CsgoStats.Game

    @valid_attrs %{demo_name: "some demo_name", map_name: "some map_name", rounds_played: 42, team1_score: 42, team2_score: 42, tick_rate: 42}
    @update_attrs %{demo_name: "some updated demo_name", map_name: "some updated map_name", rounds_played: 43, team1_score: 43, team2_score: 43, tick_rate: 43}
    @invalid_attrs %{demo_name: nil, map_name: nil, rounds_played: nil, team1_score: nil, team2_score: nil, tick_rate: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> CsgoStats.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert CsgoStats.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert CsgoStats.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = CsgoStats.create_game(@valid_attrs)
      assert game.demo_name == "some demo_name"
      assert game.map_name == "some map_name"
      assert game.rounds_played == 42
      assert game.team1_score == 42
      assert game.team2_score == 42
      assert game.tick_rate == 42
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CsgoStats.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, game} = CsgoStats.update_game(game, @update_attrs)
      assert %Game{} = game
      assert game.demo_name == "some updated demo_name"
      assert game.map_name == "some updated map_name"
      assert game.rounds_played == 43
      assert game.team1_score == 43
      assert game.team2_score == 43
      assert game.tick_rate == 43
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = CsgoStats.update_game(game, @invalid_attrs)
      assert game == CsgoStats.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = CsgoStats.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> CsgoStats.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = CsgoStats.change_game(game)
    end
  end
end

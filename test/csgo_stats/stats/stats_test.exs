defmodule CsgoStats.StatsTest do
  use CsgoStats.DataCase

  alias CsgoStats.Stats

  describe "games" do
    alias CsgoStats.Stats.Game

    @valid_attrs %{demo_name: "some demo_name", map_name: "some map_name", rounds_played: 42, team1_score: 42, team2_score: 42, tick_rate: 42}
    @update_attrs %{demo_name: "some updated demo_name", map_name: "some updated map_name", rounds_played: 43, team1_score: 43, team2_score: 43, tick_rate: 43}
    @invalid_attrs %{demo_name: nil, map_name: nil, rounds_played: nil, team1_score: nil, team2_score: nil, tick_rate: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stats.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Stats.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Stats.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Stats.create_game(@valid_attrs)
      assert game.demo_name == "some demo_name"
      assert game.map_name == "some map_name"
      assert game.rounds_played == 42
      assert game.team1_score == 42
      assert game.team2_score == 42
      assert game.tick_rate == 42
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stats.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, game} = Stats.update_game(game, @update_attrs)
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
      assert {:error, %Ecto.Changeset{}} = Stats.update_game(game, @invalid_attrs)
      assert game == Stats.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Stats.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Stats.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Stats.change_game(game)
    end
  end

  describe "teams" do
    alias CsgoStats.Stats.Team

    @valid_attrs %{bomb_defusal_ids: [], bomb_plant_ids: [], round_loss_ids: [], round_win_ids: [], rounds_lost: 42, rounds_won: 42, teamnum: 42}
    @update_attrs %{bomb_defusal_ids: [], bomb_plant_ids: [], round_loss_ids: [], round_win_ids: [], rounds_lost: 43, rounds_won: 43, teamnum: 43}
    @invalid_attrs %{bomb_defusal_ids: nil, bomb_plant_ids: nil, round_loss_ids: nil, round_win_ids: nil, rounds_lost: nil, rounds_won: nil, teamnum: nil}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stats.create_team()

      team
    end

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Stats.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Stats.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Stats.create_team(@valid_attrs)
      assert team.bomb_defusal_ids == []
      assert team.bomb_plant_ids == []
      assert team.round_loss_ids == []
      assert team.round_win_ids == []
      assert team.rounds_lost == 42
      assert team.rounds_won == 42
      assert team.teamnum == 42
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stats.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      assert {:ok, team} = Stats.update_team(team, @update_attrs)
      assert %Team{} = team
      assert team.bomb_defusal_ids == []
      assert team.bomb_plant_ids == []
      assert team.round_loss_ids == []
      assert team.round_win_ids == []
      assert team.rounds_lost == 43
      assert team.rounds_won == 43
      assert team.teamnum == 43
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Stats.update_team(team, @invalid_attrs)
      assert team == Stats.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Stats.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Stats.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Stats.change_team(team)
    end
  end

  describe "players" do
    alias CsgoStats.Stats.Player

    @valid_attrs %{adr: 120.5, assist_count: 42, death_count: 42, deaths_traded: 42, first_deaths: 42, first_kills: 42, headshot_count: 42, kast: 120.5, kill_count: 42, name: "some name", rounds_played: 42, teamnum: 42, trade_kills: 42, userid: 42, xuid: 42}
    @update_attrs %{adr: 456.7, assist_count: 43, death_count: 43, deaths_traded: 43, first_deaths: 43, first_kills: 43, headshot_count: 43, kast: 456.7, kill_count: 43, name: "some updated name", rounds_played: 43, teamnum: 43, trade_kills: 43, userid: 43, xuid: 43}
    @invalid_attrs %{adr: nil, assist_count: nil, death_count: nil, deaths_traded: nil, first_deaths: nil, first_kills: nil, headshot_count: nil, kast: nil, kill_count: nil, name: nil, rounds_played: nil, teamnum: nil, trade_kills: nil, userid: nil, xuid: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Stats.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Stats.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Stats.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      assert {:ok, %Player{} = player} = Stats.create_player(@valid_attrs)
      assert player.adr == 120.5
      assert player.assist_count == 42
      assert player.death_count == 42
      assert player.deaths_traded == 42
      assert player.first_deaths == 42
      assert player.first_kills == 42
      assert player.headshot_count == 42
      assert player.kast == 120.5
      assert player.kill_count == 42
      assert player.name == "some name"
      assert player.rounds_played == 42
      assert player.teamnum == 42
      assert player.trade_kills == 42
      assert player.userid == 42
      assert player.xuid == 42
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stats.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, player} = Stats.update_player(player, @update_attrs)
      assert %Player{} = player
      assert player.adr == 456.7
      assert player.assist_count == 43
      assert player.death_count == 43
      assert player.deaths_traded == 43
      assert player.first_deaths == 43
      assert player.first_kills == 43
      assert player.headshot_count == 43
      assert player.kast == 456.7
      assert player.kill_count == 43
      assert player.name == "some updated name"
      assert player.rounds_played == 43
      assert player.teamnum == 43
      assert player.trade_kills == 43
      assert player.userid == 43
      assert player.xuid == 43
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Stats.update_player(player, @invalid_attrs)
      assert player == Stats.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Stats.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Stats.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Stats.change_player(player)
    end
  end
end

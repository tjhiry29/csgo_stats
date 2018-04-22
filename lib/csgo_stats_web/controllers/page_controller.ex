defmodule CsgoStatsWeb.PageController do
  use CsgoStatsWeb, :controller
  alias CsgoStats.{Repo, Stats}
  require DemoInfoGo

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def dump(conn, %{"file_name" => filename}) do
    Exq.subscribe(Exq, "demo_parsing")

    if !File.exists?("deps/demo_info_go/results/#{filename}.dump") do
      {:ok, jid} =
        Exq.enqueue(Exq, "demo_parsing", DemoParserWorker, [filename, "deps/demo_info_go/"])

      render(conn, "parse_start.json", message: "Demo is being dumped", pid: jid)
    else
      render(conn, "parse_start.json", message: "Demo has already been dumped", pid: nil)
    end
  end

  def results(conn, %{"file_name" => filename}) do
    game = Stats.get_game_by_demo_name(filename)

    if game do
      results = DemoInfoGo.parse_results("#{filename}", ["-gameevents"], "deps/demo_info_go/")
      [{player_infos, teams}] = results
      render(conn, "game_test.json", player_infos: player_infos, teams: teams, game: game)
    else
      results = DemoInfoGo.parse_results("#{filename}", ["-gameevents"], "deps/demo_info_go/")

      if length(results) == 0 do
        render(conn, "parse_start.json", message: "Demo has not been parsed", pid: nil)
      else
        [{player_infos, teams}] = results
        results = %{player_infos: player_infos, teams: teams}
        {:ok, game} = Stats.create_game(teams, filename)
        first_team = Enum.at(teams, 0)
        second_team = Enum.at(teams, 1)

        game_events = [
          first_team.round_wins
          | [first_team.bomb_defusals | [first_team.bomb_plants | first_team.round_losses]]
        ]

        game_events = [second_team.bomb_defusals | [second_team.bomb_plants | game_events]]
        game_events = List.flatten(game_events)
        {:ok, game_events} = Stats.create_game_events(game_events, game)
        {:ok, team1} = Stats.create_team_from_game(game, first_team)
        {:ok, team2} = Stats.create_team_from_game(game, second_team)

        {:ok, first_players} =
          Stats.create_players_from_team(first_team.players, game, team1, player_infos)

        {:ok, second_players} =
          Stats.create_players_from_team(second_team.players, game, team2, player_infos)

        players = first_team.players ++ second_team.players
        kills = Enum.flat_map(players, fn player -> player.kills end)

        get_grenade_throws = fn players, filter_method ->
          Enum.flat_map(players, fn player ->
            Enum.filter(player.grenade_throws, &filter_method.(&1))
          end)
        end

        smokegrenade_throws =
          get_grenade_throws.(players, &DemoInfoGo.SmokegrenadeThrow.is_smokegrenade_throw(&1))

        hegrenade_throws =
          get_grenade_throws.(players, &DemoInfoGo.HegrenadeThrow.is_hegrenade_throw(&1))

        flashbang_throws =
          get_grenade_throws.(players, &DemoInfoGo.FlashbangThrow.is_flashbang_throw(&1))

        molotov_throws =
          get_grenade_throws.(players, &DemoInfoGo.MolotovThrow.is_molotov_throw(&1))

        game_players = Enum.map(first_players ++ second_players, fn {:ok, player} -> player end)

        {:ok, _} = Stats.create_kills_and_assists(kills, game_players, game)
        {:ok, _} = Stats.create_smokegrenade_throws(smokegrenade_throws, game_players, game)
        {:ok, _} = Stats.create_hegrenade_throws(hegrenade_throws, game_players, game)
        {:ok, _} = Stats.create_molotov_throws(molotov_throws, game_players, game)
        {:ok, _} = Stats.create_flashbang_throws(flashbang_throws, game_players, game)

        render(conn, "test.json", results)
      end
    end
  end
end

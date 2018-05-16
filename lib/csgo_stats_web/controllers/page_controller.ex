defmodule CsgoStatsWeb.PageController do
  use CsgoStatsWeb, :controller
  alias CsgoStats.Stats
  require DemoInfoGo

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # TODO: Re-implement EXQ or a different job manager.
  # def dump(conn, %{"file_name" => filename}) do
  #   Exq.subscribe(Exq, "demo_parsing")

  #   if !File.exists?("deps/demo_info_go/results/#{filename}.dump") do
  #     {:ok, jid} =
  #       Exq.enqueue(Exq, "demo_parsing", DemoParserWorker, [filename, "deps/demo_info_go/"])

  #     render(conn, "parse_start.json", message: "Demo is being dumped", pid: jid)
  #   else
  #     render(conn, "parse_start.json", message: "Demo has already been dumped", pid: nil)
  #   end
  # end

  # def results(conn, %{"file_name" => filename}) do
  #   game = Stats.get_game_by_demo_name(filename)

  #   if game do
  #     results = DemoInfoGo.parse_results("#{filename}", ["-gameevents"], "deps/demo_info_go/")
  #     [{player_infos, teams}] = results
  #     render(conn, "game_test.json", player_infos: player_infos, teams: teams, game: game)
  #   else
  #     results = DemoInfoGo.parse_results("#{filename}", ["-gameevents"], "deps/demo_info_go/")

  #     if length(results) == 0 do
  #       render(conn, "parse_start.json", message: "Demo has not been parsed", pid: nil)
  #     else
  #       [{player_infos, teams}] = results
  #       results = %{player_infos: player_infos, teams: teams}
  #       Stats.create_game_from_demo(teams, filename, player_infos)

  #       render(conn, "test.json", results)
  #     end
  #   end
  # end
end

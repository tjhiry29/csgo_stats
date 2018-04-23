defmodule CsgoStatsWeb.GameController do
  use CsgoStatsWeb, :controller

  alias CsgoStats.Stats

  def index(conn, _params) do
    games = Stats.list_games()
    render(conn, "index.html", games: games)
  end

  def show(conn, %{"id" => id}) do
    game =
      Stats.get_game!(id)
      |> Stats.get_game_player_records()

    players_by_team =
      game.player_game_records
      |> Enum.sort_by(fn p -> p.kill_count end, &>=/2)
      |> Enum.group_by(fn p -> p.teamnum end)

    render(conn, "show.html", game: game, players_by_team: players_by_team)
  end
end

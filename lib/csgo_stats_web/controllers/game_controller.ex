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
      |> Stats.get_game_kills()

    kills_by_player =
      game.kills
      |> Enum.group_by(fn k -> k.attacker_id end)

    players_by_team =
      game.player_game_records
      |> Enum.sort_by(fn p -> p.kill_count end, &>=/2)
      |> Enum.group_by(fn p -> p.teamnum end)

    all_players =
      players_by_team
      |> Enum.flat_map(fn {_, players} -> players end)

    render(
      conn,
      "show.html",
      game: game,
      all_players: all_players,
      players_by_team: players_by_team,
      kills_by_player: kills_by_player
    )
  end

  def duels(conn, %{"id" => id}) do
    game =
      Stats.get_game!(id)
      |> Stats.get_game_player_records()
      |> Stats.get_game_kills()

    kills_by_player =
      game.kills
      |> Enum.group_by(fn k -> k.attacker_name end)

    render(
      conn,
      "show.html",
      game: game,
      players: game.player_game_records,
      kills_by_player: kills_by_player
    )
  end
end

defmodule CsgoStatsWeb.PlayerController do
  use CsgoStatsWeb, :controller

  alias CsgoStats.Stats
  alias CsgoStats.Stats.Player

  def index(conn, _params) do
    players = Stats.list_players()
    render(conn, "index.html", players: players)
  end

  def show(conn, %{"id" => id}) do
    player =
      Stats.get_player!(id)
      |> Stats.get_player_game_records()

    render(conn, "show.html", player: player)
  end
end

defmodule CsgoStatsWeb.GameController do
  use CsgoStatsWeb, :controller

  alias CsgoStats.Stats
  alias CsgoStats.Stats.Game

  def index(conn, _params) do
    games = Stats.list_games()
    render(conn, "index.html", games: games)
  end

  def new(conn, _params) do
    changeset = Stats.change_game(%Game{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"game" => game_params}) do
    case Stats.create_game(game_params) do
      {:ok, game} ->
        conn
        |> put_flash(:info, "Game created successfully.")
        |> redirect(to: game_path(conn, :show, game))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
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

  def edit(conn, %{"id" => id}) do
    game = Stats.get_game!(id)
    changeset = Stats.change_game(game)
    render(conn, "edit.html", game: game, changeset: changeset)
  end

  def update(conn, %{"id" => id, "game" => game_params}) do
    game = Stats.get_game!(id)

    case Stats.update_game(game, game_params) do
      {:ok, game} ->
        conn
        |> put_flash(:info, "Game updated successfully.")
        |> redirect(to: game_path(conn, :show, game))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", game: game, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    game = Stats.get_game!(id)
    {:ok, _game} = Stats.delete_game(game)

    conn
    |> put_flash(:info, "Game deleted successfully.")
    |> redirect(to: game_path(conn, :index))
  end
end

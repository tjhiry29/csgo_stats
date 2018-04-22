defmodule CsgoStatsWeb.PlayerController do
  use CsgoStatsWeb, :controller

  alias CsgoStats.Stats
  alias CsgoStats.Stats.Player

  def index(conn, _params) do
    players = Stats.list_players()
    render(conn, "index.html", players: players)
  end

  def new(conn, _params) do
    changeset = Stats.change_player(%Player{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"player" => player_params}) do
    case Stats.create_player(player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player created successfully.")
        |> redirect(to: player_path(conn, :show, player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    player =
      Stats.get_player!(id)
      |> Stats.get_player_game_records()

    render(conn, "show.html", player: player)
  end

  def edit(conn, %{"id" => id}) do
    player = Stats.get_player!(id)
    changeset = Stats.change_player(player)
    render(conn, "edit.html", player: player, changeset: changeset)
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    player = Stats.get_player!(id)

    case Stats.update_player(player, player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player updated successfully.")
        |> redirect(to: player_path(conn, :show, player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", player: player, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    player = Stats.get_player!(id)
    {:ok, _player} = Stats.delete_player(player)

    conn
    |> put_flash(:info, "Player deleted successfully.")
    |> redirect(to: player_path(conn, :index))
  end
end

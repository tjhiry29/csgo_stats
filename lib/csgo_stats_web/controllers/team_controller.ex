defmodule CsgoStatsWeb.TeamController do
  use CsgoStatsWeb, :controller

  alias CsgoStats.Stats
  alias CsgoStats.Stats.Team

  def index(conn, _params) do
    teams = Stats.list_teams()
    render(conn, "index.html", teams: teams)
  end

  def new(conn, _params) do
    changeset = Stats.change_team(%Team{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"team" => team_params}) do
    case Stats.create_team(team_params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team created successfully.")
        |> redirect(to: team_path(conn, :show, team))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    team = Stats.get_team!(id)
    render(conn, "show.html", team: team)
  end

  def edit(conn, %{"id" => id}) do
    team = Stats.get_team!(id)
    changeset = Stats.change_team(team)
    render(conn, "edit.html", team: team, changeset: changeset)
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team = Stats.get_team!(id)

    case Stats.update_team(team, team_params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Team updated successfully.")
        |> redirect(to: team_path(conn, :show, team))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", team: team, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    team = Stats.get_team!(id)
    {:ok, _team} = Stats.delete_team(team)

    conn
    |> put_flash(:info, "Team deleted successfully.")
    |> redirect(to: team_path(conn, :index))
  end
end

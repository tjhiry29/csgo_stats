defmodule CsgoStatsWeb.TeamControllerTest do
  use CsgoStatsWeb.ConnCase

  alias CsgoStats.Stats

  @create_attrs %{bomb_defusal_ids: [], bomb_plant_ids: [], round_loss_ids: [], round_win_ids: [], rounds_lost: 42, rounds_won: 42, teamnum: 42}
  @update_attrs %{bomb_defusal_ids: [], bomb_plant_ids: [], round_loss_ids: [], round_win_ids: [], rounds_lost: 43, rounds_won: 43, teamnum: 43}
  @invalid_attrs %{bomb_defusal_ids: nil, bomb_plant_ids: nil, round_loss_ids: nil, round_win_ids: nil, rounds_lost: nil, rounds_won: nil, teamnum: nil}

  def fixture(:team) do
    {:ok, team} = Stats.create_team(@create_attrs)
    team
  end

  describe "index" do
    test "lists all teams", %{conn: conn} do
      conn = get conn, team_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Teams"
    end
  end

  describe "new team" do
    test "renders form", %{conn: conn} do
      conn = get conn, team_path(conn, :new)
      assert html_response(conn, 200) =~ "New Team"
    end
  end

  describe "create team" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, team_path(conn, :create), team: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == team_path(conn, :show, id)

      conn = get conn, team_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Team"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, team_path(conn, :create), team: @invalid_attrs
      assert html_response(conn, 200) =~ "New Team"
    end
  end

  describe "edit team" do
    setup [:create_team]

    test "renders form for editing chosen team", %{conn: conn, team: team} do
      conn = get conn, team_path(conn, :edit, team)
      assert html_response(conn, 200) =~ "Edit Team"
    end
  end

  describe "update team" do
    setup [:create_team]

    test "redirects when data is valid", %{conn: conn, team: team} do
      conn = put conn, team_path(conn, :update, team), team: @update_attrs
      assert redirected_to(conn) == team_path(conn, :show, team)

      conn = get conn, team_path(conn, :show, team)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, team: team} do
      conn = put conn, team_path(conn, :update, team), team: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Team"
    end
  end

  describe "delete team" do
    setup [:create_team]

    test "deletes chosen team", %{conn: conn, team: team} do
      conn = delete conn, team_path(conn, :delete, team)
      assert redirected_to(conn) == team_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, team_path(conn, :show, team)
      end
    end
  end

  defp create_team(_) do
    team = fixture(:team)
    {:ok, team: team}
  end
end

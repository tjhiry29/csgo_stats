defmodule CsgoStatsWeb.PlayerControllerTest do
  use CsgoStatsWeb.ConnCase

  alias CsgoStats.Stats

  @create_attrs %{
    adr: 120.5,
    assist_count: 42,
    death_count: 42,
    deaths_traded: 42,
    first_deaths: 42,
    first_kills: 42,
    headshot_count: 42,
    kast: 120.5,
    kill_count: 42,
    name: "some name",
    rounds_played: 42,
    teamnum: 42,
    trade_kills: 42,
    userid: 42,
    xuid: 42
  }
  @update_attrs %{
    adr: 456.7,
    assist_count: 43,
    death_count: 43,
    deaths_traded: 43,
    first_deaths: 43,
    first_kills: 43,
    headshot_count: 43,
    kast: 456.7,
    kill_count: 43,
    name: "some updated name",
    rounds_played: 43,
    teamnum: 43,
    trade_kills: 43,
    userid: 43,
    xuid: 43
  }
  @invalid_attrs %{
    adr: nil,
    assist_count: nil,
    death_count: nil,
    deaths_traded: nil,
    first_deaths: nil,
    first_kills: nil,
    headshot_count: nil,
    kast: nil,
    kill_count: nil,
    name: nil,
    rounds_played: nil,
    teamnum: nil,
    trade_kills: nil,
    userid: nil,
    xuid: nil
  }

  def fixture(:player) do
    {:ok, player} = Stats.create_player(@create_attrs)
    player
  end

  describe "index" do
    test "lists all players", %{conn: conn} do
      conn = get(conn, Routes.player_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Players"
    end
  end

  describe "new player" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.player_path(conn, :new))
      assert html_response(conn, 200) =~ "New Player"
    end
  end

  describe "create player" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, Routes.player_path(conn, :create), player: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.player_path(conn, :show, id)

      conn = get(conn, Routes.player_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Player"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.player_path(conn, :create), player: @invalid_attrs
      assert html_response(conn, 200) =~ "New Player"
    end
  end

  describe "edit player" do
    setup [:create_player]

    test "renders form for editing chosen player", %{conn: conn, player: player} do
      conn = get(conn, Routes.player_path(conn, :edit, player))
      assert html_response(conn, 200) =~ "Edit Player"
    end
  end

  describe "update player" do
    setup [:create_player]

    test "redirects when data is valid", %{conn: conn, player: player} do
      conn = put conn, Routes.player_path(conn, :update, player), player: @update_attrs
      assert redirected_to(conn) == Routes.player_path(conn, :show, player)

      conn = get(conn, Routes.player_path(conn, :show, player))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, player: player} do
      conn = put conn, Routes.player_path(conn, :update, player), player: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Player"
    end
  end

  describe "delete player" do
    setup [:create_player]

    test "deletes chosen player", %{conn: conn, player: player} do
      conn = delete(conn, Routes.player_path(conn, :delete, player))
      assert redirected_to(conn) == Routes.player_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.player_path(conn, :show, player))
      end
    end
  end

  defp create_player(_) do
    player = fixture(:player)
    {:ok, player: player}
  end
end

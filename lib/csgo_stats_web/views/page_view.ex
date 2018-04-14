defmodule CsgoStatsWeb.PageView do
  use CsgoStatsWeb, :view

  def render("parse_start.json", %{message: message, pid: pid}) do
    %{
      message: message,
      pid: pid
    }
  end

  def render("game_test.json", %{teams: teams, player_infos: player_infos, game: game}) do
    %{
      teams: teams,
      player_infos: player_infos,
      game: game
    }
  end

  def render("test.json", %{teams: teams, player_infos: player_infos}) do
    %{
      teams: teams,
      player_infos: player_infos
    }
  end
end

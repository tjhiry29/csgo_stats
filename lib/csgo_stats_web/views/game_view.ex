defmodule CsgoStatsWeb.GameView do
  use CsgoStatsWeb, :view

  def title(_template, _assigns) do
    "CSGO GAME STATS"
  end

  def get_kills_by_player(kills) do
    kills |> Enum.group_by(fn k -> k.attacker_id end)
  end

  def get_round_breakdown(kills) do
    kills
    |> Enum.sort_by(fn k -> k.tick end)
    |> Enum.group_by(fn k -> k.round end)
    |> Enum.sort_by(fn {roundnum, _kills} -> roundnum end)
  end

  def format_kill(kill = %CsgoStats.Stats.Kill{}) do
    "#{kill.attacker_name} [#{kill.weapon}#{headshot_string(kill)}] #{kill.victim_name} @ #{
      Float.round(kill.time_elapsed || 0.0, 1)
    }s into the round"
  end

  def headshot_string(kill = %CsgoStats.Stats.Kill{}) do
    if kill.headshot do
      " HS"
    else
      ""
    end
  end

  def date_inserted(game) do
    game.inserted_at
    |> NaiveDateTime.to_date()
    |> Date.to_iso8601()
  end

  def duel_record(player, kills_by_player, all_players) do
    player_kills = Map.get(kills_by_player, player.id)

    all_players
    |> Enum.map(fn p ->
      player_kills_against = get_player_kills_against(player_kills, p.id)

      deaths =
        Map.get(kills_by_player, p.id)
        |> get_player_kills_against(player.id)

      {player_kills_against, deaths, p.name}
    end)
  end

  def short_duel_record(kills, deaths, player_name, victim_name) do
    "#{player_name} #{kills}-#{deaths} #{victim_name}"
  end

  def print_duel_record(kills, deaths) do
    if kills > 0 || deaths > 0 do
      "#{kills} (#{Float.round(kills / (kills + deaths) * 100, 2)}%)"
    else
      "#{kills}"
    end
  end

  def short_player_name(str) do
    cond do
      length(String.graphemes(str)) > 9 -> "#{String.slice(str, 0..9)}.."
      true -> str
    end
  end

  defp get_player_kills_against(player_kills, victim_id) do
    if !player_kills do
      0
    else
      player_kills
      |> Enum.filter(fn k ->
        k.victim_id == victim_id
      end)
      |> length()
    end
  end
end

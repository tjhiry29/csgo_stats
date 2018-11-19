defmodule CsgoStatsWeb.TestChannel do
  use Phoenix.Channel
  alias CsgoStats.Repo
  alias CsgoStats.Stats
  require Logger

  def join("test:test", _message, socket) do
    {:ok, socket}
  end

  def handle_in("test:info", msg, socket) do
    # IO.inspect(Map.get(msg, "info") |> Map.get("playerRoundRecords"))
    # IO.inspect(Map.get(msg, "info") |> Map.get("mapName"))
    # IO.inspect(Map.get(msg, "info") |> Map.get("tickRate"))
    process_demo_info(Map.get(msg, "info"))
    {:noreply, assign(socket, :info, Map.get(msg, "info"))}
  end

  defp process_demo_info(info) do
    teams = info |> Map.get("teams")
    tick_rate = info |> Map.get("tick_rate")
    map_name = info |> Map.get("map_name")
    kills = info |> Map.get("kills")
    grenade_throws = info |> Map.get("grenade_throws")
    player_info = info |> Map.get("player_info")
    round_wins = info |> Map.get("round_wins")
    player_round_records = info |> Map.get("player_round_records")
    demo_name = info |> Map.get("demo_name")

    Repo.transaction(fn ->
      game_record = create_game(demo_name, teams, map_name, tick_rate)
      # |> Repo.insert()

      # player_records =
      #   player_info
      #   |> Enum.filter(fn p -> Map.get(p, "fakePlayer") != true end)
      #   |> Enum.map(fn p ->
      #     find_or_create_player(p)
      #   end)

      # team_game_records = create_team_game_records(teams, game_record)

      # player_game_records =
      #   create_player_game_records(
      #     player_round_records,
      #     team_game_records,
      #     teams,
      #     game_record,
      #     player_records
      #   )
    end)
  end

  defp create_game(demo_name, teams, map_name, tick_rate) do
    team1_score = teams |> Enum.at(2) |> Map.get("score")
    team2_score = teams |> Enum.at(3) |> Map.get("score")
    rounds_played = team1_score + team2_score

    Stats.Game.changeset(%Stats.Game{}, %{
      demo_name: demo_name,
      map_name: map_name,
      tick_rate: tick_rate,
      team1_score: team1_score,
      team2_score: team2_score,
      rounds_played: rounds_played
    })
  end

  defp create_team_game_records(teams, game_record) do
    team1_score = teams |> Enum.at(2) |> Map.get("score")
    team2_score = teams |> Enum.at(3) |> Map.get("score")

    team1 =
      Stats.TeamGameRecord.changeset(%Stats.TeamGameRecord{}, %{
        teamnum: 2,
        rounds_won: team1_score,
        rounds_lost: team2_score
      })
      |> Stats.TeamGameRecord.put_game(game_record)
      |> Repo.insert()

    team2 =
      Stats.TeamGameRecord.changeset(%Stats.TeamGameRecord{}, %{
        teamnum: 3,
        rounds_won: team2_score,
        rounds_lost: team1_score
      })
      |> Stats.TeamGameRecord.put_game(game_record)
      |> Repo.insert()

    [team1, team2]
  end

  defp find_or_create_player(player_info) do
    changeset = create_player(player_info)

    case Repo.get_by(Player, %{
           xuid_lo: Map.get(player_info, "xuid_lo"),
           xuid_hi: Map.get(player_info, "xuid_hi")
         }) do
      nil -> Repo.insert(changeset)
      new_player -> {:ok, new_player}
    end
  end

  defp create_player(player_info) do
    Stats.Player.changeset(%Stats.Player{}, %{
      name: Map.get(player_info, "name"),
      friends_id: Map.get(player_info, "friends_id") |> String.to_integer(),
      xuid_lo: Map.get(player_info, "xuid_lo"),
      xuid_hi: Map.get(player_info, "xuid_hi"),
      guid: Map.get(player_info, "guid")
    })
  end

  defp create_player_game_records(
         player_round_records,
         team_game_records,
         teams,
         game_record,
         player_records
       ) do
  end

  defp create_kills(kills_info, players) do
  end

  defp create_kill(kill_info, players) do
  end

  defp create_assist(kill, players) do
  end
end

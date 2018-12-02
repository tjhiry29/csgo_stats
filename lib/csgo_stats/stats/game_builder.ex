defmodule CsgoStats.Stats.GameBuilder do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias CsgoStats.{Stats, Repo}

  def process_demo_info(info) do
    teams = info |> Map.get("teams")
    tick_rate = info |> Map.get("tick_rate")
    map_name = info |> Map.get("map_name")
    kills_info = info |> Map.get("kills")
    grenade_throws_info = info |> Map.get("grenade_throws")
    player_info = info |> Map.get("player_info")
    # round_wins = info |> Map.get("round_wins")
    player_round_records_info = info |> Map.get("player_round_records")
    demo_name = info |> Map.get("demo_name")
    player_game_record_info = info |> Map.get("players")

    Repo.transaction(fn ->
      {:ok, game_record} =
        create_game(demo_name, teams, map_name, tick_rate)
        |> Repo.insert()

      player_records =
        player_info
        |> Enum.filter(fn p -> Map.get(p, "fakeplayer") != true end)
        |> Enum.map(fn p ->
          {:ok, res} = find_or_create_player(p)
          res
        end)

      team_game_records = create_team_game_records(teams, game_record)

      player_game_records =
        create_player_game_records(
          team_game_records,
          game_record,
          player_records,
          player_game_record_info
        )

      player_round_records =
        create_player_round_records(
          player_round_records_info,
          player_records,
          player_game_records,
          team_game_records,
          game_record
        )

      kills = create_kills(kills_info, player_game_records, game_record)

      grenade_throws =
        Enum.map(grenade_throws_info, fn gt ->
          create_grenade_throw(gt, player_game_records, game_record)
        end)
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

    {:ok, team1} =
      Stats.TeamGameRecord.changeset(%Stats.TeamGameRecord{}, %{
        teamnum: 2,
        rounds_won: team1_score,
        rounds_lost: team2_score
      })
      |> Stats.TeamGameRecord.put_game(game_record)
      |> Repo.insert()

    {:ok, team2} =
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

    case Repo.get_by(Stats.Player,
           xuid: Map.get(player_info, "xuid") |> String.to_integer()
         ) do
      nil -> Repo.insert(changeset)
      new_player -> {:ok, new_player}
    end
  end

  defp create_player(player_info) do
    Stats.Player.changeset(%Stats.Player{}, %{
      name: Map.get(player_info, "name"),
      friends_id: Map.get(player_info, "friends_id"),
      xuid: Map.get(player_info, "xuid") |> String.to_integer(),
      guid: Map.get(player_info, "guid")
    })
  end

  defp create_player_game_records(
         team_game_records,
         game_record,
         player_records,
         player_infos
       ) do
    Enum.map(player_infos, fn p ->
      {_, info} = p

      {:ok, record} =
        %Stats.PlayerGameRecord{}
        |> Stats.PlayerGameRecord.changeset(info)
        |> Stats.PlayerGameRecord.put_game(game_record)
        |> Stats.PlayerGameRecord.put_team_game_record(
          Enum.at(team_game_records, Map.get(info, "teamnum") - 2)
        )
        |> Stats.PlayerGameRecord.put_player(
          Enum.find(player_records, fn record ->
            record.xuid == Map.get(info, "xuid") |> String.to_integer()
          end)
        )
        |> Repo.insert()

      record
    end)
  end

  defp create_player_round_records(
         player_round_records_info,
         player_records,
         player_game_records,
         team_game_records,
         game_record
       ) do
    player_round_records_info
    |> Enum.flat_map(fn round_records ->
      Enum.map(round_records, fn p ->
        {:ok, result} =
          %Stats.PlayerRoundRecord{}
          |> Stats.PlayerRoundRecord.changeset(p)
          |> Stats.PlayerRoundRecord.put_player(
            Enum.find(player_records, fn player -> player.name == Map.get(p, "name") end)
          )
          |> Stats.PlayerRoundRecord.put_game(game_record)
          |> Stats.PlayerRoundRecord.put_team_game_record(
            Enum.at(team_game_records, Map.get(p, "teamnum") - 2)
          )
          |> Stats.PlayerRoundRecord.put_player_game_record(
            Enum.find(player_game_records, fn player -> player.userid == Map.get(p, "userid") end)
          )
          |> Repo.insert()

        result
      end)
    end)
  end

  defp create_kills(kills_info, player_game_records, game) do
    Enum.map(kills_info, fn kill_info ->
      create_kill(kill_info, player_game_records, game)
    end)
  end

  defp create_assist(kill_info, player_game_records, game) do
    {:ok, assist} =
      %Stats.Assist{}
      |> Stats.Assist.changeset(kill_info)
      |> Stats.Assist.put_victim(
        Enum.find(player_game_records, fn player ->
          player.userid == Map.get(kill_info, "victim_userid")
        end)
      )
      |> Stats.Assist.put_assister(
        Enum.find(player_game_records, fn player ->
          player.userid == Map.get(kill_info, "assister_userid")
        end)
      )
      |> Stats.Assist.put_game(game)
      |> Repo.insert()

    assist
  end

  defp create_kill(kill_info, player_game_records, game) do
    changeset =
      %Stats.Kill{}
      |> Stats.Kill.changeset(kill_info)
      |> Stats.Kill.put_victim(
        Enum.find(player_game_records, fn player ->
          player.userid == Map.get(kill_info, "victim_userid")
        end)
      )
      |> Stats.Kill.put_attacker(
        Enum.find(player_game_records, fn player ->
          player.userid == Map.get(kill_info, "attacker_userid")
        end)
      )
      |> Stats.Kill.put_game(game)

    {:ok, kill} =
      case Map.get(kill_info, "assister_name") do
        "unnamed" ->
          changeset
          |> Repo.insert()

        _name ->
          changeset
          |> Stats.Kill.put_assist(create_assist(kill_info, player_game_records, game))
          |> Repo.insert()
      end

    kill
  end

  defp create_grenade_throw(grenade_throw, player_game_records, game) do
    player =
      Enum.find(player_game_records, fn p ->
        Map.get(grenade_throw, "player_userid") == p.userid
      end)

    {:ok, grenade_throw} =
      case Map.get(grenade_throw, "weapon") do
        "weapon_hegrenade" ->
          Stats.HegrenadeThrow.changeset(%Stats.HegrenadeThrow{}, grenade_throw)

        "weapon_molotov" ->
          Stats.MolotovThrow.changeset(%Stats.MolotovThrow{}, grenade_throw)

        "weapon_incgrenade" ->
          Stats.MolotovThrow.changeset(%Stats.MolotovThrow{}, grenade_throw)

        "weapon_flashbang" ->
          Stats.FlashbangThrow.changeset(%Stats.FlashbangThrow{}, grenade_throw)

        "weapon_smokegrenade" ->
          Stats.SmokegrenadeThrow.changeset(%Stats.SmokegrenadeThrow{}, grenade_throw)
      end
      |> put_assoc(:game, game)
      |> put_assoc(:player_game_record, player)
      |> Repo.insert()

    grenade_throw
  end
end

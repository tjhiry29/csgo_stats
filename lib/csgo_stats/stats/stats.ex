defmodule CsgoStats.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias CsgoStats.Repo

  def batch_insert(changesets) do
    result =
      changesets
      |> Enum.with_index()
      |> Enum.reduce(Ecto.Multi.new(), fn {changeset, index}, multi ->
        Ecto.Multi.insert(multi, Integer.to_string(index), changeset)
      end)
      |> Repo.transaction()

    case result do
      {:ok, models} ->
        models =
          models
          |> Enum.map(fn {_, model} ->
            model
          end)

        {:ok, models}

      {:error, _changeset} ->
        {:error, []}
    end
  end

  alias CsgoStats.Stats.Game

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  def get_game_by_demo_name(demo_name), do: Repo.get_by(Game, demo_name: demo_name)

  def get_game_player_records(game) do
    game
    |> Repo.preload(:player_game_records)
  end

  def get_game_kills(game) do
    game
    |> Repo.preload(:kills)
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(teams, filename) do
    %Game{}
    |> Game.create_game({teams, filename})
    |> Repo.insert()
  end

  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{source: %Game{}}

  """
  def change_game(%Game{} = game) do
    Game.changeset(game, %{})
  end

  alias CsgoStats.Stats.TeamGameRecord

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%TeamGameRecord{}, ...]

  """
  def list_teams do
    Repo.all(TeamGameRecord)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the TeamGameRecord does not exist.

  ## Examples

      iex> get_team!(123)
      %TeamGameRecord{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(TeamGameRecord, id)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %TeamGameRecord{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %TeamGameRecord{}
    |> TeamGameRecord.changeset(attrs)
    |> Repo.insert()
  end

  def create_team_game_record(game = %Game{}, team) do
    %TeamGameRecord{}
    |> TeamGameRecord.create_team_game_record(game, team)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %TeamGameRecord{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%TeamGameRecord{} = team, attrs) do
    team
    |> TeamGameRecord.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TeamGameRecord.

  ## Examples

      iex> delete_team(team)
      {:ok, %TeamGameRecord{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%TeamGameRecord{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{source: %TeamGameRecord{}}

  """
  def change_team(%TeamGameRecord{} = team) do
    TeamGameRecord.changeset(team, %{})
  end

  alias CsgoStats.Stats.{Player, PlayerGameRecord}

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  def get_player_game_records(player) do
    player = player |> Repo.preload(:player_game_records)

    player_game_records =
      Enum.map(player.player_game_records, fn game_record -> Repo.preload(game_record, :game) end)

    %{player | player_game_records: player_game_records}
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  def create_or_get_player(player) do
    changeset = Player.create_player(player)

    case Repo.get_by(Player, xuid: Map.get(player, :xuid)) do
      nil -> Repo.insert(changeset)
      new_player -> {:ok, new_player}
    end
  end

  def create_players_from_team(players, game, team, player_infos) do
    players =
      players
      |> Enum.map(&Player.normalize_player(&1, player_infos))
      |> Player.filter_bots()

    Enum.map(players, fn player ->
      {:ok, new_player} = create_or_get_player(player)

      PlayerGameRecord.create_player_from_stats(player, game, team, new_player)
    end)
    |> batch_insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{source: %Player{}}

  """
  def change_player(%Player{} = player) do
    Player.changeset(player, %{})
  end

  alias CsgoStats.Stats.GameEvent

  def create_game_events(attrs, game) do
    Repo.transaction(fn ->
      Enum.map(attrs, fn event ->
        GameEvent.create_game_event(event, game)
        |> Repo.insert()
      end)
    end)
  end

  alias CsgoStats.Stats.Assist

  def create_assist(assist, players, game) do
    cond do
      assist != nil ->
        Assist.create_assist(assist, players, game)
        |> Repo.insert()

      true ->
        {:ok, nil}
    end
  end

  alias CsgoStats.Stats.Kill

  def create_kills_and_assists(kills, players, game) do
    Repo.transaction(fn ->
      Enum.map(kills, fn kill ->
        {:ok, assist} = create_assist(kill.assist, players, game)

        Kill.create_kill(kill, players, assist, game)
      end)
      |> batch_insert()
    end)
  end

  alias CsgoStats.Stats.SmokegrenadeThrow

  def create_smokegrenade_throws(smokegrenade_throws, players, game) do
    Repo.transaction(fn ->
      Enum.map(smokegrenade_throws, fn smokegrenade_throw ->
        SmokegrenadeThrow.create_smokegrenade_throw(smokegrenade_throw, players, game)
      end)
      |> batch_insert()
    end)
  end

  alias CsgoStats.Stats.HegrenadeThrow

  def create_hegrenade_throws(hegrenade_throws, players, game) do
    Repo.transaction(fn ->
      Enum.map(hegrenade_throws, fn hegrenade_throw ->
        HegrenadeThrow.create_hegrenade_throw(hegrenade_throw, players, game)
      end)
      |> batch_insert()
    end)
  end

  alias CsgoStats.Stats.MolotovThrow

  def create_molotov_throws(molotov_throws, players, game) do
    Repo.transaction(fn ->
      Enum.map(molotov_throws, fn molotov_throw ->
        MolotovThrow.create_molotov_throw(molotov_throw, players, game)
      end)
      |> batch_insert()
    end)
  end

  alias CsgoStats.Stats.FlashbangThrow

  def create_flashbang_throws(flashbang_throws, players, game) do
    Repo.transaction(fn ->
      Enum.map(flashbang_throws, fn flashbang_throw ->
        FlashbangThrow.create_flashbang_throw(flashbang_throw, players, game)
      end)
      |> batch_insert()
    end)
  end

  def create_game_from_demo(info) do
    player_info = Map.get(info, "player_info")
    tick_rate = Map.get(info, "tick_rate")
    map_name = Map.get(info, "map_name")
    player_round_records = Map.get(info, "player_round_records")
    kills = Map.get(info, "kills")
    grenade_throws = Map.get(info, "grenade_throws")
    round_wins = Map.get(info, "round_wins")
  end

  @doc """
    Creates game and associated models from the results of the DemoInfoGo module.
  """
  # TODO: refactor this whole transaction to use Multi.
  def create_game_from_demo(teams, filename, player_infos) do
    Repo.transaction(fn ->
      {:ok, game} = create_game(teams, filename)
      first_team = Enum.at(teams, 0)
      second_team = Enum.at(teams, 1)

      game_events = [
        first_team.round_wins
        | [first_team.bomb_defusals | [first_team.bomb_plants | first_team.round_losses]]
      ]

      game_events = [second_team.bomb_defusals | [second_team.bomb_plants | game_events]]
      game_events = List.flatten(game_events)
      {:ok, _game_events} = create_game_events(game_events, game)
      {:ok, team1} = create_team_game_record(game, first_team)
      {:ok, team2} = create_team_game_record(game, second_team)

      {:ok, first_players} =
        create_players_from_team(first_team.players, game, team1, player_infos)

      {:ok, second_players} =
        create_players_from_team(second_team.players, game, team2, player_infos)

      players = first_team.players ++ second_team.players
      kills = Enum.flat_map(players, fn player -> player.kills end)

      get_grenade_throws = fn players, filter_method ->
        Enum.flat_map(players, fn player ->
          Enum.filter(player.grenade_throws, &filter_method.(&1))
        end)
      end

      # smokegrenade_throws =
      #   get_grenade_throws.(players, &DemoInfoGo.SmokegrenadeThrow.is_smokegrenade_throw(&1))

      # hegrenade_throws =
      #   get_grenade_throws.(players, &DemoInfoGo.HegrenadeThrow.is_hegrenade_throw(&1))

      # flashbang_throws =
      #   get_grenade_throws.(players, &DemoInfoGo.FlashbangThrow.is_flashbang_throw(&1))

      # molotov_throws = get_grenade_throws.(players, &DemoInfoGo.MolotovThrow.is_molotov_throw(&1))

      # game_players = first_players ++ second_players

      # {:ok, _} = create_kills_and_assists(kills, game_players, game)
      # {:ok, _} = create_smokegrenade_throws(smokegrenade_throws, game_players, game)
      # {:ok, _} = create_hegrenade_throws(hegrenade_throws, game_players, game)
      # {:ok, _} = create_molotov_throws(molotov_throws, game_players, game)
      # {:ok, _} = create_flashbang_throws(flashbang_throws, game_players, game)
    end)
  end
end

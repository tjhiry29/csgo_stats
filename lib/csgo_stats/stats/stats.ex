defmodule CsgoStats.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias CsgoStats.Repo

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

  alias CsgoStats.Stats.Team

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  def create_team_from_game(game = %Game{}, team = %DemoInfoGo.Team{}) do
    %Team{}
    |> Team.create_team_from_game(game, team)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{source: %Team{}}

  """
  def change_team(%Team{} = team) do
    Team.changeset(team, %{})
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

  def create_or_get_player(player = %DemoInfoGo.Player{}) do
    new_player = Player.create_player(player)

    case Repo.get_by(Player, xuid: Map.get(player, :xuid)) do
      {:ok, existing} ->
        {:ok, existing}

      _ ->
        Repo.insert(new_player)
    end
  end

  def create_players_from_team(players, game, team, player_infos) do
    players =
      players
      |> Enum.map(&Player.normalize_player(&1, player_infos))
      |> Player.filter_bots()

    Repo.transaction(fn ->
      Enum.map(players, fn player ->
        {:ok, new_player} = create_or_get_player(player)

        PlayerGameRecord.create_player(player, game, team, new_player)
        |> Repo.insert()
      end)
    end)
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
        |> Repo.insert()
      end)
    end)
  end

  alias CsgoStats.Stats.SmokegrenadeThrow

  def create_smokegrenade_throws(smokegrenade_throws, players, game) do
    Repo.transaction(fn ->
      Enum.map(smokegrenade_throws, fn smokegrenade_throw ->
        SmokegrenadeThrow.create_smokegrenade_throw(smokegrenade_throw, players, game)
        |> Repo.insert()
      end)
    end)
  end

  alias CsgoStats.Stats.HegrenadeThrow

  def create_hegrenade_throws(hegrenade_throws, players, game) do
    Repo.transaction(fn ->
      Enum.map(hegrenade_throws, fn hegrenade_throw ->
        HegrenadeThrow.create_hegrenade_throw(hegrenade_throw, players, game)
        |> Repo.insert()
      end)
    end)
  end

  alias CsgoStats.Stats.MolotovThrow

  def create_molotov_throws(molotov_throws, players, game) do
    Repo.transaction(fn ->
      Enum.map(molotov_throws, fn molotov_throw ->
        MolotovThrow.create_molotov_throw(molotov_throw, players, game)
        |> Repo.insert()
      end)
    end)
  end

  alias CsgoStats.Stats.FlashbangThrow

  def create_flashbang_throws(flashbang_throws, players, game) do
    Repo.transaction(fn ->
      Enum.map(flashbang_throws, fn flashbang_throw ->
        FlashbangThrow.create_flashbang_throw(flashbang_throw, players, game)
        |> Repo.insert()
      end)
    end)
  end
end

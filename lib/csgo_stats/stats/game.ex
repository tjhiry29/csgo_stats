defmodule CsgoStats.Stats.Game do
  use Ecto.Schema
  import Ecto.Changeset
  alias CsgoStats.Stats.{TeamGameRecord, PlayerGameRecord, Kill, GameEvent, Assist}

  @derive {Poison.Encoder,
           only: [
             :id,
             :map_name,
             :rounds_played,
             :team1_score,
             :team2_score,
             :tick_rate,
             :demo_name
           ]}
  schema "games" do
    field(:demo_name, :string)
    field(:map_name, :string)
    field(:rounds_played, :integer)
    field(:team1_score, :integer)
    field(:team2_score, :integer)
    field(:tick_rate, :integer)
    has_many(:assists, Assist)
    has_many(:game_events, GameEvent)
    has_many(:kills, Kill)
    has_many(:team_game_records, TeamGameRecord)
    has_many(:player_game_records, PlayerGameRecord)
    has_many(:players, through: [:player_game_records, :player])

    timestamps()
  end

  def create_game(game, {teams, filename}) do
    [first_team, second_team] = teams
    first_players = first_team.players
    second_players = second_team.players

    kills =
      List.flatten([first_players, second_players])
      |> Enum.flat_map(fn p -> p.kills end)

    map_name = Enum.at(kills, 0).map_name
    rounds_played = first_team.rounds_won + second_team.rounds_won

    map = %{
      rounds_played: rounds_played,
      team1_score: first_team.rounds_won,
      team2_score: second_team.rounds_won,
      map_name: map_name,
      demo_name: filename
    }

    game
    |> cast(map, [
      :rounds_played,
      :map_name,
      :team1_score,
      :team2_score,
      :rounds_played,
      :demo_name
    ])
    |> validate_required([:map_name, :team1_score, :team2_score, :rounds_played, :demo_name])
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:map_name, :tick_rate, :team1_score, :team2_score, :rounds_played, :demo_name])
    |> validate_required([
      :map_name,
      :tick_rate,
      :team1_score,
      :team2_score,
      :rounds_played,
      :demo_name
    ])
  end
end

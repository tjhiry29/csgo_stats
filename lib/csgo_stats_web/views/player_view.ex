defmodule CsgoStatsWeb.PlayerView do
  use CsgoStatsWeb, :view

  def title(_, _) do
    "CSGO PLAYER STATS"
  end

  def date_inserted(player) do
    player.inserted_at
    |> NaiveDateTime.to_date()
    |> Date.to_iso8601()
  end
end

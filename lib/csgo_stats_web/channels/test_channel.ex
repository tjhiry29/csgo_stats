defmodule CsgoStatsWeb.TestChannel do
  use Phoenix.Channel
  require Logger

  def join("test:test", _message, socket) do
    {:ok, socket}
  end

  def handle_in("test:info", msg, socket) do
    IO.inspect(Map.get(msg, "info") |> Map.get("playerRoundRecords"))
    IO.inspect(Map.get(msg, "info") |> Map.get("mapName"))
    IO.inspect(Map.get(msg, "info") |> Map.get("tickRate"))
    # Stats.process_demo_info(Map.get(msg, "info"))
    {:noreply, assign(socket, :info, Map.get(msg, "info"))}
  end
end

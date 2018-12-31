defmodule CsgoStatsWeb.TestChannel do
  use Phoenix.Channel
  require Logger

  def join("test:test", _msg, socket) do
    {:ok, socket}
  end

  def handle_in("test:info", msg, socket) do
    try do
      CsgoStats.Stats.GameBuilder.process_demo_info(Map.get(msg, "info"))
    rescue
      e in RuntimeError -> {:error, %{reason: e}}
    end

    {:noreply, socket}
  end
end

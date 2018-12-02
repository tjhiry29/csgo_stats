defmodule CsgoStatsWeb.TestChannel do
  use Phoenix.Channel
  require Logger

  def join("test:test", _msg, socket) do
    {:ok, socket}
  end

  def handle_in("test:info", msg, socket) do
    CsgoStats.Stats.GameBuilder.process_demo_info(Map.get(msg, "info"))
    {:noreply, socket}
  end
end

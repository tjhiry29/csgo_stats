# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CsgoStats.Repo.insert!(%CsgoStats.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CsgoStats.Stats
require DemoInfoGo

for file <- File.ls!("seeds/") do
  [filename | _] = String.split(file, ".")

  case File.cp("seeds/#{file}", "deps/demo_info_go/results/#{file}") do
    {:error, reason} ->
      IO.inspect(reason)
      :error

    :ok ->
      [{player_infos, teams}] =
        DemoInfoGo.parse_results("#{filename}", ["-gameevents"], "deps/demo_info_go/")

      Stats.create_game_from_demo(teams, file, player_infos)
      :ok
  end
end

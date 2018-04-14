defmodule DemoParserWorker do
  def perform(filename, path) do
    DemoInfoGo.parse_demo(filename, ["-gameevents"], path)
  end
end

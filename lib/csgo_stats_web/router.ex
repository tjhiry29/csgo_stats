defmodule CsgoStatsWeb.Router do
  use CsgoStatsWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", CsgoStatsWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/parse", PageController, :dump)
    get("/results", PageController, :results)

    resources("/games", GameController, only: [:index, :show])
    resources("/players", PlayerController, only: [:index, :show])
  end

  # Other scopes may use custom stacks.
  # scope "/api", CsgoStatsWeb do
  #   pipe_through :api
  # end
end

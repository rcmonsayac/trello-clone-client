defmodule TrelloCloneClientWeb.Router do
  use TrelloCloneClientWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TrelloCloneClientWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticated do
    plug TrelloCloneClientWeb.Plugs.AuthenticatedPipeline
    plug TrelloCloneClientWeb.Plugs.CurrentUser
  end

  pipeline :unauthenticated do
    plug TrelloCloneClientWeb.Plugs.UnauthenticatedPipeline
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TrelloCloneClientWeb do
    pipe_through [:browser, :unauthenticated]

    get "/signin", SessionController, :new
    post "/signin", SessionController, :signin
    get "/create", SessionController, :create
    get "/register", RegistrationController, :index
    post "/register", RegistrationController, :register
  end

  scope "/", TrelloCloneClientWeb do
    pipe_through [:browser, :authenticated]

    get "/logout", SessionController, :logout

    get "/", HomeController, :index
    get "/home", HomeController, :index

    resources "/boards", BoardController

  end

  # Other scopes may use custom stacks.
  # scope "/api", TrelloCloneClientWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TrelloCloneClientWeb.Telemetry
    end
  end
end

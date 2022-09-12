# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :utility,
  ecto_repos: [Utility.Repo],
  generators: [binary_id: true],
  redis_url: System.get_env("REDIS_URL", "redis://127.0.0.1:6379"),
  redis_pool_size: 5,
  gendiff_storage: Utility.GenDiff.Storage.LocalImplementation,
  cache: Utility.Cache.RedisImplementation,
  cache_version: 2,
  builder_mount: System.tmp_dir!(),
  app_env: Mix.env()

config :utility, Oban,
  repo: Utility.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [builder: 1]

config :utility, Utility.Repo, migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :utility, UtilityWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "gJjLZxqBoWFJVdwbLjZe1v2jd2txjpePiZan9WJrhOZsnKhLGftHdjSDHOmDQ+tP",
  signing_salt: "foobar",
  render_errors: [view: UtilityWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Utility.PubSub,
  live_view: [signing_salt: "pni4F/on"]

config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --loader:.ttf=file --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.0.24",
  default: [
    args: ~w[
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ],
    cd: Path.expand("../assets", __DIR__)
  ]

config :utility, :basic_auth,
  auth_user: System.get_env("AUTH_USER", "admin"),
  auth_pass: System.get_env("AUTH_PASS", "admin")

config :mime, :types, %{
  "application/xml" => ["xml"],
  "application/manifest+json" => ["webmanifest"]
}

config :logger,
  backends: [:console, Sentry.LoggerBackend]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  base_path: "/login",
  json_library: Jason,
  providers: [
    github:
      {Ueberauth.Strategy.Github,
       [
         request_path: "/login/github",
         callback_methods: ["POST"],
         callback_path: "/login/github/callback",
         allow_private_emails: true,
         send_redirect_uri: true,
         default_scope: "read:user"
       ]},
    twitter:
      {Ueberauth.Strategy.Twitter,
       [
         request_path: "/login/twitter",
         callback_path: "/login/twitter/callback",
         callback_methods: ["POST"]
       ]}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

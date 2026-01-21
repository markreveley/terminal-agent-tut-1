import Config

# General application configuration
config :agent_tutorial,
  env: config_env()

# Logger configuration
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

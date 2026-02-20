# Module Instantiation
buckets = {
  cosmetics = {
    name = "cosmetics"
    tags = { purpose = "cosmetics" }
  }
  worlds = {
    name = "worlds"
    tags = { purpose = "worlds" }
  }
}

# Non-secret parameters
server_environment     = "production"
db_should_migrate      = "true"
email_sender_address   = "atusgames.official@gmail.com"
session_token_duration = "24h"
email_logo_url         = "https://avatars.githubusercontent.com/u/231922724?s=400"

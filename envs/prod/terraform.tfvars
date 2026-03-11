# Module Instantiation
buckets = {
  cosmetics = {
    name = "feedtherealm-prod-cosmetics"
    tags = { purpose = "cosmetics" }
  }
  worlds = {
    name = "feedtherealm-prod-worlds"
    tags = { purpose = "worlds" }
  }
}

# Non-secret parameters
server_environment     = "production"
db_should_migrate      = "true"
email_sender_address   = "atusgames.official@gmail.com"
session_token_duration = "24h"
email_logo_url         = "https://avatars.githubusercontent.com/u/231922724?s=400"
ami = "ami-0b0b78dcacbab728f" # Amazon Linux 2023 with kernel 6.1, 2024-06-01.
#!/bin/bash

set -e

NOMAD_TLS_DIR="$1"
REGION="${2:-us-east-2}"

if [ -z "$NOMAD_TLS_DIR" ]; then
  echo "Usage: $0 <nomad_tls_dir> [region]"
  exit 1
fi

aws ssm put-parameter --region "$REGION" --type SecureString --overwrite \
  --name "/nomad/tls/ca_cert" \
  --value "$(cat "$NOMAD_TLS_DIR/nomad-agent-ca.pem")" --profile "$AWS_PROFILE"

aws ssm put-parameter --region "$REGION" --type SecureString --overwrite \
  --name "/nomad/tls/server_cert" \
  --value "$(cat "$NOMAD_TLS_DIR/global-server-nomad.pem")" --profile "$AWS_PROFILE"

aws ssm put-parameter --region "$REGION" --type SecureString --overwrite \
  --name "/nomad/tls/server_key" \
  --value "$(cat "$NOMAD_TLS_DIR/global-server-nomad-key.pem")" --profile "$AWS_PROFILE"

aws ssm put-parameter --region "$REGION" --type SecureString --overwrite \
  --name "/nomad/tls/client_cert" \
  --value "$(cat "$NOMAD_TLS_DIR/global-client-nomad.pem")" --profile "$AWS_PROFILE"

aws ssm put-parameter --region "$REGION" --type SecureString --overwrite \
  --name "/nomad/tls/client_key" \
  --value "$(cat "$NOMAD_TLS_DIR/global-client-nomad-key.pem")" --profile "$AWS_PROFILE"

aws ssm put-parameter --region "$REGION" --type SecureString --overwrite \
  --name "/nomad/tls/cli_cert" \
  --value "$(cat "$NOMAD_TLS_DIR/global-cli-nomad.pem")" --profile "$AWS_PROFILE"

aws ssm put-parameter --region "$REGION" --type SecureString --overwrite \
  --name "/nomad/tls/cli_key" \
  --value "$(cat "$NOMAD_TLS_DIR/global-cli-nomad-key.pem")" --profile "$AWS_PROFILE"

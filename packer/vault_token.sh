#!/bin/bash

#===========================================================================
# script to generate and renew VAULT_TOKEN to be used to make HTTP API calls
#===========================================================================
	
set -e
set -o pipefail

# Declare params that can be set by
export VAULT_ADDR="${VAULT_ADDR:-https://35.202.192.195:8200}"
export USERNAME="${USERNAME:-deployer}"
export PASSWORD="${PASSWORD:-deployer}"

# HTTP API call to acquire a userpass token
get_vault_access_token() {
  if [[ $VAULT_ADDR ]]; then
      curl -kX POST $VAULT_ADDR/v1/auth/userpass/login/${USERNAME} -d '{"password":"'${PASSWORD}'"}' | \
      jq .auth.client_token | \
      awk '{print substr($0,2,length($0)-2)}' > VAULT_TOKEN
  else
      echo "Missing VAULT_ADDR env variable."
  fi
}

# start a cronjob to renew the token regularly
create_access_token_renew_cron() {
  VAULT_TOKEN=$(cat VAULT_TOKEN)
  VAULT_TOKEN_RENEW_ADDR=${VAULT_ADDR}/v1/auth/token/renew

  if [[ $VAULT_TOKEN && ! $VAULT_TOKEN == "ul" ]]; then
      echo {\"token\":\"${VAULT_TOKEN}\"} > payload.json

      `(crontab -l 2>/dev/null | grep -v renew-token; echo '0 23 20 * * curl -kX POST -H "X-Vault-Token:'$VAULT_TOKEN'" --data '\'$(cat payload.json)\'' '$VAULT_TOKEN_RENEW_ADDR' #renew-token') | crontab -`

      export VAULT_TOKEN="${VAULT_TOKEN}"

      rm -f payload && rm -f VAULT_TOKEN
  else
     echo "Invalid token."
  fi
}

main() {
  export VAULT_TOKEN=""
  while [[ -z "$VAULT_TOKEN" || $VAULT_TOKEN == "ul" ]]; do
    get_vault_access_token
    create_access_token_renew_cron
  done
}


main "$@"
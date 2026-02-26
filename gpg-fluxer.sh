#!/usr/bin/env bash

set -e

TOKEN="PUT_YOUR_TOKEN_HERE"


if [[ $1 == '-d' ]]; then
  # Decrypt
  if ! command -v wl-paste >/dev/null 2>&1; then
    echo "wl-clipboard is not installed. It's needed to use the -d option."
    exit 1
  fi
  
  wl-paste | gpg -d
else
  # Encrypt
  TO_EMAIL_GPG=$1

  FLUXER_CHANNEL_ID=$2

  UNENCRYPTED_MESSAGE_FILE=$(mktemp)
  trap 'rm -f "$UNENCRYPTED_MESSAGE_FILE"' EXIT

  EDITOR=${EDITOR:-nvim}


  if [[ -z "$TO_EMAIL_GPG" || -z "$FLUXER_CHANNEL_ID" ]]; then
    echo "usage:"
    echo
    echo "   Encrypt:  $0 <TO_EMAIL_GPG> <FLUXER_CHANNEL_ID>"
    echo
    echo "              * Send a GPG encrypted message on the specified fluxer channel using the specified account token"
    echo "                to the specified recipient (by their email which is connected to their key which you're"
    echo "                assumed to have imported)."
    echo
    echo
    echo "   Decrypt:  $0 -d"
    echo
    echo "              * Decrypt GPG encrypted message from your clipboard."
    echo
    echo
    echo
    echo "   * Assumes the user has set up a gpg key"
    echo "   * Assumes the recipient's key is imported"

    exit 1
  fi

  "$EDITOR" "$UNENCRYPTED_MESSAGE_FILE"

  ENCRYPTED_MESSAGE=$(gpg --encrypt --armor \
    --recipient "$TO_EMAIL_GPG" \
    --output - \
    "$UNENCRYPTED_MESSAGE_FILE")

  if (( ${#ENCRYPTED_MESSAGE} < 2000 )); then
    curl -s -X POST "https://api.canary.fluxer.app/channels/$FLUXER_CHANNEL_ID/messages" \
      -H "Authorization: $TOKEN" \
      -H "Content-Type: application/json" \
      -d "$(jq -n --arg msg "$ENCRYPTED_MESSAGE" '{content: $msg}')" | jq
  else
    ENCRYPTED_MESSAGE_FILE=$(mktemp)
    printf %s "$ENCRYPTED_MESSAGE" > "$ENCRYPTED_MESSAGE_FILE"

    set +e
      X0ST_URL=$(curl -sF "file=@$ENCRYPTED_MESSAGE_FILE" https://0x0.st)
      CURL_EXIT=$?
    set -e

    if [[ $CURL_EXIT -ne 0 || ! $X0ST_URL == http* ]]; then
        echo "Uploading encrypted message to 0x0.st via curl failed."
        echo "Encrypted message file at $ENCRYPTED_MESSAGE_FILE"
        exit 1
    fi

    ENC_X0ST_URL=$(echo "$X0ST_URL" | gpg --encrypt --armor \
      --recipient "$TO_EMAIL_GPG" \
      --output - \
      -)

    curl -s -X POST "https://api.canary.fluxer.app/channels/$FLUXER_CHANNEL_ID/messages" \
      -H "Authorization: $TOKEN" \
      -H "Content-Type: application/json" \
      -d "$(jq -n --arg msg "$ENC_X0ST_URL" '{content: $msg}')" | jq
  fi
fi
